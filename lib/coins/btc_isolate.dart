import 'dart:isolate';

import 'package:tejory/coins/bitcoin.dart';

void BTCNetworkIsolate(SendPort mainSendPort) {
  List<Bitcoin> coins = [];
  final isolateReceivePort = ReceivePort();
  mainSendPort.send(isolateReceivePort.sendPort);

  // initialize the DB
  // initialize the coins list

  isolateReceivePort.listen((dynamic msg){
    Map<String, dynamic> msgMap = msg;
    int walletId = msgMap["walletId"];
    switch (msgMap["command"]) {
      case "connect":
      (Map<String, dynamic> msgMap) async {
        var result = await coins[walletId].connect(ip: msgMap["ip"] as String?);
        Map<String, dynamic> resMap = {
          "command": msgMap["command"],
          "walletId": msgMap["walletId"],
          "error": null,
          "response": result,
        };
        mainSendPort.send(resMap);
      }(msgMap);
        
    }
  });
}