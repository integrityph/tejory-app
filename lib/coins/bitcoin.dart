import 'dart:convert';
import 'dart:math';
import 'package:bech32/bech32.dart';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:dnsolve/dnsolve.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:murmur3/murmur3.dart';
import 'package:tejory/coins/bitcoin_tx_out.dart';
import 'package:tejory/coins/bitcoin_block.dart';
import 'package:tejory/coins/btc_helper.dart';
import 'package:tejory/coins/const.dart';
import 'package:tejory/coins/psbt.dart';
import 'package:tejory/coins/pst.dart';
import 'package:tejory/coins/bitcoin_tx.dart';
import 'package:tejory/coins/bitcoin_tx_in.dart';
import 'package:tejory/coins/tx.dart';
import 'package:tejory/coins/visual_tx.dart';
import 'package:tejory/coins/wallet.dart';
import 'package:tejory/collections/balance.dart';
import 'package:tejory/collections/block.dart';
import 'package:tejory/collections/key.dart' as keyCollection;
import 'package:tejory/collections/next_key.dart';
import 'package:tejory/collections/tx.dart';
import 'package:tejory/collections/walletDB.dart';
import 'package:tejory/crypto-helper/bech32m.dart';
import 'package:tejory/crypto-helper/hd_wallet.dart';
import 'package:tejory/crypto-helper/other_helpers.dart';
import 'package:tejory/singleton.dart';
import 'package:tejory/wallets/iwallet.dart';
import 'package:tejory/wallets/tejorycard/bitcoin_applet.dart';
import 'crypto_coin.dart';
import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'dart:io';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';
import 'dart:collection';
import 'package:mutex/mutex.dart';
import 'package:http/http.dart' as http;

class Bitcoin extends CryptoCoin {
  // String? __mnemonicSeed;
  // Uint8List __seed = Uint8List(0);
  String? extendedPrivateKey;
  final BTC_PROTOCOL_VERSION = Constants.BTC_PROTOCOL_VERSION;
  // late List<int> magic;
  List<Uint8List> addressList = [];
  String hrp = "bc";

  Socket? socket;
  Uint8List buffer = Uint8List(0);
  final int MIN_FILTER_BYTES = 12;
  final int MAX_FILTER_BYTES = 36000;
  final int MAX_HASH_FUNCS = 50;
  final int EXTERNAL_INDEX = 0;
  final int INTERNAL_INDEX = 1;
  int numHashFuncs = 2;
  Map<String, String> pubKeyAddressMap = {};
  Map<String, String> pubKeyAddressPathMap = {};
  Map<String, String> txBlockHash = {};
  Queue<String> blockChain = Queue<String>();
  Queue<Tuple<String, DateTime>> blockTimestamp =
      Queue<Tuple<String, DateTime>>();
  Map<String, BitcoinTxOut> utxoSet = {};

  final int MAX_BLOCKS = 3;
  String _keyFingerprint = "";
  int _remainingBlockCount = 0;
  int remainingTxCount = 0;
  final mutex = Mutex();
  final counterMutex = Mutex();
  final msgMutex = Mutex();
  final heightMutex = Mutex();
  bool getBlocks = false;
  String currentPeerIP = "";
  int loopId = 0;
  int dnsShuffle = 0;
  bool handshakeCompleted = false;
  late Wallet wallet;
  int tipHeight = 0;
  DateTime tipTimestamp = DateTime.now();
  BuildContext? context;
  List<Uint8List> unsendTx = [];
  int connectionId = 0;
  double cachedFee = 2.0;
  DateTime cachedFeeExpiry = DateTime.now().subtract(Duration(minutes: 1));
  static final int FEE_CACHE_MAX_AGE = 1;
  static const String DEFAULT_TX_TYPE = "P2WPKH";
  Map<String, int> lastAddedIndex = {};
  bool utxoSetChanged = false;

  Bitcoin(
    int walletId, {
    required WalletType walletType,
    required List<int> magic,
    required int port,
    required String peerSeedType,
    required String peerSource,
    int? coinId,
    String? netVersionPublicHex,
    String? netVersionPrivateHex,
  }) : super.newCoin("Bitcoin", "BTC", 8) {
    super.port = port;
    super.id = coinId;
    super.peerSource = peerSource;
    super.peerSeedType = peerSeedType;
    super.walletType = walletType;
    super.magic = magic;
    super.walletId = walletId;
    super.netVersionPublicHex = netVersionPublicHex;
    super.netVersionPrivateHex = netVersionPrivateHex;
    wallet = Wallet(id: walletId);
  }

  void initCoin({List<Block>? blocks, List<TxDB>? txList, Balance? balanceDB}) {
    if (balanceDB != null && balanceDB.coinBalance != null) {
      balance = BigInt.from(balanceDB.coinBalance!);
    }
    if (isUIInstance) {
      getAssetIsolatePort().send(<String, dynamic>{
        "command": "initCoin",
        "params": {"blocks": blocks, "txList": txList, "balanceDB": balanceDB},
      });
      return;
    }
    if (balanceDB != null) {
      if (balanceDB.lastBlockUpdate != null) {
        blockChain.add(
          String.fromCharCodes(
            hex.decode(balanceDB.lastBlockUpdate!).reversed.toList(),
          ),
        );
      }
    }

    utxoSet = {};

    // run getPublicKeyHashes to calculate the addresses with the public keys
    getPublicKeyHashes(refresh: true);

    // for (int i=0; i<addressList.length; i++) {
    //   print("${hex.encode(addressList[i])}: ${pubKeyAddressPathMap[String.fromCharCodes(addressList[i])]}");
    // }

    // populate utxoSet
    txList?.forEach((txdb) {
      if ((txdb.spent ?? true) == true ||
          ((txdb.isDeposit ?? false) == false)) {
        return;
      }
      if ((txdb.failed ?? false) == true ||
          ((txdb.verified ?? true) == false)) {
        return;
      }
      BitcoinTxOut utxo = BitcoinTxOut(); // make new bitcointxout
      // populate utxo
      utxo.value = BigInt.from(txdb.amount!);
      utxo.scriptPubKey = Uint8List.fromList(hex.decode(txdb.lockingScript!));

      if (utxo.getPubKeyScriptType() == "P2TR") {
        utxo.pubKey = Uint8List.fromList(utxo.getAddress());
      } else {
        utxo.pubKey = Uint8List.fromList(
          pubKeyAddressMap[String.fromCharCodes(utxo.getAddress())]!.codeUnits,
        );
      }

      utxo.txHash = Uint8List.fromList(hex.decode(txdb.hash!));
      utxo.index = txdb.outputIndex!;
      utxo.spent = txdb.spent!;
      var buf = Uint8List(4)
        ..buffer.asByteData().setUint32(0, utxo.index, Endian.little);
      utxoSet['${txdb.hash!}${hex.encode(buf)}'] = utxo;
      utxoSetChanged = true;
    });

    notifyListeners();
    _setupPrivateKey();

    // recalculate height
    () async {
      calculateHeight().then((void x) async {
        // start a connection in a separate thread
        connect();
      });
    }();

    // get the current fee rate
    () async {
      getFeeFromAPI();
    }();
  }

  @override
  BigInt getBalance() {
    if (isUIInstance) {
      return balance;
    }
    BigInt total = BigInt.zero;
    utxoSet.keys.forEach((key) {
      if (utxoSet[key]!.spent) {
        return;
      }
      total += utxoSet[key]!.value;
    });
    return total;
  }

  @override
  void callInternalFunction(String method, Map<String, dynamic> params) {
    switch (method) {
      case "getPublicKeyHashes":
        getPublicKeyHashes(
          refresh: params["refresh"],
          externalGap: params["externalGap"],
          internalGap: params["internalGap"],
        );
      default:
        print("bitcoin.callInternalFunction unknown method ${method}");
    }
  }

  List<Uint8List> getPublicKeyHashes({
    bool? refresh = false,
    int? externalGap = 20,
    int? internalGap = 20,
    bool? refreshBloomFilters = false,
  }) {
    refresh = refresh ?? false;
    externalGap = externalGap ?? 20;
    internalGap = internalGap ?? 20;
    refreshBloomFilters = refreshBloomFilters ?? false;
    if (isUIInstance) {
      getAssetIsolatePort().send(<String, dynamic>{
        "command": "callInternalFunction",
        "params": {
          "method": "getPublicKeyHashes",
          "params": {
            "refresh": refresh,
            "externalGap": externalGap,
            "internalGap": internalGap,
            "refreshBloomFilters": refreshBloomFilters,
          },
        },
      });
      return [];
    }
    if (addressList.isNotEmpty && !refresh) {
      return addressList;
    }
    // DONE: scan through the HD wallet and get all BTC addresses
    // addressList = [];
    Uint8List pubKey = Uint8List(0);
    Uint8List pubKeyHash = Uint8List(0);
    String path = "";
    List<String> scanAddressTypeList = ["P2PKH", "P2WPKH", "P2TR"];
    for (var addressType in scanAddressTypeList) {
      for (int change = 0; change < 2; change++) {
        var purpose = getPurposeByAddressType(addressType);
        path = "m/$purpose'/0'/0'/$change";
        int lastIndex = (change == 0) ? externalGap : internalGap;
        NextKey? nextKey = Singleton.isar!.nextKeys.getByPathCoinWalletSync(
          path,
          id,
          walletId,
        );
        if (nextKey != null && nextKey.nextKey != null) {
          lastIndex += nextKey.nextKey!;
        }
        int? startIndex = lastAddedIndex[path];
        if (startIndex == null) {
          startIndex = 0;
        }
        for (int index = startIndex + 1; index < lastIndex; index++) {
          pubKey = getPublicKey("$path/$index");
          lastAddedIndex[path] = index;
          if (addressType == "P2TR") {
            pubKey = tweakPublicKey(pubKey);
            // var addHex = hex.encode(pubKey);
            // print("m/${purpose}'/0'/0'/$change/$index - $addHex");
            addressList.add(pubKey);
            pubKeyAddressPathMap[String.fromCharCodes(pubKey)] =
                "m/${purpose}'/0'/0'/$change/$index";
            pubKeyAddressMap[String.fromCharCodes(
              pubKey,
            )] = String.fromCharCodes(pubKey);
          } else {
            addressList.add(pubKey);
            pubKeyHash = getAddress(addressList.last, addressType);
            addressList.add(pubKeyHash);
            // print("m/${purpose}'/0'/0'/$change/$index - ${getAddressFromBytes(pubKeyHash)}");
            pubKeyAddressMap[String.fromCharCodes(
              pubKeyHash,
            )] = String.fromCharCodes(pubKey);
            pubKeyAddressPathMap[String.fromCharCodes(pubKeyHash)] =
                "m/${purpose}'/0'/0'/$change/$index";
            pubKeyAddressPathMap[String.fromCharCodes(pubKey)] =
                "m/${purpose}'/0'/0'/$change/$index";
          }
        }
      }
    }

    if (refreshBloomFilters) {
      () async {
        Uint8List payload = await msgFilterLoad(addressList);
        sendMessage(makeMsg('filterload', payload));
      }();
    }

    return addressList;
  }

  Future<String> getPeer() async {
    if (peerList.isEmpty) {
      if (peerSeedType == "fixed") {
        peerList = peerSource.split(",");
      } else if (peerSeedType == "dns") {
        peerList += await getPeersFromDNS();
      } else {
        print("peerSeedType: ($peerSeedType) is unknown");
      }
    }
    if (peerList.isEmpty) {
      return "";
    }
    return peerList[(new Random()).nextInt(peerList.length)];
  }

  Future<List<String>> getPeersFromDNS() async {
    var dnsList = peerSource.split(",");
    final dnsolve = DNSolve();
    ResolveResponse response;
    const MAX_ERROR = 10;
    List<String> peerIPs = [
      "103.101.44.30",
      "103.101.44.30",
      "103.101.44.30",
      "103.101.44.30",
      "103.101.44.30",
      "103.101.44.30",
      "103.101.44.30",
      "103.101.44.30",
      "103.101.44.30",
      "103.101.44.30",
    ];
    for (int i = 0 + dnsShuffle; i < MAX_ERROR + dnsShuffle; i++) {
      try {
        response = await dnsolve.lookup(
          dnsList[i % dnsList.length],
          dnsSec: true,
          type: RecordType.A,
          provider:
              [DNSProvider.google, DNSProvider.cloudflare][dnsShuffle % 2],
        );
        dnsShuffle++;
        if (response.answer?.records != null &&
            response.answer?.records?.length != 0) {
          for (final record in response.answer!.records!) {
            peerIPs.add(record.data);
          }
          break;
        }
      } catch (Exception) {
        await Future.delayed(Duration(seconds: 1));
      }
    }
    return peerIPs;
  }

  Future<void> resetState() async {
    disconnect();
    await calculateHeight();
    handshakeCompleted = false;
    var isar = Singleton.getDB();
    var blocks =
        isar.blocks
            .filter()
            .coinEqualTo(id)
            .sortByHeightDesc()
            .limit(1)
            .findAllSync();
    for (var i = 0; i < blocks.length; i++) {
      var block = blocks[i];
      if (block.height != null && block.hash != null) {
        if (i == 0) {
          blockChain.clear();
          tipHeight = blocks[0].height!;
          if (blocks[0].time != null) {
            tipTimestamp = blocks[0].time!;
          }
          if (block.previousHash != null) {
            blockChain.add(
              String.fromCharCodes(
                hex.decode(block.previousHash!).reversed.toList(),
              ),
            );
          }
          blockChain.add(
            String.fromCharCodes(hex.decode(block.hash!).reversed.toList()),
          );
        } else {
          blockChain.add(
            String.fromCharCodes(hex.decode(block.hash!).reversed.toList()),
          );
        }
      }
    }

    currentPeerIP = "";
    txBlockHash = {};
    blockTimestamp = Queue<Tuple<String, DateTime>>();
    setIsConnected(false);
    _remainingBlockCount = 0;
    remainingTxCount = 0;
    try {
      await mutex.acquire();
      mutex.release();
    } catch (e) {}
    try {
      await counterMutex.acquire();
      counterMutex.release();
    } catch (e) {}
    try {
      await msgMutex.acquire();
      buffer = Uint8List(0);
      msgMutex.release();
    } catch (e) {}
    getBlocks = false;
  }

  Future<bool> connect({String? ip}) async {
    if (!online) {
      return false;
    }
    int currentTime = loopId;
    loopId++;
    await resetState();
    const MAX_ERROR = 25;
    String serverIp = "";
    for (int i = 0; i < MAX_ERROR; i++) {
      serverIp = ip ?? await getPeer();
      if (serverIp == "") {
        continue;
      }
      try {
        currentPeerIP = serverIp;
        print("$currentTime connecting to $currentPeerIP:$port ${e}");
        socket = await Socket.connect(
          serverIp,
          port,
          timeout: Duration(seconds: 2),
        );
        setIsConnected(true);
        break;
      } catch (e) {
        print("Unable to connect to $currentPeerIP:$port ${e}");
        print("Removing $currentPeerIP:$port from peerList");
        peerList.remove(currentPeerIP);
        if (i == MAX_ERROR) {
          return false;
        }
      }
    }
    if (!isConnected) {
      connect();
      return false;
    }
    connectionId++;
    addSocketListener();
    updateBalance();
    return true;
  }

  Uint8List makeMsg(String command, Uint8List payload, {List<int>? magicP}) {
    magicP ??= magic;
    Uint8List cmd = Uint8List.fromList(
      (command + '\x00' * (12 - command.length)).codeUnits,
    );
    Uint8List payloadSize = Uint8List(4)
      ..buffer.asByteData().setUint32(0, payload.length, Endian.little);
    Uint8List checksum = Uint8List.fromList(
      sha256.convert(sha256.convert(payload).bytes).bytes.sublist(0, 4),
    );
    Uint8List msg = Uint8List.fromList(
      magicP + cmd + payloadSize + checksum + payload,
    );
    return msg;
  }

  Uint8List concatenateBlocks(List<Uint8List> blocks) {
    Uint8List buf = Uint8List(32 * blocks.length);

    for (int i = 0; i < blocks.length; i++) {
      buf.setRange(i * 32, (i + 1) * 32, blocks[i]);
    }
    return buf;
  }

  Uint8List msgGetBlocks() {
    getBlocks = true;
    List<Uint8List> blocks = [];
    for (var block in blockChain) {
      blocks.add(Uint8List.fromList(block.codeUnits));
      // print("value.codeUnits: ${hex.encode(block.codeUnits.reversed.toList())}");
    }
    // blockChain.forEach((value) {
    //   blocks.add(Uint8List.fromList(value.codeUnits));
    //   print("value.codeUnits: ${hex.encode(value.codeUnits)}");
    // });

    Uint8List version = Uint8List(4)
      ..buffer.asByteData().setUint32(0, BTC_PROTOCOL_VERSION, Endian.little);
    Uint8List hashCount = makeVarint(BigInt.from(blocks.length));
    Uint8List blockHeaderHashes = concatenateBlocks(blocks.reversed.toList());
    Uint8List stopHash = Uint8List(32);

    Uint8List payload = Uint8List.fromList(
      version + hashCount + blockHeaderHashes + stopHash,
    );
    return payload;
  }

  Uint8List msgVersion() {
    Uint8List version = Uint8List(4)
      ..buffer.asByteData().setUint32(0, BTC_PROTOCOL_VERSION, Endian.little);
    Uint8List services = Uint8List(8);
    Uint8List timestamp = Uint8List(8)
      ..buffer.asByteData().setUint64(
        0,
        (DateTime.now().millisecondsSinceEpoch / 1000.0).round(),
        Endian.little,
      );
    Uint8List addrRecvServices = Uint8List(8);
    Uint8List addrRecvIpAddress = ipToBytes(socket!.remoteAddress.address);
    Uint8List addrRecvPort = Uint8List(2)
      ..buffer.asByteData().setUint16(0, port, Endian.big);
    Uint8List addrTransServices = Uint8List(8);
    Uint8List addrTransIpAddress = ipToBytes("127.0.0.1");
    Uint8List addrTransPort = Uint8List(2)
      ..buffer.asByteData().setUint16(0, 8333, Endian.big);
    Uint8List nonce = Uint8List(8);
    Uint8List userAgent = Uint8List(1);
    Uint8List startHeight = Uint8List(4)
      ..buffer.asByteData().setUint32(0, tipHeight, Endian.little);
    Uint8List relay = Uint8List(1);

    Uint8List payload = Uint8List.fromList(
      version +
          services +
          timestamp +
          addrRecvServices +
          addrRecvIpAddress +
          addrRecvPort +
          addrTransServices +
          addrTransIpAddress +
          addrTransPort +
          nonce +
          userAgent +
          startHeight +
          relay,
    );
    return payload;
  }

  Uint8List ipToBytes(String ip) {
    // This is based on this example:
    // 127.0.0.1
    // 00 00 00 00 00 00 00 00 00 00 FF FF 7F 00 00 01
    Uint8List buf = Uint8List(16);
    buf[10] = 0xff;
    buf[11] = 0xff;

    var ipParts = ip.split(".");
    buf[12] = int.parse(ipParts[0]);
    buf[13] = int.parse(ipParts[1]);
    buf[14] = int.parse(ipParts[2]);
    buf[15] = int.parse(ipParts[3]);
    return buf;
  }

  Future<Uint8List> getBloomFilter(List<Uint8List> values, int nTweak) async {
    // for (final v in values) {
    // if (v.length == 32) {
    //   print("bloom value: ${hex.encode(v)}");
    // }
    // }
    int n = values.length;
    double p = 0.00001;
    int nFilterBytes =
        ((-1 / math.pow(math.log(2.0), 2.0) * n.toDouble() * math.log(p)) / 8)
            .round();
    if (nFilterBytes < MIN_FILTER_BYTES) {
      nFilterBytes = MIN_FILTER_BYTES;
    }
    if (nFilterBytes > MAX_FILTER_BYTES) {
      nFilterBytes = MAX_FILTER_BYTES;
    }
    // nFilterBytes = 64;
    Uint8List filterBytes = Uint8List(nFilterBytes);

    int nHashFuncs = (nFilterBytes.toDouble() * 8 / n * math.log(2)).round();
    // nHashFuncs = 1;
    numHashFuncs = nHashFuncs;
    Uint8List value;
    for (int j = 0; j < values.length; j++) {
      value = values[j];
      for (int i = 0; i < nHashFuncs; i++) {
        // Calculate the seed and run murmur3 then set the bit
        int seed = i * 0xfba4c795 + nTweak;
        seed &= 0xffffffff;
        int hash = await murmur3a(value, seed: seed);
        hash %= nFilterBytes * 8;
        int byteIndex = (hash.toDouble() / 8).floor();
        filterBytes[byteIndex] |= 1 << (hash % 8);
      }
    }
    return filterBytes;
  }

  Future<Uint8List> msgFilterLoad(List<Uint8List> values) async {
    int nTweak = 0;
    Uint8List filterBytes = await getBloomFilter(values, nTweak);
    Uint8List nFilterBytes = makeVarint(BigInt.from(filterBytes.length));
    Uint8List nHashFuncs = Uint8List(4)
      ..buffer.asByteData().setUint32(0, numHashFuncs, Endian.little);
    Uint8List nTweakBytes = Uint8List(4)
      ..buffer.asByteData().setUint32(0, nTweak, Endian.little);
    Uint8List nFlags = Uint8List(1)..buffer.asByteData().setUint8(0, 0);
    Uint8List payload = Uint8List.fromList(
      nFilterBytes + filterBytes + nHashFuncs + nTweakBytes + nFlags,
    );

    return payload;
  }

  Future<void> sendMessage(Uint8List payload) async {
    if (!isConnected) {
      return;
    }
    // print("sending cmd ${String.fromCharCodes(payload.sublist(4, 16))}: ${hex.encode(payload)}");
    await mutex.acquire();
    socket?.add(payload);
    try {
      await socket?.flush();
    } catch (e) {}
    try {
      mutex.release();
    } catch (e) {}
  }

  void processIncomingMsg(Uint8List msg) async {
    await msgMutex.acquire();
    if (isValidMsg(msg, clearOnBadMagic: false) && !buffer.isEmpty) {
      buffer = Uint8List.fromList(msg + buffer);
    } else {
      buffer = Uint8List.fromList(buffer + msg);
    }

    try {
      msgMutex.release();
    } catch (e) {}
    if (isConnected) {
      processBuffer();
    }
  }

  bool isValidMsg(Uint8List buf, {bool clearOnBadMagic = true}) {
    // check length
    if (buf.length < 24) {
      // print("ERROR: buffer corrupted less than 24 buffer:" + hex.encode(buf));
      return false;
    }

    // check magic
    if (String.fromCharCodes(buf.sublist(0, 4)) !=
        String.fromCharCodes(magic)) {
      if (clearOnBadMagic) {
        print("ERROR: buffer corrupted bad magic buffer:" + hex.encode(buf));
        buffer = Uint8List(0);
      }

      return false;
    }
    var payloadLength = ByteData.sublistView(
      buf.sublist(16, 20),
    ).getUint32(0, Endian.little);

    // check if we have a full message
    var msgEndIndex = payloadLength + 24;
    if (buf.length < msgEndIndex) {
      // print(
      //     "ERROR: buffer too short buffer.length ${buf.length}  msgEndIndex ${msgEndIndex}");
      return false;
    }
    return true;
  }

  Future<void> processBuffer() async {
    if (!isValidMsg(buffer)) {
      return;
    }

    await msgMutex.acquire();
    var payloadLength = ByteData.sublistView(
      buffer.sublist(16, 20),
    ).getUint32(0, Endian.little);

    // check if we have a full message
    var msgEndIndex = payloadLength + 24;

    Uint8List msg = buffer.sublist(0, msgEndIndex);
    buffer = buffer.sublist(msgEndIndex);
    try {
      msgMutex.release();
    } catch (e) {}

    processP2PMessage(msg);

    // process again if there is more in buffer
    if (buffer.isNotEmpty && isValidMsg(buffer)) {
      processBuffer();
    }
  }

  void processMsgTx(Uint8List msg) async {
    // debug stuffs
    remainingTxCount--;
    BitcoinTx tx = BitcoinTx.fromTxBytes(msg.sublist(24));
    String txHash = tx.getHashHex();
    var blkHash = txBlockHash[txHash];

    // check if the tx has a block
    if (blkHash == null) {
      return;
    }

    DateTime? txTimeStamp = () {
      DateTime? tempDate;
      blockTimestamp.forEach((item) {
        if (item.item1 == blkHash) {
          tempDate = item.item2;
        }
      });
      return tempDate;
    }();

    storeTransaction(
      tx,
      confirmed: true,
      verified: true,
      failed: false,
      txTimeStamp: txTimeStamp,
      blkHash: blkHash,
    );
  }

  Future<void> processMsgMerkleBlock(Uint8List msg) async {
    BitcoinBlock blk = BitcoinBlock.fromMerkleBlockBytes(msg.sublist(24));
    // check if this block is newer than my last block
    if (tipTimestamp.add(Duration(days: -7)).isAfter(blk.timestamp)) {
      print("IGNORING BLOCK with timestamp: ${blk.timestamp}");
      if (isConnected) {
        disconnect();
      }

      return;
    }

    String blkHash = blk.getHashHex();
    for (int i = 0; i < blk.txList.length; i++) {
      txBlockHash[blk.txList[i]] = blkHash;
    }

    // blockMap[blkHash] = blk;
    blockTimestamp.add(Tuple(blkHash, blk.timestamp));
    if (blockTimestamp.length > MAX_BLOCKS) {
      blockTimestamp.removeFirst();
    }

    counterMutex.acquire();
    _remainingBlockCount -= 1;
    bool getMoreBlocks = _remainingBlockCount == 0;
    remainingTxCount += blk.merkleTxCount;
    try {
      counterMutex.release();
    } catch (e) {}

    final block =
        Block()
          ..hash = blkHash
          ..time = blk.timestamp
          ..filePath = ''
          ..coin = id
          ..previousHash = blk.getprevHashHex();

    block.save().then((int blockId) async {
      if (getMoreBlocks) {
        sendMessage(makeMsg('getblocks', msgGetBlocks()));
        // print("calculating height");
        calculateHeight();
      }
    });
  }

  void processP2PMessage(Uint8List msg) {
    var cmd = String.fromCharCodes(msg.sublist(4, 16)).replaceAll("\x00", "");

    // print("processP2PMessage cmd ${cmd}");

    switch (cmd) {
      case 'version':
        var ok = processMsgVersion(msg);
        if (!ok) {
          peerList.remove(currentPeerIP);
          disconnect();
        }
      case 'verack':
        processMsgVerack(msg);
      case 'inv':
        processMsgInventory(msg);
      case 'tx':
        processMsgTx(msg);
      case 'merkleblock':
        processMsgMerkleBlock(msg);
      case 'ping':
        processMsgPing(msg);
      case 'addr':
        processMsgAddr(msg);
      case 'feefilter':
        processMsgFeeFilter(msg);
      case 'sendaddrv2':
        processMsgSendAddr2(msg);
      case 'reject':
        peerList.remove(currentPeerIP);
        disconnect();
      // connect();
      default:
        break;
    }
  }

  void processMsgAddr(Uint8List msg) {
    // Do thing
  }

  void processMsgSendAddr2(Uint8List msg) {
    // do nothing
    print("processMsgSendAddr2: ${hex.encode(msg.sublist(24))}");
  }

  void processMsgFeeFilter(Uint8List msg) {
    // do nothing
  }

  void processMsgPing(Uint8List msg) {
    // check if the message mas a payload
    Uint8List payload = Uint8List(0);
    if (msg.length > 24) {
      payload = msg.sublist(24);
    }
    sendMessage(makeMsg('pong', payload));
  }

  void processMsgInventory(Uint8List msg) {
    if (!getBlocks) {
      return;
    }
    getBlocks = false;
    int index = 24;
    int invCount = 0;
    int invBytes = 0;
    (invCount, invBytes) = parseVarint(msg, index);
    List<int> payload = [];
    index += invBytes;

    int counter = 0;
    int blockCounter = 0;
    List<int> tx;
    while (index < msg.length) {
      counter++;
      tx = msg.sublist(index, index + 36);
      if (tx[0] != 2 && tx[0] != 3) {
        index += 36;
        continue;
      }
      blockCounter++;
      tx[0] = 3;
      payload += tx;
      if (counter >= invCount - 5) {
        blockChain.add(String.fromCharCodes(tx).substring(4));
        if (blockChain.length > MAX_BLOCKS) {
          blockChain.removeFirst();
        }
      }
      index += 36;
    }
    counterMutex.acquire();
    _remainingBlockCount += blockCounter;
    try {
      counterMutex.release();
    } catch (e) {}

    if (payload.isNotEmpty) {
      () async {
        payload = makeVarint(BigInt.from(blockCounter)) + payload;
        sendMessage(makeMsg('getdata', Uint8List.fromList(payload)));
      }();
    } else {
      getBlocks = true;
    }
  }

  void setIsConnected(bool value) {
    isConnected = value;
    notifyListeners();

    if (isConnected) {
      for (int i = unsendTx.length - 1; i >= 0; i--) {
        transmitTxBytes(unsendTx.last);
        unsendTx.removeLast();
      }
    }
  }

  Future<void> clearOldBlocks(int height) async {
    var isar = Singleton.getDB();
    await isar.writeTxn(() async {
      await isar.blocks
          .filter()
          .coinEqualTo(id)
          .heightLessThan(height - 1000)
          .deleteAll();
    });
  }

  Future<void> calculateHeight() async {
    await heightMutex.acquire();
    var isar = Singleton.getDB();
    List<Block> blocks;
    int highest = 0;
    String highestHash = "";
    DateTime highestTimeStamp = DateTime.now();
    for (int i = 0; i < 10; i++) {
      blocks =
          isar.blocks
              .filter()
              .coinEqualTo(id)
              .heightIsNull()
              .limit(500)
              .findAllSync();
      if (blocks.isEmpty) {
        break;
      }
      for (int j = 0; j < blocks.length; j++) {
        blocks[j].height = blocks[j].getHeight();
        await blocks[j].save();
        if (highest < (blocks[j].height ?? -1)) {
          highest = blocks[j].height!;
          highestHash = blocks[j].hash!;
          highestTimeStamp = blocks[j].time!;
          tipHeight = blocks[j].height!;
          tipTimestamp = blocks[j].time!;
        }
      }
      if (highestHash == "") {
        break;
      }
      // await Future.delayed(Duration(seconds: 1));
    }

    if (highestHash != "") {
      final balance =
          Balance()
            ..coin = id
            ..wallet = walletId
            ..coinBalance = getBalance().toInt()
            ..usdBalance = null
            ..fiatBalanceDC = null
            ..lastUpdate = highestTimeStamp
            ..lastBlockUpdate = highestHash;
      await balance.save();
    }

    try {
      await clearOldBlocks(tipHeight);
      heightMutex.release();
    } catch (e) {}
  }

  bool processMsgVersion(Uint8List msg) {
    // TODO: check if the nod version is too old and add a minimum version
    // constant to the class
    Uint8List payload = msg.sublist(24);
    // print("version payload: ${hex.encode(payload)}");
    const NODE_NETWORK = 0x01;
    // const NODE_GETUTXO = 0x02;
    const NODE_BLOOM = 0x04;

    if ((payload[4] & NODE_BLOOM) == 0) {
      print("node does not support NODE_BLOOM");
      return false;
    }
    if ((payload[4] & NODE_NETWORK) == 0) {
      print("node does not support NODE_NETWORK");
      return false;
    }
    print("node supported");
    return true;
  }

  void processMsgVerack(Uint8List msg) async {
    handshakeCompleted = true;
    // sendMessage(makeMsg('wtxidrelay', Uint8List(0)));
    sendMessage(makeMsg('verack', Uint8List(0)));

    // handshake is completed, start getting blocks
    startP2PGetBlocksSession();
  }

  void startP2PGetBlocksSession() async {
    getPublicKeyHashes(refresh: true);
    Uint8List payload = await msgFilterLoad(addressList);

    await sendMessage(makeMsg('filterload', payload));
    await sendMessage(makeMsg('getblocks', msgGetBlocks()));
  }

  void addSocketListener() async {
    socket!.listen(
      (data) {
        processIncomingMsg(data);
      },
      onDone: () {
        connectionId++;
        print("socket got disconnected");
        peerList.remove(currentPeerIP);
        setIsConnected(false);
        connect();
      },
      onError: (error) {
        print("Bitcoin(addSocketListener): ERROR: ${error.toString()}");
        // connect();
      },
    );
  }

  void disconnect() {
    setIsConnected(false);
    socket?.destroy();
  }

  Future<void> _setupPrivateKey() async {
    if (walletType == WalletType.phone) {
      extendedPrivateKey = wallet.extendedPrivKey;
    }
  }

  Future<void> updateBalance() async {
    await sendMessage(makeMsg('version', msgVersion()));
    (int currentId) async {
      await Future.delayed(Duration(seconds: 5));
      if (connectionId != currentId) {
        return;
      }
      if (!handshakeCompleted) {
        disconnect();
        // connect();
      }
    }(connectionId);
    // await sendMessage(makeMsg('verack', Uint8List(0)));

    // addressList = getPublicKeyHashes();
    // Uint8List payload = await msgFilterLoad(addressList);
    // for (int i = 0; i < addressList.length; i++) {}

    // await sendMessage(makeMsg('filterload', payload));
    // await sendMessage(makeMsg('getblocks', msgGetBlocks()));
  }

  Bip32KeyNetVersions getNetVersion() {
    return Bip32KeyNetVersions(
      hex.decode(netVersionPublicHex!),
      hex.decode(netVersionPrivateHex!),
    );
    //[0x04, 0x35, 0x87, 0xCF], [0x04, 0x35, 0x83, 0x94]);
  }

  String getMasterFingerprint() {
    if (_keyFingerprint == "") {
      Wallet wallet = Wallet(id: walletId);

      if (wallet.fingerprint == null) {
        final hdw = Bip32Slip10Secp256k1.fromExtendedKey(
          extendedPrivateKey!,
          getNetVersion(),
        );
        // final hdw = Bip32Slip10Secp256k1.fromSeed(__seed);
        wallet.fingerprint = hdw.fingerPrint.toHex();
        wallet.save();
      }
      _keyFingerprint = wallet.fingerprint!;
    }

    return _keyFingerprint;
  }

  void getFeeFromAPI() async {
    if (DateTime.now().isBefore(cachedFeeExpiry)) {
      return;
    }
    const LOW_BOUND = 500000;
    const HIGH_BOUND = 750000;
    double lowBoundValue = 0.0;
    double highBoundValue = 0.0;
    var URL = Uri.parse("https://mempool.space/api/mempool");
    http.Response response;
    try {
      response = await http.get(URL);
    } catch (e) {
      return;
    }

    Map<String, dynamic> jObj =
        jsonDecode(response.body) as Map<String, dynamic>;

    double value = 0;
    int bound = 0;
    int cumBound = 0;
    List<dynamic> feeHist = jObj["fee_histogram"] as List<dynamic>;
    for (final (int index, List<dynamic> item) in feeHist.indexed) {
      bound = item[1];
      if (index == 0) {
        value = item[0];
      } else {
        value = (feeHist[index - 1] as List<dynamic>)[0];
      }

      cumBound += bound;
      if (cumBound >= LOW_BOUND && lowBoundValue == 0.0) {
        lowBoundValue = value;
      }
      if (cumBound >= HIGH_BOUND && highBoundValue == 0.0) {
        highBoundValue = value;
        break;
      }
    }

    // check if he network is very under utilized
    if (lowBoundValue == 0.0) {
      cachedFee = 2.0;
    } else if (highBoundValue == 0.0) {
      cachedFee = lowBoundValue;
    } else {
      cachedFee = (highBoundValue + lowBoundValue) / 2;
    }
    cachedFeeExpiry = DateTime.now().add(Duration(minutes: FEE_CACHE_MAX_AGE));
  }

  BigInt getTxFeeEstimate(int nBytes) {
    getFeeFromAPI();
    return BigInt.from(nBytes * cachedFee);
  }

  @override
  Future<BigInt> calculateFee(
    String toAddress,
    BigInt amount, {
    noChange = false,
  }) async {
    List<BitcoinTxOut> txUTXOSet = [];
    BigInt balance = BigInt.zero;
    /*
     Explication of the value below:
     ScriptSig = OP_PUSHBYTES_72 + Signature + OP_PUSHBYTES_33 + PubKey
     ScriptSig = 2 bytes for commands + 114 + 51 = 147
     nBytesPerInputP2PKH = 32 (TXID) + 4 (VOUT) + 1 (ScriptSig Size) + 147 (ScriptSig) + 4 (Sequence)
    */
    int nBytesPerInputP2PKH = 188;

    // nBytesPerInputP2WPKH = 32 (TXID) + 4 (VOUT) + 1 (ScriptSig Size) + 0 (ScriptSig) + 4 (Sequence)
    int nBytesPerInputP2WPKHBase = 41;
    // nBytesPerInputP2WPKH = 41 (nBytesPerInputP2WPKHBase) + 1 (witnes items count) + 1 (sig length) + 72 (sig) + 1 (pubkey length) + 33 (pubkey)
    int nBytesPerInputP2WPKH = 149;

    // ScriptPubKey = OP_0 OP_PUSHBYTES_20 841b80d2cc75f5345c482af96294d04fdd66b2b7
    // ScriptPubKey = 2 command bytes + 20 bytes for the address = 22
    // nBytesPerOutput = 8 (Amount) + 1 (ScriptPubKey Size) + 22 (ScriptPubKey)
    // int outputCount = noChange ? 1 : 2;
    int nBytesPerOutputP2PKH = 34;
    int nBytesPerOutputP2WPKH = 31;

    // P2TR
    /// nBytesPerInputP2TR = 32 (TXID) + 4 (VOUT) + 1 (ScriptSig Size) + 0 (ScriptSig) + 4 (Sequence)
    int nBytesPerInputP2TRBase = 41;
    // nBytesPerInputP2TR = 41 (nBytesPerInputP2WPKHBase) + 1 (witnes items count) + 1 (sig length) + 64 (sig)
    int nBytesPerInputP2TR = 107;

    // ScriptPubKey = OP_PUSHNUM_1 OP_PUSHBYTES_32 bb0b81d3f8a449b496e105f62774fe43238ee79d0aa69485d7689eb3fd6d3bb5
    // ScriptPubKey = 2 command bytes + 32 bytes for the address = 34
    // nBytesPerOutput = 8 (Amount) + 1 (ScriptPubKey Size) + 34 (ScriptPubKey)
    int nBytesPerOutputP2TR = 43;

    // baseTxBytesSegWit = 4 (Version) + 1 (input count) + 1 (output count) + 4 (lock time)
    int baseTxBytes = 10;
    // baseTxBytesSegWit = 4 (Version) + 2 (flag) + 1 (input count) + 1 (output count) + 4 (lock time)
    int baseTxBytesSegWit = 12;
    int nBytesBase = baseTxBytesSegWit;
    int nBytesTotal = baseTxBytes;
    int nBytes = 0;
    BigInt fee = BigInt.zero;
    String key = "";

    // calculate output bytes
    var addressType = getAddressType(toAddress);
    switch (addressType) {
      case "P2PKH":
        nBytesBase += nBytesPerOutputP2PKH;
        nBytesTotal += nBytesPerOutputP2PKH;
      case "P2PWKH":
        nBytesBase += nBytesPerOutputP2WPKH;
        nBytesTotal += nBytesPerOutputP2WPKH;
      case "P2TR":
        nBytesBase += nBytesPerOutputP2TR;
        nBytesTotal += nBytesPerOutputP2TR;
      default:
        nBytesBase += nBytesPerOutputP2PKH;
        nBytesTotal += nBytesPerOutputP2PKH;
    }
    if (!noChange) {
      switch (DEFAULT_TX_TYPE) {
        case "P2PKH":
          nBytesBase += nBytesPerOutputP2PKH;
          nBytesTotal += nBytesPerOutputP2PKH;
        case "P2PWKH":
          nBytesBase += nBytesPerOutputP2WPKH;
          nBytesTotal += nBytesPerOutputP2WPKH;
        case "P2TR":
          nBytesBase += nBytesPerOutputP2TR;
          nBytesTotal += nBytesPerOutputP2TR;
        default:
          nBytesBase += nBytesPerOutputP2PKH;
          nBytesTotal += nBytesPerOutputP2PKH;
      }
    }

    for (int i = 0; i < utxoSet.length; i++) {
      key = utxoSet.keys.elementAt(i);
      if (utxoSet[key]!.spent) {
        continue;
      }
      txUTXOSet.add(utxoSet[key]!);
      balance += utxoSet[key]!.value;
      switch (utxoSet[key]!.getPubKeyScriptType()) {
        case "P2PKH":
          nBytesBase += nBytesPerInputP2PKH;
          nBytesTotal += nBytesPerInputP2PKH;
        case "P2WPKH":
          nBytesBase += nBytesPerInputP2WPKHBase;
          nBytesTotal += nBytesPerInputP2WPKH;
        case "P2TR":
          nBytesBase += nBytesPerInputP2TRBase;
          nBytesTotal += nBytesPerInputP2TR;
        default:
          nBytesBase += nBytesPerInputP2PKH;
          nBytesTotal += nBytesPerInputP2PKH;
          print("Bitcoin(makeTransaction): Unknown script type");
      }
      nBytes = ((nBytesBase * 3 + nBytesTotal) / 4).ceil();
      fee = getTxFeeEstimate(nBytes);
      if (balance >= (amount + fee)) {
        break;
      }
    }
    // print("calculateFee(noChange): ${noChange}");
    // print("calculateFee(balance): ${balance.toInt()}");
    // print("calculateFee(amount): ${amount.toInt()}");
    // print("calculateFee(fee): ${fee.toInt()}");
    // print("calculateFee(cachedFee): ${cachedFee}");
    // print("calculateFee(nBytesBase): ${nBytesBase}");
    // print("calculateFee(nBytesTotal): ${nBytesTotal}");
    // print("calculateFee(nBytes): ${nBytes}");
    return fee;
  }

  @override
  Tx? makeTransaction(String toAddress, BigInt amount, {noChange = false}) {
    BitcoinTx tx = BitcoinTx();
    List<BitcoinTxOut> txUTXOSet = [];
    BigInt balance = BigInt.zero;
    // ScriptSig = OP_PUSHBYTES_72 + Signature + OP_PUSHBYTES_33 + PubKey
    // ScriptSig = 2 bytes for commands + 114 + 51 = 147
    // nBytesPerInputP2PKH = 32 (TXID) + 4 (VOUT) + 1 (ScriptSig Size) + 147 (ScriptSig) + 4 (Sequence)
    int nBytesPerInputP2PKH = 188;
    // nBytesPerInputP2WPKH = 32 (TXID) + 4 (VOUT) + 1 (ScriptSig Size) + 0 (ScriptSig) + 4 (Sequence)
    int nBytesPerInputP2WPKHBase = 41;
    // nBytesPerInputP2WPKH = 41 (nBytesPerInputP2WPKHBase) + 1 (witnes items count) + 1 (sig length) + 72 (sig) + 1 (pubkey length) + 33 (pubkey)
    int nBytesPerInputP2WPKH = 149;
    // ScriptPubKey = OP_0 OP_PUSHBYTES_20 841b80d2cc75f5345c482af96294d04fdd66b2b7
    // ScriptPubKey = 2 command bytes + 20 bytes for the address = 22
    // nBytesPerOutput = 8 (Amount) + 1 (ScriptPubKey Size) + 22 (ScriptPubKey)
    int outputCount = noChange ? 1 : 2;
    int nBytesPerOutputP2PKH = 34;
    int nBytesPerOutputP2WPKH = 31;

    // P2TR
    /// nBytesPerInputP2TR = 32 (TXID) + 4 (VOUT) + 1 (ScriptSig Size) + 0 (ScriptSig) + 4 (Sequence)
    int nBytesPerInputP2TRBase = 41;
    // nBytesPerInputP2TR = 41 (nBytesPerInputP2WPKHBase) + 1 (witnes items count) + 1 (sig length) + 64 (sig)
    int nBytesPerInputP2TR = 107;

    // ScriptPubKey = OP_PUSHNUM_1 OP_PUSHBYTES_32 bb0b81d3f8a449b496e105f62774fe43238ee79d0aa69485d7689eb3fd6d3bb5
    // ScriptPubKey = 2 command bytes + 32 bytes for the address = 34
    // nBytesPerOutput = 8 (Amount) + 1 (ScriptPubKey Size) + 34 (ScriptPubKey)
    int nBytesPerOutputP2TR = 43;

    // baseTxBytesSegWit = 4 (Version) + 1 (input count) + 1 (output count) + 4 (lock time)
    int baseTxBytes = 10;
    // baseTxBytesSegWit = 4 (Version) + 2 (flag) + 1 (input count) + 1 (output count) + 4 (lock time)
    int baseTxBytesSegWit = 12;
    int nBytesBase = baseTxBytesSegWit;
    int nBytesTotal = baseTxBytes;
    int nBytes = 0;
    BigInt fee = BigInt.zero;
    String key = "";

    // calculate output bytes
    var addressType = getAddressType(toAddress);
    switch (addressType) {
      case "P2PKH":
        nBytesBase += nBytesPerOutputP2PKH;
        nBytesTotal += nBytesPerOutputP2PKH;
      case "P2PWKH":
        nBytesBase += nBytesPerOutputP2WPKH;
        nBytesTotal += nBytesPerOutputP2WPKH;
      case "P2TR":
        nBytesBase += nBytesPerOutputP2TR;
        nBytesTotal += nBytesPerOutputP2TR;
      default:
        nBytesBase += nBytesPerOutputP2PKH;
        nBytesTotal += nBytesPerOutputP2PKH;
    }
    if (!noChange) {
      switch (DEFAULT_TX_TYPE) {
        case "P2PKH":
          nBytesBase += nBytesPerOutputP2PKH;
          nBytesTotal += nBytesPerOutputP2PKH;
        case "P2PWKH":
          nBytesBase += nBytesPerOutputP2WPKH;
          nBytesTotal += nBytesPerOutputP2WPKH;
        case "P2TR":
          nBytesBase += nBytesPerOutputP2TR;
          nBytesTotal += nBytesPerOutputP2TR;
        default:
          nBytesBase += nBytesPerOutputP2PKH;
          nBytesTotal += nBytesPerOutputP2PKH;
      }
    }

    for (int i = 0; i < utxoSet.length; i++) {
      key = utxoSet.keys.elementAt(i);
      if (utxoSet[key]!.spent) {
        continue;
      }
      txUTXOSet.add(utxoSet[key]!);
      balance += utxoSet[key]!.value;
      switch (utxoSet[key]!.getPubKeyScriptType()) {
        case "P2PKH":
          nBytesBase += nBytesPerInputP2PKH;
          nBytesTotal += nBytesPerInputP2PKH;
        case "P2WPKH":
          nBytesBase += nBytesPerInputP2WPKHBase;
          nBytesTotal += nBytesPerInputP2WPKH;
        case "P2TR":
          nBytesBase += nBytesPerInputP2TRBase;
          nBytesTotal += nBytesPerInputP2TR;
        default:
          nBytesBase += nBytesPerInputP2PKH;
          nBytesTotal += nBytesPerInputP2PKH;
          print("Bitcoin(makeTransaction): Unknown script type");
      }
      nBytes = ((nBytesBase * 3 + nBytesTotal) / 4).ceil();
      fee = getTxFeeEstimate(nBytes);
      if (balance >= (amount + fee)) {
        break;
      }
    }

    if (balance < (amount + fee)) {
      return null;
    }
    // print("makeTransaction(noChange): ${noChange}");
    // print("makeTransaction(balance): ${balance.toInt()}");
    // print("makeTransaction(amount): ${amount.toInt()}");
    // print("makeTransaction(fee): ${fee.toInt()}");
    // print("makeTransaction(nBytes): ${nBytes}");
    // print("makeTransaction(cachedFee): ${cachedFee}");

    tx.version = 2;
    tx.segwit = false;

    tx.inCount = txUTXOSet.length;
    BitcoinTxIn input;
    for (int i = 0; i < txUTXOSet.length; i++) {
      input = BitcoinTxIn();

      input.previousOutHash = txUTXOSet[i].txHash;
      input.previousOutIndex = txUTXOSet[i].index;
      input.sequence = 0xffffffff - 2;
      input.scriptSig = Uint8List(0);
      input.utx = txUTXOSet[i];

      if (input.utx.getPubKeyScriptType() == "P2WPKH" ||
          input.utx.getPubKeyScriptType() == "P2TR") {
        tx.segwit = true;
      }

      tx.inputs.add(input);
    }

    tx.outCount = outputCount;
    BitcoinTxOut output = BitcoinTxOut();
    if (noChange) {
      amount = balance - fee;
    }
    output.value = amount;
    // output.scriptPubKey = Uint8List.fromList([0x00, 0x14] + toAddress);
    var addressBytes = getAddressBytes(toAddress);
    output.scriptPubKey = BitcoinTxOut.getLockingScriptFromAddress(
      addressBytes,
      addressType,
    );
    // sanity check
    if (output.scriptPubKey.isEmpty) {
      return null;
    }

    tx.outputs.add(output);

    if (!noChange) {
      BitcoinTxOut change = BitcoinTxOut();
      change.value = balance - amount - fee;
      change.scriptPubKey = Uint8List.fromList(
        [0x00, 0x14] + getChangeAddress(),
      );
      tx.outputs.add(change);
    }

    tx.lockTime = 0x00000000;

    tx.fee = fee;
    return tx;
  }

  @override
  PST makePST(Tx tx) {
    BitcoinTx btcTx = tx as BitcoinTx;
    PSBT psbt = PSBT();
    psbt.global[0x00] = {"valuedata": btcTx.getRawTX()};
    for (int i = 0; i < btcTx.inCount; i++) {
      Uint8List pubkey = btcTx.inputs[i].utx.pubKey;
      String addressType = btcTx.inputs[i].utx.getPubKeyScriptType();

      List<int> fingerprint = Uint8List.fromList(
        hex.decode(getMasterFingerprint()),
      );
      String path;
      if (addressType == "P2TR") {
        path = pubKeyAddressPathMap[String.fromCharCodes(pubkey)]!;
      } else {
        path =
            pubKeyAddressPathMap[String.fromCharCodes(
              getAddress(pubkey, addressType),
            )]!;
      }

      Uint8List derivation = HDWalletHelpers.serializeHDPath(path);
      psbt.inputs.add({
        0x01: {"valuedata": btcTx.inputs[i].utx.getRawBytes()},
        0x06: {
          "keydata": pubkey,
          "valuedata": Uint8List.fromList(fingerprint + derivation),
        },
      });
    }

    for (int i = 0; i < btcTx.outCount; i++) {
      psbt.outputs.add({});
    }

    return psbt;
  }

  String getAddressTypeByNetwork(String? network) {
    Map<String?, String> networkAddressType = {
      null: DEFAULT_TX_TYPE,
      "BTC_LEGACY": "P2PKH",
      "BTC_SEGWIT": "P2WPKH",
      "BTC_TAPROOT": "P2TR",
      "BTC_LIGHTNING": "P2LN", // LN is not implemented yet
    };
    String? addressType = networkAddressType[network];
    if (addressType == null) {
      addressType = DEFAULT_TX_TYPE;
    }
    return addressType;
  }

  String getPurposeByAddressType(String? addressType) {
    Map<String?, String> networkPathPurpose = {
      null: "84",
      "P2PKH": "44",
      "P2WPKH": "84",
      "P2TR": "86",
      "P2LN": "84", // LN is not implemented yet
    };
    String? pathPurpose = networkPathPurpose[addressType];
    if (pathPurpose == null) {
      pathPurpose = "84";
    }
    return pathPurpose;
  }

  @override
  Future<String> getReceivingAddress({
    String? network,
    int account = 0,
    BigInt? amount,
  }) async {
    String addressType = getAddressTypeByNetwork(network);
    String? pathPurpose = getPurposeByAddressType(addressType);
    String path = "m/${pathPurpose}'/0'/${account}'/${EXTERNAL_INDEX}";
    int nextIndex = getNextIndex(path);
    path += "/${nextIndex}";
    var pubKey = getPublicKey(path);
    // print("path: ${path}, getPublicKey: ${hex.encode(pubKey)}");
    var address = getAddress(pubKey, addressType);
    var returnAddress = getAddressFromBytes(address, addressType: addressType);

    return returnAddress;
  }

  int getNextIndex(String path) {
    var isar = Singleton.getDB();
    NextKey? nextKey = isar.nextKeys.getByPathCoinWalletSync(
      path,
      id,
      walletId,
    );

    int nextKeyIndex = (nextKey?.nextKey ?? 0);

    // save the next key in a seperate thread
    () async {
      if (nextKey == null) {
        nextKey = NextKey();
        nextKey!.coin = id;
        nextKey!.wallet = walletId;
        nextKey!.path = path;
      }
      nextKey!.nextKey = nextKeyIndex + 1;
      await nextKey!.save();

      // update address list
      getPublicKeyHashes(refresh: true, refreshBloomFilters: true);
    }();

    return nextKeyIndex;
  }

  Future<void> setNextIndex(String path, int index) async {
    var isar = Singleton.getDB();
    NextKey? nextKey = isar.nextKeys.getByPathCoinWalletSync(
      path,
      walletId,
      id,
    );

    // save the next key in a seperate thread
    if (nextKey == null) {
      nextKey = NextKey();
      nextKey.coin = id;
      nextKey.wallet = walletId;
      nextKey.path = path;
      nextKey.nextKey = index;
      await nextKey.save();
    } else if (nextKey.nextKey! < index) {
      nextKey.nextKey = index;
      await nextKey.save();
    }

    // update address list
    getPublicKeyHashes();
  }

  Bip32Slip10Secp256k1? getNearestParentKey(String path) {
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
      var isar = Singleton.getDB();
      key = isar.keys.getByPathWalletCoinSync(tempPath, walletId, id);
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

  String getExtendedPublicKey(String path) {
    // check if the key is already in the DB
    var isar = Singleton.getDB();
    keyCollection.Key? key = isar.keys.getByPathWalletCoinSync(
      path,
      walletId,
      id,
    );
    Bip32PublicKey pubkey;

    // if the key is not if the DB, create it and save it
    if (key == null) {
      var hdw = getNearestParentKey(path);
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

  // Uint8List getPrivateKey(String path) {
  //   final hdw = Bip32Slip10Secp256k1.fromExtendedKey(
  //       extendedPrivateKey!, getNetVersion());
  //   // final hdw = Bip32Slip10Secp256k1.fromSeed(__seed);
  //   var account = hdw.derivePath(path);

  //   return Uint8List.fromList(account.privateKey.raw);
  // }

  Uint8List getChangeAddress({int account = 0}) {
    String purpose = getPurposeByAddressType(DEFAULT_TX_TYPE);
    String accountPath = "m/${purpose}'/0'/${account}'/${INTERNAL_INDEX}";
    String extendedPubKey = getExtendedPublicKey(accountPath);
    var parentAccount = Bip32Slip10Secp256k1.fromExtendedKey(
      extendedPubKey,
      getNetVersion(),
    );
    int nextIndex = getNextIndex(accountPath);
    var childKey = parentAccount.childKey(Bip32KeyIndex(nextIndex));

    return getAddress(
      Uint8List.fromList(childKey.publicKey.compressed),
      DEFAULT_TX_TYPE,
    );
  }

  Uint8List getAddress(Uint8List pubKeyBytes, String addressType) {
    switch (addressType) {
      case "P2PKH":
      case "P2PWKH":
        final pubKey = ECPublic.fromBytes(pubKeyBytes);
        return Uint8List.fromList(pubKey.toHash160());
      case "P2TR":
        return tweakPublicKey(pubKeyBytes);
      case "P2LN":
      // LN is not imlemented yet
    }
    final pubKey = ECPublic.fromBytes(pubKeyBytes);
    return Uint8List.fromList(pubKey.toHash160());
  }

  Uint8List tweakPublicKey(Uint8List pubKey) {
    if (pubKey.length == 32) {
      return pubKey;
    } else if (pubKey[0] == 0x03) {
      pubKey = Uint8List.fromList([0x02, ...pubKey.sublist(1)]);
    }
    var tweak = taggedHash("TapTweak", pubKey.sublist(1));
    var pubTweak = ECPrivate.fromBytes(tweak).getPublic();
    var tweakedPoint = OtherHelpers.pointAdd(
      pubKey,
      Uint8List.fromList(hex.decode(pubTweak.toHex())),
    );
    var tweakedPointXHex = tweakedPoint.X.toRadixString(16).padLeft(64, "0");
    return Uint8List.fromList(hex.decode(tweakedPointXHex));
  }

  Uint8List taggedHash(String tag, Uint8List data) {
    var tagHash = sha256.convert(tag.codeUnits).bytes;
    return Uint8List.fromList(
      sha256.convert([...tagHash, ...tagHash, ...data]).bytes,
    );
  }

  Uint8List getPublicKey(String path) {
    var pathParts = path.split("/");
    String parentPubKey = getExtendedPublicKey(
      pathParts.sublist(0, pathParts.length - 1).join("/"),
    );
    var parentAccount = Bip32Slip10Secp256k1.fromExtendedKey(
      parentPubKey,
      getNetVersion(),
    );
    var childKey = parentAccount.childKey(
      Bip32KeyIndex(int.parse(pathParts[pathParts.length - 1])),
    );
    var returnPubKey = Uint8List.fromList(childKey.publicKey.compressed);

    return returnPubKey;
  }

  Future<Map<String, dynamic>?> transmitTxBytes(Uint8List buf) async {
    if (isUIInstance) {
      getAssetIsolatePort().send(<String, dynamic>{
        "command": "transmitTxBytes",
        "params": {"buf": buf},
      });
      return {};
    }
    Uint8List txMsg = makeMsg("tx", buf);
    await sendMessage(txMsg);
    return {};
  }

  @override
  String getAddressFromBytes(
    Uint8List address, {
    String? bechHRP,
    String addressType = DEFAULT_TX_TYPE,
  }) {
    switch (addressType) {
      case "P2PKH":
        return getAddressFromBytesBase58(address, 0);
      case "P2SH":
        return getAddressFromBytesBase58(address, 5);
      case "P2WPKH":
        return getAddressFromBytesBech32(address);
      case "P2WSH":
        return getAddressFromBytesBech32(address);
      case "P2TR":
        return getAddressFromBytesBech32m(address);
      default:
        print("Unknown address type ${addressType}");
    }
    return "";
  }

  String getAddressFromBytesBech32(Uint8List address) {
    String b = address.map((i) => i.toRadixString(2).padLeft(8, '0')).join();

    // Convert the binary string to a list of 5-bit integers
    List<int> valueList = [0];
    int index = 0;
    while (index < b.length) {
      valueList.add(int.parse(b.substring(index, index + 5), radix: 2));
      index += 5;
    }
    var bech32 = Bech32Codec();
    var bech32Data = Bech32(hrp, valueList);
    String receivingAddress = bech32.encode(bech32Data);

    return receivingAddress;
  }

  String getAddressFromBytesBech32m(Uint8List address) {
    String b = address.map((i) => i.toRadixString(2).padLeft(8, '0')).join();

    // Convert the binary string to a list of 5-bit integers
    List<int> valueList = [1];
    int index = 0;
    int endIndex = 0;
    b = b.padRight((b.length / 5).ceil() * 5, "0");
    while (index < b.length) {
      endIndex = index + 5;
      valueList.add(int.parse(b.substring(index, endIndex), radix: 2));
      index += 5;
    }
    var bech32 = Bech32mCodec();
    var bech32Data = Bech32m(hrp, valueList);
    String receivingAddress = bech32.encode(bech32Data);

    return receivingAddress;
  }

  String getAddressFromBytesBase58(Uint8List address, int prefix) {
    String receivingAddress = Base58Encoder.checkEncode([
      prefix,
      ...address.toList(),
    ]);

    return receivingAddress;
  }

  String getAddressType(String address) {
    if (address.isEmpty) {
      return "UNKNOWN";
    }
    if (address.length == 34 && address.startsWith("1")) {
      return "P2PKH";
    }
    if (address.length == 34 && address.startsWith("3")) {
      return "P2SH";
    }
    if (address.length == 42 && address.startsWith("bc1q")) {
      return "P2WPKH";
    }
    if (address.length == 62 && address.startsWith("bc1q")) {
      return "P2WSH";
    }
    if (address.length == 62 && address.startsWith("bc1p")) {
      return "P2TR";
    }

    return "UNKNOWN";
  }

  Uint8List getAddressBytes(String address) {
    var addressType = getAddressType(address);
    switch (addressType) {
      case "P2PKH":
        return getAddressBytesBase58(address);
      case "P2SH":
        return getAddressBytesBase58(address);
      case "P2WPKH":
        return getAddressBytesBech32(address);
      case "P2WSH":
        return getAddressBytesBech32(address);
      case "P2TR":
        return getAddressBytesBech32m(address);
    }
    return Uint8List(0);
  }

  Uint8List getAddressBytesBase58(String address) {
    try {
      var bech32Data = Base58Decoder.checkDecode(address);
      return Uint8List.fromList(bech32Data.sublist(1));
    } catch (Exception) {}

    return Uint8List(0);
  }

  Uint8List getAddressBytesBech32(String address) {
    var bech32 = Bech32Codec();
    var bech32Data = bech32.decode(address);

    // Convert the RIPEMD-160 hash to a binary string
    String b =
        bech32Data.data.map((i) => i.toRadixString(2).padLeft(5, '0')).join();

    // remove the first number which is the version
    b = b.substring(5);

    // Convert the binary string to a list of 5-bit integers
    List<int> valueList = [];
    int index = 0;
    while (index < b.length) {
      valueList.add(int.parse(b.substring(index, index + 8), radix: 2));
      index += 8;
    }

    return Uint8List.fromList(valueList);
  }

  Uint8List getAddressBytesBech32m(String address) {
    var bech32 = Bech32mCodec();
    var bech32Data = bech32.decode(address);

    // Convert the RIPEMD-160 hash to a binary string
    String b =
        bech32Data.data.map((i) => i.toRadixString(2).padLeft(5, '0')).join();

    // remove the first number which is the version
    b = b.substring(5);
    b = b.substring(0, (b.length / 8).floor() * 8);

    // Convert the binary string to a list of 5-bit integers
    List<int> valueList = [];
    int index = 0;
    while (index < b.length) {
      valueList.add(int.parse(b.substring(index, index + 8), radix: 2));
      index += 8;
    }

    return Uint8List.fromList(valueList);
  }

  BigInt getBaseAmount(double val) {
    return BigInt.from((val * 100000000).round());
  }

  String getDecimalAmount(BigInt val) {
    return (val.toDouble() / 100000000).toStringAsFixed(8);
  }

  double getDecimalAmountDouble(BigInt val) {
    return (val.toDouble() / 100000000);
  }

  @override
  Future<Uint8List?> signPST(PST? pst, Tx? tx, BuildContext? context) async {
    PSBT psbt = pst as PSBT;
    BitcoinTx btcTX = tx as BitcoinTx;

    // figureout the path of the input
    List<String> paths = [];
    // List<ECPrivate> privateKeys = [];
    for (int j = 0; j < psbt.inputs.length; j++) {
      List<String> pathList = ["m"];

      for (int i = 4; i < psbt.inputs[j][6]!["valuedata"]!.length; i += 4) {
        int tempNumber = psbt.inputs[j][6]!["valuedata"]![i];
        tempNumber += psbt.inputs[j][6]!["valuedata"]![i + 1] << (8 * 1);
        tempNumber += psbt.inputs[j][6]!["valuedata"]![i + 2] << (8 * 2);
        tempNumber +=
            (psbt.inputs[j][6]!["valuedata"]![i + 3] & 0x7f) << (8 * 3);
        pathList.add(tempNumber.toString());

        if ((psbt.inputs[j][6]!["valuedata"]![i + 3] & 128) == 128) {
          pathList.last += "'";
        }
      }
      String path = pathList.join("/");
      paths.add(path);
      // Uint8List privateKeyBytes = getPrivateKey(path);
      // // final privateKey = ECPrivate.fromBytes(privateKeyBytes);
      // privateKeys.add(privateKey);
    }

    final b = BitcoinTransactionBuilder(
      inputOrdering: BitcoinOrdering.none,
      outputOrdering: BitcoinOrdering.none,
      outPuts: () {
        List<BitcoinBaseOutput> outputs = [];
        for (int i = 0; i < btcTX.outputs.length; i++) {
          BitcoinBaseAddress tempAddress;
          if (btcTX.outputs[i].getPubKeyScriptType() == "P2WPKH") {
            tempAddress = P2wpkhAddress.fromAddress(
              address: getAddressFromBytes(
                btcTX.outputs[i].getAddress(),
                addressType: btcTX.outputs[i].getPubKeyScriptType(),
              ),
              network: BitcoinNetwork.mainnet,
            );
          } else if (btcTX.outputs[i].getPubKeyScriptType() == "P2TR") {
            tempAddress = P2trAddress.fromAddress(
              address: getAddressFromBytes(
                btcTX.outputs[i].getAddress(),
                addressType: btcTX.outputs[i].getPubKeyScriptType(),
              ),
              network: BitcoinNetwork.mainnet,
            );
          } else {
            tempAddress = P2wpkhAddress.fromAddress(
              address: getAddressFromBytes(
                btcTX.outputs[i].getAddress(),
                addressType: btcTX.outputs[i].getPubKeyScriptType(),
              ),
              network: BitcoinNetwork.mainnet,
            );
          }
          outputs.add(
            BitcoinOutput(address: tempAddress, value: btcTX.outputs[i].value),
          );
        }
        return outputs;
      }(),
      fee: btcTX.fee,
      network: BitcoinNetwork.mainnet,
      utxos: () {
        List<UtxoWithAddress> utxos = [];

        for (int i = 0; i < psbt.inputs.length; i++) {
          var publicKeyBytes = getPublicKey(paths[i]);
          BitcoinAddressType tempType;
          if (btcTX.inputs[i].utx.getPubKeyScriptType() == "P2TR") {
            tempType = SegwitAddressType.p2tr;
          } else {
            tempType = SegwitAddressType.p2wpkh;
          }
          utxos.add(
            UtxoWithAddress(
              utxo: BitcoinUtxo(
                /// Transaction hash uniquely identifies the referenced transaction
                txHash: hex.encode(
                  btcTX.inputs[i].previousOutHash.reversed.toList(),
                ),

                /// Value represents the amount of the UTXO in satoshis.
                value: btcTX.inputs[i].utx.value,

                /// Vout is the output index of the UTXO within the referenced transaction
                vout: btcTX.inputs[i].previousOutIndex,

                /// Script type indicates the type of script associated with the UTXO's address
                scriptType: tempType,
              ),

              /// Include owner details with the public key and address associated with the UTXO
              ownerDetails: UtxoAddressDetails(
                publicKey: hex.encode(publicKeyBytes),
                address: ECPublic.fromBytes(publicKeyBytes).toAddress(),
              ),
            ),
          );
        }

        return utxos;
      }(),
    );

    List<Uint8List>? sigList;
    await wallet.signingWallet!.startSession(context, await (
      dynamic session, {
      List<int>? pinCode,
      List<int>? pinCodeNew,
    }) async {
      wallet.signingWallet!.setMediumSession(session);
      sigList = await wallet.signingWallet!.getPSTSignature(pst, tx, "BTC");
      return true;
    });

    if (sigList == null) {
      return null;
    }

    sigList = adjustSignatures(sigList!);

    // print("expecting ${privateKeys.length} inputs");
    final tr = b.buildTransaction((trDigest, utxo, publicKey, int sighash) {
      /// For each input in the transaction, locate the corresponding private key
      /// and sign the transaction digest to construct the unlocking script.
      // for (int i = 0; i < privateKeys.length; i++) {
      //   print(
      //       "checking: ${privateKeys[i].getPublic().toHex()} with $publicKey");
      //   if (privateKeys[i].getPublic().toHex() != publicKey) {
      //     continue;
      //   }
      //   print("put a key, for $i");
      //   return privateKeys[i].signInput(trDigest);
      // }
      // // print("ERROR ERROR !!!!!!! $publicKey");
      // return "";
      // print("PUBLIC KEY: ${publicKey}");
      // print("PREIMAGE: ${hex.encode(trDigest)}");
      // print("SIG: ${hex.encode(sigList!.first)}");
      var sig = sigList![0].toList();
      sig.add(sighash);

      sigList!.removeAt(0);
      return hex.encode(sig);
    });

    return Uint8List.fromList(tr.toBytes(allowWitness: true));
  }

  List<Uint8List> adjustSignatures(List<Uint8List> sigList) {
    // check if the S value is too big
    BigInt n = BigInt.parse(
      "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141",
      radix: 16,
    );
    BigInt halfn = BigInt.parse(
      "7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0",
      radix: 16,
    );
    for (int i = 0; i < sigList.length; i++) {
      List<int> sig = sigList[i];
      int rLength = sig[3];
      int sIndex = 4 + rLength + 2;
      bool isSchnorr = sig.length == 64;
      if (isSchnorr) {
        rLength = 32;
        sIndex = 32;
      }
      String sHex = hex.encode(sig.sublist(sIndex));
      BigInt s = BigInt.parse(sHex, radix: 16);
      if (s < halfn) {
        continue;
      }
      s = n - s;
      sHex = s.toRadixString(16).padLeft(64, "0");
      // if ((sHex.length % 2) != 0) {
      //   sHex = "0" + sHex;
      // }
      List<int> sBytes = hex.decode(sHex);
      if (!isSchnorr) {
        if (sBytes[0] > 0x80) {
          sBytes = [0x00, ...sBytes];
        }
        sig[sIndex - 1] = sBytes.length;
      }
      // put the new length of s in the signature
      sig = [...sig.sublist(0, sIndex), ...sBytes];
      if (!isSchnorr) {
        sig[1] = sig.length - 2;
      }
      sigList[i] = Uint8List.fromList(sig);
    }

    return sigList;
  }

  @override
  Future<Uint8List?> signTx(PST? pst, Tx? tx, BuildContext? context) async {
    PSBT psbt = pst as PSBT;
    BitcoinTx btcTX = tx as BitcoinTx;

    // figureout the path of the input
    List<String> paths = [];
    // List<ECPrivate> privateKeys = [];
    bool useSigwit = false;
    for (int j = 0; j < psbt.inputs.length; j++) {
      List<String> pathList = ["m"];

      for (int i = 4; i < psbt.inputs[j][6]!["valuedata"]!.length; i += 4) {
        int tempNumber = psbt.inputs[j][6]!["valuedata"]![i];
        tempNumber += psbt.inputs[j][6]!["valuedata"]![i + 1] << (8 * 1);
        tempNumber += psbt.inputs[j][6]!["valuedata"]![i + 2] << (8 * 2);
        tempNumber +=
            (psbt.inputs[j][6]!["valuedata"]![i + 3] & 0x7f) << (8 * 3);
        pathList.add(tempNumber.toString());

        if ((psbt.inputs[j][6]!["valuedata"]![i + 3] & 128) == 128) {
          pathList.last += "'";
        }
      }
      String path = pathList.join("/");
      paths.add(path);
      // Uint8List privateKeyBytes = getPrivateKey(path);
      // // final privateKey = ECPrivate.fromBytes(privateKeyBytes);
      // privateKeys.add(privateKey);
    }

    final b = BitcoinTransactionBuilder(
      inputOrdering: BitcoinOrdering.none,
      outputOrdering: BitcoinOrdering.none,
      outPuts: () {
        List<BitcoinBaseOutput> outputs = [];
        for (int i = 0; i < btcTX.outputs.length; i++) {
          BitcoinBaseAddress address;
          Uint8List addressBytes = btcTX.outputs[i].getAddress();
          String addressType = btcTX.outputs[i].getPubKeyScriptType();
          String addressString = getAddressFromBytes(
            addressBytes,
            addressType: addressType,
          );
          if (btcTX.outputs[i].getPubKeyScriptType() == "P2WPKH") {
            address = P2wpkhAddress.fromAddress(
              address: addressString,
              network: BitcoinNetwork.mainnet,
            );
          } else if (btcTX.outputs[i].getPubKeyScriptType() == "P2WSH") {
            address = P2wshAddress.fromAddress(
              address: addressString,
              network: BitcoinNetwork.mainnet,
            );
          } else if (btcTX.outputs[i].getPubKeyScriptType() == "P2TR") {
            address = P2trAddress.fromAddress(
              address: addressString,
              network: BitcoinNetwork.mainnet,
            );
          } else if (btcTX.outputs[i].getPubKeyScriptType() == "P2PKH") {
            address = P2pkhAddress.fromAddress(
              address: addressString,
              network: BitcoinNetwork.mainnet,
            );
          } else if (btcTX.outputs[i].getPubKeyScriptType() == "P2SH") {
            address = P2shAddress.fromAddress(
              address: addressString,
              network: BitcoinNetwork.mainnet,
            );
          } else {
            print(
              "Unknow output type ${btcTX.outputs[i].getPubKeyScriptType()}",
            );
            continue;
          }

          outputs.add(
            BitcoinOutput(address: address, value: btcTX.outputs[i].value),
          );
        }
        return outputs;
      }(),
      fee: btcTX.fee,
      network: BitcoinNetwork.mainnet,
      enableRBF: true,
      utxos: () {
        List<UtxoWithAddress> utxos = [];

        for (int i = 0; i < psbt.inputs.length; i++) {
          var publicKeyBytes = getPublicKey(paths[i]);
          utxos.add(
            UtxoWithAddress(
              utxo: BitcoinUtxo(
                /// Transaction hash uniquely identifies the referenced transaction
                txHash: hex.encode(
                  btcTX.inputs[i].previousOutHash.reversed.toList(),
                ),

                /// Value represents the amount of the UTXO in satoshis.
                value: btcTX.inputs[i].utx.value,

                /// Vout is the output index of the UTXO within the referenced transaction
                vout: btcTX.inputs[i].previousOutIndex,

                /// Script type indicates the type of script associated with the UTXO's address
                scriptType: () {
                  var addressType = btcTX.inputs[i].utx.getPubKeyScriptType();
                  switch (addressType) {
                    case "P2PKH":
                      return P2pkhAddressType.p2pkh;
                    case "P2WPKH":
                      useSigwit = true;
                      return SegwitAddressType.p2wpkh;
                    case "P2TR":
                      useSigwit = true;
                      return SegwitAddressType.p2tr;
                  }
                  return SegwitAddressType.p2wpkh;
                }(),
              ),

              /// Include owner details with the public key and address associated with the UTXO
              ownerDetails: UtxoAddressDetails(
                publicKey: hex.encode(publicKeyBytes),
                address: ECPublic.fromBytes(publicKeyBytes).toAddress(),
              ),
            ),
          );
        }

        return utxos;
      }(),
    );

    List<Uint8List> preImageList = [];
    List<BitcoinSigningOptions> signingOptionsList = [];

    b.buildTransaction((trDigest, utxo, publicKey, int sighash) {
      preImageList.add(Uint8List.fromList(trDigest));
      // BitcoinOpCodeConst
      signingOptionsList.add(
        (sighash == BitcoinOpCodeConst.sighashDefault)
            ? BitcoinSigningOptions.TAPROOT()
            : BitcoinSigningOptions.SEGWIT(),
      );
      return "";
    });

    List<Uint8List> sigList = [];

    int MAX_SIG_ERROR = 5;

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
      Uint8List? tempSig;
      int counter = 0;
      for (int i = 0; i < preImageList.length; i++) {
        counter = 0;
        while (tempSig == null) {
          tempSig = await wallet.signingWallet!.signTX(
            preImageList[i],
            "BTC",
            true,
            paths: [paths[i]],
            coinOptions: signingOptionsList[i],
          );
          if (tempSig != null && tempSig.isNotEmpty) {
            sigList.add(tempSig);
            tempSig = null;
            break;
          }
          counter++;
          if (counter >= MAX_SIG_ERROR) {
            return false;
          }
        }
      }

      return true;
    });

    if (!success) {
      if (errorMes != null) {
        throw Exception(errorMes!);
      }
      return null;
    }

    if (sigList.length != preImageList.length) {
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
    for (int i = 0; i < sigList.length; i++) {
      // 0x02 is Taproot which uses Schnorr and format and length of signature are
      // 64 bytes without DER formatting
      if (signingOptionsList[i].getSigningType() == 0x02) {
        List<int> sig = sigList[i];
        int sIndex = 32;
        String sHex = hex.encode(sig.sublist(sIndex));
        BigInt s = BigInt.parse(sHex, radix: 16);
        if (s < halfn) {
          continue;
        }
        s = n - s;
        sHex = s.toRadixString(16).padLeft(64, "0");
        List<int> sBytes = hex.decode(sHex);
        // put the new length of s in the signature
        sig = [...sig.sublist(0, sIndex), ...sBytes];
        sigList[i] = Uint8List.fromList(sig);
      } else {
        List<int> sig = sigList[i];
        int rLength = sig[3];
        int sIndex = 4 + rLength + 2;
        String sHex = hex.encode(sig.sublist(sIndex));
        BigInt s = BigInt.parse(sHex, radix: 16);
        if (s < halfn) {
          continue;
        }
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
        sig[sIndex - 1] = sBytes.length;
        sig = [...sig.sublist(0, sIndex), ...sBytes];
        sig[1] = sig.length - 2;
        sigList[i] = Uint8List.fromList(sig);
      }
    }

    int counter = 0;
    var tr = b.buildTransaction((trDigest, utxo, publicKey, int sighash) {
      var finalSig = sigList[counter].toList();
      counter++;

      // don't add sighash if the transaction is taproot
      if (sighash != 0) {
        finalSig.add(sighash);
      }
      return hex.encode(finalSig);
    });

    return Uint8List.fromList(tr.toBytes(allowWitness: useSigwit));
  }

  @override
  List<String> getInitialDerivationPaths() {
    return [
      "m/44'/0'/0'",
      "m/44'/0'/0'/0",
      "m/44'/0'/0'/1",
      "m/84'/0'/0'",
      "m/84'/0'/0'/0",
      "m/84'/0'/0'/1",
      "m/86'/0'/0'",
      "m/86'/0'/0'/0",
      "m/86'/0'/0'/1",
    ];
    // return ["m/84'/0'/0'/0", "m/84'/0'/0'/1"];
  }

  @override
  List<String> getInitialEasyImportPaths() {
    // return ["m/44'/0'/0'/0", "m/44'/0'/0'/1", "m/84'/0'/0'/0", "m/84'/0'/0'/1", "m/86'/0'/0'/0", "m/86'/0'/0'/1"];
    return ["m/44'/0'/0'/0", "m/84'/0'/0'/0", "m/86'/0'/0'/0"];
  }

  @override
  Future<Block?> getStartBlock(
    bool isNew,
    bool easyImport,
    int? startYear, {
    int? blockHeight,
  }) async {
    if (isNew) {
      try {
        var URL = Uri.parse('https://mempool.space/api/blocks/tip');
        final response = await http.get(URL);
        List<dynamic> jObj = jsonDecode(response.body) as List<dynamic>;
        Map<String, dynamic> jsonBlock = jObj.last as Map<String, dynamic>;
        Block block = Block();
        block.coin = id;
        block.hash = jsonBlock["id"] ?? null;
        DateTime? time;
        if (jObj.last.containsKey("timestamp")) {
          int timeStamp = jsonBlock["timestamp"] as int;
          timeStamp *= 1000;
          time = DateTime.fromMillisecondsSinceEpoch(timeStamp);
        }
        block.time = time;
        block.height = jsonBlock["height"] ?? null;
        block.previousHash = jsonBlock["previousblockhash"];
        await block.save();
        return block;
      } catch (e) {
        print(e);
        var block = getCheckpointBlock(year: startYear, isNew: isNew);
        await block.save();
        return block;
      }
    }

    // this section only runs during import
    if (easyImport) {
      try {
        var URL = Uri.parse('https://mempool.space/api/blocks/tip');
        final response = await http.get(URL);
        List<dynamic> jObj = jsonDecode(response.body) as List<dynamic>;
        Map<String, dynamic> jsonBlock = jObj.last as Map<String, dynamic>;
        Block block = Block();
        block.coin = id;
        block.hash = jsonBlock["id"] ?? null;
        DateTime? time;
        if (jObj.last.containsKey("timestamp")) {
          int timeStamp = jsonBlock["timestamp"] as int;
          timeStamp *= 1000;
          time = DateTime.fromMillisecondsSinceEpoch(timeStamp);
        }
        block.time = time;
        block.height = jsonBlock["height"] ?? null;
        block.previousHash = jsonBlock["previousblockhash"];
        await block.save();
        return block;
      } catch (e) {
        print(e);
        var block = getCheckpointBlock(year: startYear, isNew: isNew);
        await block.save();
        return block;
      }
    }
    var block = getCheckpointBlock(year: startYear, isNew: isNew);
    await block.save();
    return block;
  }

  Future<Map<String, dynamic>?> sendTxBytes(Uint8List txBytes) async {
    // TODO: the correct way of sending this is to store it in a DB
    //       and add a check for setIsConnected where it sends all pending
    //       transactions when it gets connected
    if (!isConnected) {
      unsendTx.add(txBytes);
      return null;
    }
    return transmitTxBytes(txBytes);
  }

  String getAddressFromPath(
    String path, {
    String addressType = DEFAULT_TX_TYPE,
  }) {
    Uint8List pubKey = getPublicKey(path);
    Uint8List pubKeyAddressBytes = getAddress(pubKey, addressType);
    return getAddressFromBytes(pubKeyAddressBytes, addressType: addressType);
  }

  @override
  Future<List<TxDB>?> setupTransactionsForPathChildren(
    List<String> paths,
  ) async {
    if (isUIInstance) {
      getAssetIsolatePort().send(<String, dynamic>{
        "command": "setupTransactionsForPathChildren",
        "params": {"paths": paths},
      });
      return [];
    }
    Map<int, String> txIndex = {};
    List<TxDB> txList = [];
    var isar = Singleton.getDB();

    const ADDRESS_GAP_EXTERNAL = 20;
    const ADDRESS_GAP_INTERNAL = 200;

    // recalculate out address list
    getPublicKeyHashes(
      refresh: true,
      externalGap: ADDRESS_GAP_EXTERNAL,
      internalGap: ADDRESS_GAP_INTERNAL,
    );

    // Get transactions for each cild external address upto ADDRESS_GAP
    int gap = 0;
    int exIndex = 0;
    int inIndex = 0;
    List<String> inAddressList = [];
    Map<String, String> addressMap = {};
    Set<String> inAddressUsed = {};
    Set<String> inAddressSearched = {};
    String blockHash = "";
    // DateTime blockTime = DateTime.now();
    String inPath;
    List<String> pathParts;
    String addressType;

    String address;
    for (final path in paths) {
      pathParts = path.split("/");
      addressType = "P2WPKH";
      switch (pathParts[1]) {
        case "44'":
          addressType = "P2PKH";
        case "84'":
          addressType = "P2WPKH";
        case "86'":
          addressType = "P2TR";
      }

      // build the internal path
      inPath = (pathParts.sublist(0, pathParts.length - 1) + ["1"]).join("/");
      for (int i = 0; i < ADDRESS_GAP_INTERNAL; i++) {
        inIndex = i;
        address = getAddressFromPath(
          "$inPath/$inIndex",
          addressType: addressType,
        );
        inAddressList.add(address);
        addressMap[address] = "$inPath/$inIndex";
      }
    }

    List<BitcoinTx> tempTxList = [];
    String lastBlockHash = "";

    for (final path in paths) {
      gap = 0;
      exIndex = 0;
      inIndex = ADDRESS_GAP_INTERNAL;
      pathParts = path.split("/");
      inPath = (pathParts.sublist(0, pathParts.length - 1) + ["1"]).join("/");
      addressType = "P2WPKH";
      switch (pathParts[1]) {
        case "44'":
          addressType = "P2PKH";
        case "84'":
          addressType = "P2WPKH";
        case "86'":
          addressType = "P2TR";
      }

      bool inAddress = false;
      List<String> searchAddressList = [];
      List<dynamic> txs = [];

      while (gap < ADDRESS_GAP_EXTERNAL || !inAddressUsed.isEmpty) {
        searchAddressList.clear();
        if (inAddressUsed.isEmpty) {
          for (int i = 0; i < ADDRESS_GAP_EXTERNAL; i++) {
            searchAddressList.add(
              getAddressFromPath("$path/$exIndex", addressType: addressType),
            );
            addressMap[searchAddressList.last] = "$path/$exIndex";
            exIndex += 1;
          }
          inAddress = false;
        } else {
          searchAddressList.addAll(inAddressUsed);
          inAddressSearched.addAll(inAddressUsed);
          inAddressUsed.clear();
          inAddress = true;

          for (int i = 0; i < ADDRESS_GAP_EXTERNAL; i++) {
            inAddressList.add(
              getAddressFromPath("$inPath/$inIndex", addressType: addressType),
            );
            addressMap[inAddressList.last] = "$inPath/$inIndex";
            inIndex += 1;
          }
        }

        bool successful = false;
        int errorCounter = 0;
        const MAX_ERROR = 10;
        try {
          while (!successful && errorCounter < MAX_ERROR) {
            try {
              var URL = Uri.parse(
                'https://blockchain.info/multiaddr?active=${searchAddressList.join("|")}',
              );
              print(URL.toString());
              final response = await http
                  .get(URL)
                  .timeout(Duration(seconds: 5));
              Map<String, dynamic> jObj =
                  jsonDecode(response.body) as Map<String, dynamic>;
              txs = jObj["txs"];
              var infoMap = jObj["info"] as Map<String, dynamic>;
              var lastBlockMap =
                  infoMap["latest_block"] as Map<String, dynamic>;
              lastBlockHash = lastBlockMap["hash"];
              successful = true;
            } catch (e) {
              errorCounter++;
              Future.delayed(Duration(seconds: errorCounter * 2 + 2));
              continue;
            }
          }

          if (!successful) {
            continue;
          }

          if (txs.isEmpty) {
            if (!inAddress) {
              gap += ADDRESS_GAP_EXTERNAL;
            }
            continue;
          } else {
            gap = 0;
          }

          // sort the list
          txs.sort((a, b) {
            Map<String, dynamic> aMap = a as Map<String, dynamic>;
            Map<String, dynamic> bMap = b as Map<String, dynamic>;
            return aMap["time"] - bMap["time"];
          });

          // loop over the transactions
          for (var rawTx in txs) {
            Map<String, dynamic> jsonTx = rawTx as Map<String, dynamic>;
            String txHash = hex.encode(
              hex.decode(jsonTx["hash"]).reversed.toList(),
            );
            txIndex[jsonTx["tx_index"]] = txHash;

            BitcoinTx btctx = BitcoinTx();
            btctx.hash = Uint8List.fromList(hex.decode(txHash));

            // blockHash = jsonStatus["block_hash"];
            btctx.timestamp = DateTime.fromMillisecondsSinceEpoch(
              jsonTx["time"] * 1000,
            );
            btctx.fee = BigInt.from(jsonTx["fee"] as int);

            // check inputs
            String? prevOutHash;
            for (final inputObj in jsonTx["inputs"] as List<dynamic>) {
              Map<String, dynamic> input = inputObj as Map<String, dynamic>;
              Map<String, dynamic> prevout =
                  input["prev_out"] as Map<String, dynamic>;
              prevOutHash = txIndex[prevout["tx_index"]!];
              if (prevOutHash == null) {
                prevOutHash =
                    "INDEX-INDEX-INDEX-${prevout["tx_index"]! as int}";
              } else {
                prevOutHash = String.fromCharCodes(hex.decode(prevOutHash));
              }

              BitcoinTxIn txInput = BitcoinTxIn();
              txInput.previousOutHash = Uint8List.fromList(
                prevOutHash.codeUnits,
              );
              txInput.previousOutIndex = prevout["n"];
              BitcoinTxOut utx = BitcoinTxOut();
              utx.index = txInput.previousOutIndex;
              utx.scriptPubKey = Uint8List.fromList(
                hex.decode(prevout["script"]),
              );
              utx.pubKey = utx.getAddress();
              utx.value = BigInt.from(prevout["value"] as int);
              txInput.utx = utx;

              btctx.inputs.add(txInput);
            }

            // check outputs
            for (final outputObj in jsonTx["out"] as List<dynamic>) {
              Map<String, dynamic> output = outputObj as Map<String, dynamic>;

              BitcoinTxOut txOutput = BitcoinTxOut();
              var spendingOutput =
                  output["spending_outpoints"] as List<dynamic>;
              String? spendingHash;
              if (spendingOutput.isNotEmpty) {
                spendingHash =
                    txIndex[(spendingOutput[0]
                        as Map<String, dynamic>)["tx_index"]];
                spendingHash ??=
                    "INDEX-${(spendingOutput[0] as Map<String, dynamic>)["tx_index"]}";
              }
              txOutput.index = output["n"];
              txOutput.scriptPubKey = Uint8List.fromList(
                hex.decode(output["script"]),
              );
              txOutput.spent = output["spent"];
              txOutput.spendingHash = spendingHash;
              txOutput.txHash = Uint8List.fromList(hex.decode(txHash));
              txOutput.value = BigInt.from(output["value"] as int);

              btctx.outputs.add(txOutput);

              if (inAddressSearched.contains(output["addr"])) {
              } else if (inAddressList.contains(output["addr"])) {
                inAddressUsed.add(output["addr"]);
                pathParts = addressMap[output["addr"]]!.split("/");
                await setNextIndex(
                  pathParts.sublist(0, pathParts.length - 1).join("/"),
                  int.parse(pathParts.last) + 1,
                );
              } else if (searchAddressList.contains(output["addr"])) {
                pathParts = addressMap[output["addr"]]!.split("/");
                await setNextIndex(
                  pathParts.sublist(0, pathParts.length - 1).join("/"),
                  int.parse(pathParts.last) + 1,
                );
              }
            }
            tempTxList.add(btctx);
          }
        } catch (e) {
          print(e);
          // return null;
        }
      }
    }

    // Do some adjustments
    tempTxList.sort((a, b) {
      return a.timestamp!.isAfter(b.timestamp!) ? 1 : 0;
    });
    for (final btctx in tempTxList) {
      for (final output in btctx.outputs) {
        if (output.spendingHash != null &&
            output.spendingHash!.startsWith("INDEX-")) {
          output.spendingHash =
              txIndex[int.parse(output.spendingHash!.substring(6))];
        }
      }
    }
    // save txs
    for (final btctx in tempTxList) {
      await storeTransaction(
        btctx,
        confirmed: true,
        verified: true,
        failed: false,
        txTimeStamp: btctx.timestamp,
        blkHash: lastBlockHash,
      );
    }

    getPublicKeyHashes(refresh: true);

    txList =
        await isar.txDBs
            .filter()
            .coinEqualTo(id)
            .walletEqualTo(walletId)
            .findAll();

    txList.forEach((txdb) {
      if ((txdb.spent ?? true) == true ||
          ((txdb.isDeposit ?? false) == false)) {
        return;
      }
      BitcoinTxOut utxo = BitcoinTxOut(); // make new bitcointxout
      // populate utxo
      utxo.value = BigInt.from(txdb.amount!);
      utxo.scriptPubKey = Uint8List.fromList(hex.decode(txdb.lockingScript!));

      utxo.pubKey = Uint8List.fromList(
        pubKeyAddressMap[String.fromCharCodes(utxo.getAddress())]!.codeUnits,
      );
      utxo.txHash = Uint8List.fromList(hex.decode(txdb.hash!));
      utxo.index = txdb.outputIndex!;
      utxo.spent = txdb.spent!;
      // utxo.pubkey = Uint8List(0); // we don't know how to get this yet since it's not yet in txDB
      // possibly bech32 the public key hash
      var buf = Uint8List(4)
        ..buffer.asByteData().setUint32(0, utxo.index, Endian.little);
      utxoSet['${txdb.hash!}${hex.encode(buf)}'] = utxo;
      utxoSetChanged = true;
    });

    // for (final key in utxoSet.keys) {
    //   print("$key: ${utxoSet[key]!.value} ${utxoSet[key]!.spent}");
    // }

    final balance =
        Balance()
          ..coin = id
          ..wallet = walletId
          ..coinBalance = getBalance().toInt()
          ..usdBalance = null
          ..fiatBalanceDC = null
          ..lastUpdate = DateTime.now()
          ..lastBlockUpdate = blockHash;
    await balance.save();
    notifyListeners();

    return txList;
  }

  Block getCheckpointBlock({int? year, bool? isNew}) {
    List<Block> checkpointBlocks = [
      // first block
      Block()
        ..hash =
            "00000000839a8e6886ab5951d76f411475428afc90947ee320161bbf18eb6048"
        ..height = 1
        ..previousHash =
            "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f"
        ..time = DateTime.parse("2009-01-09 10:54:25"),
      // 2024
      Block()
        ..hash =
            "00000000000000000001361599d1dac4e30e805f9b4112061e97769f5930a696"
        ..height = 823739
        ..previousHash =
            "000000000000000000011c530c4720607944f9485de38f6fd4792cb1bb69aa06"
        ..time = DateTime.parse("2024-01-01 00:05:17"),
      // 2025
      Block()
        ..hash =
            "00000000000000000000bf5895e5bb0e3d7afdd6f2f36686306a9ab4b92a2305"
        ..height = 877222
        ..previousHash =
            "00000000000000000000d447ed787552c0459709714f31eb725eb46a323d3dde"
        ..time = DateTime.parse("2025-01-01 00:21:38"),
      // Latest
      Block()
        ..hash =
            "0000000000000000000065cf652b48b1dc2d2a7c089f1ad579ef8b7cdcf2014e"
        ..height = 883252
        ..previousHash =
            "00000000000000000000177b2c98eef41f69d0269636457d652dcb0fa44f83f7"
        ..time = DateTime.parse("2025-02-11 10:54:05"),
    ];

    Block blk;
    if (isNew ?? true) {
      blk = checkpointBlocks.last;
      blk.coin = id;
      return blk;
    }
    if (year == null) {
      blk = checkpointBlocks.first;
      blk.coin = id;
      return blk;
    }

    blk = checkpointBlocks.first;

    for (Block block in checkpointBlocks.sublist(
      0,
      checkpointBlocks.length - 1,
    )) {
      if (block.time!.year <= year) {
        blk = block;
      }
    }

    blk.coin = id;
    return blk;
  }

  Future<void> storeTransaction(
    Tx tx, {
    PST? pst,
    bool confirmed = true,
    bool verified = true,
    bool failed = false,
    DateTime? txTimeStamp,
    String? blkHash,
  }) async {
    BitcoinTx btctx = tx as BitcoinTx;

    List<TxDB> txList = [];
    bool changed = false;

    // store outputs where the address belongs to the wallet
    bool belongToWallet;
    Uint8List buf;
    String txHash = btctx.getHashHex();
    for (final (index, output) in btctx.outputs.indexed) {
      belongToWallet = false;
      Uint8List address = output.getAddress();
      for (int j = 0; j < addressList.length; j++) {
        if (ListEquality().equals(addressList[j], address)) {
          belongToWallet = true;
          break;
        }
      }

      TxDB txdb =
          TxDB()
            ..amount = output.value.toInt()
            ..coin = id
            ..confirmed = confirmed
            ..failed = failed
            ..fee = btctx.fee.toInt()
            ..hash = txHash
            ..isDeposit = belongToWallet
            ..outputIndex = output.index
            ..spent = output.spent
            ..spendingTxHash = output.spendingHash
            ..verified = verified
            ..wallet = walletId
            ..time = txTimeStamp
            ..lockingScript = hex.encode(output.scriptPubKey)
            ..lockingScriptType = output.getPubKeyScriptType();

      if (belongToWallet) {
        buf = Uint8List(4)
          ..buffer.asByteData().setUint32(0, index, Endian.little);
        utxoSet['${txHash}${hex.encode(buf)}'] = tx.outputs[index];
        changed = true;
        utxoSetChanged = true;
      }

      txList.add(txdb);
    }

    PSBT? psbt = pst as PSBT?;
    if (psbt != null) {
      for (final (index, _) in tx.inputs.indexed) {
        Uint8List utxoBytes = psbt.inputs[index][1]!["valuedata"]!;
        BitcoinTxOut utxo = BitcoinTxOut.parseFromBytes(utxoBytes);
        tx.inputs[index].utx = utxo;
      }
    }

    // store all inputs as spending
    var isar = Singleton.getDB();
    bool hasOurUTXO = false;
    for (final input in tx.inputs) {
      var address = input.utx.getAddress();
      for (int j = 0; j < addressList.length; j++) {
        if (ListEquality().equals(addressList[j], address)) {
          hasOurUTXO = true;
          break;
        }
      }

      TxDB? utx = isar.txDBs.getByHashCoinOutputIndexSync(
        hex.encode(input.previousOutHash),
        id,
        input.previousOutIndex,
      );
      if (utx == null) {
        continue;
      } else {
        hasOurUTXO = true;
        changed = true;
        utx.spent = true;
        utx.spendingTxHash = txHash;
        utx.save();

        buf = Uint8List(4)
          ..buffer.asByteData().setUint32(
            0,
            input.previousOutIndex,
            Endian.little,
          );
        utxoSet['${hex.encode(input.previousOutHash)}${hex.encode(buf)}']
            ?.spent = true;
        utxoSetChanged = true;
      }
    }

    if (!hasOurUTXO) {
      for (int i = txList.length - 1; i >= 0; i--) {
        if (!txList[i].isDeposit!) {
          txList.removeAt(i);
        }
      }
    }

    for (int i = 0; i < txList.length; i++) {
      await txList[i].save();
      // print("TX saved: ${txHash}");
      changed = true;
    }

    if (changed) {
      final balance =
          Balance()
            ..coin = id
            ..wallet = walletId
            ..coinBalance = getBalance().toInt()
            ..usdBalance = null
            ..fiatBalanceDC = null
            ..lastUpdate = txTimeStamp
            ..lastBlockUpdate = blkHash;
      await balance.save();
      notifyListeners();
    }
    txBlockHash.remove(txHash);
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
        txMap[tx.hash!]!.usdAmount = tx.usdAmount ?? 0.0;
      } else if (txMap[tx.hash]!.time == null) {
        txMap[tx.hash!]!.time = tx.time!;
        txMap[tx.hash!]!.fee = tx.fee!;
        txMap[tx.hash!]!.usdAmount = tx.usdAmount ?? 0.0;
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
      } else {
        BitcoinTxOut txout = BitcoinTxOut();
        txout.scriptPubKey = Uint8List.fromList(
          hex.decode(tx.lockingScript ?? ""),
        );
        txMap[tx.hash!]!.outAddress = getAddressFromBytes(
          txout.getAddress(),
          addressType: txout.getPubKeyScriptType(),
        );
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

  bool isValidAddress(String address) {
    List<int> validAddressLength = [34, 42, 44, 62];
    if (!validAddressLength.contains(address.length)) {
      return false;
    }
    var addressBytes = getAddressBytes(address);
    if (addressBytes.isEmpty) {
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
    txHash = hex.encode(hex.decode(txHash).reversed.toList());
    return "https://mempool.space/tx/${txHash}";
  }

  @override
  void receiveResponse(Map<String, dynamic> message) {
    if (message["command"] is String) {
      switch (message["command"]) {
        case "notifyListeners":
          balance = message["balance"];
          isConnected = message["isConnected"];
          utxoSet = message["utxoSet"] ?? utxoSet;
          pubKeyAddressPathMap =
              message["pubKeyAddressPathMap"] ?? pubKeyAddressPathMap;
          notifyListeners();
      }
    }
  }

  @override
  Map<String, dynamic> getState() {
    Map<String, dynamic> state = {
      "command": "notifyListeners",
      "balance": getBalance(),
      "isConnected": isConnected,
    };
    if (utxoSetChanged) {
      state["utxoSet"] = utxoSet;
      state["pubKeyAddressPathMap"] = pubKeyAddressPathMap;
      utxoSetChanged = false;
    }
    return state;
  }
}
