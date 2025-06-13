import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:tejory/api_keys/api_keys.dart';
import 'package:tejory/coins/const.dart';
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
import 'package:tejory/crypto-helper/ethscan.dart';
import 'package:tejory/crypto-helper/keccak.dart';
import 'package:tejory/box_models.g.dart';
import 'package:tejory/singleton.dart';
import 'package:http/http.dart' as http;
import 'package:tejory/wallets/iwallet.dart';
import 'package:tejory/wallets/wallet_type.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

import 'ether_tx.dart';

class ERC20 extends CryptoCoin {
  // constants
  static const CHAIN_ID = Constants.ETHER_CHAIN_ID;
  // late List<int> _magic;
  late Wallet wallet;
  String? extendedPrivateKey;
  bool stayConnected = true;
  BigInt balance = BigInt.zero;
  List<String> rpcServer = [
    // "rpc.ankr.com/eth_sepolia",
    // "rpc-sepolia.rockx.com",
    "eth.drpc.org", //"sepolia.drpc.org",
    "eth-mainnet.public.blastapi.io", //"eth-sepolia.public.blastapi.io",
    "gateway.tenderly.co/public/mainnet", // "gateway.tenderly.co/public/sepolia",
    // "eth-sepolia.api.onfinality.io/public"
    "eth.llamarpc.com",
    "eth.rpc.blxrbdn.com",
    "ethereum-rpc.publicnode.com",
    "rpc.mevblocker.io"
        "eth-mainnet.g.alchemy.com/v2/${APIKeys.getAPIKey("alchemy")}",
  ];
  List<String> rpcWebsocketServer = [
    "eth-mainnet.g.alchemy.com/v2/${APIKeys.getAPIKey("alchemy")}",
  ];
  late int rpcIndex = Random(
    DateTime.now().millisecondsSinceEpoch,
  ).nextInt(rpcServer.length);
  String API_SERVER = "api.etherscan.io"; //"api-sepolia.etherscan.io";
  int cachedFee = 20000000000; // 20_000_000_000 (20 gwei)
  int? cachedNonce = 0;
  DateTime cachedFeeExpiry = DateTime.now().subtract(Duration(minutes: 1));
  final FEE_CACHE_MAX_AGE = 1;
  final DEFAULT_TX_TYPE = 2;
  bool ready = false;
  bool connected = false;
  final double PRIORITY_PERCENTAGE = 0.1;
  final TX_GAS_UNITS = 84000;
  String? contractHash;
  late int ethCoinId;

  ERC20(
    int walletId, {
    required WalletType walletType,
    required List<int> magic,
    required int port,
    required String peerSeedType,
    required String peerSource,
    required int decimals,
    int? coinId,
    String? netVersionPublicHex,
    String? netVersionPrivateHex,
    String? coinName,
    String? coinSymbol,
    String? this.contractHash,
  }) : super.newCoin(coinName!, coinSymbol!, decimals) {
    super.port = port;
    super.id = coinId;
    super.peerSource = peerSource;
    super.peerSeedType = peerSeedType;
    super.walletType = walletType;
    // _magic = magic;
    super.walletId = walletId;
    super.netVersionPublicHex = netVersionPublicHex;
    super.netVersionPrivateHex = netVersionPrivateHex;
    wallet = Wallet(id: walletId);
    ethCoinId = Singleton.assetList.assetListState.getERC20Id();
  }

  @override
  void dispose() {
    super.dispose();
    stayConnected = false;
  }

  @override
  Future<void> initCoin({List<Block>? blocks, List<TxDB>? txList, Balance? balanceDB}) async {
    if (balanceDB != null && balanceDB.coinBalance != null) {
      balance = BigInt.from(balanceDB.coinBalance!);
    }

    connect();
    () async {
      getTxListFromAPI(showNotifications: !Singleton.initialSetup);
      await getFeeFromAPI();
      await getNonceFromAPI();
      ready = true;
      setIsConnected(connected);
    }();
  }

  @override
  Future<BigInt> calculateFee(
    String toAddress,
    BigInt amount, {
    noChange = false,
  }) async {
    var maxFeePerGas = getGasPrice();
    var maxPriorityFeePerGas = BigInt.from(
      (maxFeePerGas.toDouble() * PRIORITY_PERCENTAGE).toInt(),
    );
    maxFeePerGas += maxPriorityFeePerGas;

    return maxFeePerGas * BigInt.from(TX_GAS_UNITS);
  }

  @override
  Uint8List getAddressBytes(String address) {
    if (!address.startsWith("0x")) {
      throw Exception("address should start with 0x");
    }
    if (address.length != 42) {
      throw Exception("address length should be 42");
    }
    return Uint8List.fromList(hex.decode(address.substring(2)));
  }

  @override
  String getAddressFromBytes(Uint8List address, {String? bechHRP}) {
    var addressHex = hex.encode(address);
    var checksum = keccak(
      Uint8List.fromList(addressHex.toLowerCase().codeUnits),
    );

    var checksumHex = hex.encode(checksum);

    // print("checksumHex: $checksumHex");

    String finalAddress = "";

    for (int i = 0; i < addressHex.length; i++) {
      // 55 is ASCII of 7
      if (checksumHex.codeUnits[i] > 55) {
        finalAddress += addressHex.substring(i, i + 1).toUpperCase();
      } else {
        finalAddress += addressHex.substring(i, i + 1).toLowerCase();
      }
    }

    return "0x${finalAddress}";
  }

  @override
  BigInt getBaseAmount(double val) {
    return BigInt.from((val * pow(10, decimals)).round());
  }

  @override
  String getDecimalAmount(BigInt val) {
    return (val.toDouble() / pow(10, decimals)).toStringAsFixed(decimals);
  }

  @override
  List<String> getInitialDerivationPaths() {
    return ["m/44'/60'/0'/0"];
  }

  @override
  List<String> getInitialEasyImportPaths() {
    return getInitialDerivationPaths();
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
    //   ethCoinId,
    // );
    keyCollection.Key? key = await Models.key.getUnique(walletId, ethCoinId, path);
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
      key.coin = ethCoinId;
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
      // key = isar.keys.getByPathWalletCoinSync(tempPath, walletId, ethCoinId);
      key = await Models.key.getUnique(walletId, ethCoinId, tempPath);
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
    String path = "m/44'/60'/${account}'/0/0";
    // int nextIndex = getNextIndex(path);
    // path += "/${nextIndex}";
    var pubKey = await getPublicKey(path, compressed: false);
    var address = getAddress(pubKey);
    // Convert the RIPEMD-160 hash to a binary string
    var returnAddress = getAddressFromBytes(address);

    return returnAddress;
  }

  Uint8List getAddress(Uint8List pubKeyBytes) {
    // https://info.etherscan.com/what-is-an-ethereum-address/
    if (pubKeyBytes.length == 65) {
      pubKeyBytes = pubKeyBytes.sublist(1);
    }
    var hash = keccak(pubKeyBytes, 32);

    return hash.sublist(hash.length - 20, hash.length);
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
    getFeeFromAPI();
    return BigInt.from(nBytes * cachedFee);
  }

  BigInt getGasPrice() {
    getFeeFromAPI();
    return BigInt.from(cachedFee);
  }

  @override
  PST makePST(Tx tx) {
    return new PSBT();
  }

  @override
  Future<Tx?> makeTransaction(String toAddress, BigInt amount, {noChange = false}) async {
    var tx = new EtherTx();
    tx.type = DEFAULT_TX_TYPE;
    tx.chainId = Constants.ETHER_CHAIN_ID;
    tx.destination = Uint8List.fromList(hex.decode(contractHash!));
    tx.gasLimit = TX_GAS_UNITS;
    tx.maxFeePerGas = getGasPrice();
    tx.maxPriorityFeePerGas = BigInt.from(
      (tx.maxFeePerGas.toDouble() * PRIORITY_PERCENTAGE).toInt(),
    );
    tx.maxFeePerGas += tx.maxPriorityFeePerGas;
    tx.amount = BigInt.zero;
    BigInt tokenAmount = amount;
    if (noChange) {
      if ((tokenAmount - balance).abs() > BigInt.from(5)) {
        throw Exception(
          "invalid amount tx.amount: ${tx.amount}, amount:${amount}",
        );
      }
      tokenAmount = balance;
    }

    // a9059cbb is the first 4 bytes of keccak("transfer(address,uint256)")
    // then 12 bytes of 00 to make the address 32 bytes.
    List<int> data = hex.decode("a9059cbb000000000000000000000000").toList();
    data.addAll(getAddressBytes(toAddress));
    data.addAll(hex.decode(tokenAmount.toRadixString(16).padLeft(64, "0")));
    tx.data = Uint8List.fromList(data);

    var nonce = getNonce();
    if (nonce == null) {
      return null;
    }
    tx.nonce = nonce;
    return tx;
  }

  @override
  Future<Map<String, dynamic>?> sendTxBytes(Uint8List tx) async {
    print("Sending TX: ${hex.encode(tx)}");
    var jObj = await rpcCall("eth_sendRawTransaction", ["0x${hex.encode(tx)}"]);

    if (jObj == null) {
      await Future.delayed(Duration(seconds: 10));
      return sendTxBytes(tx);
    }

    if (jObj["result"] == null) {
      await Future.delayed(Duration(seconds: 10));
      return sendTxBytes(tx);
    }

    // Future.delayed(Duration(seconds: 20)).then((d) {
    //   getTxListFromAPI();
    // });

    return jObj;
  }

  @override
  Future<List<TxDB>?> setupTransactionsForPathChildren(
    List<String> paths,
  ) async {
    return null;
  }

  @override
  Future<Uint8List?> signTx(PST? pst, Tx? tx, BuildContext? context) async {
    return signPST(pst, tx, context);
  }

  @override
  Future<Uint8List?> signPST(PST? pst, Tx? tx, BuildContext? context) async {
    if (tx == null) {
      return null;
    }

    String path = "m/44'/60'/0'/0/0";
    List<int>? sig;
    EtherTx ethTx = tx as EtherTx;
    String? errorMes;
    var success = await wallet.signingWallet!.startSession(context, await (
      dynamic session, {
      List<int>? pinCode,
      List<int>? pinCodeNew,
    }) async {
      wallet.signingWallet!.setMediumSession(session);
      if (pinCode == null) {
        errorMes = "PIN code was not entered";
        return false;
      }
      var pinResult = await wallet.signingWallet!.verifyPIN(
        String.fromCharCodes(pinCode),
      );
      print("startSession: sent verifyPIN, result is ${pinResult}");
      if (pinResult != VerifyPINResult.OK) {
        errorMes = pinResult.toString();
        return false;
      }
      sig = await wallet.signingWallet!.signTX(
        ethTx.getRawTX(),
        "ETH",
        true,
        paths: [path],
      );
      return true;
    });

    if (!success) {
      if (errorMes != null) {
        throw Exception(errorMes!);
      }
      return null;
    }

    if (sig == null || sig?.length == 0) {
      return null;
    }

    // check if the S value is too big
    BigInt n = BigInt.parse(
      "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141",
      radix: 16,
    );
    BigInt halfn = BigInt.parse(
      "7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0",
      radix: 16,
    );

    int rLength = sig![3];
    int sIndex = 4 + rLength + 2;
    String sHex = hex.encode(sig!.sublist(sIndex));
    BigInt s = BigInt.parse(sHex, radix: 16);
    if (s >= halfn) {
      s = n - s;
      sHex = s.toRadixString(16);
      if ((sHex.length % 2) != 0) {
        sHex = "0" + sHex;
      }
      List<int> sBytes = hex.decode(sHex);
      if (sBytes[0] > 0x80) {
        sBytes = [0x00, ...sBytes];
      }
      // put the new length of s in the signature
      sig![sIndex - 1] = sBytes.length;
      sig = [...sig!.sublist(0, sIndex), ...sBytes];
      sig![1] = sig!.length - 2;
    }

    var pubKey = await getPublicKey(path);
    ethTx.setSignature(Uint8List.fromList(sig!), pubKey);

    return ethTx.getRawTX();
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
  void transmitTxBytes(Uint8List buf) {}

  @override
  Future<void> updateBalance() async {
    return null;
  }

  @override
  List<VisualTx> getVisualTxList(List<TxDB> txDBList) {
    List<VisualTx> txList = [];
    VisualTx tx;
    for (int i = 0; i < txDBList.length; i++) {
      tx = VisualTx();
      tx.amount =
          txDBList[i].isDeposit! ? txDBList[i].amount! : -txDBList[i].amount!;
      tx.fee = 0; //txDBList[i].fee!;
      tx.inAddress = txDBList[i].isDeposit! ? txDBList[i].lockingScript! : "";
      tx.outAddress = txDBList[i].isDeposit! ? "" : txDBList[i].lockingScript!;
      tx.time = txDBList[i].time!;
      tx.usdAmount = txDBList[i].usdAmount!;
      tx.isDeposit = txDBList[i].isDeposit!;
      txList.add(tx);
    }
    return txList;
  }

  Future<void> connect() async {
    bool firstPass = true;
    streamEvents();
    while (stayConnected) {
      if (!firstPass) {
        await Future.delayed(Duration(minutes: 1));
      }
      firstPass = false;

      var newBalance = await getBalanceFromAPI();
      if (newBalance == null) {
        continue;
      }
      if (balance != newBalance) {
        balance = newBalance;
        saveBalance();
        getTxListFromAPI();
        notifyListeners();
      }
      await Future.delayed(Duration(minutes: 5));
    }
  }

  Future<BigInt?> getBalanceFromAPI() async {
    String address = await getReceivingAddress();
    address = address.substring(2).toLowerCase();
    String data = "0x70a08231000000000000000000000000" + address;
    Map<String, String> obj = {"to": contractHash!, "data": data};
    var jObj = await rpcCall("eth_call", [obj, "latest"]);

    if (jObj == null) {
      return null;
    }

    String? newBalanceStr = (jObj["result"] ?? null) as String?;
    if (newBalanceStr == null) {
      return null;
    }
    BigInt newBalance = BigInt.parse(newBalanceStr.substring(2), radix: 16);
    return newBalance;
  }

  Future<Map<String, dynamic>?> rpcCall(
    String method,
    List<dynamic> params, {
    int depth = 0,
  }) async {
    if (depth == rpcServer.length * 2) {
      return null;
    }
    var URL = Uri.parse('https://${rpcServer[rpcIndex % rpcServer.length]}');
    rpcIndex++;
    Map<String, String> headers = <String, String>{
      "Content-Type": "application/json",
    };
    Map<String, dynamic> bodyObj = {
      "jsonrpc": "2.0",
      "method": method,
      "params": params,
      "id": 0,
    };
    String body = json.encode(bodyObj);

    http.Response response;
    Map<String, dynamic> jObj;

    try {
      response = await http
          .post(URL, headers: headers, body: body)
          .timeout(Duration(seconds: 5));
    } catch (e) {
      setIsConnected(false);
      return rpcCall(method, params, depth: depth + 1);
    }

    try {
      jObj = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      setIsConnected(false);
      return rpcCall(method, params, depth: depth + 1);
    }

    if (!jObj.containsKey("result")) {
      setIsConnected(false);
      return rpcCall(method, params, depth: depth + 1);
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

  Future<void> getTxListFromAPI({bool showNotifications=true}) async {
    String address = await getReceivingAddress();
    var URL = Uri.parse(
      'https://${API_SERVER}/v2/api?chainid=${CHAIN_ID}&module=account&action=tokentx&contractaddress=0x${contractHash}&address=${address}&startblock=0&endblock=99999999&page=1&offset=10&sort=asc&apikey=${APIKeys.getAPIKey("etherscan")}',
    );
    http.Response response;
    Map<String, dynamic> jObj;

    try {
      response = await http.get(URL).timeout(Duration(seconds: 5));
      jObj = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return;
    }

    Ethscan resultObj = Ethscan.fromJson(jObj);
    if (resultObj.result == null) {
      return;
    }
    // var isar = Singleton.getDB();
    TxDB? tx;
    for (var result in resultObj.result!) {
      // tx = await isar.txDBs.getByHashCoinOutputIndex(result.hash, id, 0);
      tx = await Models.txDB.getUnique(id, result.hash, 0);
      if (tx != null) {
        continue;
      }
      tx = TxDB();
      tx.hash = result.hash;
      tx.coin = id;
      tx.amount = int.parse(result.value ?? "0");
      tx.blockHash = result.blockHash;
      tx.confirmed = true;
      tx.failed = false;
      tx.fee =
          int.parse(result.gasPrice ?? "0") * int.parse(result.gasUsed ?? "0");
      tx.isDeposit =
          (result.from!.toLowerCase() == address.toLowerCase()) ? false : true;
      tx.lockingScript = (tx.isDeposit!) ? result.from! : result.to!;
      tx.outputIndex = 0;
      tx.time = DateTime.fromMillisecondsSinceEpoch(
        int.parse(result.timeStamp!) * 1000,
      );
      tx.verified = true;
      tx.wallet = walletId;
      await tx.save();
      if (showNotifications && !Singleton.initialSetup) {
        // Singleton.sendNotification(
        //   "${tx.isDeposit! ? "Received" : "Sent"} ${symbol()} Transaction",
        //   "${getDecimalAmount(BigInt.from(tx.amount!))} ${symbol()} transaction was completed successfully. Your new balance is ${getDecimalAmount(getBalance())}",
        //   groupKey: "${symbol()}",
        // );
        sendNotification(tx);
      }
    }
  }

  Future<int?> getFeeFromAPI() async {
    if (DateTime.now().isBefore(cachedFeeExpiry)) {
      return cachedFee;
    }

    var jObj = await rpcCall("eth_gasPrice", []);

    if (jObj == null) {
      return null;
    }

    if (jObj["result"] == null) {
      return null;
    }

    cachedFee = int.parse(jObj["result"]! as String);

    cachedFeeExpiry = DateTime.now().add(Duration(minutes: FEE_CACHE_MAX_AGE));

    return cachedFee;
  }

  int? getNonce({bool synch = false}) {
    () async {
      getNonceFromAPI();
    }();
    return cachedNonce;
  }

  Future<int?> getNonceFromAPI() async {
    var jObj = await rpcCall("eth_getTransactionCount", [
      await getReceivingAddress(),
      "latest",
    ]);
    if (jObj == null) {
      return null;
    }
    if (jObj["result"] == null) {
      return null;
    }
    cachedNonce = int.parse(jObj["result"]! as String);

    return cachedNonce;
  }

  Future<void> streamEvents() async {
    var URL = Uri.parse('wss://${rpcWebsocketServer[0]}');
    var myAddress = await getReceivingAddress();

    Map<String, dynamic> filterObj = {
      "jsonrpc": "2.0",
      "method": "eth_subscribe",
      "params": [
        "alchemy_minedTransactions",
        {
          "addresses": [
            {"to": myAddress},
            {"from": myAddress},
          ],
          "includeRemoved": false,
          "hashesOnly": true,
        },
      ],
      "id": 1,
    };

    final channel = WebSocketChannel.connect(URL);

    channel.ready
        .then((val) {
          setIsConnected(true);
          channel.sink.add(json.encode(filterObj));
          channel.stream.listen(
            (msg) async {
              try {
                setIsConnected(true);
                print(msg);
                var msgStr = msg as String;
                var obj = jsonDecode(msgStr) as Map<String, dynamic>;
                Map<String, dynamic>? params = obj["params"];
                if (params == null) {
                  return;
                }
                var newBalance = await getBalanceFromAPI();
                if (newBalance == null) {
                  return;
                }
                if (newBalance != balance) {
                  balance = newBalance;
                  getTxListFromAPI();
                  notifyListeners();
                }
              } catch (e) {
                setIsConnected(false);
                print(e);
              }
            },
            onError: (v) {
              try {
                channel.sink.close(status.goingAway);
              } catch (e) {}
              // retry again after 5 seconds
              Future.delayed(Duration(seconds: 5)).then((v) {
                streamEvents();
              });
            },
            onDone: () {
              try {
                channel.sink.close(status.goingAway);
              } catch (e) {}
              // retry again after 5 seconds
              Future.delayed(Duration(seconds: 5)).then((v) {
                streamEvents();
              });
            },
          );
        })
        .onError((e, s) {
          setIsConnected(false);
          // retry again after 5 seconds
          Future.delayed(Duration(seconds: 5)).then((v) {
            streamEvents();
          });
        });
  }

  bool isValidAddress(String address) {
    if (!address.startsWith("0x")) {
      return false;
    }
    if (address.length != 42) {
      return false;
    }
    return true;
  }

  @override
  BigInt? getAmountFromAddress(String address) {
    return null;
  }

  @override
  String getTrackingURL(String txHash) {
    return "https://etherscan.io/tx/0x${txHash}";
  }
}
