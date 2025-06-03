import 'dart:typed_data';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:tejory/coins/const.dart';
import 'package:tejory/crypto-helper/keccak.dart';
import 'package:tejory/crypto-helper/other_helpers.dart';
import 'package:tejory/crypto-helper/rlp.dart';

import 'tx.dart';

class EtherTx implements Tx {
  // Compliance with EIP-1559
  // https://eips.ethereum.org/EIPS/eip-1559

  // Signing Tx
  // The signature_y_parity, signature_r, signature_s elements of this transaction represent a secp256k1 signature over
  // keccak256(0x02 || rlp([chain_id, nonce, max_priority_fee_per_gas, max_fee_per_gas, gas_limit, destination, amount, data, access_list]))

  int chainId = 0;
  int nonce = 0;
  BigInt maxPriorityFeePerGas = BigInt.zero;
  BigInt maxFeePerGas = BigInt.zero;
  int gasLimit = 21000;
  Uint8List destination = Uint8List(0);
  BigInt amount = BigInt.zero;
  Uint8List data = Uint8List(0);
  List<Tuple<BigInt, List<BigInt>>> accessList = [];
  int signatureYParity = 0;
  Uint8List signatureR = Uint8List(0);
  Uint8List signatureS = Uint8List(0);
  int type = 0;

  EtherTx();
  @override
  fromTxBytes(Uint8List buffer) {
    // sanity check
    if (buffer.length < 4) {
      return;
    }
    // check if this is a legacy or EIP-2718
    if (buffer[0] < 0x7f) {
      type = buffer[0];
      if (type == 1) {
        // EIP-2930
        parseType1(buffer);
      } else if (type == 2) {
        // EIP-1559
        parseType2(buffer);
      } else {
        return;
      }
    } else if (buffer[0] >= 0xc0 && buffer[0] >= 0xfe) {
      // legacy
      type = 0;
      parseLegacy(buffer);
    } else {
      // unknown type
      return;
    }
  }

  void parseLegacy(Uint8List buffer) {
    // rlp([nonce, gasPrice, gasLimit, to, value, data, v, r, s])
    var rObj = RLP.decode(buffer);

    // sanity check
    if (!(rObj is List)) {
      return;
    }
    if (rObj.length != 9) {
      return;
    }

    try {
      nonce = int.parse(rObj[0], radix: 16);
    } catch (e) {
      nonce = 0;
    }
    try {
      maxFeePerGas = BigInt.parse(rObj[1], radix: 16);
    } catch (e) {
      maxFeePerGas = BigInt.zero;
    }
    try {
      gasLimit = int.parse(rObj[2], radix: 16);
    } catch (e) {
      gasLimit = 0;
    }
    destination = Uint8List.fromList(hex.decode(rObj[3]));
    try {
      amount = BigInt.parse(rObj[4], radix: 16);
    } catch (e) {
      amount = BigInt.zero;
    }
    data = Uint8List.fromList(hex.decode(rObj[5]));
    try {
      signatureYParity = int.parse(rObj[6], radix: 16);
    } catch (e) {
      signatureYParity = 0;
    }
    signatureR = Uint8List.fromList(hex.decode(rObj[7]));
    signatureS = Uint8List.fromList(hex.decode(rObj[8]));
  }

  void parseType1(Uint8List buffer) {
    // rlp([chainId, nonce, gasPrice, gasLimit, to, value, data, accessList, signatureYParity, signatureR, signatureS])
    var rObj = RLP.decode(buffer);

    // sanity check
    if (!(rObj is List)) {
      return;
    }
    if (rObj.length != 12) {
      return;
    }

    try {
      chainId = int.parse(rObj[0], radix: 16);
    } catch (e) {
      chainId = 0;
    }
    try {
      nonce = int.parse(rObj[1], radix: 16);
    } catch (e) {
      nonce = 0;
    }
    try {
      maxFeePerGas = BigInt.parse(rObj[2], radix: 16);
    } catch (e) {
      maxFeePerGas = BigInt.zero;
    }
    try {
      gasLimit = int.parse(rObj[3], radix: 16);
    } catch (e) {
      gasLimit = 0;
    }
    destination = Uint8List.fromList(hex.decode(rObj[4]));
    try {
      amount = BigInt.parse(rObj[5], radix: 16);
    } catch (e) {
      amount = BigInt.zero;
    }
    data = Uint8List.fromList(hex.decode(rObj[6]));
    if (!(rObj[7] is List)) {
      return;
    }
    accessList = () {
      List<Tuple<BigInt, List<BigInt>>> val = [];

      BigInt item1;
      List<dynamic> item2Raw;
      List<BigInt> item2;
      for (int i = 0; i < rObj[7].length; i++) {
        item1 = BigInt.parse(rObj[7][i][0], radix: 16);
        item2Raw = rObj[7][i][1] as List<dynamic>;
        item2 = [];
        for (int j = 0; j < item2Raw.length; j++) {
          item2.add(BigInt.parse(item2Raw[j] as String, radix: 16));
        }
        val.add(Tuple<BigInt, List<BigInt>>(item1, item2));
      }

      return val;
    }();
    try {
      signatureYParity = int.parse(rObj[8], radix: 16);
    } catch (e) {
      signatureYParity = 0;
    }
    signatureR = Uint8List.fromList(hex.decode(rObj[9]));
    signatureS = Uint8List.fromList(hex.decode(rObj[10]));
  }

  void parseType2(Uint8List buffer) {
    // rlp([chain_id, nonce, max_priority_fee_per_gas, max_fee_per_gas, gas_limit, destination, amount, data, access_list, signature_y_parity, signature_r, signature_s])
    var rObj = RLP.decode(buffer);

    // sanity check
    if (!(rObj is List)) {
      return;
    }
    if (rObj.length != 12) {
      return;
    }

    try {
      chainId = int.parse(rObj[0], radix: 16);
    } catch (e) {
      chainId = 0;
    }
    try {
      nonce = int.parse(rObj[1], radix: 16);
    } catch (e) {
      nonce = 0;
    }
    try {
      maxPriorityFeePerGas = BigInt.parse(rObj[2], radix: 16);
    } catch (e) {
      maxPriorityFeePerGas = BigInt.zero;
    }
    try {
      maxFeePerGas = BigInt.parse(rObj[3], radix: 16);
    } catch (e) {
      maxFeePerGas = BigInt.zero;
    }
    try {
      gasLimit = int.parse(rObj[4], radix: 16);
    } catch (e) {
      gasLimit = 0;
    }
    destination = Uint8List.fromList(hex.decode(rObj[5]));
    try {
      amount = BigInt.parse(rObj[6], radix: 16);
    } catch (e) {
      amount = BigInt.zero;
    }
    data = Uint8List.fromList(hex.decode(rObj[7]));
    if (!(rObj[8] is List)) {
      return;
    }
    accessList = () {
      List<Tuple<BigInt, List<BigInt>>> val = [];

      BigInt item1;
      List<dynamic> item2Raw;
      List<BigInt> item2;
      for (int i = 0; i < rObj[8].length; i++) {
        item1 = BigInt.parse(rObj[8][i][0], radix: 16);
        item2Raw = rObj[8][i][1] as List<dynamic>;
        item2 = [];
        for (int j = 0; j < item2Raw.length; j++) {
          item2.add(BigInt.parse(item2Raw[j] as String, radix: 16));
        }
        val.add(Tuple<BigInt, List<BigInt>>(item1, item2));
      }

      return val;
    }();
    try {
      signatureYParity = int.parse(rObj[9], radix: 16);
    } catch (e) {
      signatureYParity = 0;
    }
    signatureR = Uint8List.fromList(hex.decode(rObj[10]));
    signatureS = Uint8List.fromList(hex.decode(rObj[11]));
  }

  @override
  BigInt getFee() {
    return maxFeePerGas * BigInt.from(gasLimit);
  }

  @override
  String getHashHex() {
    var buf = getRawTX();
    return hex.encode(keccak(buf));
  }

  @override
  Uint8List getRawTX() {
    List<dynamic> val = [];
    if (type == 0) {
      // legacy
      // rlp([nonce, gasPrice, gasLimit, to, value, data, v, r, s])
      int v = Constants.ETHER_CHAIN_ID;
      if (signatureR.length != 0) {
        v = signatureYParity + Constants.ETHER_CHAIN_ID * 2 + 35;
      }
      val = [
        nonce,
        maxFeePerGas,
        gasLimit,
        String.fromCharCodes(destination),
        amount,
        String.fromCharCodes(data),
        v,
        String.fromCharCodes(signatureR),
        String.fromCharCodes(signatureS)
      ];
    } else if (type == 1) {
      // rlp([chainId, nonce, gasPrice, gasLimit, to, value, data, accessList, signatureYParity, signatureR, signatureS])
      List<dynamic> accessListRaw = [];
      List<dynamic> item = [];
      for (int i = 0; i < accessList.length; i++) {
        item = [accessList[i].item1, accessList[i].item2];
        accessListRaw.add(item);
      }
      val = [
        chainId,
        nonce,
        maxFeePerGas,
        gasLimit,
        String.fromCharCodes(destination),
        amount,
        String.fromCharCodes(data),
        accessListRaw,
        signatureYParity,
        String.fromCharCodes(signatureR),
        String.fromCharCodes(signatureS)
      ];
    } else if (type == 2) {
      // rlp([chain_id, nonce, max_priority_fee_per_gas, max_fee_per_gas, gas_limit, destination, amount, data, access_list, signature_y_parity, signature_r, signature_s])
      // keccak256(0x02 || rlp([chain_id, nonce, max_priority_fee_per_gas, max_fee_per_gas, gas_limit, destination, amount, data, access_list])).
      List<dynamic> accessListRaw = [];
      List<dynamic> item = [];
      for (int i = 0; i < accessList.length; i++) {
        item = [accessList[i].item1, accessList[i].item2];
        accessListRaw.add(item);
      }
      val = [
        chainId,
        nonce,
        maxPriorityFeePerGas,
        maxFeePerGas,
        gasLimit,
        String.fromCharCodes(destination),
        amount,
        String.fromCharCodes(data),
        accessListRaw
      ];
      if (signatureR.length != 0) {
        val = [
          ...val,
          signatureYParity,
          BigInt.parse(hex.encode(signatureR), radix:16),
          BigInt.parse(hex.encode(signatureS), radix:16)
        ];
      }
    }

    List<int> envType = () {
      if (type == 0) {
        return <int>[];
      }
      return [type];
    }();

    var txBytes = Uint8List.fromList([...envType, ...RLP.encode(val)]);
    return txBytes;
  }

  void setSignature(Uint8List sigRaw, Uint8List pubKey) {
    var hash = hex.decode(getHashHex());
    List<int> sig = sigRaw;
    int rLength = sig[3];
    int rIndex = 4;
    int sIndex = 4 + rLength + 2;
    List<int> s = sig.sublist(sIndex);
    List<int> r = sig.sublist(rIndex, rIndex + rLength);
    signatureR = Uint8List.fromList(r);
    signatureS = Uint8List.fromList(s);
    signatureYParity = OtherHelpers.getYParity(pubKey, hash, sigRaw);
  }
}
