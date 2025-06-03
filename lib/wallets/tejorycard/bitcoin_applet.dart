import 'dart:typed_data';

import 'package:blockchain_utils/hex/hex.dart';
import 'package:tejory/apdu/iso7816/iso7816.dart';
import 'package:tejory/apdu/channel.dart';
import 'package:tejory/crypto-helper/hd_wallet.dart';
import 'package:tejory/wallets/coin_signing_options.dart';
import 'package:tejory/wallets/tejorycard/applet/applet_sw_response.dart';
import 'package:tejory/wallets/tejorycard/coin_applet.dart';

class BitcoinSigningOptions implements CoinSigningOptions {
  @override
  List<int>? options;

  BitcoinSigningOptions({this.options});

  @override
  int getSigningType() {
    if (options == null || options?.length == 0) {
      return -1;
    }
    return options![0];
  }

  static BitcoinSigningOptions LEGACY() {
    return BitcoinSigningOptions(options: [0x00]);
  }

  static BitcoinSigningOptions SEGWIT() {
    return BitcoinSigningOptions(options: [0x01]);
  }

  static BitcoinSigningOptions TAPROOT() {
    return BitcoinSigningOptions(options: [0x02]);
  }
}

class BitcoinApplet implements CoinApplet {
  static const int CLA = 0xc0;
  static const int INS_SIGN_PST = 0xd1;
  static const int INS_SIGN_TX = 0xd0;
  static const List<int> AID = [0x84, 0x6a, 0x60, 0x80, 0x00, 0x00, 0x00, 0x00];

  Channel ch;
  bool _selected = false;

  BitcoinApplet(this.ch);

  Future<Map<String, Uint8List>?> selectApplet() async {
    if (_selected) {
      return {};
    }
    var response = await ch.sendAPDU(ISO7816.CLA_ISO, ISO7816.INS_SELECT, 0x04,
        0x00, AID.length, Uint8List.fromList(AID), 0x00);

    Map<String, Uint8List> resMap = {};

    if (response == null) {
      resMap["_ERROR_MSG"] = Uint8List.fromList("null response".codeUnits);
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }

    var sw = Channel.swToInt(response);
    resMap["_SW"] = Channel.intToSW(sw);
    if (sw != 0x9000) {
      resMap["_ERROR_MSG"] = Uint8List.fromList(
          (AppletSWResponse.getSWResponse(sw, resMap["_SW"]!)).codeUnits);
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }
    _selected = true;

    return resMap;
  }

  @override
  Future<Map<String, Uint8List>?> signPST(String pst, String tx, bool getRawSignature,
      {CoinSigningOptions? signingOptions}) async {
    // ensure applet is selected
    await selectApplet();

    int signatureType = signingOptions?.getSigningType() ?? 1;

    int p1 = signatureType;
    int p2 = 0;
    int lc = 0;
    List<int> cdata = [];

    cdata.addAll(
        Uint8List(2)..buffer.asByteData().setUint16(0, pst.length, Endian.big));
    cdata.addAll(pst.codeUnits);

    int sIndex = 0;
    int eIndex = 255;
    bool first = true;
    bool last = false;
    // bool moreData = false;
    Uint8List? response;
    List<int> fullResponse = [];
    Map<String, Uint8List> resMap = {};
    while (sIndex < cdata.length) {
      if (eIndex > cdata.length) {
        last = true;
        eIndex = cdata.length;
      }
      if (sIndex > eIndex) {
        sIndex = eIndex;
      }
      p2 = getRawSignature ? 0 : 1;
      p2 |= first ? 0x04 : 0x00;
      p2 |= last ? 0x02 : 0x00;
      lc = eIndex - sIndex;
      response = await ch.sendAPDU(CLA, INS_SIGN_PST, p1, p2, lc,
          Uint8List.fromList(cdata.sublist(sIndex, eIndex)), 0x00);
      if (response == null) {
        resMap["_ERROR_MSG"] = Uint8List.fromList("null response".codeUnits);
        print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
        return resMap;
      }
      sIndex += 255;
      eIndex += 255;
      first = false;

      if (response.length < 2) {
        return null;
      }

      fullResponse.addAll(response.sublist(0, response.length - 2));
    }

    resMap["SIGNATURE"] = Uint8List.fromList(fullResponse);

    return resMap;
  }

  void resetSelected() {
    _selected = false;
  }
  
  @override
  Future<Map<String, Uint8List>?> signTX(List<String> paths, String tx, bool getRawSignature, {CoinSigningOptions? signingOptions}) async {
    // ensure applet is selected
    await selectApplet();

    int signatureType = signingOptions?.getSigningType() ?? 1;

    int p1 = signatureType;
    int p2 = 0;
    int lc = 0;
    List<int> cdata = [];

    // add the length of paths then the paths
    // cdata.add(paths.length);
    for (int i = 0; i < paths.length; i++) {
      var pathSerialized = HDWalletHelpers.serializeHDPath(paths[i], endian:Endian.big);
      cdata.add(pathSerialized.length);
      cdata.addAll(pathSerialized);
    }

    // add the hash
    cdata.add(tx.codeUnits.length);
    print("Preimage: ${hex.encode(tx.codeUnits)}");
    cdata.addAll(tx.codeUnits);

    Uint8List? response;
    Map<String, Uint8List> resMap = {};
    p2 = getRawSignature ? 0 : 1;
    lc = cdata.length;
    response = await ch.sendAPDU(
        CLA, INS_SIGN_TX, p1, p2, lc, Uint8List.fromList(cdata), 0x00);
    if (response == null) {
      resMap["_ERROR_MSG"] = Uint8List.fromList("null response".codeUnits);
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }

    if (response.length < 2) {
      return null;
    }

    resMap["SIGNATURE"] = Uint8List.fromList(response.sublist(0, response.length - 2));

    return resMap;
  }
}
