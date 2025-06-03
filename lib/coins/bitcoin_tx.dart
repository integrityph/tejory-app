import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:blockchain_utils/hex/hex.dart';
import 'package:tejory/coins/bitcoin_tx_in.dart';
import 'package:tejory/coins/bitcoin_tx_out.dart';
import 'package:tejory/coins/btc_helper.dart';
import 'package:tejory/coins/tx.dart';

class BitcoinTx implements Tx {
  Uint8List body = Uint8List(0);
  Uint8List hash = Uint8List(0);
  Uint8List whash = Uint8List(0);
  DateTime? timestamp;
  int version = 0;
  bool segwit = false;
  int inCount = 0;
  List<BitcoinTxIn> inputs = [];
  int outCount = 0;
  List<BitcoinTxOut> outputs = [];
  int lockTime = 0;
  BigInt fee = BigInt.zero;
  Map<int, String> globalKeyTypeMap = {
    0x00: "PSBT_GLOBAL_UNSIGNED_TX",
    0x01: "PSBT_GLOBAL_XPUB",
    0x02: "PSBT_GLOBAL_TX_VERSION",
    0x03: "PSBT_GLOBAL_FALLBACK_LOCKTIME",
    0x04: "PSBT_GLOBAL_INPUT_COUNT",
    0x05: "PSBT_GLOBAL_OUTPUT_COUNT",
    0x06: "PSBT_GLOBAL_TX_MODIFIABLE",
    0xFB: "PSBT_GLOBAL_VERSION",
    0xFC: "PSBT_GLOBAL_PROPRIETARY",
  };

  Map<int, String> inputKeyTypeMap = {
    0x00: 'PSBT_IN_NON_WITNESS_UTXO',
    0x01: 'PSBT_IN_WITNESS_UTXO',
    0x02: 'PSBT_IN_PARTIAL_SIG',
    0x03: 'PSBT_IN_SIGHASH_TYPE',
    0x04: 'PSBT_IN_REDEEM_SCRIPT',
    0x05: 'PSBT_IN_WITNESS_SCRIPT',
    0x06: 'PSBT_IN_BIP32_DERIVATION',
    0x07: 'PSBT_IN_FINAL_SCRIPTSIG',
    0x08: 'PSBT_IN_FINAL_SCRIPTWITNESS',
    0x09: 'PSBT_IN_POR_COMMITMENT',
    0x0a: 'PSBT_IN_RIPEMD160',
    0x0b: 'PSBT_IN_SHA256',
    0x0c: 'PSBT_IN_HASH160',
    0x0d: 'PSBT_IN_HASH256',
    0x0e: 'PSBT_IN_PREVIOUS_TXID',
    0x0f: 'PSBT_IN_OUTPUT_INDEX',
    0x10: 'PSBT_IN_SEQUENCE',
    0x11: 'PSBT_IN_REQUIRED_TIME_LOCKTIME',
    0x12: 'PSBT_IN_REQUIRED_HEIGHT_LOCKTIME',
    0x13: 'PSBT_IN_TAP_KEY_SIG',
    0x14: 'PSBT_IN_TAP_SCRIPT_SIG',
    0x15: 'PSBT_IN_TAP_LEAF_SCRIPT',
    0x16: 'PSBT_IN_TAP_BIP32_DERIVATION',
    0x17: 'PSBT_IN_TAP_INTERNAL_KEY',
    0x18: 'PSBT_IN_TAP_MERKLE_ROOT',
    0xFC: 'PSBT_IN_PROPRIETARY',
  };

  Map<int, String> outputKeyTypeMap = {
    0x00: 'PSBT_OUT_REDEEM_SCRIPT',
    0x01: 'PSBT_OUT_WITNESS_SCRIPT',
    0x02: 'PSBT_OUT_BIP32_DERIVATION',
    0x03: 'PSBT_OUT_AMOUNT',
    0x04: 'PSBT_OUT_SCRIPT',
    0x05: 'PSBT_OUT_TAP_INTERNAL_KEY',
    0x06: 'PSBT_OUT_TAP_TREE',
    0x07: 'PSBT_OUT_TAP_BIP32_DERIVATION',
    0xFC: 'PSBT_OUT_PROPRIETARY',
  };

  BitcoinTx();
  BitcoinTx.fromTxBytes(Uint8List buffer) {
    try {
      body = buffer.sublist(0);
      
      whash = Uint8List.fromList(sha256.convert(sha256.convert(body).bytes).bytes);
      
      version = ByteData.view(buffer.sublist(0, 4).buffer).getUint32(0, Endian.little);
      int offset = 4;

      segwit = false;
      if (body[offset] == 0 && body[offset+1] == 1) {
        segwit = true;
        offset += 2;
      }

      inCount = 0;
      int byteCount = 0;
      int temp = 0;
      (temp, byteCount) = parseVarint(buffer, offset);
      inCount = temp;
      offset += byteCount;

      inputs = [];
      int scriptLength = 0;
      for (int i = 0; i < inCount; i++) {
        BitcoinTxIn txIn = BitcoinTxIn();
        txIn.previousOutHash = buffer.sublist(offset, offset + 32);
        txIn.previousOutIndex =
            ByteData.view(buffer.sublist(offset + 32, offset + 36).buffer)
                .getUint32(0, Endian.little);
        (scriptLength, byteCount) = parseVarint(buffer, offset + 36);
        offset += byteCount + 36;

        txIn.scriptSig = buffer.sublist(offset, offset + scriptLength);
        offset += scriptLength;

        txIn.sequence = ByteData.view(buffer.sublist(offset, offset + 4).buffer)
            .getUint32(0, Endian.little);
        inputs.add(txIn);
        offset += 4;
      }

      outCount = 0;
      (temp, byteCount) = parseVarint(buffer, offset);
      offset += byteCount;

      outCount = temp;
      outputs = [];
      for (int i = 0; i < outCount; i++) {
        BitcoinTxOut txOut = BitcoinTxOut();
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
        txOut.index = i;
        outputs.add(txOut);
        offset += scriptLength;
      }
      int witnessIndex = offset;
      if (segwit) {
        int witnessCount = 0;

        for (int i = 0; i < inCount; i++) {
          (witnessCount, byteCount) = parseVarint(buffer, offset);
          offset += byteCount;
          for (int j = 0; j < witnessCount; j++) {
            (scriptLength, byteCount) = parseVarint(buffer, offset);
            offset += byteCount;
            Uint8List witness = buffer.sublist(offset, offset + scriptLength);
            inputs[i].witnesses.add(witness);
            offset += scriptLength;
          }
        }
      }

      lockTime = ByteData.view(buffer.sublist(offset, offset + 4).buffer)
          .getUint32(0, Endian.little);

      if (segwit) {
        List<int> txRaw = buffer.sublist(0, 4);
        txRaw += buffer.sublist(6, witnessIndex);
        txRaw += buffer.sublist(offset, offset + 4);
        hash = Uint8List.fromList(
            sha256.convert(sha256.convert(txRaw).bytes).bytes);
      } else {
        hash = whash;
      }
    } catch (e) {
      print("FAILED TX PARSING");
    }
  }

  BitcoinTx fromTxBytes(Uint8List buffer) {
    return BitcoinTx.fromTxBytes(buffer);
  }

  Uint8List getRawTX() {
    List<int> raw = Uint8List(0);

    // version
    int txVersion = 1;
    if (version != 0) {
      txVersion = version;
    }
    raw += Uint8List(4)
      ..buffer.asByteData().setUint32(0, txVersion, Endian.little);

    // flag
    if (segwit) {
      raw += [0, 1];
    }

    raw += makeVarint(BigInt.from(inputs.length));
    inputs.forEach((val) => raw += val.getRawBytes());

    //Output Part
    raw += makeVarint(BigInt.from(outputs.length));
    for (int i = 0; i < outputs.length; i++) {
      raw += outputs[i].getRawBytes();
    }
    // outputs.forEach((val) => raw += val.getRawBytes());

    if (segwit) {
      for (int i = 0; i < inCount; i++) {
        raw += makeVarint(BigInt.from(inputs[i].witnesses.length));
        for (int j = 0; j < inputs[i].witnesses.length; j++) {
          raw += inputs[i].witnesses[j];
        }
      }
    }

    raw += Uint8List(4)
      ..buffer.asByteData().setUint32(0, lockTime, Endian.little);

    return Uint8List.fromList(raw);
  }

  String getHashHex() {
    return hex.encode(hash);
  }

  String getWHashHex() {
    return hex.encode(whash);
  }

  BigInt getFee() {
    return fee;
  }
}
