import 'dart:typed_data';


abstract class ChannelWrapper {
  bool isInitialized();
  (Uint8List?, bool) getInitializeBytes(Uint8List? previousResponse);
  Uint8List wrapCommand(int cla, int ins, int p1, int p2, Uint8List lc,
      Uint8List cdata, Uint8List le);
}
