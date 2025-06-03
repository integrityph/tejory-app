import 'package:flutter/services.dart';

import 'package:tejory/apdu/channel.dart';
import 'package:tejory/wallets/tejorycard/applet/applet_sw_response.dart';

class ReplaceHdwSeedResp {
  static Map<String, Uint8List> parseFromList(
      Uint8List response, Uint8List? BIP32Seed) {
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
    int resLen = 32;
    int offset = 0;

    // BIP39 entropy
    if (BIP32Seed == null) {
      if (resData.length < resLen) {
        resMap["_ERROR_MSG"] = Uint8List.fromList(
            "Invalid response length while reading BIP39 entropy. Expected at least $resLen, got ${resData.length}"
                .codeUnits);
        print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
        return resMap;
      }
      resMap["BIP39_ENTROPY"] =
          Uint8List.fromList(resData.sublist(offset, offset + 32));
    }

    return resMap;
  }
}
