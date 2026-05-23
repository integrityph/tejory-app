import 'dart:typed_data';

import 'package:tejory/coins/tx.dart';

class SparkTx implements Tx {
  @override
  fromTxBytes(Uint8List buffer) {}

  @override
  BigInt getFee() {
    return BigInt.zero;
  }

  @override
  String getHashHex() {
    return "";
  }

  @override
  Uint8List getRawTX() {
    return Uint8List(0);
  }
}