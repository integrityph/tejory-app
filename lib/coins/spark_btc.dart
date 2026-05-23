import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flashnet_dart/flashnet_dart.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mutex/mutex.dart';
import 'package:spark_dart/graphql/objects/lightning_receive_request.dart';
import 'package:spark_dart/graphql/objects/lightning_send_request.dart';
import 'package:spark_dart/graphql/objects/lightning_send_request_status.dart';
import 'package:spark_dart/graphql/objects/transfer.dart';
import 'package:spark_dart/services/bolt11_spark.dart';
import 'package:spark_dart/services/wallet_config.dart';
import 'package:spark_dart/spark_wallet/spark_wallet.dart';
import 'package:spark_dart/spark_wallet/types.dart';
import 'package:spark_dart/types/sdk_types.dart';
import 'package:spark_dart/utils/address.dart';
import 'package:spark_dart/utils/network.dart' as spark_net;
import 'package:spark_dart/utils/token_identifier.dart';
import 'package:tejory/api_keys/api_keys.dart';
import 'package:tejory/coins/bitcoin_tx.dart';
import 'package:tejory/coins/const.dart';
import 'package:tejory/coins/crypto_coin.dart';
import 'package:tejory/coins/network.dart';
import 'package:tejory/coins/psbt.dart';
import 'package:tejory/coins/pst.dart';
import 'package:tejory/coins/tx.dart';
import 'package:tejory/coins/visual_tx.dart';
import 'package:tejory/coins/wallet.dart';
import 'package:tejory/crypto-helper/bech32m.dart';
import 'package:tejory/crypto-helper/se_helper.dart';
import 'package:tejory/objectbox.g.dart';
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
import 'package:spark_dart/src/proto/spark_token.pb.dart';
import 'package:flashnet_dart/types/index.dart';

import 'ether_tx.dart';

class SparkBTC extends CryptoCoin {
  late Wallet wallet;
  String? extendedPrivateKey;
  bool stayConnected = true;
  late SparkWallet? spark;
  bool connected = false;
  final Mutex txListMutex = Mutex();
  final Map<String, BigInt> feeMap = {};
  final Map<String, String> lnNodeAliases = {};
  final Completer sparkReady = Completer();
  FlashnetClient? _flashnetClient;
  Completer _flashnetReady = Completer();
  Map<String, List<Function()>> _tokenTransactionHandler = {};
  List<String> _tokenTransactionList = [];
  

  SparkBTC(
    int walletId, {
    required WalletType walletType,
    required List<int> magic,
    required int port,
    required String peerSeedType,
    required String peerSource,
    int? coinId,
    String? netVersionPublicHex,
    String? netVersionPrivateHex,
  }) : super.newCoin("Spark BTC", "SPKBTC", 8) {
    super.port = port;
    super.id = coinId;
    super.peerSource = peerSource;
    super.peerSeedType = peerSeedType;
    super.walletType = walletType;
    // _magic = magic;
    super.walletId = walletId;
    super.netVersionPublicHex = netVersionPublicHex;
    super.netVersionPrivateHex = netVersionPrivateHex;
    super.getPrivateKeyDerivation = true;
    wallet = Wallet(id: walletId);
  }

  @override
  void dispose() {
    super.dispose();
    stayConnected = false;
  }

  @override
  Future<void> initCoin({List<Block>? blocks, List<TxDB>? txList, Balance? balanceDB, List<keyCollection.Key>? keys}) async {
    if (balanceDB != null && balanceDB.coinBalance != null) {
      balance = BigInt.from(balanceDB.coinBalance!);
    }
    if (isUIInstance) {
      // await the SE to be ready
      await SEHelper.ready.future;

      final keyList = Models.key.find(q: Key_.coin.equals(id!) & Key_.wallet.equals(walletId));
      if (keyList==null) {
        return;
      }
      for (int i=0; i<keyList.length; i++) {
        keyList[i].privateKey = hex.encode(SEHelper.decrypt(Uint8List.fromList(hex.decode(keyList[i].privateKey!)))!);
      }
      getAssetIsolatePort().send(<String, dynamic>{
        "command": "initCoin",
        "params": {"blocks": blocks, "txList": txList, "balanceDB": balanceDB, "keys": keyList},
      });
      return;
    }

    if (keys == null) {
      return;
    }
    List<({Uint8List chainCode, String path, Uint8List privateKey})>? keyset = [];
    for (final key in keys) {
      keyset.add((
        privateKey: Uint8List.fromList(hex.decode(key.privateKey!)),
        chainCode: Uint8List.fromList(hex.decode(key.chainCode!)),
        path: key.path!,
      ));
    }

    SparkWallet.initialize(
      props: SparkWalletProps(
        keyset: keyset,
        accountNumber: 1,
        encryptAndStoreInSE: false, // no need as we are doing this in the app
        options: ConfigOptions(
          network: spark_net.Network.mainnet,
          isReadOnly: false,
          log: true,
        ),
      ),
    ).then((response) async {
      spark = response.wallet;

      connect();
      // await testSwap();
      () async {
        getTxListFromAPI(showNotifications: !Singleton.initialSetup);
        connected = true;
        setIsConnected(connected);
        sparkReady.complete();
      }();
      notifyListeners();
    });
  }

  Future<void> testSwap() async {
    final client = new FlashnetClient.withConfig(spark!, FlashnetClientConfig(
      sparkNetworkType: SparkNetworkTypes.mainnet,
      clientConfig: "mainnet",
    ));

    await client.initialize();

    const BTC_ID = "020202020202020202020202020202020202020202020202020202020202020202";
    const USDB_ID = "3206c93b24a4d18ea19d0a9a213204af2c7e74a6d16c7535cc5d33eca4ad1eca";

    final pools = await client.listPools(ListPoolsQuery(
      assetAAddress: USDB_ID,
      assetBAddress: BTC_ID,
      sort: "TVL_DESC",
    ));

    debugPrint("pools.totalCount: ${pools.totalCount}");

    for (final pool in pools.pools) {
      debugPrint("pool: ${jsonEncode(pool)}");
    }

    // try clawback
    // final response = await client.clawback(sparkTransferId: "019e3030-1693-7a23-8864-c37993e41c0a", lpIdentityPublicKey: "037579aee81891fc3a28cbe7b13e565031d46248b420fb39dcb308598f472b4513");

    // debugPrint("response of clawback: ${response.accepted}");

    const poolId = "037579aee81891fc3a28cbe7b13e565031d46248b420fb39dcb308598f472b4513";
    // First simulate to get expected output
    final simulation = await client.simulateSwap(SimulateSwapRequest(
      poolId: poolId,
      assetInAddress: BTC_ID,
      assetOutAddress: USDB_ID,
      amountIn: "10000",
    ));

    // Calculate minimum output with slippage tolerance
    final amountOut = BigInt.parse(simulation.amountOut);
    final minAmountOut = amountOut - (amountOut ~/ BigInt.from(100));

    // Execute the swap
    final swap = await client.executeSwap(
      poolId: poolId,
      assetInAddress: BTC_ID,
      assetOutAddress: USDB_ID,
      amountIn: "10000",
      minAmountOut: minAmountOut.toString(),
      maxSlippageBps: 100, // 1% max slippage
    );

    debugPrint('Swap successful!');
    debugPrint('Amount out: ${swap.response.amountOut}');
    debugPrint('Outbound transfer: ${swap.response.outboundTransferId}');
  }

  @override
  Future<BigInt> calculateFee(
    String toAddress,
    BigInt amount, {
    noChange = false,
  }) async { 
    if (isUIInstance) {
      final uuid = UUID.generateUUIDv4();
      isolateRequests[uuid] = Completer();
      getAssetIsolatePort().send(<String, dynamic>{
        "command": "calculateFee",
        "params": {"toAddress": toAddress, "amount": amount, "noChange": noChange},
        "uuid": uuid,
      });

      final result = ((await isolateRequests[uuid]!.future) as BigInt?) ?? BigInt.zero;
      isolateRequests.remove(uuid);
      return result;
    }
    if (toAddress.startsWith("spark1")) {
      return BigInt.zero; // for now there are no spark to spark fees
    } else if (toAddress.startsWith("lnbc")) {
      BigInt fee = BigInt.from(await spark!.getLightningSendFeeEstimate(encodedInvoice: toAddress));
      double feeDouble = fee.toDouble();
      feeDouble += (feeDouble * 0.1); // add 10% extra budget for the maximum fee
      fee = BigInt.from(feeDouble.ceil());
      feeMap[toAddress] = fee;
      return fee;
    } else {
      // unknown type
      return BigInt.zero;
    }
  }

  @override
  Uint8List getAddressBytes(String address) {
    return Uint8List(0);
  }

  @override
  String getAddressFromBytes(Uint8List address, {String? bechHRP}) {
    return "";
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
    return ["m/8797555'/1'/0'", "m/8797555'/1'/1'", "m/8797555'/1'/2'", "m/8797555'/1'/3'", "m/8797555'/1'/4'"];
  }

  @override
  List<String> getInitialEasyImportPaths() {
    return getInitialDerivationPaths();
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
    BigInt? amount,
  }) async {
    if (isUIInstance) {
      final uuid = UUID.generateUUIDv4();
      isolateRequests[uuid] = Completer();
      getAssetIsolatePort().send(<String, dynamic>{
        "command": "getReceivingAddress",
        "params": {"network": network, "amount": amount},
        "uuid": uuid,
      });
      
      final result = ((await isolateRequests[uuid]!.future) as String?) ?? "";
      isolateRequests.remove(uuid);
      return result;
    }

    String address;
    switch (network) {
      case ("BTCLN"):
        if (amount == null) {
          return "";
        }
        address = (await spark?.createLightningInvoice(amountSats: amount.toInt()))?.invoice.encodedInvoice ?? "";
        break;
      case ("SPKBTC"):
        address = await spark?.getSparkAddress()??"NA";
        break;
      case ("SPKBTCI"): // Spark Invoice
        if (amount == null) {
          return "";
        }
        address = await spark?.createSatsInvoice(amount: amount.toInt(), memo: "test memo") ?? "";
      default:
        address = "";
    }
     
    return address;
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
    if (isUIInstance) {
      getAssetIsolatePort().send(<String, dynamic>{
        "command": "makeTransaction",
        "params": {"toAddress": toAddress, "amount": amount, "noChange": noChange},
      });
      
      var tx = new BitcoinTx();
      return tx;
    }

    DecodedSparkAddressData? sparkAddress;
    try {
      sparkAddress = decodeSparkAddress(toAddress);
    } catch (_) {}
    

    if (sparkAddress != null && sparkAddress.sparkInvoiceFields == null) {
      try {
        await spark!.transfer(amountSats: amount, receiverSparkAddress: toAddress);
      } catch (e) {
        debugPrint("Unable to make transfer. $e");
        return null;
      }
    } else if (sparkAddress != null && sparkAddress.sparkInvoiceFields?.paymentType?.type == "sats") {
      try {
        final result = await spark!.fulfillSparkInvoice([(amount: amount, invoice: toAddress)]);
        if (result.satsTransactionSuccess.length !=1 ) {
          debugPrint("Error in fulfillSparkInvoice for sats. invalidInvoices: ${result.invalidInvoices}, satsTransactionErrors: ${result.satsTransactionErrors}");
          return null;
        }
      } catch (e) {
        debugPrint("Unable to make spark sats invoice payment. $e");
        return null;
      }
    } else if (toAddress.startsWith("lnbc")) {
      final fee = feeMap[toAddress] ?? await calculateFee(toAddress, amount);
      final response = await spark!.payLightningInvoice(
        invoice: toAddress,
        maxFeeSats: fee.toInt(),
        amountSatsToSend: null,
      );

      // assume it's always a LN transfer
      response.lightningSendRequest!;
      if (response.lightningSendRequest!.status != LightningSendRequestStatus.lightningPaymentInitiated &&
          response.lightningSendRequest!.status != LightningSendRequestStatus.lightningPaymentSucceeded
      ) {
        return null;
      }

      // // get the actual fee
      // fee = BigInt.from(response.lightningSendRequest!.fee.getValueInSatoshi());

      // // store the transaction in DB
      // TxDB tx = TxDB()
      // ..hash = response.lightningSendRequest!.id
      // ..amount = amount.toInt()
      // ..fee = fee.toInt()
      // ..time = DateTime.parse(response.lightningSendRequest!.createdAt)
      // ..coin = id
      // ..wallet = walletId
      // ..confirmed = true
      // ..failed = false
      // ..verified = true
      // ..isDeposit = true
      // ..outputIndex = 0
      // ..blockHash = ""
      // ..lockingScript = "";
      // await tx.save();
    }
    
    var tx = BitcoinTx();
    return tx;
  }

  @override
  Future<Map<String, dynamic>?> sendTxBytes(Uint8List tx) async {
    return {"result":""};
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
    return Uint8List(0);
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
      tx.amount = txDBList[i].isDeposit! ? txDBList[i].amount! : -txDBList[i].amount!;
      tx.fee = txDBList[i].fee!;
      tx.inAddress = txDBList[i].isDeposit! ? txDBList[i].lockingScript! : "";
      tx.outAddress = txDBList[i].isDeposit! ? "" : txDBList[i].lockingScript!;
      tx.time = txDBList[i].time!;
      tx.usdAmount = txDBList[i].usdAmount;
      tx.isDeposit = txDBList[i].isDeposit!;
      txList.add(tx);
    }
    return txList;
  }

  Future<BigInt?> getBalanceFromAPI() async {
    try{
      final response = await spark!.getBalance();
      return response.balance;
    } catch (e) { return null; }
    
    
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

  @override
  BigInt getBalance() {
    return balance;
  }

  void setIsConnected(bool value) {
    var oldValue = isConnected;
    connected = value;
    isConnected = connected;
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
    txListMutex.protect<void>(() async {
      // Models.txDB.delete(q: TxDB_.wallet.equals(walletId) & TxDB_.coin.equals(id!));
      // int offset = Models.txDB.count(q:
      //   TxDB_.wallet.equals(walletId) &
      //   TxDB_.coin.equals(id!),
      // )??0;
      // print("offset: ${offset}");
      final limit = 20;
      int offset = 0;
      for (int i=0; i<5; i++) {
        ({int offset, List<WalletTransfer> transfers}) txList;
        try{
          txList = await spark!.getTransfers(limit: limit, offset: offset);
        } catch (e) {
          return;
        }
        
        offset = txList.offset;


        TxDB? tx;
        for (var item in txList.transfers) {
          tx = await Models.txDB.getUnique(id, item.id, 0);
          if (tx != null) {
            return;
          }

          final LightningSendRequest? lightningSendRequest = (item.userRequest is LightningSendRequest)
            ? item.userRequest as LightningSendRequest
            : null;

          final isDeposit = (item.transferDirection.value == "INCOMING") ? true : false;

          final lockingScript = await getTxLockingscript(item);

          tx = TxDB();
          tx.hash = item.id;
          tx.coin = id;
          tx.amount = item.totalValue;
          tx.blockHash = "";
          tx.confirmed = true;
          tx.failed = false;
          tx.fee = lightningSendRequest?.fee.getValueInSatoshi() ?? 0;
          tx.isDeposit = isDeposit;
          tx.lockingScript = lockingScript;
          tx.outputIndex = 0;
          tx.time = item.createdTime;
          tx.verified = true;
          tx.wallet = walletId;
          await tx.save();
          if (showNotifications && !Singleton.initialSetup) {
            sendNotification(tx);
          }
        }

        if (offset == -1) {
          break;
        }
      }
    });
  }

  Future<String> getTxLockingscript(WalletTransfer transfer) async {
    final isDeposit = transfer.transferDirection.value == "INCOMING";

    if (transfer.userRequest case LightningSendRequest request) {
      final invoice = decodeInvoice(request.encodedInvoice);
      final payeePublicKey = await extractPayeePublicKey(invoice.signature!, invoice.msgHash!);
      final nodeAliase =  await getLightningNodeName(hex.encode(payeePublicKey));
      return "Lightning ⚡️ $nodeAliase";
    } else if (transfer.userRequest case LightningReceiveRequest _) {
      return "Lightning ⚡️";
    }

    return isDeposit
      ? getAddressFromBytesBech32m(Uint8List.fromList(hex.decode(transfer.senderIdentityPublicKey)))
      : getAddressFromBytesBech32m(Uint8List.fromList(hex.decode(transfer.receiverIdentityPublicKey)));
  }

  Future<String> getPublicKeyHexFromSig(List<int>? sig) async {
    return "";
  }

  Future<String> getLightningNodeName(String publicKeyHex) async {
    if (publicKeyHex.isEmpty) {
      return "";
    }
    if (lnNodeAliases.containsKey(publicKeyHex)) {
      return lnNodeAliases[publicKeyHex]!;
    }
    final URL = "https://1ml.com/node/${publicKeyHex}/json";
    try {
      final response = await http.get(Uri.parse(URL)).timeout(Duration(seconds: 5));
      final obj = jsonDecode(response.body) as Map<String, dynamic>;
      if (obj["alias"] != null) {
        lnNodeAliases[publicKeyHex] = obj["alias"] as String;
      }
      return obj["alias"] ?? "";
    } catch (e) {
      print(e);
    }
    
    return "";
  }

  Future<void> streamEvents() async {
    spark!.onBalanceUpdate((BalanceUpdateData data) async {
      final newBalance = data.available;
      if (newBalance != balance) {
        balance = newBalance;
        await getTxListFromAPI();
        notifyListeners();
      }
    });
    spark!.onDepositConfirmed((_,_) async {
        await getTxListFromAPI();
        notifyListeners();
    });
    spark!.onTransferClaimed((_,_) async {
        await getTxListFromAPI();
        notifyListeners();
    });
    spark!.onStreamConnected(() {
      setIsConnected(true);
    });
    spark!.onStreamDisconnected((_) {
      setIsConnected(false);
    });
    spark!.onStreamReconnecting((_,_,_,_) {
      setIsConnected(false);
    });
    spark!.onStreamHeartbeat((){});
    spark!.onTokenTransaction((List<TokenSyncTransaction> transactions, Map<Bech32mTokenIdentifier, TokenBalanceInfo> tokenBalances){
      for (final syncTx in transactions) {
        _tokenTransactionList.addAll(syncTx.tokenIdentifiers);
      }
      notifyListeners();
    });
  }

  bool isValidAddress(String address) {
    DecodedSparkAddressData? sparkAddress;
    try {
      sparkAddress = decodeSparkAddress(address);
    } catch (_) {}

    if (
      (sparkAddress != null && sparkAddress.sparkInvoiceFields == null) ||
      (sparkAddress != null && sparkAddress.sparkInvoiceFields?.paymentType?.type == "sats")
    ) {
      return true;
    } else if (address.startsWith("lnbc")) {
      return SparkBTC.parseInvoice(address) != null;
    }
    // TODO: add onchain addresses
    return false;
  }

  @override
  BigInt? getAmountFromAddress(String address) {
    if (address.startsWith("lnbc")) {
      // Lightening Network
      final invoice = SparkBTC.parseInvoice(address);
      return invoice?["amount"]??0;
    } else if (address.startsWith("spark1")) {
      final decoded = decodeSparkAddress(address);
      return decoded.sparkInvoiceFields?.paymentType?.amount ?? null;
    }

    return null;
  }

  @override
  String getTrackingURL(String txHash) {
    return "";
  }

  @override
  List<Network> getNetworks({String? address}) {
    DecodedSparkAddressData? sparkAddress;
    try {
      sparkAddress = address != null ? decodeSparkAddress(address) : null;
    } catch (_) {}

    var networkList = [
      if (address == null || (sparkAddress != null && sparkAddress.sparkInvoiceFields == null)) Network("SPKBTC", "Spark"),
      if (address == null || (sparkAddress != null && sparkAddress.sparkInvoiceFields?.paymentType?.type == "sats")) Network("SPKBTCI", "Spark Invoice", requiresAmount:true),
      if (address?.startsWith("lnbc")??true) Network("BTCLN", "Lightning", requiresAmount:true),
    ];

    return networkList;
  }



  static Map<String, dynamic>? parseInvoice(String invoice) {
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
  Map<String,dynamic> getState() {
    final state = super.getState();
    state["sparkReady"] = sparkReady.isCompleted;
    state["tokenTransactionList"] = _tokenTransactionList.map((v)=>v).toList(); // This is required to ensure we copy the list before clearing it
    _tokenTransactionList.clear();
    return state;
  }

  @override
  void receiveResponse(Map<String, dynamic> message) {
    if (message["command"] is String) {
      switch (message["command"]) {
        case "notifyListeners":
          balance = message["balance"];
          isConnected = message["isConnected"];
          if (message["sparkReady"] && !sparkReady.isCompleted) {
            sparkReady.complete();
          }
          if ((message["tokenTransactionList"] as List<String>).length != 0) {
            for (final tokenId in message["tokenTransactionList"]){
              if (!_tokenTransactionHandler.containsKey(tokenId)) {
                continue;
              }
              for (final handler in _tokenTransactionHandler[tokenId]!) {
                handler();
              }
            }
          }
          notifyListeners();
      }

      // Handle responses from the isolate requests
      if (message["uuid"] is String) {
        if (isolateRequests.containsKey(message["uuid"])) {
          isolateRequests[message["uuid"]]!.complete(message["response"]);
        }
      }
    }
  }

  // TOKEN interactions
  Map<Bech32mTokenIdentifier, TokenBalanceInfo> _tokenBalanceCache = {};
  Future<BigInt?> getTokenBalance(String btknId) async {
    if (isUIInstance) {
      final uuid = UUID.generateUUIDv4();
      isolateRequests[uuid] = Completer();
      getAssetIsolatePort().send(<String, dynamic>{
        "command": "callInternalFunction",
        "params": {"method":"getTokenBalance", "params":{"btknId": btknId}},
        "uuid": uuid,
      });
      
      final result = ((await isolateRequests[uuid]!.future) as BigInt?) ?? null;
      isolateRequests.remove(uuid);
      return result;
    }
    _tokenBalanceCache = await spark!.getTokenBalance();

    return _tokenBalanceCache[Bech32mTokenIdentifier(btknId)]?.availableToSendBalance;
  }

  Future<List<TokenTransactionWithStatus>?> getTokenTransactions(String btknId) async {
    if (isUIInstance) {
      final uuid = UUID.generateUUIDv4();
      isolateRequests[uuid] = Completer();
      getAssetIsolatePort().send(<String, dynamic>{
        "command": "callInternalFunction",
        "params": {"method":"getTokenTransactions", "params":{"btknId": btknId}},
        "uuid": uuid,
      });
      
      final result = ((await isolateRequests[uuid]!.future) as List<TokenTransactionWithStatus>?) ?? null;
      isolateRequests.remove(uuid);
      return result;
    }

    final sparkAddress = await spark!.getSparkAddress();

    QueryTokenTransactionsResponse? response = null;
    List<TokenTransactionWithStatus> txList = [];
    while (response?.pageResponse.hasNextPage ?? true)  {
      response = await spark!.queryTokenTransactionsWithFilters(
        sparkAddresses: [sparkAddress],
        tokenIdentifiers: [btknId],
        pageSize: 50,
      );
      txList.addAll(response.tokenTransactionsWithStatus);
    }
    
    final key = Models.key.getUnique(walletId, id, "m/8797555'/1'/0'");
    final publicKey = key?.pubKey;

    // Get a list of incoming transactions sent to our public key
    final incomingTxList = txList.where((v) => 
      v.tokenTransaction.tokenOutputs.any((utxo) => hex.encode(utxo.ownerPublicKey) == publicKey)
    );

    // Flatten all inputs from those incoming transactions
    final inputs = incomingTxList.expand((v) => v.tokenTransaction.transferInput.outputsToSpend).toList();

    // Convert existing hashes to a Set for instant O(1) lookups
    final existingTxHashes = txList.map((v) => hex.encode(v.tokenTransactionHash)).toSet();

    // Find the inputs whose previous transactions are NOT in our list,
    // and map them directly to a unique list of hex hashes to fetch from the API.
    final missingTxHashesToFetch = inputs
      .map((v) => hex.encode(v.prevTokenTransactionHash))
      .where((hash) => !existingTxHashes.contains(hash)) // Added the missing '!' bang operator
      .toSet() // Using .toSet() ensures you don't call the API multiple times for the same transaction
      .toList();
    
    response = await spark!.queryTokenTransactionsByTxHashes(missingTxHashesToFetch);
    txList = [...response.tokenTransactionsWithStatus, ...txList];

    return txList;
  }

  @override
  Future<dynamic> callInternalFunction(String method, Map<String, dynamic> params) async {
    switch (method) {
      case "getTokenBalance":
        return await getTokenBalance(
          params["btknId"],
        );
      case "getTokenTransactions":
        return await  getTokenTransactions(
          params["btknId"],
        );
      case "transferToken":
        return await transferToken(
          params["btknId"],
          params["to"],
          params["amount"],
        );
      case "simulateSwap":
        return await simulateSwap(
          params["lPId"],
          params["currency0"],
          params["currency1"],
          params["amountIn"],
          zeroForOne: params["zeroForOne"],
        );
      case "executeSwap":
        return await executeSwap(
          poolId: params["poolId"],
          assetInAddress: params["assetInAddress"],
          assetOutAddress: params["assetOutAddress"],
          amountIn: params["amountIn"],
          maxSlippageBps: params["maxSlippageBps"],
          minAmountOut: params["minAmountOut"],
          integratorFeeRateBps: params["integratorFeeRateBps"],
          integratorPublicKey: params["integratorPublicKey"],
          useFreeBalance: params["useFreeBalance"],
          useAvailableBalance: params["useAvailableBalance"],
        );
      case "createTokensInvoice":
        return await createTokensInvoice(
          amount: params["amount"],
          tokenIdentifier: params["tokenIdentifier"],
          memo: params["memo"],
          senderSparkAddress: params["senderSparkAddress"],
          expiryTime: params["expiryTime"],
        );
      case "fulfillSparkInvoice":
        return await fulfillSparkInvoice(
          params["amount"],
          params["invoice"],
        );
      default:
        print("bitcoin.callInternalFunction unknown method ${method}");
    }
  }

  static String getAddressFromBytesBech32m(Uint8List address) {
    if (address.length > 255) {
      throw Exception("address should be less than 255 bytes");
    }
    String b = [0x0a, address.length, ...address].map((i) => i.toRadixString(2).padLeft(8, '0')).join();

    // Convert the binary string to a list of 5-bit integers
    List<int> valueList = [];
    int index = 0;
    int endIndex = 0;
    b = b.padRight((b.length / 5).ceil() * 5, "0");
    while (index < b.length) {
      endIndex = index + 5;
      valueList.add(int.parse(b.substring(index, endIndex), radix: 2));
      index += 5;
    }
    var bech32 = Bech32mCodec();
    var bech32Data = Bech32m("spark", valueList);
    String receivingAddress = bech32.encode(bech32Data);

    return receivingAddress;
  }

  List<int> extractPayeePublicKey(List<int> signature65, List<int> messageHash) {
    if (signature65.length != 65) {
      throw Exception("Invalid sig");
    }
    // 1. Separate the 64-byte R+S and the 1-byte Recovery ID
    final rAndS = signature65.sublist(0, 64);
    final recId = signature65.last;

    // 2. Create the signature object using the Secp256k1 generator
    // In blockchain_utils, this is usually CryptoSignerConst.generatorSecp256k1
    final sig = ECDSASignature.fromBytes(
      rAndS, 
      CryptoSignerConst.generatorSecp256k1
    );

    // 3. Call the instance method you found in your class
    final ECDSAPublicKey recoveredKey = sig.recoverPublicKey(
      messageHash,
      CryptoSignerConst.generatorSecp256k1,
      recId,
    );

    // 4. Return the compressed public key bytes
    return recoveredKey.point.toBytes();
  }

  Future<String?> transferToken(String btknId, String to, BigInt amount) async {
    if (isUIInstance) {
      final uuid = UUID.generateUUIDv4();
      isolateRequests[uuid] = Completer();
      getAssetIsolatePort().send(<String, dynamic>{
        "command": "callInternalFunction",
        "params": {"method":"transferToken", "params":{
          "btknId": btknId,
          "to": to,
          "amount": amount,
        }},
        "uuid": uuid,
      });
      
      final result = ((await isolateRequests[uuid]!.future) as String?) ?? null;
      isolateRequests.remove(uuid);
      return result;
    }

    final txHash = await spark!.transferTokens(
      tokenIdentifier: btknId,
      tokenAmount: amount,
      receiverSparkAddress: to,
    );

    return txHash;
  }

  Future<SimulateSwapResponse?> simulateSwap(String lPId, String currency0, String currency1, BigInt amountIn, {bool zeroForOne=true}) async {
    if (isUIInstance) {
      final uuid = UUID.generateUUIDv4();
      isolateRequests[uuid] = Completer();
      getAssetIsolatePort().send(<String, dynamic>{
        "command": "callInternalFunction",
        "params": {"method":"simulateSwap", "params":{
          "currency0": currency0,
          "currency1": currency1,
          "amountIn": amountIn,
          "lPId": lPId,
          "zeroForOne": zeroForOne,
        }},
        "uuid": uuid,
      });
      
      final result = ((await isolateRequests[uuid]!.future) as SimulateSwapResponse?) ?? null;
      isolateRequests.remove(uuid);
      return result;
    }

    await _initializeFlashnet();

    return _flashnetClient!.simulateSwap(SimulateSwapRequest(
      poolId: lPId,
      assetInAddress: zeroForOne ? currency0 :currency1,
      assetOutAddress: zeroForOne ? currency1 :currency0,
      amountIn: amountIn.toString(),
    ));
  }

  Future<SwapResponse?> executeSwap({
    required String poolId,
    required String assetInAddress,
    required String assetOutAddress,
    required String amountIn,
    required int maxSlippageBps,
    required String minAmountOut,
    int? integratorFeeRateBps,
    String? integratorPublicKey,
    bool? useFreeBalance,
    bool? useAvailableBalance,
  }) async {
    if (isUIInstance) {
      final uuid = UUID.generateUUIDv4();
      isolateRequests[uuid] = Completer();
      getAssetIsolatePort().send(<String, dynamic>{
        "command": "callInternalFunction",
        "params": {"method":"executeSwap", "params":{
          "poolId": poolId,
          "assetInAddress": assetInAddress,
          "assetOutAddress": assetOutAddress,
          "amountIn": amountIn,
          "maxSlippageBps": maxSlippageBps,
          "minAmountOut": minAmountOut,
          "integratorFeeRateBps": integratorFeeRateBps,
          "integratorPublicKey": integratorPublicKey,
          "useFreeBalance": useFreeBalance,
          "useAvailableBalance": useAvailableBalance,
        }},
        "uuid": uuid,
      });
      
      final result = ((await isolateRequests[uuid]!.future) as SwapResponse?) ?? null;
      isolateRequests.remove(uuid);
      return result;
    }

    await _initializeFlashnet();

    try {
      final response = await _flashnetClient!.executeSwap(
        poolId: poolId,
        assetInAddress: assetInAddress,
        assetOutAddress: assetOutAddress,
        amountIn: amountIn,
        maxSlippageBps: maxSlippageBps,
        minAmountOut: minAmountOut
      );
      return response.response;
    } catch (e) {
      debugPrint("executeSwap failed: ${e}");
      return null;
    }
  }

  Future<FulfillSparkInvoiceResponse?> fulfillSparkInvoice(BigInt? amount, String invoice) async {
    if (isUIInstance) {
      final uuid = UUID.generateUUIDv4();
      isolateRequests[uuid] = Completer();
      getAssetIsolatePort().send(<String, dynamic>{
        "command": "callInternalFunction",
        "params": {"method":"fulfillSparkInvoice", "params":{
          "amount": amount,
          "invoice": invoice,
        }},
        "uuid": uuid,
      });
      
      final result = ((await isolateRequests[uuid]!.future) as FulfillSparkInvoiceResponse?) ?? null;
      isolateRequests.remove(uuid);
      return result;
    }

    try {
      final response = await spark!.fulfillSparkInvoice([(amount: amount, invoice: invoice)]);
      return response;
    } catch (e, stack) {
      debugPrint("fulfillSparkInvoice failed: ${e} $stack");
      return null;
    }
  }

  Future<String> createTokensInvoice({
    BigInt? amount,
    String? tokenIdentifier,
    String? memo,
    String? senderSparkAddress,
    DateTime? expiryTime,
  }) async {
    if (isUIInstance) {
      final uuid = UUID.generateUUIDv4();
      isolateRequests[uuid] = Completer();
      getAssetIsolatePort().send(<String, dynamic>{
        "command": "callInternalFunction",
        "params": {"method":"createTokensInvoice", "params":{
          "amount": amount,
          "tokenIdentifier": tokenIdentifier,
          "memo": memo,
          "senderSparkAddress": senderSparkAddress,
          "expiryTime": expiryTime,
        }},
        "uuid": uuid,
      });
      
      final result = ((await isolateRequests[uuid]!.future) as String?) ?? "";
      isolateRequests.remove(uuid);
      return result;
    }

    try {
      final response = await spark!.createTokensInvoice(
        amount: amount,
        tokenIdentifier: tokenIdentifier,
        memo: memo,
        senderSparkAddress: senderSparkAddress,
        expiryTime: expiryTime,
      );
      return response;
    } catch (e) {
      debugPrint("createTokensInvoice failed: ${e}");
      return "";
    }
  }

  Future<void> _initializeFlashnet() async {
    if (_flashnetReady.isCompleted) {
      return;
    }
    await sparkReady.future;
    _flashnetClient = new FlashnetClient.withConfig(spark!, FlashnetClientConfig(
      sparkNetworkType: SparkNetworkTypes.mainnet,
      clientConfig: "mainnet",
    ));

    await _flashnetClient!.initialize();
    _flashnetReady.complete();
  }

  void onTokenTransaction(String btknId, void Function() handler) {
    _tokenTransactionHandler.putIfAbsent(btknId, () => []).add(handler);
  }
}
