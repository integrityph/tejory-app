import 'dart:convert';
import 'dart:typed_data';

import 'package:tejory/coins/tx.dart';

class SparkTx implements Tx {
  Uint8List _raw = Uint8List(0);

  @override
  fromTxBytes(Uint8List buffer) {
    _raw = buffer;
    return this;
  }

  @override
  BigInt getFee() {
    return BigInt.zero;
  }

  @override
  String getHashHex() {
    return utf8.decode(_raw);
  }

  @override
  Uint8List getRawTX() {
    return _raw;
  }
}