import 'dart:typed_data';

abstract class PST {
  Uint8List getRawBytes();
  Uint8List getSignedTxFromPST(Uint8List buf);
}
