import 'package:flutter/services.dart';

import 'package:tejory/apdu/channel.dart';
import 'package:tejory/wallets/tejorycard/applet/applet_sw_response.dart';

class InitialSetupResp {
  static Map<String, Uint8List> parseFromList(
      Uint8List response, Uint8List? BIP32Seed, String? pin, String? puk) {
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
    int resLen = 16;
    int offset = 0;

    // Serial number
    if (resData.length < resLen) {
      resMap["_ERROR_MSG"] = Uint8List.fromList(
          "Invalid response length while reading serial number. Expected at least $resLen, got ${resData.length}"
              .codeUnits);
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }
    resMap["SERIAL_NUMBER"] = Uint8List.fromList(resData.sublist(0, 16));
    offset += 16;

    // BIP39 entropy
    if (BIP32Seed == null) {
      resLen += 32;
      if (resData.length < resLen) {
        resMap["_ERROR_MSG"] = Uint8List.fromList(
            "Invalid response length while reading BIP39 entropy. Expected at least $resLen, got ${resData.length}"
                .codeUnits);
        print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
        return resMap;
      }
      resMap["BIP32_SEED"] =
          Uint8List.fromList(resData.sublist(offset, offset + 32));
      offset += 32;
    }

    if (pin == null) {
      // PIN Length
      resLen += 1;

      if (resData.length < resLen) {
        resMap["_ERROR_MSG"] = Uint8List.fromList(
            "Invalid response length while reading PIN_LENGTH. Expected at least $resLen, got ${resData.length}"
                .codeUnits);
        print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
        return resMap;
      }
      int pinLength = resData[offset];
      offset += 1;

      // PIN
      resLen += pinLength;

      if (resData.length < resLen) {
        resMap["_ERROR_MSG"] = Uint8List.fromList(
            "Invalid response length while reading PIN. Expected at least $resLen, got ${resData.length}"
                .codeUnits);
        print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
        return resMap;
      }
      resMap["PIN"] =
          Uint8List.fromList(resData.sublist(offset, offset + pinLength));
      offset += pinLength;
    }

    if (puk == null) {
      // PUK Length
      resLen += 1;

      if (resData.length < resLen) {
        resMap["_ERROR_MSG"] = Uint8List.fromList(
            "Invalid response length while reading PUK_LENGTH. Expected at least $resLen, got ${resData.length}"
                .codeUnits);
        print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
        return resMap;
      }
      int pinLength = resData[offset];
      offset += 1;

      // PUK
      resLen += pinLength;

      if (resData.length < resLen) {
        resMap["_ERROR_MSG"] = Uint8List.fromList(
            "Invalid response length while reading PUK. Expected at least $resLen, got ${resData.length}"
                .codeUnits);
        print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
        return resMap;
      }
      resMap["PUK"] =
          Uint8List.fromList(resData.sublist(offset, offset + pinLength));
      offset += pinLength;
    }
    return resMap;
  }
}
