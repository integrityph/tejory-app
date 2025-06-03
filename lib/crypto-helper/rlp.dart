
import 'package:blockchain_utils/blockchain_utils.dart';

class RLP {
  static dynamic decode(List<int> buffer) {
    dynamic val;
    val = readValue(buffer, 0);
    return val;
  }

  static Tuple<int, dynamic> readValue(List<int> buffer, int offset) {
    if (buffer[offset] <= 0x7f) {
      return Tuple<int, dynamic>(1, hex.encode(buffer.sublist(offset, offset+1)));
    } else if (buffer[offset] >= 0x80 && buffer[offset] <= 0xb7){
      var stringLen = buffer[offset]-0x80;
      return Tuple<int, dynamic>(1+stringLen, hex.encode(buffer.sublist(1+offset,1+offset+stringLen)));
    } else if (buffer[offset] >= 0xb8 && buffer[offset] <= 0xbf){
      var lengthLen = buffer[offset]-0xb7;
      int stringLen = 0;
      for (int i = 0; i<lengthLen; i++) {
        stringLen = stringLen << 8;
        stringLen += buffer[1+offset+i];
      }
      return Tuple<int, dynamic>(1+lengthLen+stringLen, hex.encode(buffer.sublist(1+offset+lengthLen,1+offset+lengthLen+stringLen)));
    } else if (buffer[offset] >= 0xc0 && buffer[offset] <= 0xf7){
      var listPayloadLen = buffer[offset]-0xc0;
      List<dynamic> val = [];
      Tuple<int, dynamic> result;
      int index = 0;
      while (index < listPayloadLen) {
        result = readValue(buffer, offset+index);
        index += result.item1;
        val.add(result.item2);
      }
      return Tuple<int, dynamic>(1+listPayloadLen, val);
    }else if (buffer[offset] >= 0xf8 && buffer[offset] <= 0xff){
      var lengthLen = buffer[offset]-0xf7;
      var listPayloadLen = 0;
      for (int i = 0; i<lengthLen; i++) {
        listPayloadLen = listPayloadLen << 8;
        listPayloadLen += buffer[1+offset+i];
      }
      List<dynamic> val = [];
      Tuple<int, dynamic> result;
      int index = 0;
      while (index < listPayloadLen) {
        result = readValue(buffer, offset+lengthLen+index);
        index += result.item1;
        val.add(result.item2);
      }
      return Tuple<int, dynamic>(1+lengthLen+listPayloadLen, val);
    }

    // This is never reached
    return Tuple<int, dynamic>(0, null);
  }

  static List<int> encode(dynamic val) {
    if (val is List) {
      return encodeList(val);
    } else if (val is int) {
      return encodeInt(BigInt.from(val));
    } else if (val is BigInt) {
      return encodeInt(val);
    } else if (val is String) {
      return encodeString(val);
    }
    return [];
  }

  static List<int> encodeInt(BigInt val) {
    if (val <= BigInt.zero) {
      return [0x80];
    } else if (val <= BigInt.from(0x7f)) {
      return [val.toInt()];
    } else if (val.bitLength/8 <= 55) {
      return [(val.bitLength /8).ceil() + 0x80, ...hex.decode(val.toRadixString(16).padLeft((val.bitLength/8).ceil()*2,"0"))];
    } else if (BigInt.from(val.bitLength/8) < BigInt.two.pow(64)){
      int lengthLen = ((val.bitLength/8).ceil() / 256).ceil();
      List<int> intLen = hex.decode((val.bitLength/8).ceil().toRadixString(16).padLeft(lengthLen*2, "0"));
      return [lengthLen + 0xb7, ...intLen, ...hex.decode(val.toRadixString(16).padLeft((val.bitLength/8).ceil()*2, "0"))];
    }
    return [];
  }

  static List<int> encodeString(String val) {
    if (val.length==0) {
      return [0x80];
    } else if (val.length <= 55) {
      return [val.length+0x80, ...val.codeUnits];
    } else {
      int lengthLen = (val.length.bitLength / 8).ceil();
      List<int> stringLen = hex.decode(val.length.toRadixString(16).padLeft(lengthLen*2, "0"));
      return [lengthLen+0xb7, ...stringLen, ...val.codeUnits];
    }
  }

  static List<int> encodeList(List<dynamic> val) {
    List<int> buffer = [];
    for (int i=0; i<val.length; i++) {
      buffer.addAll(encode(val[i]));
    }

    if (buffer.length <= 55) {
      buffer = [buffer.length + 0xc0, ...buffer];
    } else {
      int lengthLen = (buffer.length.bitLength / 8).ceil();
      List<int> listLen = hex.decode(buffer.length.toRadixString(16).padLeft(lengthLen*2, "0"));
      buffer = [lengthLen + 0xf7, ...listLen, ...buffer];
    }

    return buffer;
  }
}