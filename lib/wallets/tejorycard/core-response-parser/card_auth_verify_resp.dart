import 'dart:typed_data';

import 'package:tejory/apdu/channel.dart';
import 'package:tejory/wallets/tejorycard/applet/applet_sw_response.dart';

class CardAuthVerifyResp {
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

    // AUTH_PUB_KEY_LENGTH
    if (resData.length < resLen) {
      resMap["_ERROR_MSG"] = Uint8List.fromList(
          "Invalid response length while reading AUTH_PUB_KEY_LENGTH. Expected at least $resLen, got ${resData.length}"
              .codeUnits);
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }
    int authPubKeyLength = resData[offset];
    offset += 1;

    // AUTH_PUB_KEY
    resLen += authPubKeyLength;

    if (resData.length < resLen) {
      resMap["_ERROR_MSG"] = Uint8List.fromList(
          "Invalid response length while reading AUTH_PUB_KEY. Expected at least $resLen, got ${resData.length}"
              .codeUnits);
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }
    resMap["AUTH_PUB_KEY"] =
        Uint8List.fromList(resData.sublist(offset, offset + authPubKeyLength));
    offset += authPubKeyLength;

    // SIGNED_AUTHKEY_LENGTH
    if (resData.length < resLen) {
      resMap["_ERROR_MSG"] = Uint8List.fromList(
          "Invalid response length while reading SIGNED_AUTHKEY_LENGTH	. Expected at least $resLen, got ${resData.length}"
              .codeUnits);
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }
    int signedAuthKeyLength = resData[offset];
    offset += 1;

    // SIGNED_AUTHKEY
    resLen += signedAuthKeyLength;

    if (resData.length < resLen) {
      resMap["_ERROR_MSG"] = Uint8List.fromList(
          "Invalid response length while reading SIGNED_AUTHKEY. Expected at least $resLen, got ${resData.length}"
              .codeUnits);
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }
    resMap["SIGNED_AUTHKEY"] = Uint8List.fromList(
        resData.sublist(offset, offset + signedAuthKeyLength));
    offset += signedAuthKeyLength;

    // CARD_CRYPTOGRAM_LENGTH
    if (resData.length < resLen) {
      resMap["_ERROR_MSG"] = Uint8List.fromList(
          "Invalid response length while reading CARD_CRYPTOGRAM_LENGTH	. Expected at least $resLen, got ${resData.length}"
              .codeUnits);
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }
    int cardCryptogramLength = resData[offset];
    offset += 1;

    // CARD_CRYPTOGRAM
    resLen += cardCryptogramLength;

    if (resData.length < resLen) {
      resMap["_ERROR_MSG"] = Uint8List.fromList(
          "Invalid response length while reading CARD_CRYPTOGRAM. Expected at least $resLen, got ${resData.length}"
              .codeUnits);
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }
    resMap["CARD_CRYPTOGRAM"] = Uint8List.fromList(
        resData.sublist(offset, offset + cardCryptogramLength));
    offset += cardCryptogramLength;

    return resMap;
  }
}
