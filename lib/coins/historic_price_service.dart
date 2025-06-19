import 'dart:async';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:mutex/mutex.dart';
import 'package:tejory/api_keys/api_keys.dart';
import 'package:tejory/crypto-helper/blockchain_api.dart';
import 'package:tejory/objectbox/tx.dart';
import 'package:tejory/objectbox.g.dart';
import 'package:tejory/objectbox/objectbox.dart';
import 'package:tejory/singleton.dart';

class HistoricPriceService {
  const HistoricPriceService();
  static Isolate? _isolate;
  static final _receivePort = ReceivePort();
  static late SendPort _sendPort;
  static Completer _ready = Completer();

  static Map<int, String?> _coinSymbolMap = {};
  static Map<String, double> _priceCache = {};

  static Future<void> start() async {
    // Listen for messages from the isolate
    _receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
        final RootIsolateToken? rootIsolateToken = RootIsolateToken.instance;
        Map<String, dynamic> msg = {
          "token": rootIsolateToken,
          "box": Singleton.getObjectBoxDB().getStore().reference,
          'api_keys': APIKeys.keys,
        };
        _sendPort.send(msg);
      } else if (message is String && message == "ready") {
        print("HistoricPriceService: ready");
        _ready.complete();
      } else {
        print(
          "HistoricPriceService: ERROR: unknown message type ${message.runtimeType}. ${message}",
        );
      }
    });

    // Spawn the new isolate
    _isolate = await Isolate.spawn(
      _worker,
      _receivePort.sendPort,
      onError: _receivePort.sendPort,
      onExit: _receivePort.sendPort,
    );
  }

  static void update(int txId) async {
    await _ready.future;
    _sendPort.send(<String, dynamic>{"txId": txId});
  }

  static void _worker(SendPort sendPort) {
    print("HistoricPriceService: isolate stared");
    final _receivePort = ReceivePort();
    sendPort.send(_receivePort.sendPort);
    ObjectBox? box;
    final priceFetchMutex = Mutex();

    final updatePrice = ([int? txId]) {
      priceFetchMutex.protect(() async {
        print("HistoricPriceService: updating prices");
        if (box == null) {
          return;
        }
        Condition<TxDB> q = TxDB_.usdAmount.isNull();
        if (txId != null) {
          q = TxDB_.id.equals(txId);
        }
        final List<TxDB> txList = box!.txDBBox.query(q).build().find();

        for (final tx in txList) {
          if (tx.usdAmount != null || tx.coin == null) {
            continue;
          }

          if (!_coinSymbolMap.containsKey(tx.coin)) {
            _coinSymbolMap[tx.coin!] =
                box!.coinBox
                    .query(Coin_.id.equals(tx.coin!))
                    .build()
                    .findFirst()
                    ?.yahooFinance;
          }
          String? symbol = _coinSymbolMap[tx.coin];
          tx.usdAmount = await _fetchPrice(symbol, tx.time);

          if (tx.usdAmount == null) {
            print("HistoricPriceService: skipping update");
            continue;
          }
          print("HistoricPriceService: saving update");
          await tx.save();
        }
      });
    };

    _receivePort.listen((message) async {
      try {
        if (message is! Map<String, dynamic>) {
          return;
        }

        // control messages
        if (message.containsKey("token")) {
          BackgroundIsolateBinaryMessenger.ensureInitialized(message["token"]);
          await Singleton.initObjectBoxDB(fromBytes: message["box"]);
          box = Singleton.getObjectBoxDB();
          APIKeys.keys = message['api_keys'];

          sendPort.send("ready");

          while (true) {
            updatePrice();
            await Future.delayed(Duration(minutes: 5));
          }
        }

        if (box == null) {
          print("HistoricPriceService: DB is not initialized");
          return;
        }

        if (message.containsKey("txId")) {
          updatePrice(message["txId"]);
        }
      } catch (e) {
        print("HistoricPriceService: ERROR: $e");
      }
    });
  }

  static void stop() {
    if (_isolate != null) {
      _isolate?.kill(priority: Isolate.immediate);
      _isolate = null;
      _receivePort.close();
      print("HistoricPriceService: Isolate stopped.");
    }
  }

  // helper functions
  static String _formatDate(DateTime date) {
    return "${date.millisecondsSinceEpoch ~/ 86400000}";
  }

  static Future<double?> _fetchPrice(String? symbol, DateTime? time) async {
    if (time == null || symbol == null) {
      return null;
    }

    // check if the price is already in cache
    String cacheKey = "${symbol}-${_formatDate(time)}";
    if (_priceCache.containsKey(cacheKey)) {
      print("HistoricPriceService: price from cache");
      return _priceCache[cacheKey];
    }
    double? price = await getBlockchainAPIHistoricPrice(symbol, time);
    if (price != null) {
      _priceCache[cacheKey] = price;
    }
    return price;
  }
}
