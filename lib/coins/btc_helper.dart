import 'dart:typed_data';
import 'package:blockchain_utils/blockchain_utils.dart';

(int, int) parseVarint(Uint8List buffer, int index) {
  if (buffer[index] < 0xfd) {
    return (buffer[index], 1);
  } else if (buffer[index] == 0xfd) {
    return (
      ByteData.view(buffer.sublist(index + 1, index + 3).buffer)
          .getUint16(0, Endian.little),
      3
    );
  } else if (buffer[index] == 0xfe) {
    return (
      ByteData.view(buffer.sublist(index + 1, index + 5).buffer)
          .getUint32(0, Endian.little),
      5
    );
  } else if (buffer[index] == 0xff) {
    return (
      ByteData.view(buffer.sublist(index + 1, index + 9).buffer)
          .getUint64(0, Endian.little),
      9
    );
  }
  return (0, 0);
}

Uint8List makeVarint(BigInt value) {
  Uint8List buffer = Uint8List(0);
  if (value < BigInt.from(0xfd)) {
    buffer = Uint8List.fromList([value.toInt()]);
  } else if (value < (BigInt.one << 16)) {
    List<int> payloadSize =
        hex.decode(value.toRadixString(16).padLeft(4, "0")).reversed.toList();
    buffer = Uint8List.fromList([
          0xfd,
        ] +
        payloadSize);
  } else if (value < (BigInt.one << 32)) {
    List<int> payloadSize =
        hex.decode(value.toRadixString(16).padLeft(8, "0")).reversed.toList();
    buffer = Uint8List.fromList([
          0xfe,
        ] +
        payloadSize);
  } else if (value < (BigInt.one << 64)) {
    List<int> payloadSize =
        hex.decode(value.toRadixString(16).padLeft(16, "0")).reversed.toList();
    buffer = Uint8List.fromList([
          0xff,
        ] +
        payloadSize);
  }

  return buffer;
}
