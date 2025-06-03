import 'dart:typed_data';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:tejory/coins/btc_helper.dart';

class BitcoinTxOut {
  BigInt value = BigInt.zero;
  Uint8List scriptPubKey = Uint8List(0);
  Uint8List txHash = Uint8List(0);
  Uint8List pubKey = Uint8List(0); // hindi nagagamit
  String? spendingHash;
  int index = 0;
  bool spent = false;

  static int OP_DUP = 0x76;
  static int OP_HASH160 = 0xA9;
  static int OP_EQUALVERIFY = 0x88;
  static int OP_CHECKSIG = 0xAC;
  static int OP_EQUAL = 0x87;
  static int OP_0 = 0x00;
  static int OP_1 = 0x51;

  static BitcoinTxOut parseFromBytes(Uint8List buffer) {
    BitcoinTxOut txOut = BitcoinTxOut();
    int offset = 0;
    int scriptLength = 0;
    int byteCount = 0;
    BigInt value = BigInt.zero;

    for (int j = 7; j >= 0; j--) {
      value <<= 8;
      value |= BigInt.from(buffer[offset + j]);
    }
    txOut.value = value.toUnsigned(64);
    offset += 8;
    (scriptLength, byteCount) = parseVarint(buffer, offset);
    offset += byteCount;
    txOut.scriptPubKey = buffer.sublist(offset, offset + scriptLength);
    txOut.pubKey = txOut.getAddress();

    return txOut;
  }

  double getValueInBTC() {
    return (value as double) / 100000000.0;
  }

  Uint8List getRawBytes() {
    List<int> raw = [];
    raw +=
        hex.decode(value.toRadixString(16).padLeft(16, '0')).reversed.toList();
    raw += makeVarint(BigInt.from(scriptPubKey.length));
    raw += scriptPubKey;

    return Uint8List.fromList(raw);
  }

  Uint8List getAddress() {
    if (getPubKeyScriptType() == "P2PKH") {
      return Uint8List.fromList(scriptPubKey.sublist(3, scriptPubKey.length-2));
    }
    if (getPubKeyScriptType() == "P2SH") {
      return Uint8List.fromList(scriptPubKey.sublist(2, scriptPubKey.length-1));
    }
    if (getPubKeyScriptType() == "P2WPKH") {
      return Uint8List.fromList(scriptPubKey.sublist(2));
    }
    if (getPubKeyScriptType() == "P2WSH") {
      return Uint8List.fromList(scriptPubKey.sublist(2));
    }
    if (getPubKeyScriptType() == "P2TR") {
      return Uint8List.fromList(scriptPubKey.sublist(2));
    }
    return Uint8List(0);
  }

  Uint8List getAmountBytes() {
    return Uint8List(8)
      ..buffer.asByteData().setUint64(0, value.toInt(), Endian.little);
  }

  Uint8List getScriptPubKeyBytes() {
    return scriptPubKey;
  }

  String getPubKeyScriptType() {
    // DONE: check locking script and produce the correct type (e.g. P2PKH)
    // c/o sir nikko
    // constants here. can be moved
    if (scriptPubKey.length == 25 &&
        scriptPubKey[0] == OP_DUP &&
        scriptPubKey[1] == OP_HASH160 &&
        scriptPubKey[2] == 20 &&
        scriptPubKey[23] == OP_EQUALVERIFY &&
        scriptPubKey[24] == OP_CHECKSIG) {
      return "P2PKH";
    } else if (scriptPubKey.length == 23 &&
        scriptPubKey[0] == OP_HASH160 &&
        scriptPubKey[1] == 20 &&
        scriptPubKey[22] == OP_EQUAL) {
      return "P2SH";
    } else if (scriptPubKey.length == 22 &&
        scriptPubKey[0] == OP_0 &&
        scriptPubKey[1] == 20) {
      return "P2WPKH";
    } else if (scriptPubKey.length == 34 &&
        scriptPubKey[0] == OP_0 &&
        scriptPubKey[1] == 32) {
      return "P2WSH";
    } else if (scriptPubKey.length == 34 &&
        scriptPubKey[0] == OP_1 &&
        scriptPubKey[1] == 32) {
      return "P2TR";
    }
    return "UNKNOWNTYPE";
  }

  static Uint8List getLockingScriptFromAddress(
      Uint8List address, String scriptType) {
    List<int> tempScript = [];
    switch (scriptType) {
      case "P2PKH":
        tempScript.add(OP_DUP);
        tempScript.add(OP_HASH160);
        tempScript.add(20);
        tempScript.addAll(address);
        tempScript.add(OP_EQUALVERIFY);
        tempScript.add(OP_CHECKSIG);
        break;
      case "P2SH":
        tempScript.add(OP_HASH160);
        tempScript.add(20);
        tempScript.addAll(address);
        tempScript.add(OP_EQUAL);
        break;
      case "P2WPKH":
        tempScript.add(OP_0);
        tempScript.add(20);
        tempScript.addAll(address);
        break;
      case "P2WSH":
        tempScript.add(OP_0);
        tempScript.add(32);
        tempScript.addAll(address);
        break;
      case "P2TR":
        tempScript.add(OP_1);
        tempScript.add(32);
        tempScript.addAll(address);
        break;
      default:
        print("UNKNOW locking script type");
    }

    return Uint8List.fromList(tempScript);
  }

  String? getScriptPubKey() {
    return hex.encode(scriptPubKey);
  }
}
