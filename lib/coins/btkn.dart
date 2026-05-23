import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:collection/collection.dart';
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
import 'package:tejory/api_keys/api_keys.dart';
import 'package:tejory/coins/bitcoin_tx.dart';
import 'package:tejory/coins/const.dart';
import 'package:tejory/coins/crypto_coin.dart';
import 'package:tejory/coins/network.dart';
import 'package:tejory/coins/psbt.dart';
import 'package:tejory/coins/pst.dart';
import 'package:tejory/coins/spark_btc.dart';
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

import 'ether_tx.dart';

class BTKN extends CryptoCoin {
  late Wallet wallet;
  String? extendedPrivateKey;
  bool stayConnected = true;
  bool connected = false;
  final Mutex txListMutex = Mutex();
  late SparkBTC spark;
  late String? btknId;
  

  BTKN(
    int walletId, {
    required WalletType walletType,
    required List<int> magic,
    required int port,
    required String peerSeedType,
    required String peerSource,
    int? coinId,
    String? netVersionPublicHex,
    String? netVersionPrivateHex,
    String? this.btknId,
    required int decimals,
    String? coinName,
    String? coinSymbol,
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
    
    // await main spark wallet to be initialized
    spark = (Singleton.assetList.assetListState.findAsset("SPKBTC")!.coins[0] as SparkBTC);
    await spark.sparkReady.future;

    connect();
    () async {
      getTxListFromAPI(showNotifications: !Singleton.initialSetup);
      connected = true;
      setIsConnected(connected);
      spark.onTokenTransaction(btknId!, () async {
        var newBalance = await getBalanceFromAPI();
        if (newBalance != null) {
          if (balance != newBalance) {
            balance = newBalance;
            saveBalance();
            getTxListFromAPI();
            notifyListeners();
          }
        }
      });
    }();
    notifyListeners();
  }

  @override
  Future<BigInt> calculateFee(
    String toAddress,
    BigInt amount, {
    noChange = false,
  }) async { 
    return BigInt.zero;
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
    return BigInt.from((val * pow(10, decimals)).round());
  }

  @override
  String getDecimalAmount(BigInt val) {
    return (val.toDouble() / pow(10, decimals)).toStringAsFixed(decimals);
  }

  @override
  List<String> getInitialDerivationPaths() {
    return [];
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
    switch (network) {
      case ("SPKBTC"):
      // return await spark.createTokensInvoice(tokenIdentifier: btknId!, memo: "terminal 1");
        return await spark.getReceivingAddress(network: network, amount: amount);
      case ("SPKBTCI"): // Spark Invoice
        if (amount == null) {
          return "";
        }
        return await spark.createTokensInvoice(tokenIdentifier: btknId! ,amount: amount);
      default:
        return "";
    }
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
    DecodedSparkAddressData? sparkAddress;
    try {
      sparkAddress = decodeSparkAddress(toAddress);
    } catch (_) {}

    if (sparkAddress != null && sparkAddress.sparkInvoiceFields == null) {
      final txHash = await spark.transferToken(btknId!, toAddress, amount);
      if (txHash == null) {
        return null;
      }
    } else if (sparkAddress != null && sparkAddress.sparkInvoiceFields?.paymentType?.type == "tokens") {
      final result = await spark.fulfillSparkInvoice(amount, toAddress);
      if (result == null) {
        return null;
      }
      if (result.tokenTransactionSuccess.length != 1) {
        debugPrint("Error in fulfillSparkInvoice for tokens. invalidInvoices: ${result.invalidInvoices}, tokenTransactionErrors: ${result.tokenTransactionErrors}");
        return null;
      }
    } else {
      return null;
    }

    var tx = BitcoinTx();
    return tx;
  }

  @override
  Future<Map<String, dynamic>?> sendTxBytes(Uint8List tx) async {
    return {};
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
    Map<String, VisualTx> txMap = {};
    List<VisualTx> vTxList = [];

    txDBList.forEach((tx) {
      if (txMap[tx.hash] == null) {
        txMap[tx.hash!] = VisualTx();
        txMap[tx.hash!]!.time = tx.time!;
        txMap[tx.hash!]!.fee = tx.fee!;
        txMap[tx.hash!]!.usdAmount = tx.usdAmount;
      } else if (txMap[tx.hash]!.time == null) {
        txMap[tx.hash!]!.time = tx.time!;
        txMap[tx.hash!]!.fee = tx.fee!;
        txMap[tx.hash!]!.usdAmount = tx.usdAmount;
      }

      if (tx.spendingTxHash != null) {
        if (txMap[tx.spendingTxHash] == null) {
          txMap[tx.spendingTxHash!] = VisualTx();
          txMap[tx.spendingTxHash!]!.time = null;
        }
        txMap[tx.spendingTxHash]!.spentAmount += tx.amount!;
        txMap[tx.spendingTxHash]!.amount =
            txMap[tx.spendingTxHash]!.earnedAmount -
            txMap[tx.spendingTxHash]!.spentAmount;
        txMap[tx.spendingTxHash]!.isDeposit =
            txMap[tx.spendingTxHash]!.amount > 0;
      }

      if (tx.isDeposit!) {
        txMap[tx.hash!]!.earnedAmount += tx.amount!;
        txMap[tx.hash!]!.inAddress = tx.lockingScript!;
      } else {
        txMap[tx.hash!]!.outAddress = tx.lockingScript!;
      }
      txMap[tx.hash!]!.amount =
          txMap[tx.hash!]!.earnedAmount - txMap[tx.hash]!.spentAmount;
      txMap[tx.hash!]!.isDeposit = txMap[tx.hash!]!.amount > 0;
    });

    for (var tx in txMap.values) {
      if (!tx.isDeposit) {
        tx.amount += tx.fee;
      }
      vTxList.add(tx);
    }

    return vTxList;
  }

  Future<BigInt?> getBalanceFromAPI() async {
    try{
      final response = await spark.getTokenBalance(btknId!);
      return response;
    } catch (e) { return null; }
  }

  Future<void> connect() async {
    bool firstPass = true;
    // streamEvents();
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
      Map<String, Map<int, ({BigInt amount, String publicKey})>> utxoSet = {};
      // Models.txDB.delete(q: TxDB_.wallet.equals(walletId) & TxDB_.coin.equals(id!));
      try {
        final response = await spark.getTokenTransactions(btknId!);
        if (response == null) {
          return null;
        }

        // build the UTXO set
        for (final item in response) {
          for (final (index, output) in item.tokenTransaction.tokenOutputs.indexed) {
            utxoSet
              .putIfAbsent(hex.encode(item.tokenTransactionHash), ()=>{})
              [index] = (amount: bytesToBigInt(output.tokenAmount), publicKey: hex.encode(output.ownerPublicKey));
          }
        }

        final key = Models.key.getUnique(walletId, spark.id, "m/8797555'/1'/0'");
        final publicKey = key?.pubKey;
        // bool haveOutputs = false;
        for (final (itemIndex, item) in response.indexed) {
          // if (Models.txDB.getUnique(id, hex.encode(item.tokenTransactionHash), 0) != null) {
          //   continue;
          // }

          // haveOutputs = item.tokenTransaction.tokenOutputs.any((v)=>hex.encode(v.ownerPublicKey)==publicKey);

          // first we scan outputs
          final time = item.tokenTransaction.clientCreatedTimestamp.toDateTime();
          // Assuming the all inputs has the same owner, we use only the first input
          final inputTxHash = item.tokenTransaction.transferInput.outputsToSpend.elementAtOrNull(0)?.prevTokenTransactionHash ?? null;
          final inputVOut = item.tokenTransaction.transferInput.outputsToSpend.elementAtOrNull(0)?.prevTokenTransactionVout ?? 0;
          final lockingScriptBytes = inputTxHash != null ? (utxoSet[hex.encode(inputTxHash)]?[inputVOut]?.publicKey ?? null) : null;

          // extract memo data
          final sparkInvoice = item.tokenTransaction.invoiceAttachments.elementAtOrNull(0)?.sparkInvoice ?? null;
          final memo = sparkInvoice != null ? decodeSparkAddress(sparkInvoice).sparkInvoiceFields?.memo ?? "" : "";

          if (itemIndex == response.length-1) {
            print("last");
          }

          // build final lockingScript for incoming transactions
          String lockingScript = lockingScriptBytes == null
            ? "Unknown"
            : getAddressFromBytesBech32m(Uint8List.fromList(hex.decode(lockingScriptBytes)));
          lockingScript += memo == "" ? "" : "\n$memo";

          for (final (index, output) in item.tokenTransaction.tokenOutputs.indexed) {
            // skip in this is not our UTXO
            if (hex.encode(output.ownerPublicKey) != publicKey) {
              continue;
            }
            
            if (Models.txDB.getUnique(id, hex.encode(item.tokenTransactionHash), index) != null) {
              continue;
            }

            // I'm assuming the second output is the change from the sender
            // final lockingScript = item.tokenTransaction.tokenOutputs.elementAtOrNull(1)?.ownerPublicKey ?? "NA".codeUnits;
            
            final amount = bytesToBigInt(output.tokenAmount);
            final tx = TxDB();
            tx.hash = hex.encode(item.tokenTransactionHash);
            tx.coin = id;
            tx.amount = amount.toInt();
            tx.blockHash = "";
            tx.confirmed = true;
            tx.failed = false;
            tx.fee = 0;
            tx.isDeposit = true;
            tx.lockingScript = lockingScript;
            tx.outputIndex = index;
            tx.time = time;
            tx.verified = true;
            tx.wallet = walletId;

            await tx.save();
            if (showNotifications && !Singleton.initialSetup) {
              sendNotification(tx);
            }
          }

          // now we scan the inputs
          for (final (index, input) in item.tokenTransaction.transferInput.outputsToSpend.indexed) {
            if (Models.txDB.getUnique(id, hex.encode(item.tokenTransactionHash),  -1-index) != null) {
              continue;
            }

            final txHash = hex.encode(input.prevTokenTransactionHash);
            final utxo = utxoSet[txHash]?[input.prevTokenTransactionVout];
            if (utxo == null) {
              continue;
            }
            if (utxo.publicKey != publicKey) {
              continue;
            }

            final spentTx = Models.txDB.getUnique(id, hex.encode(input.prevTokenTransactionHash), input.prevTokenTransactionVout);
            spentTx?.spent = true;
            spentTx?.spendingTxHash = hex.encode(item.tokenTransactionHash);
            spentTx?.save();
            
            
            // I'm assuming the address in the first output in the receiver
            final lockingScriptBytes = item.tokenTransaction.tokenOutputs.elementAtOrNull(0)?.ownerPublicKey ?? null;
            String lockingScript = lockingScriptBytes == null ? "Unknown" : getAddressFromBytesBech32m(Uint8List.fromList(lockingScriptBytes));
            lockingScript += memo == "" ? "" : "\n$memo";
            
            final tx = TxDB();
            tx.hash = hex.encode(item.tokenTransactionHash);
            tx.coin = id;
            tx.amount = utxo.amount.toInt();
            tx.blockHash = "";
            tx.confirmed = true;
            tx.failed = false;
            tx.fee = 0;
            tx.isDeposit = false;
            tx.lockingScript = lockingScript;
            tx.outputIndex = -1-index;
            tx.time = time;
            tx.verified = true;
            tx.wallet = walletId;
            await tx.save();
            if (showNotifications && !Singleton.initialSetup) {
              sendNotification(tx);
            }

            // utxoSet[hex.encode(input.prevTokenTransactionHash)]!.remove(input.prevTokenTransactionVout);
          }
        }
        
      } catch (e) {
        return null;
      }

      
      return null;
    });
  }

  Future<String> getTxLockingscript(WalletTransfer transfer) async {
    final isDeposit = transfer.transferDirection.value == "INCOMING";

    if (transfer.userRequest case LightningSendRequest request) {
      final invoice = decodeInvoice(request.encodedInvoice);
      final payeePublicKey = await getPublicKeyHexFromSig(invoice.signature);
      return await getLightningNodeName(payeePublicKey);
    } else if (transfer.userRequest case LightningReceiveRequest _) {
      return "Lightning ⚡️";
    }

    return isDeposit
      ? transfer.senderIdentityPublicKey
      : transfer.receiverIdentityPublicKey;
  }

  Future<String> getPublicKeyHexFromSig(List<int>? sig) async {
    return "";
  }

  Future<String> getLightningNodeName(String publicKeyHex) async {
  //   if (publicKeyHex.isEmpty) {
  //     return "Lightning ⚡️";
  //   }
  //   if (lnNodeAliases.containsKey(publicKeyHex)) {
  //     return lnNodeAliases[publicKeyHex]!;
  //   }
  //   final URL = "https://1ml.com/node/${publicKeyHex}/json";
  //   try {
  //     final response = await http.get(Uri.parse(URL)).timeout(Duration(seconds: 5));
  //     final obj = jsonDecode(response.body) as Map<String, dynamic>;
  //     if (obj["alias"] != null) {
  //       lnNodeAliases[publicKeyHex] = obj["alias"] as String;
  //     }
  //     return obj["alias"] ?? "Lightning ⚡️";
  //   } catch (e) {
  //     print(e);
  //   }
    
    return "Lightning ⚡️";
  }

  Future<void> streamEvents() async {
    // spark!.onBalanceUpdate((BalanceUpdateData data) async {
    //   final newBalance = data.available;
    //   if (newBalance != balance) {
    //     balance = newBalance;
    //     await getTxListFromAPI();
    //     notifyListeners();
    //   }
    // });
    // spark!.onDepositConfirmed((_,_) async {
    //     await getTxListFromAPI();
    //     notifyListeners();
    // });
    // spark!.onTransferClaimed((_,_) async {
    //     await getTxListFromAPI();
    //     notifyListeners();
    // });
    // spark!.onStreamConnected(() {
    //   setIsConnected(true);
    // });
    // spark!.onStreamDisconnected((_) {
    //   setIsConnected(false);
    // });
    // spark!.onStreamReconnecting((_,_,_,_) {
    //   setIsConnected(false);
    // });
  }

  bool isValidAddress(String address) {
    DecodedSparkAddressData? sparkAddress;
    try {
      sparkAddress = decodeSparkAddress(address);
    } catch (_) {}

    if (
      (sparkAddress != null && sparkAddress.sparkInvoiceFields == null) ||
      (sparkAddress != null && sparkAddress.sparkInvoiceFields?.paymentType?.type == "tokens")
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
    return "https://etherscan.io/tx/0x${txHash}";
  }

  @override
  List<Network> getNetworks({String? address}) {
    DecodedSparkAddressData? sparkAddress;
    try {
      sparkAddress = address != null ? decodeSparkAddress(address) : null;
    } catch (_) {}

    var networkList = [
      if (address == null || (sparkAddress != null && sparkAddress.sparkInvoiceFields == null)) Network("SPKBTC", "Spark"),
      if (address == null || (sparkAddress != null && sparkAddress.sparkInvoiceFields?.paymentType?.type == "tokens")) Network("SPKBTCI", "Spark Invoice", requiresAmount:true),
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

  BigInt bytesToBigInt(List<int> bytes) {
    BigInt result = BigInt.zero;
    
    for (final byte in bytes) {
      // Shift the current result left by 8 bits and add the new byte
      result = (result << 8) | BigInt.from(byte);
    }
    
    return result;
  }

  void main() {
    // Example: 0x0102 (which is 258 in decimal)
    List<int> bigEndianBytes = [1, 2]; 
    
    BigInt number = bytesToBigInt(bigEndianBytes);
    print(number); // Outputs: 258
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

  String? getBTKNHex() {
    if (btknId == null) {
      return null;
    }

    final b32 = bech32mDecode(btknId!);
    
    // Convert 5-bit words to 8-bit bytes (equivalent to your MagicallyChange function)
    final dataBytes = _convertBits(b32.data, 5, 8, false);
    
    return hex.encode(dataBytes);
  }

  /// Helper function to handle bit-width conversion (BIP-173 standard)
  List<int> _convertBits(List<int> data, int fromBits, int toBits, bool pad) {
    var acc = 0;
    var bits = 0;
    final ret = <int>[];
    final maxv = (1 << toBits) - 1;

    for (var value in data) {
      if (value < 0 || (value >> fromBits) != 0) {
        throw FormatException('Invalid value encountered during bit conversion: $value');
      }
      acc = (acc << fromBits) | value;
      bits += fromBits;
      while (bits >= toBits) {
        bits -= toBits;
        ret.add((acc >> bits) & maxv);
      }
    }

    if (pad) {
      if (bits > 0) {
        ret.add((acc << (toBits - bits)) & maxv);
      }
    } else if (bits >= fromBits || ((acc << (toBits - bits)) & maxv) != 0) {
      throw FormatException('Invalid padding remaining after bit conversion');
    }

    return ret;
  }
}
