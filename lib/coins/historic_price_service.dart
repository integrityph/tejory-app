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
  HistoricPriceService();
  Isolate? _isolate;
  final _receivePort = ReceivePort();
  late SendPort _sendPort;

  Future<void> start() async {
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
      } else {
        print(
          "HistoricPriceService: ERROR: unknown message type ${message.runtimeType}. ${message}",
        );
      }
    });

    // Spawn the new isolate
    _isolate = await Isolate.spawn(
      worker,
      _receivePort.sendPort,
      onError: _receivePort.sendPort,
      onExit: _receivePort.sendPort,
    );
  }

  void fetchPrice(int txId) {
    _sendPort.send(<String, dynamic>{"txId": txId});
  }

  static void worker(SendPort sendPort) {
    print("HistoricPriceService: isolate stared");
    final _receivePort = ReceivePort();
    sendPort.send(_receivePort.sendPort);
    print("HistoricPriceService: isolate port sent");
    ObjectBox? box;
    final priceFetchMutex = Mutex();
    final Map<int, String?> coinSymbolMap = {};

    final priceFetch = ([int? txId]) {
      priceFetchMutex.protect(() async {
        print("HistoricPriceService: updating prices");
        if (box == null) {
          return;
        }
        Condition<TxDB> q = TxDB_.usdAmount.isNull();
        if (txId != null) {
          q &= TxDB_.id.equals(txId);
        }
        final List<TxDB> txList = box!.txDBBox.query(q).build().find();

        for (int i = 0; i < txList.length; i++) {
          if (txList[i].usdAmount != null ||
              txList[i].time == null ||
              txList[i].coin == null) {
            print("HistoricPriceService: not updating ${i}?!?!?");
            continue;
          }
          if (txList[i].usdAmount == null && txList[i].time != null ||
              txList[i].coin == null) {
            if (!coinSymbolMap.containsKey(txList[i].coin)) {
              coinSymbolMap[txList[i].coin!] =
                  box!.coinBox
                      .query(Coin_.id.equals(txList[i].coin!))
                      .build()
                      .findFirst()
                      ?.yahooFinance;
            }
            print("HistoricPriceService: updating ${i}");
            String? coinSymbol = coinSymbolMap[txList[i].coin];
            print(
              "HistoricPriceService: updating ${i} - coinSymbol: $coinSymbol",
            );
            if (coinSymbol == null) {
              continue;
            }

            txList[i].usdAmount = await getBlockchainAPIHistoricPrice(
              coinSymbol,
              txList[i].time!,
            );
            print(
              "HistoricPriceService: updating ${i} - coinSymbol: $coinSymbol - txList[i].usdAmount: ${txList[i].usdAmount}",
            );
            if (txList[i].usdAmount != null) {
              await txList[i].save();
              print("HistoricPriceService: updated");
            } else {
              print("HistoricPriceService: didn't updated");
            }
          }
        }
      });
    };

    _receivePort.listen((message) async {
      try {
        print("HistoricPriceService: isolate received message ${message}");
        if (message is! Map<String, dynamic>) {
          print(
            "HistoricPriceService: message is not Map<String, dynamic>. ${message}",
          );
          return;
        }

        // control messages
        if (message.containsKey("token")) {
          print("HistoricPriceService: received initial configuration");
          BackgroundIsolateBinaryMessenger.ensureInitialized(message["token"]);
          await Singleton.initObjectBoxDB(fromBytes: message["box"]);
          box = Singleton.getObjectBoxDB();

					APIKeys.keys = message['api_keys'];

          print("HistoricPriceService: done with initial configuration");
          while (true) {
            print("HistoricPriceService: fetching prices from the loop");
            priceFetch();
            await Future.delayed(Duration(minutes: 5));
          }
        }

        if (box == null) {
          print("HistoricPriceService: DB is not initialized");
          return;
        }

        if (message.containsKey("txId")) {
          priceFetch(message["txId"]);
        }
      } catch (e) {
        print("HistoricPriceService: ERROR: $e");
      }
    });
  }

  void stop() {
    if (_isolate != null) {
      _isolate?.kill(priority: Isolate.immediate);
      _isolate = null;
      _receivePort.close();
      print("HistoricPriceService: Isolate stopped.");
    }
  }
}
