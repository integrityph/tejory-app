import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:tejory/coins/asset_isolate.dart';
import 'package:tejory/coins/pst.dart';
import 'package:tejory/coins/tx.dart';
import 'package:tejory/coins/visual_tx.dart';
import 'package:tejory/collections/balance.dart';
import 'package:tejory/collections/block.dart';
import 'package:tejory/collections/tx.dart';
import 'package:tejory/collections/walletDB.dart';
import 'package:tejory/singleton.dart';

abstract class CryptoCoin with ChangeNotifier {
  String? _name;
  String? _symbol;
  String hrp = "";
  int walletId = 0;
  WalletType walletType = WalletType.phone;
  List<String> peerList = [];
  List<int> magic = [];
  late int port;
  late String peerSeedType;
  late String peerSource;
  int? id;
  String? netVersionPublicHex;
  String? netVersionPrivateHex;
  late int decimals;
  bool isConnected = false; // Add this to keep track of connection status
  BigInt balance = BigInt.zero;
  bool online = true;
  bool isUIInstance = true;
  bool available = true;
  int assetIndex=0;
  int coinIndex=0;
  String? template;

  CryptoCoin(
      {required this.walletId,
      required List<int> magic,
      required int port,
      required String peerSeedType,
      required String peerSource,
      required this.decimals,
      String? netVersionPublicHex,
      String? netVersionPrivateHex});
  CryptoCoin.newCoin(String name, String  symbol, this.decimals) {
    _name = name;
    _symbol = symbol;
  }

  String name() {
    return _name == null ? "" : _name!;
  }

  String symbol() {
    return _symbol == null ? "" : _symbol!;
  }

  BigInt getBalance();

  PST makePST(Tx tx);

  Tx? makeTransaction(String toAddress, BigInt amount, {noChange = false});

  // use first
  void transmitTxBytes(Uint8List buf);

  Future<String> getReceivingAddress({String? network, BigInt? amount});

  // use first
  Uint8List getAddressBytes(String address);

  // use first
  BigInt getBaseAmount(double val);
  // use first
  String getDecimalAmount(BigInt val);
  // use first
  BigInt getTxFeeEstimate(int nBytes);

  // Update the balance from the blockchain
  Future<void> updateBalance();

  void initCoin({List<Block>? blocks, List<TxDB>? txList, Balance? balanceDB});
  Future<Uint8List?> signPST(PST? pst, Tx? tx, BuildContext? context);
  Future<Uint8List?> signTx(PST? pst, Tx? tx, BuildContext? context);
  List<String> getInitialDerivationPaths();
  List<String> getInitialEasyImportPaths();
  Future<Block?> getStartBlock(bool isNew, bool easyImport, int? startYear,
      {int? blockHeight});

  Future<Map<String, dynamic>?> sendTxBytes(Uint8List tx);
  Future<List<TxDB>?> setupTransactionsForPathChildren(List<String> paths);

  Future<BigInt> calculateFee(String toAddress, BigInt amount, {noChange = false});

  void storeTransaction(
    Tx tx, {
    PST? pst,
    bool confirmed = true,
    bool verified = true,
    bool failed = false,
  });

  String getAddressFromBytes(Uint8List address, {String? bechHRP});
  List<VisualTx> getVisualTxList(List<TxDB> txDBList);

  bool isValidAddress(String address);

  BigInt? getAmountFromAddress(String address) {
    return null;
  }

  String getTrackingURL(String txHash);

  void callInternalFunction(String method, Map<String, dynamic> params) {

  }

  void receiveResponse(Map<String, dynamic> message) {
    if (message["command"] is String) {
      switch (message["command"]) {
        case "notifyListeners":
          balance = message["balance"];
          isConnected = message["isConnected"];
          notifyListeners();
      }
    }
  }

  Map<String,dynamic> getState() {
    return {
      "command": "notifyListeners",
      "balance": getBalance(),
      "isConnected": isConnected,
    };
  }

  AssetIsolate getAssetIsolate() {
    return Singleton.assetList.assetListState.assets[assetIndex].isolate!;
  }

  SendPort getAssetIsolatePort() {
    return getAssetIsolate().sendPorts[coinIndex]!;
  }

  Map<String, dynamic> toConfigMap() {
    return {
      "_name":_name,
      "_symbol":_symbol,
      "name":_name,
      "symbol":_symbol,
      "hrp":hrp,
      "walletId":walletId,
      "walletType":walletType,
      "peerList":peerList,
      "magic":magic,
      "port":port,
      "peerSeedType":peerSeedType,
      "peerSource":peerSource,
      "id":id,
      "coinId":id,
      "netVersionPublicHex":netVersionPublicHex,
      "netVersionPrivateHex":netVersionPrivateHex,
      "decimals":decimals,
      "isConnected":isConnected,
      "balance":balance,
      "online":online,
      "isUIInstance":isUIInstance,
      "available":available,
      "assetIndex":assetIndex,
      "coinIndex":coinIndex,
      "template":template,
    };
  }

  void setOnline(bool val) {
    online = val;
    if (isUIInstance) {
      getAssetIsolatePort().send(<String, dynamic>{
        "command": "setOnline",
        "params":{
          "val": val,
        }
      });
      return;
    }
  }
}
