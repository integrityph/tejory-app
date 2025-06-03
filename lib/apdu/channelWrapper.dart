import 'dart:typed_data';

import 'package:blockchain_utils/blockchain_utils.dart';

abstract class ChannelWrapper {
  bool isInitialized();
  Tuple<Uint8List?, bool> getInitializeBytes(Uint8List? previousResponse);
  Uint8List wrapCommand(int cla, int ins, int p1, int p2, Uint8List lc,
      Uint8List cdata, Uint8List le);
}
