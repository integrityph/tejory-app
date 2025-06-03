import 'dart:typed_data';

abstract class Tx {
  fromTxBytes(Uint8List buffer);
  Uint8List getRawTX();
  BigInt getFee();
  String getHashHex();
}
