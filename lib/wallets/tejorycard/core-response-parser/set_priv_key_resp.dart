import 'dart:typed_data';

import 'package:tejory/apdu/channel.dart';
import 'package:tejory/wallets/tejorycard/applet/applet_sw_response.dart';

class SetPrivKeyResp {
  static Map<String, Uint8List> parseFromList(Uint8List response) {
    Map<String, Uint8List> resMap = {};

    var sw = Channel.swToInt(response);
    resMap["_SW"] = Channel.intToSW(sw);
    if (sw != 0x9000) {
      resMap["_ERROR_MSG"] = Uint8List.fromList(
          (AppletSWResponse.getSWResponse(sw, resMap["_SW"]!)).codeUnits);
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }

    // remove sw from response
    var resData = response.toList().sublist(0, response.length - 2);
    int resLen = 1;
    int offset = 0;

    // PUB_KEY_LENGTH
    if (resData.length < resLen) {
      resMap["_ERROR_MSG"] = Uint8List.fromList(
          "Invalid response length while reading PUB_KEY_LENGTH. Expected at least $resLen, got ${resData.length}"
              .codeUnits);
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }
    int pubKeyLength = resData[offset];
    offset += 1;

    // PUB_KEY
    resLen += pubKeyLength;

    if (resData.length < resLen) {
      resMap["_ERROR_MSG"] = Uint8List.fromList(
          "Invalid response length while reading PUB_KEY. Expected at least $resLen, got ${resData.length}"
              .codeUnits);
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }
    resMap["PUB_KEY"] =
        Uint8List.fromList(resData.sublist(offset, offset + pubKeyLength));
    offset += pubKeyLength;

    return resMap;
  }
}
