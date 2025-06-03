import 'dart:async';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:tejory/coins/crypto_coin.dart';
import 'package:tejory/singleton.dart';
import 'package:tejory/ui/asset.dart';

class AssetIsolate {
  List<CryptoCoin> coins;
  int initializedCoinCount = 0;
  late List<ReceivePort> receivePorts;
  late List<SendPort?> sendPorts;
  List<Isolate> isolates = [];
  List<Future<void>> exitList = [];
  late List<Completer<void>> _isolatesReady;

  AssetIsolate(List<CryptoCoin> this.coins) {
    initializedCoinCount = this.coins.length;
    sendPorts = List.filled(coins.length, null);
    _initializeCompleters();
    _initializeReceivePorts();
    spawn();
  }

  void _initializeReceivePorts() {
    receivePorts = List.filled(coins.length, ReceivePort());
    for (int i = 0; i < receivePorts.length; i++) {
      final coinId = coins[i].id; // Or another unique ID from coins[i]
      receivePorts[i].listen((message) {
        _handleResponsesFromIsolate(message, coinId, i); // Pass identifier
      });
    }
  }

  void _initializeCompleters() {
    _isolatesReady = new List.filled(coins.length, Completer.sync());
  }

  Future<void> spawn() async {
    for (int i = 0; i < receivePorts.length; i++) {
      var exitPort = ReceivePort();
      exitList.add(exitPort.first);

      isolates.add(
        await Isolate.spawn(
          _startRemoteIsolate,
          receivePorts[i].sendPort,
          onExit: exitPort.sendPort,
          debugName: "${coins[i].symbol()}.$i",
        ),
      );
    }
  }

  Future<dynamic> ready() async {
    return Future.wait(
      _isolatesReady.map((isolateReady) => isolateReady.future),
    );
  }

  Future<dynamic> kill() async {
    sendPorts.forEach((final SendPort? sendPort) {
      sendPort?.send("KILL");
    });
    return Future.wait(exitList);
  }

  void _handleResponsesFromIsolate(
    dynamic message,
    dynamic coinId,
    int workerIndex,
  ) {
    if (message is SendPort) {
      sendPorts[workerIndex] = message;
      final RootIsolateToken? rootIsolateToken = RootIsolateToken.instance;
      sendPorts[workerIndex]!.send(rootIsolateToken);
    } else if (message is String && message == "READY") {
      _isolatesReady[workerIndex].complete();
    } else if (message is String && message == "GET_ASSET_CONFIG") {
      print("isolate sending coin to isolate");
      // send first message containing the coin
      Map<String, dynamic> coinMessage = {
        'command': 'initialize_coin_from_config',
        'config': coins[workerIndex].toConfigMap(),
      };
      sendPorts[workerIndex]!.send(coinMessage);
    } else if (message is Map<String, dynamic>) {
      coins[workerIndex].receiveResponse(message);
    }
  }

  static void _startRemoteIsolate(SendPort sendPort) async {
    print("Isolate started");
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    print("Isolate receivePort sent");

    CryptoCoin? coin;

    // listen to incoming commands
    receivePort.listen((dynamic msg) async {
      
      // Handle control messages
      if (msg is String && msg == "KILL") {
        // Handle special KILL command
        Isolate.exit();
      } else if (msg is RootIsolateToken) {
        BackgroundIsolateBinaryMessenger.ensureInitialized(msg);
        print("Isolate opening DB");
        await Singleton.initDB();
        print("Isolate READY");
        sendPort.send("GET_ASSET_CONFIG");
        return;
      }
      
      // This part if for CryptoCoin method messages
      if (msg is! Map<String, dynamic>) {
        print("Isolate All messages should be a Map<String, dynamic>");
        return;
      }
      Map<String, dynamic> msgMap = msg;

      if (msgMap["command"] == "initialize_coin_from_config") {
        // assign the coin instance which is a copy of the main isolate instance
        Map<String, dynamic> receivedConfig = msgMap['config'];

        coin = Asset.fromConfig(receivedConfig);

        // configure the coin for worker isolate
        coin!.isUIInstance = false;
        coin!.addListener((){
          print("isolate sending notifyListeners");
          // send notify listeners changes:
          sendPort.send(coin!.getState());
        });

        sendPort.send("READY");
        return;
      }

      if (coin == null) {
        print("isolate coin is null");
        return;
      }

      // call instance method
      dynamic result = null;
      Object? error = null;
      switch (msgMap["command"]) {
        case "name":
          try {
            result = coin!.name();
          } catch (e) {
            error = e;
          }
          break;
        case "initCoin":
          try {
            coin!.initCoin(blocks: msgMap["params"]["blocks"], txList: msgMap["params"]["txList"], balanceDB: msgMap["params"]["balanceDB"]);
          } catch (e) {
            error = e;
          }
          break;
        case "setupTransactionsForPathChildren":
          try {
            coin!.setupTransactionsForPathChildren(msgMap["params"]["paths"]);
          } catch (e) {
            error = e;
          }
          break;
        case "transmitTxBytes":
          try {
            coin!.transmitTxBytes(msgMap["params"]["buf"]);
          } catch (e) {
            error = e;
          }
          break;
        case "setOnline":
          try {
            coin!.setOnline(msgMap["params"]["val"]);
          } catch (e) {
            error = e;
          }
          break;
        default:
          error = Exception("Unknown command");
      }

      // return the response
      Map<String, dynamic> resMap = {
        "command": msgMap["command"],
        "error": error,
        "response": result,
      };
      if (error != null) {
        print("isolate error: ${resMap}");
      }
      sendPort.send(resMap);
    });
  }
}
