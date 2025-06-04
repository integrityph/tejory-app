// ignore_for_file: unused_local_variable, avoid_print

import 'dart:typed_data';

import 'package:nfc_manager/nfc_manager.dart';
import 'package:tejory/apdu/channel.dart';
import 'package:tejory/apdu/iso7816/iso7816.dart';
import 'package:tejory/wallets/iwallet.dart';
import 'package:tejory/wallets/tejorycard/core-response-parser/card_auth_verify_resp.dart';
import 'package:tejory/wallets/tejorycard/core-response-parser/get_pub_key_resp.dart';
import 'package:tejory/wallets/tejorycard/core-response-parser/get_status_resp.dart';
import 'package:tejory/wallets/tejorycard/core-response-parser/hd_pub_key_derive_resp.dart';
import 'package:tejory/wallets/tejorycard/core-response-parser/initial_setup_resp.dart';
import 'package:tejory/wallets/tejorycard/core-response-parser/replace_hdw_seed_resp.dart';
import 'package:tejory/wallets/tejorycard/core-response-parser/set_priv_key_resp.dart';
import 'package:tejory/wallets/tejorycard/core_instruction.dart';
import 'applet/applet_sw_response.dart';

class CoreApplet {
  static const int CLA = 0xc0;
  static const List<int> AID = [0x84, 0x6a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];

  Channel ch;
  bool selected = false;

  CoreApplet(this.ch);

  void setTag(NfcTag tag) {
    ch.setTag(tag);
    selected = false;
  }

  Future<Map<String, Uint8List>?> selectApplet() async {
    if (selected) {
      return {};
    }
    var response = await ch.sendAPDU(
      ISO7816.CLA_ISO,
      ISO7816.INS_SELECT,
      0x04,
      0x00,
      AID.length,
      Uint8List.fromList(AID),
      0x00,
    );

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
        (AppletSWResponse.getSWResponse(sw, resMap["_SW"]!)).codeUnits,
      );
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }
    selected = true;

    return resMap;
  }

  // APDU FUNCTIONS
  // #1 Initial Setup
  Future<Map<String, Uint8List>?> initialSetup(
    Uint8List? BIP32Seed,
    String? pin,
    String? puk,
  ) async {
    // ensure applet is selected
    await selectApplet();

    int p1 = 0;
    int lc = 0;
    List<int> cdata = [];
    if (BIP32Seed != null) {
      p1 |= 0x04;
      lc += 64;
      cdata.addAll(BIP32Seed);
    }
    if (pin != null) {
      p1 |= 0x02;
      lc += pin.length + 1;
      cdata.add(pin.length);
      cdata.addAll(pin.codeUnits);
    }
    if (puk != null) {
      p1 |= 0x01;
      lc += puk.length + 1;
      cdata.add(puk.length);
      cdata.addAll(puk.codeUnits);
    }

    var response = await ch.sendAPDU(
      CLA,
      CoresInstruction.INS_INITIAL_SETUP,
      p1,
      0x00,
      lc,
      Uint8List.fromList(cdata),
      0x00,
    );

    Map<String, Uint8List> resMap = {};

    if (response == null) {
      resMap["_ERROR_MSG"] = Uint8List.fromList("null response".codeUnits);
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }

    resMap = InitialSetupResp.parseFromList(response, BIP32Seed, pin, puk);

    return resMap;
  }

  // #2 Replace HD Wallet Seed
  Future<Map<String, Uint8List>?> replaceHDSeed(Uint8List? BIP32Seed) async {
    await selectApplet();

    int p1 = (BIP32Seed == null) ? 0 : 1;
    int lc = BIP32Seed?.length ?? 0;
    List<int> cdata = [];
    if (BIP32Seed != null) {
      p1 |= 0x01;
      cdata.addAll(BIP32Seed);
    }

    var response = await ch.sendAPDU(
      CLA,
      CoresInstruction.INS_REPLACE_HD_SEED,
      p1,
      0x00,
      lc,
      Uint8List.fromList(cdata),
      0x00,
    );

    Map<String, Uint8List> resMap = {};

    if (response == null) {
      resMap["_ERROR_MSG"] = Uint8List.fromList("null response".codeUnits);
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }

    resMap = ReplaceHdwSeedResp.parseFromList(response, BIP32Seed);

    return resMap;
  }

  // #3 HD Public Key Derivation
  Future<Map<String, Uint8List>?> hdPubKeyDerivation(
    Uint8List path, {
    bool getExtendedKey = false,
  }) async {
    await selectApplet();

    int p1 = 0;
    int lc = path.length + 1;

    if (getExtendedKey) {
      p1 |= 0x01;
    }

    List<int> cdata = [];
    cdata.add(path.length);
    cdata.addAll(path);

    var response = await ch.sendAPDU(
      CLA,
      CoresInstruction.INS_HD_PUB_KEY_DERIVE,
      p1,
      0x00,
      lc,
      Uint8List.fromList(cdata),
      0x00,
    );

    Map<String, Uint8List> resMap = {};

    if (response == null) {
      resMap["_ERROR_MSG"] = Uint8List.fromList("null response".codeUnits);
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }

    resMap = HdPubKeyDeriveResp.parseFromList(response, p1);

    return resMap;
  }

  // #4 Set Private Key
  Future<Map<String, Uint8List>?> setPrivKey(
    int keyIndex,
    Uint8List? privKey,
  ) async {
    await selectApplet();

    int p1 = 0;
    int p2 = 0;
    int lc = 0;
    if (privKey != null) {
      p1 |= keyIndex;
      p2 |= 0x01;
      lc = privKey.length + 1;
    }

    List<int> cdata = [];
    cdata.add(privKey!.length);
    cdata.addAll(privKey);

    var response = await ch.sendAPDU(
      CLA,
      CoresInstruction.INS_SET_PRIV_KEY,
      p1,
      p2,
      lc,
      Uint8List.fromList(cdata),
      0x00,
    );

    Map<String, Uint8List> resMap = {};

    if (response == null) {
      resMap["_ERROR_MSG"] = Uint8List.fromList("null response".codeUnits);
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }

    resMap = SetPrivKeyResp.parseFromList(response);

    return resMap;
  }

  // #5 Get Public Key
  Future<Map<String, Uint8List>?> getPubKey(int keyIndex) async {
    await selectApplet();

    int lc = 0;
    var response = await ch.sendAPDU(
      CLA,
      CoresInstruction.INS_GET_PUB_KEY,
      keyIndex,
      0x00,
      lc,
      Uint8List.fromList([]),
      0x00,
    );

    Map<String, Uint8List> resMap = {};

    if (response == null) {
      resMap["_ERROR_MSG"] = Uint8List.fromList("null response".codeUnits);
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }

    resMap = GetPubKeyResp.parseFromList(response);

    return resMap;
  }

  // #6 Change PIN Code
  Future<Map<String, Uint8List>?> changePinCode(
    CodeType oldCodeType,
    String oldCode,
    CodeType newCodeType,
    String newCode,
  ) async {
    await selectApplet();

    int p1 = 0;
    int lc = 0;
    List<int> cdata = [];

    // Added validation for null and empty uint8List since not sure what wiStringll be passed
    p1 |= (CodeType.PUK == oldCodeType) ? 2 : 0;
    p1 |= (CodeType.PUK == newCodeType) ? 1 : 0;
    cdata.add(oldCode.length);
    cdata.addAll(oldCode.codeUnits);
    cdata.add(newCode.length);
    cdata.addAll(newCode.codeUnits);

    lc = cdata.length;

    var response = await ch.sendAPDU(
      CLA,
      CoresInstruction.INS_CHANGE_PIN,
      p1,
      0x00,
      lc,
      Uint8List.fromList(cdata),
      0x00,
    );

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
        (AppletSWResponse.getSWResponse(sw, resMap["_SW"]!)).codeUnits,
      );
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }

    return resMap;
  }

  // #7 Get Status
  Future<Map<String, Uint8List>?> getStatus(bool getPrivileged) async {
    await selectApplet();

    int lc = 0;
    int p1 = (getPrivileged) ? 0x00 : 0x01;

    var response = await ch.sendAPDU(
      CLA,
      CoresInstruction.INS_GET_STATUS,
      p1,
      0x00,
      lc,
      Uint8List.fromList([]),
      0x00,
    );

    Map<String, Uint8List> resMap = {};

    if (response == null) {
      resMap["_ERROR_MSG"] = Uint8List.fromList("null response".codeUnits);
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }

    resMap = GetStatusResp.parseFromList(response);

    return resMap;
  }

  // #8 Card Authenticity Verification
  Future<Map<String, Uint8List>?> cardAuthVerification(
    List<int> host_challenge,
  ) async {
    await selectApplet();

    var response = await ch.sendAPDU(
      CLA,
      CoresInstruction.INS_CARD_AUTH_VERIFY,
      0x00,
      0x00,
      0x64,
      Uint8List.fromList(host_challenge),
      0x00,
    );

    Map<String, Uint8List> resMap = {};

    if (response == null) {
      resMap["_ERROR_MSG"] = Uint8List.fromList("null response".codeUnits);
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }

    resMap = CardAuthVerifyResp.parseFromList(response);

    return resMap;
  }

  // #9 Card Reset
  Future<Map<String, Uint8List>?> cardReset(List<int> PIN) async {
    await selectApplet();

    var response = await ch.sendAPDU(
      CLA,
      CoresInstruction.INS_CARD_RESET,
      0x00,
      0x00,
      0x00,
      Uint8List.fromList([]),
      0x00,
    );

    Map<String, Uint8List> resMap = {};

    if (response == null) {
      resMap["_ERROR_MSG"] = Uint8List.fromList("null response".codeUnits);
      print(String.fromCharCodes(resMap["_ERROR_MSG"]!));
      return resMap;
    }

    return resMap;
  }

  Future<Map<String, Uint8List>?> manageAppletACL(List<int> PIN) async {
    await selectApplet();

    int p1 = 0;
    var response = await ch.sendAPDU(
      CLA,
      CoresInstruction.INS_MANAGE_APPLETS_ACL,
      0x00,
      0x00,
      0x00,
      Uint8List.fromList([]),
      0x00,
    );

    Map<String, Uint8List> resMap = {};

    return resMap;
  }

  // #11 Verify PIN
  Future<Map<String, Uint8List>?> verifyPin(String pin) async {
    await selectApplet();

    int lc = pin.length;
    List<int> cdata = [];
    cdata.addAll(pin.codeUnits);
    print("this is the lc $lc");

    var response = await ch.sendAPDU(
      CLA,
      CoresInstruction.INS_VERIFY_PIN,
      0x00,
      0x00,
      lc,
      Uint8List.fromList(cdata),
      0x00,
    );

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

    return resMap;
  }
}
