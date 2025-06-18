import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:tejory/bip32/derivation_bip32_key.dart';
import 'package:tejory/coins/bitcoin_tx.dart';
import 'package:tejory/coins/bitcoin_tx_out.dart';
import 'package:tejory/coins/crypto_coin.dart';
import 'package:tejory/coins/psbt.dart';
import 'package:tejory/coins/pst.dart';
import 'package:tejory/coins/tx.dart';
import 'package:tejory/coins/visual_tx.dart';
import 'package:tejory/coins/wallet.dart';
import 'package:tejory/objectbox/balance.dart';
import 'package:tejory/objectbox/block.dart';
import 'package:tejory/objectbox/key.dart' as keyCollection;
import 'package:tejory/objectbox/tx.dart';
import 'package:tejory/box_models.g.dart';
import 'package:tejory/singleton.dart';
import 'package:http/http.dart' as http;
import 'package:tejory/wallets/wallet_type.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class BTCLN extends CryptoCoin {
  // constants
  late Wallet wallet;
  String? extendedPrivateKey;
  bool stayConnected = true;
  BigInt balance = BigInt.zero;
  List<String> rpcServer = ["ln.tejory.io"];
  late int rpcIndex = Random(
    DateTime.now().millisecondsSinceEpoch,
  ).nextInt(rpcServer.length);
  bool ready = false;
  bool connected = false;
  Stopwatch watch = Stopwatch();

  BTCLN(
    int walletId, {
    required WalletType walletType,
    required List<int> magic,
    required int port,
    required String peerSeedType,
    required String peerSource,
    int? coinId,
    String? netVersionPublicHex,
    String? netVersionPrivateHex,
  }) : super.newCoin("Bitcoin Lightning", "BTCLN", 8) {
    super.port = port;
    super.id = coinId;
    super.peerSource = peerSource;
    super.peerSeedType = peerSeedType;
    super.walletType = walletType;
    super.walletId = walletId;
    super.netVersionPublicHex = netVersionPublicHex;
    super.netVersionPrivateHex = netVersionPrivateHex;
    wallet = Wallet(id: walletId);
  }

  @override
  void dispose() {
    super.dispose();
    stayConnected = false;
  }

  @override
  Future<void> initCoin({List<Block>? blocks, List<TxDB>? txList, Balance? balanceDB}) async {
    watch.start();
    if (balanceDB != null && balanceDB.coinBalance != null) {
      balance = BigInt.from(balanceDB.coinBalance!);
    }

    createNewWallet().then((_) {
      connect();
      getTxListFromAPI();
      streamLister();
      ready = true;
      setIsConnected(connected);
    });
  }

  @override
  Future<BigInt> calculateFee(
    String toAddress,
    BigInt amount, {
    noChange = false,
  }) async {
    BigInt fee;
    if (toAddress.startsWith("ln")) {
      fee = await getOffChainFee(toAddress);
    } else {
      fee = await getOnChainFee(toAddress, amount);
    }

    return fee;
  }

  Future<BigInt> getOffChainFee(String invoice) async {
    var response = await rpcCall("estimatefee", {"invoice": invoice});
    BigInt fee = BigInt.from(response?["fee"] ?? 0);
    return fee;
  }

  Future<BigInt> getOnChainFee(String address, BigInt amount) async {
    var response = await rpcCall("estimateonchainfee", {
      "address": address,
      "amount": amount.toInt(),
    });
    BigInt fee = BigInt.from(response?["fee"] ?? 0);
    return fee;
  }

  @override
  Uint8List getAddressBytes(String address) {
    return Uint8List.fromList(address.codeUnits);
  }

  @override
  String getAddressFromBytes(Uint8List address, {String? bechHRP}) {
    return String.fromCharCodes(address);
  }

  @override
  BigInt getBaseAmount(double val) {
    return BigInt.from((val * 100000000).round());
  }

  @override
  String getDecimalAmount(BigInt val) {
    return (val.toDouble() / 100000000).toStringAsFixed(8);
  }

  @override
  List<String> getInitialDerivationPaths() {
    return ["m/9011'/0"];
  }

  @override
  List<String> getInitialEasyImportPaths() {
    return ["m/9011'/0"];
  }

  int getNextIndex(String path) {
    return 0;
  }

  Future<Uint8List> getPublicKey(String path, {bool compressed = false}) async {
    var pathParts = path.split("/");
    String parentPubKey = await getExtendedPublicKey(
      pathParts.sublist(0, pathParts.length - 1).join("/"),
    );
    var parentAccount = Bip32Slip10Secp256k1.fromExtendedKey(
      parentPubKey,
      getNetVersion(),
    );
    var childKey = parentAccount.childKey(
      Bip32KeyIndex(int.parse(pathParts[pathParts.length - 1])),
    );

    if (compressed) {
      return Uint8List.fromList(childKey.publicKey.compressed);
    }
    return Uint8List.fromList(childKey.publicKey.uncompressed);
  }

  Future<String> getExtendedPublicKey(String path) async {
    // check if the key is already in the DB
    // var isar = Singleton.getDB();
    // keyCollection.Key? key = isar.keys.getByPathWalletCoinSync(
    //   path,
    //   walletId,
    //   id,
    // );
    keyCollection.Key? key = await Models.key.getUnique(walletId, id, path);
    Bip32PublicKey pubkey;

    // if the key is not if the DB, create it and save it
    if (key == null) {
      var hdw = await getNearestParentKey(path);
      if (hdw == null) {
        return "";
      }
      var account = hdw.derivePath(path);
      pubkey = account.publicKey;

      key = keyCollection.Key();
      key.chainCode = pubkey.chainCode.toHex();
      key.pubKey = pubkey.toHex();
      key.coin = id;
      key.wallet = walletId;
      key.path = path;
      key.save();
    }
    Bip32ChainCode chainCode = Bip32ChainCode(hex.decode(key.chainCode!));
    Bip32KeyData keyData = Bip32KeyData(chainCode: chainCode);
    List<int> keyBytes = hex.decode(key.pubKey!);
    EllipticCurveTypes curveType = EllipticCurveTypes.secp256k1;
    pubkey = Bip32PublicKey.fromBytes(
      keyBytes,
      keyData,
      getNetVersion(),
      curveType,
    );

    final hdw = Bip32Slip10Secp256k1.fromPublicKey(
      keyBytes,
      keyData: keyData,
      keyNetVer: getNetVersion(),
    );
    pubkey = hdw.publicKey;

    return pubkey.toExtended;
  }

  String getClientPubkey() {
    // check if the key is already in the DB
    // var isar = Singleton.getDB();
    // keyCollection.Key? key = isar.keys.getByPathWalletCoinSync(
    //   "m/9011'/0",
    //   walletId,
    //   id,
    // );
    keyCollection.Key? key = Models.key.getUnique(walletId, id, "m/9011'/0");
    return key!.pubKey!;
  }

  String getClientToken() {
    // check if the key is already in the DB
    // var isar = Singleton.getDB();
    // keyCollection.Key? key = isar.keys.getByPathWalletCoinSync(
    //   "m/9011'/0",
    //   walletId,
    //   id,
    // );
    keyCollection.Key? key = Models.key.getUnique(walletId, id, "m/9011'/0");
    return key!.chainCode!;
  }

  Future<void> setClientToken(String token) async {
    // check if the key is already in the DB
    // var isar = Singleton.getDB();
    // keyCollection.Key? key = isar.keys.getByPathWalletCoinSync(
    //   "m/9011'/0",
    //   walletId,
    //   id,
    // );
    keyCollection.Key? key = await Models.key.getUnique(walletId, id, "m/9011'/0");
    key!.chainCode = token;
    await key.save();
    print("btcln token saved to DB");
    return;
  }

  Future<Bip32Slip10Secp256k1?> getNearestParentKey(String path) async {
    if (extendedPrivateKey != null) {
      final hdw = Bip32Slip10Secp256k1.fromExtendedKey(
        extendedPrivateKey!,
        getNetVersion(),
      );
      return hdw;
    }

    keyCollection.Key? key;
    var pathParts = path.split("/");
    for (int i = pathParts.length - 1; i >= 0; i--) {
      var tempPath = pathParts.sublist(0, i).join("/");
      // var isar = Singleton.getDB();
      // key = isar.keys.getByPathWalletCoinSync(tempPath, walletId, id);
      key = await Models.key.getUnique(walletId, id, tempPath);
      if (key != null) {
        break;
      }
      if (pathParts[i].endsWith("'")) {
        return null;
      }
    }

    if (key == null ||
        key.pubKey == null ||
        key.chainCode == null ||
        key.path == null) {
      return null;
    }

    pathParts = key.path!.split("/");
    int index = int.parse(pathParts.last.replaceAll("'", ""));
    if (pathParts.last.contains("'")) {
      index += 0x80000000;
    }
    List<int> pubkey = hex.decode(key.pubKey!);
    Bip32KeyData? keyData = Bip32KeyData(
      chainCode: Bip32ChainCode(hex.decode(key.chainCode!)),
      depth: Bip32Depth(pathParts.length),
      index: Bip32KeyIndex(index),
    );
    Bip32KeyNetVersions? keyNetVer = getNetVersion();

    final hdw = Bip32Slip10Secp256k1.fromPublicKey(
      pubkey,
      keyData: keyData,
      keyNetVer: keyNetVer,
    );

    return hdw;
  }

  Bip32KeyNetVersions getNetVersion() {
    return Bip32KeyNetVersions(
      //     hex.decode(netVersionPublicHex!), hex.decode(netVersionPrivateHex!));
      [0x04, 0x35, 0x87, 0xCF],
      [0x04, 0x35, 0x83, 0x94],
    );
  }

  @override
  Future<String> getReceivingAddress({
    String? network,
    int account = 0,
    BigInt? amount,
  }) async {
    String returnAddress = "";
    if (network == "BTC_LIGHTNING") {
      Map<String, dynamic> bodyObj = {"amount": amount!.toString()};
      var response = await rpcCall("makeinvoice", bodyObj);
      returnAddress = response?["invoice"] ?? "";
    } else {
      Map<String, dynamic> bodyObj = {};
      var response = await rpcCall("getaddress", bodyObj);
      returnAddress = response?["address"] ?? "";
    }
    return returnAddress;
  }

  @override
  Future<Block?> getStartBlock(
    bool isNew,
    bool easyImport,
    int? startYear, {
    int? blockHeight,
  }) async {
    return null;
  }

  @override
  BigInt getTxFeeEstimate(int nBytes) {
    return BigInt.zero;
  }

  @override
  PST makePST(Tx tx) {
    return new PSBT();
  }

  @override
  Future<Tx?> makeTransaction(String toAddress, BigInt amount, {noChange = false}) async {
    var tx = BitcoinTx();
    var out = BitcoinTxOut();
    out.scriptPubKey = Uint8List.fromList(toAddress.codeUnits);
    out.value = amount;
    tx.outputs.add(out);
    return tx;
  }

  @override
  Future<Map<String, dynamic>?> sendTxBytes(Uint8List tx) async {
    // The first 8 bytes is the amount encoded in little endian
    var amount = ByteData.view(
      tx.sublist(0, 8).buffer,
    ).getUint64(0, Endian.little);
    var address = String.fromCharCodes(tx.sublist(8));
    if (address.startsWith("ln")) {
      // this function will send the https request the buf is the invoice
      Map<String, dynamic> body = {"invoice": address};
      var response = await rpcCall("payinvoice", body);

      var amountDouble = getDecimalAmount(BigInt.from(amount));
      if (response?["status"] != "ok") {
        String errMsg = response!["err_msg"] ?? "";
        Singleton.sendNotification(
          "Error in Send Transaction",
          "${amountDouble} BTCLN transaction failed. $errMsg",
          groupKey: "BTCLN",
        );
        return null;
      }
      getBalanceFromNetwork();
      return response;
    } else {
      // this function will send the https request the buf is the address
      Map<String, dynamic> body = {
        "address": address,
        "amount": amount.toString(),
      };
      // var response = await rpcCall("transfer", body);
      return rpcCall("transfer", body);
    }
  }

  Future<void> createNewWallet() async {
    var privKeyHex = getClientToken();
    if (privKeyHex.length != 64) {
      return;
    }

    print("btcln creating new wallet");
    var pubkeyHex = getClientPubkey();
    // var privKey1 = ECPrivate.fromHex(privKeyHex);
    var privKey = DerivationBIP32Key(privateKey: hex.decode(privKeyHex));
    var msgHash = hex.decode(pubkeyHex);
    var sig = privKey.signMessage(msgHash, messagePrefix: "\x18Lightning");
    Map<String, dynamic> body = {"pubkey": pubkeyHex, "sig": hex.encode(sig??[])};
    Map<String, String> header = {};
    print("btcln sending new wallet request to server new ${body}");
    var response = await rpcCall("create", body, customHeader: header);
    if (response != null && response.containsKey("token")) {
      print("btcln got token from server. response: ${response}");
      await setClientToken(response["token"]);
    } else {
      print("btcln didn't get token from server. response: ${response}");
    }
    await getTxListFromAPI(showNotifications: false);
  }

  @override
  Future<List<TxDB>?> setupTransactionsForPathChildren(
    List<String> paths,
  ) async {
    // await createNewWallet();
    return null;
  }

  @override
  Future<Uint8List?> signTx(PST? pst, Tx? tx, BuildContext? context) async {
    BitcoinTx btctx = tx as BitcoinTx;
    List<int> raw = [];
    raw += btctx.outputs[0].getAmountBytes();
    raw += btctx.outputs[0].scriptPubKey;
    return Uint8List.fromList(raw);
  }

  @override
  Future<Uint8List?> signPST(PST? pst, Tx? tx, BuildContext? context) async {
    return null;
  }

  @override
  void storeTransaction(
    Tx tx, {
    PST? pst,
    bool confirmed = true,
    bool verified = true,
    bool failed = false,
  }) {}

  @override
  void transmitTxBytes(Uint8List buf) {
  }

  @override
  Future<void> updateBalance() async {
    return;
  }

  @override
  List<VisualTx> getVisualTxList(List<TxDB> txDBList) {
    List<VisualTx> txList = [];
    VisualTx tx;
    for (int i = 0; i < txDBList.length; i++) {
      tx = VisualTx();
      tx.amount =
          txDBList[i].isDeposit! ? txDBList[i].amount! : -txDBList[i].amount!;
      tx.fee = txDBList[i].fee!;
      tx.inAddress = txDBList[i].isDeposit! ? txDBList[i].lockingScript! : "";
      tx.outAddress = txDBList[i].isDeposit! ? "" : txDBList[i].lockingScript!;
      tx.time = txDBList[i].time!;
      tx.usdAmount = txDBList[i].usdAmount!;
      tx.isDeposit = txDBList[i].isDeposit!;
      txList.add(tx);
    }
    return txList;
  }

  Future<BigInt?> getBalanceFromNetwork() async {
    var jObj = await rpcCall("balance", {});

    if (jObj == null) {
      return null;
    }

    Map<String, dynamic>? balances = jObj["balances"];
    if (balances == null) {
      return null;
    }
    int? newBalanceInt = balances["BTC"];
    if (newBalanceInt == null) {
      return null;
    }
    BigInt newBalance = BigInt.from(newBalanceInt);
    if (balance != newBalance) {
      balance = newBalance;
      saveBalance();
      getTxListFromAPI();
      notifyListeners();
    }

    return balance;
  }

  Future<void> connect() async {
    bool firstPass = true;
    while (stayConnected) {
      if (!firstPass) {
        await Future.delayed(Duration(minutes: 1));
      }
      firstPass = false;
      var newBalance = await getBalanceFromNetwork();
      if (newBalance == null) {
        continue;
      }
      return;
    }
  }

  Future<Map<String, dynamic>?> rpcCall(
    String method,
    Map<String, dynamic> bodyObj, {
    int depth = 0,
    Map<String, String>? customHeader,
  }) async {
    if (!online) {
      return null;
    }
    if (depth == rpcServer.length * 2) {
      return null;
    }
    var URL = Uri.parse(
      'https://${rpcServer[rpcIndex % rpcServer.length]}/$method',
    );
    rpcIndex++;
    Map<String, String> headers;
    if (customHeader == null) {
      headers = <String, String>{
        "pubkey": await getClientPubkey(),
        "token": await getClientToken(),
      };
    } else {
      headers = customHeader;
    }
    String body = json.encode(bodyObj);

    http.Response response;
    Map<String, dynamic> jObj;

    try {
      response = await http
          .post(URL, headers: headers, body: body)
          .timeout(Duration(seconds: 5));
    } catch (e) {
      setIsConnected(false);
      return rpcCall(method, bodyObj, depth: depth + 1);
    }

    try {
      jObj = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      setIsConnected(false);
      return rpcCall(method, bodyObj, depth: depth + 1);
    }

    if (!jObj.containsKey("status")) {
      setIsConnected(false);
      return rpcCall(method, bodyObj, depth: depth + 1);
    }

    if (jObj["status"] != "ok") {
      return jObj;
    }

    setIsConnected(true);
    return jObj;
  }

  @override
  BigInt getBalance() {
    return balance;
  }

  void setIsConnected(bool value) {
    var oldValue = isConnected;
    connected = value;
    isConnected = connected && ready;
    if (oldValue != isConnected) {
      notifyListeners();
    }
  }

  Future<void> saveBalance() async {
    // var isar = Singleton.getDB();
    // var balanceDB = isar.balances.getByCoinWalletSync(id, walletId);
    var balanceDB = await Models.balance.getUnique(id, walletId);
    if (balanceDB == null) {
      balanceDB = Balance();
      balanceDB.coin = id;
      balanceDB.wallet = walletId;
    }
    balanceDB.coinBalance = balance.toInt();
    balanceDB.lastUpdate = DateTime.now();
    balanceDB.save();
  }

  Future<void> getTxListFromAPI({bool showNotifications = true}) async {
    var response = await rpcCall("gettransactions", {});
    if (response == null) {
      return;
    }

    // var isar = Singleton.getDB();
    TxDB? tx;
    if (response["transactions"] == null) {
      return;
    }
    for (final txObj in response["transactions"]) {
      // tx = await isar.txDBs.getByHashCoinOutputIndex(txObj["TxHash"], id, 0);
      tx = Models.txDB.getUnique(id, txObj["TxHash"], 0);
      if (tx != null) {
        continue;
      }
      tx = TxDB();
      tx.hash = txObj["TxHash"];
      tx.coin = id;
      tx.amount = txObj["Amount"] ?? 0;
      tx.blockHash = null;
      tx.confirmed = true;
      tx.failed = false;
      tx.fee = txObj["Fee"] ?? 0;
      tx.isDeposit = txObj["IsDeposit"];
      tx.lockingScript = "";
      tx.outputIndex = 0;

      tx.time = DateTime.parse(txObj["Date"]);
      tx.verified = true;
      tx.wallet = walletId;
      await tx.save();

      // var amountDouble = getDecimalAmount(BigInt.from(tx.amount ?? 0));
      // var balanceDouble = getDecimalAmount(balance);

      if (showNotifications) {
        // Singleton.sendNotification(
        //   "${tx.isDeposit! ? "Received" : "Sent"} BTCLN Transaction",
        //   "$amountDouble BTCLN transaction was completed successfully. Your new balance is $balanceDouble",
        //   groupKey: "BTCLN",
        // );
        sendNotification(tx);
      }
    }
  }

  void streamLister() async {
    if (!online) {
      return;
    }
    String pubkey = await getClientPubkey();
    String token = await getClientToken();
    String APIServer = rpcServer[0];
    List<String> protocols = [pubkey, token];
    var URL = Uri.parse('wss://${APIServer}/streamevents');

    final channel = WebSocketChannel.connect(URL, protocols: protocols);
    List<String> msgList;
    channel.ready
        .then((val) {
          setIsConnected(true);
          channel.stream.listen(
            (msg) {
              setIsConnected(true);
              print(msg);
              var msgStr = msg as String;
              msgList = msgStr.split("\n");

              for (final msgItem in msgList) {
                try {
                  var obj = jsonDecode(msgItem) as Map<String, dynamic>;
                  int? newBalanceInt = obj["BTC"];
                  if (newBalanceInt != null) {
                    BigInt newBalance = BigInt.from(newBalanceInt);
                    if (balance != newBalance) {
                      balance = newBalance;
                      saveBalance();
                      getTxListFromAPI();
                      notifyListeners();
                    }
                  }
                } catch (e) {
                  setIsConnected(false);
                  print(e);
                }
              }
            },
            onError: (v) {
              try {
                channel.sink.close(status.goingAway);
              } catch (e) {}
              // retry again after 5 seconds
              Future.delayed(Duration(seconds: 5)).then((v) {
                streamLister();
              });
            },
            onDone: () {
              try {
                channel.sink.close(status.goingAway);
              } catch (e) {}
              // retry again after 5 seconds
              Future.delayed(Duration(seconds: 5)).then((v) {
                streamLister();
              });
            },
          );
        })
        .onError((e, s) {
          setIsConnected(false);
          // retry again after 5 seconds
          Future.delayed(Duration(seconds: 5)).then((v) {
            streamLister();
          });
        });
  }

  @override
  bool isValidAddress(String address) {
    // TODO: add invoice and Bitcoin address validation
    return true;
  }

  @override
  BigInt? getAmountFromAddress(String address) {
    print("btcln.getAmountFromAddress");
    var invoiceMap = parseInvoice(address);
    if (invoiceMap == null) {
      print("btcln.getAmountFromAddress invoiceMap null");
      return null;
    }
    if (!invoiceMap.containsKey("amount")) {
      print("btcln.getAmountFromAddress invoiceMap amount null");
      return null;
    }
    if (invoiceMap["amount"] is! BigInt) {
      print("btcln.getAmountFromAddress invoiceMap amount not BigInt");
      return null;
    }
    return invoiceMap["amount"] as BigInt;
  }

  Map<String, dynamic>? parseInvoice(String invoice) {
    if (!invoice.startsWith("lnbc")) {
      print("parseInvoice invoice no ln");
      print(invoice);
      return null;
    }
    BigInt amount = BigInt.zero;
    String unit = "";
    List<String> unitList = ["m", "u", "n", "p"];
    for (int i = 4; i < invoice.length; i++) {
      if (invoice.codeUnits[i] >= '0'.codeUnitAt(0) &&
          invoice.codeUnits[i] <= '9'.codeUnitAt(0)) {
        amount *= BigInt.from(10);
        amount += BigInt.from(invoice.codeUnits[i] - '0'.codeUnitAt(0));
      } else if (unitList.contains(invoice.substring(i, i + 1))) {
        unit = invoice.substring(i, i + 1);
        break;
      } else {
        print("unknown char at $i which is ${invoice.substring(i, i + 1)}");
        return null;
      }
    }

    Map<String, dynamic> invoiceMap = {};

    switch (unit) {
      case "m":
        invoiceMap["amount"] = amount * BigInt.from(100000);
      case "u":
        invoiceMap["amount"] = amount * BigInt.from(100);
      case "n":
        invoiceMap["amount"] = BigInt.from(amount / BigInt.from(10));
      case "p":
        invoiceMap["amount"] = BigInt.from(amount / BigInt.from(10000));
    }

    print("invoiceMap['amount'] ${invoiceMap["amount"]}");

    return invoiceMap;
  }

  @override
  String getTrackingURL(String txHash) {
    return "";
  }
}
