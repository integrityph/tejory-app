import 'package:flutter/foundation.dart';

import 'package:tejory/apdu/channel.dart';
import 'package:tejory/wallets/tejorycard/applet/applet_sw_response.dart';

class GetStatusResp {
  static Map<String, Uint8List> parseFromList(Uint8List response) {
    Map<String, Uint8List> resMap = {};

    var sw = Channel.swToInt(response);
    resMap["_SW"] = Channel.intToSW(sw);
    if (sw != 0x9000) {
      resMap["_ERROR_MSG"] = Uint8List.fromList(
        (AppletSWResponse.getSWResponse(sw, resMap["_SW"]!)).codeUnits,
      );
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }
    // remove sw from response
    var resData = response.toList().sublist(0, response.length - 2);
    int resLen = 1;
    int offset = 0;

    // SETUP_COMPLETED
    if (resData.length < resLen) {
      resMap["_ERROR_MSG"] = Uint8List.fromList(
        "Invalid response length while reading SETUP_COMPLETED. Expected at least $resLen, got ${resData.length}"
            .codeUnits,
      );
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }
    resMap["SETUP_COMPLETED"] = Uint8List.fromList(
      resData.sublist(offset, offset + 1),
    );
    offset += 1;

    // PIN_REMAINING_TRIES
    resLen += 1;

    if (resData.length < resLen) {
      resMap["_ERROR_MSG"] = Uint8List.fromList(
        "Invalid response length while reading PIN_REMAINING_TRIES. Expected at least $resLen, got ${resData.length}"
            .codeUnits,
      );
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }
    resMap["PIN_REMAINING_TRIES"] = Uint8List.fromList(
      resData.sublist(offset, offset + 1),
    );
    offset += 1;

    // PUK_REMAINING_TRIES
    resLen += 1;

    if (resData.length < resLen) {
      resMap["_ERROR_MSG"] = Uint8List.fromList(
        "Invalid response length while reading PUK_REMAINING_TRIES. Expected at least $resLen, got ${resData.length}"
            .codeUnits,
      );
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }
    resMap["PUK_REMAINING_TRIES"] = Uint8List.fromList(
      resData.sublist(offset, offset + 1),
    );
    offset += 1;

    // check if this is the end of the response for unprivileged request
    if (resData.length == resLen) {
      return resMap;
    }

    // SERIAL_NUMBER
    resLen += 16;

    if (resData.length < resLen) {
      resMap["_ERROR_MSG"] = Uint8List.fromList(
        "Invalid response length while reading SERIAL_NUMBER. Expected at least $resLen, got ${resData.length}"
            .codeUnits,
      );
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }
    resMap["SERIAL_NUMBER"] = Uint8List.fromList(
      resData.sublist(offset, offset + 16),
    );
    offset += 16;

    // APPLET_VERSION
    resLen += 2;

    if (resData.length < resLen) {
      resMap["_ERROR_MSG"] = Uint8List.fromList(
        "Invalid response length while reading APPLET_VERSION. Expected at least $resLen, got ${resData.length}"
            .codeUnits,
      );
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }
    resMap["APPLET_VERSION"] = Uint8List.fromList(
      resData.sublist(offset, offset + 2),
    );
    offset += 2;

    // API_VERSION
    resLen += 2;

    if (resData.length < resLen) {
      resMap["_ERROR_MSG"] = Uint8List.fromList(
        "Invalid response length while reading API_VERSION. Expected at least $resLen, got ${resData.length}"
            .codeUnits,
      );
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }
    resMap["API_VERSION"] = Uint8List.fromList(
      resData.sublist(offset, offset + 2),
    );
    offset += 2;

    // AVAILABLE_KEYS
    resLen += 1;

    if (resData.length < resLen) {
      resMap["_ERROR_MSG"] = Uint8List.fromList(
        "Invalid response length while reading AVAILABLE_KEYS. Expected at least $resLen, got ${resData.length}"
            .codeUnits,
      );
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }
    resMap["AVAILABLE_KEYS"] = Uint8List.fromList(
      resData.sublist(offset, offset + 1),
    );
    offset += 1;

    // INSTALLED_APPLETS_COUNT
    resLen += 1;

    if (resData.length < resLen) {
      resMap["_ERROR_MSG"] = Uint8List.fromList(
        "Invalid response length while reading INSTALLED_APPLETS_COUNT. Expected at least $resLen, got ${resData.length}"
            .codeUnits,
      );
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }
    int appletCount = resData[offset];
    offset += 1;

    // APPLETS_LIST
    resLen += appletCount;

    if (resData.length < resLen) {
      resMap["_ERROR_MSG"] = Uint8List.fromList(
        "Invalid response length while reading APPLETS_LIST. Expected at least $resLen, got ${resData.length}"
            .codeUnits,
      );
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }
    resMap["APPLETS_LIST"] = Uint8List.fromList(
      resData.sublist(offset, offset + appletCount),
    );
    offset += appletCount;

    return resMap;
  }
}
