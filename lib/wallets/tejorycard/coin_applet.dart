import 'dart:typed_data';

import 'package:tejory/wallets/coin_signing_options.dart';

abstract class CoinApplet {
  Future<Map<String, Uint8List>?> signPST(String pst, String tx, bool getRawSignature,
      {CoinSigningOptions? signingOptions});

  Future<Map<String, Uint8List>?> signTX(List<String> paths, String tx, bool getRawSignature,
      {CoinSigningOptions? signingOptions});

  void resetSelected();
}
