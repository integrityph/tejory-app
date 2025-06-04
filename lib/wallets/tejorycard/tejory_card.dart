import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tejory/apdu/channel.dart';
import 'package:tejory/bip32/derivation_bip32_key.dart';
import 'package:tejory/coins/pst.dart';
import 'package:tejory/coins/tx.dart';
import 'package:tejory/collections/walletDB.dart';
import 'package:tejory/comms/medium.dart';
import 'package:tejory/comms/nfc.dart';
import 'package:tejory/crypto-helper/hd_wallet.dart';
import 'package:tejory/wallets/coin_signing_options.dart';
import 'package:tejory/wallets/iwallet.dart';
import 'package:tejory/wallets/tejorycard/applet/applet_sw_response.dart';
import 'package:tejory/wallets/tejorycard/bitcoin_applet.dart';
import 'package:tejory/wallets/tejorycard/coin_applet.dart';
import 'package:tejory/wallets/tejorycard/core.dart';
import 'package:tejory/wallets/tejorycard/ether_applet.dart';
import 'package:tejory/wallets/wallet_setup_response.dart';
import 'package:tejory/wallets/wallet_status.dart';

class TejoryCard implements IWallet {
  WalletType type = WalletType.unknown;
  late CoreApplet core;
  late Channel ch;
  late Bip32KeyNetVersions defaultKeyNetVersions;
  bool pinVerified = false;
  Map<String, CoinApplet> coinAppletList = {};
  late Medium medium;

  TejoryCard() {
    ch = Channel(null, debug: kDebugMode);
    core = CoreApplet(ch);
    // Add coin applets
    coinAppletList["BTC"] = BitcoinApplet(ch);
    coinAppletList["ETH"] = EtherApplet(ch);
    defaultKeyNetVersions = Bip32KeyNetVersions(
      [0x04, 0x35, 0x87, 0xCF],
      [0x04, 0x35, 0x83, 0x94],
    );
    medium = NFC();
  }

  @override
  Future<VerifyPINResult?> changePINCode(
    CodeType oldCodeType,
    String oldCode,
    CodeType newCodeType,
    String newCode,
  ) async {
    Map<String, Uint8List>? res;
    try {
      res = await core.changePinCode( oldCodeType,
     oldCode,
     newCodeType,
     newCode);
    } catch (e) {
      return null;
    }

    if (res == null) {
      return null;
    }

    if (isError(res)) {
      if (res["_SW"] == null) {
        return null;
      }
      var sw = Channel.swToInt(res["_SW"]);
      if (sw == AppletSWResponse.SW_INVALID_PIN) {
        return VerifyPINResult.InvalidPIN;
      } else if (sw == AppletSWResponse.SW_LOCKED_PIN) {
        return VerifyPINResult.LockedPIN;
      }
      return null;
    }

    return VerifyPINResult.OK;
  }

  @override
  Uint8List? getPublicKey(int keyID) {
    // TODO: implement getPublicKey
    throw UnimplementedError();
  }

  @override
  Future<WalletStatus?> getStatus(bool getPrivileged) async {
    Map<String, Uint8List>? res;
    try {
      res = await core.getStatus(getPrivileged);
    } catch (e) {
      return null;
    }

    if (res == null) {
      return null;
    }

    if (res["SETUP_COMPLETED"] == null) {
      return null;
    }
    if (res["PIN_REMAINING_TRIES"] == null) {
      return null;
    }
    if (res["PUK_REMAINING_TRIES"] == null) {
      return null;
    }

    WalletStatus resObj = WalletStatus();
    resObj.setupCompleted = res["SETUP_COMPLETED"]![0] == 0x01;
    resObj.pinRemainingTries = res["PIN_REMAINING_TRIES"]![0];
    resObj.pukRemainingTries = res["PUK_REMAINING_TRIES"]![0];

    // if unprvileged, then return the result
    if (!getPrivileged) {
      return resObj;
    }

    //TODO: add the extra coding for privileged requests

    return resObj;
  }

  @override
  Future<WalletSetupResponse?> initialSetup(
    String name,
    Uint8List? bip32Seed, {
    String? pin,
    String? puk,
  }) async {
    Map<String, Uint8List>? res;
    try {
      res = await core.initialSetup(bip32Seed, pin, puk);
    } catch (e) {
      return null;
    }

    if (res == null) {
      return null;
    }

    if (res["SERIAL_NUMBER"] == null) {
      return null;
    }

    if (bip32Seed == null && res["BIP32_SEED"] == null) {
      return null;
    }

    if (pin == null && res["PIN"] == null) {
      return null;
    }

    if (puk == null && res["PUK"] == null) {
      return null;
    }

    WalletSetupResponse resObj = WalletSetupResponse();
    resObj.serialNumber = String.fromCharCodes(res["SERIAL_NUMBER"]!);
    resObj.bip32Seed =
        (res["BIP32_SEED"] != null)
            ? String.fromCharCodes(res["BIP32_SEED"]!)
            : null;
    resObj.pin =
        (res["PIN"] != null) ? String.fromCharCodes(res["PIN"]!) : null;
    resObj.puk =
        (res["PUK"] != null) ? String.fromCharCodes(res["PUK"]!) : null;

    return resObj;
  }

  @override
  void replaceHDWalletSeed(Uint8List BIP32Seed) {
    // TODO: implement replaceHDWalletSeed
  }

  @override
  void setPrivateKey(Uint8List privKey, int keyID) {
    // TODO: implement setPrivateKey
  }

  @override
  Medium getMedium() {
    return medium;
  }

  @override
  Future<Uint8List?> signTX(
    Uint8List tx,
    String coinName,
    bool getRawSignature, {
    List<String>? paths,
    List<int>? keyIDs,
    CoinSigningOptions? coinOptions,
  }) async {
    CoinApplet? app = coinAppletList[coinName];
    if (app == null) {
      return null;
    }

    String txStr = String.fromCharCodes(tx);

    Map<String, Uint8List>? res;
    try {
      res = await app.signTX(
        paths!,
        txStr,
        getRawSignature,
        signingOptions: coinOptions,
      );
    } catch (e) {
      return null;
    }

    if (res == null) {
      return null;
    }

    if (res["SIGNATURE"] == null) {
      return null;
    }

    Uint8List sigList = res["SIGNATURE"]!;

    // int index = 0;
    // int length = 0;
    // while (index < res["SIGNATURE"]!.length) {
    //   length = res["SIGNATURE"]![index];
    //   index++;
    //   sigList.add(Uint8List.fromList(res["SIGNATURE"]!.sublist(index, index + length)));
    //   index += length;
    // }

    return sigList;
  }

  @override
  Future<Bip32PublicKey?> deriveHDKey(
    String path, {
    bool getExtended = false,
    Bip32KeyNetVersions? keyNetVersions,
    Uint8List? bip32Seed,
  }) async {
    if (bip32Seed != null) {
      return deriveChildFromSeed(
        path,
        bip32Seed,
        getExtended: getExtended,
        keyNetVersions: keyNetVersions,
      );
    }

    Uint8List pathBytes = HDWalletHelpers.serializeHDPath(
      path,
      endian: Endian.big,
    );
    Map<String, Uint8List>? res;
    try {
      res = await core.hdPubKeyDerivation(
        pathBytes,
        getExtendedKey: getExtended,
      );
    } catch (e) {
      return null;
    }

    if (res == null) {
      return null;
    }

    if (isError(res)) {
      return null;
    }

    List<int>? keyBytes = res["PUB_KEY"];
    if (keyBytes == null) {
      return null;
    }

    Bip32ChainCode? chainCode = Bip32ChainCode(res["CHAIN_CODE"]);
    Bip32KeyData keyData = Bip32KeyData(chainCode: chainCode);
    EllipticCurveTypes curveType = EllipticCurveTypes.secp256k1;
    if (keyNetVersions == null) {
      keyNetVersions = defaultKeyNetVersions;
    }
    Bip32PublicKey pubkey = Bip32PublicKey.fromBytes(
      keyBytes,
      keyData,
      keyNetVersions,
      curveType,
    );

    return pubkey;
  }

  Bip32PublicKey deriveChildFromSeed(
    String path,
    Uint8List bip32Seed, {
    bool getExtended = false,
    Bip32KeyNetVersions? keyNetVersions,
  }) {
    var hdw = DerivationBIP32Key.fromSeed(
      seedBytes: bip32Seed,
      keyNetVersions: keyNetVersions!,
    );
    Bip32PublicKey childKey = Bip32PublicKey.fromBytes(
      hdw.derivePath(path)!.publicKey,
      hdw.getBip32KeyData(),
      hdw.keyNetVer!,
      hdw.curveType,
    );
    return childKey;
  }

  @override
  Future<List<Uint8List>?> getPSTSignature(
    PST? pst,
    Tx? tx,
    String coinName, {
    CoinSigningOptions? coinOptions,
    Bip32KeyNetVersions? keyNetVersions,
  }) async {
    Uint8List? res;
    try {
      res = await signPST(pst, tx, coinName, true, coinOptions: coinOptions);
    } catch (e) {
      return null;
    }

    if (res == null) {
      return null;
    }

    List<Uint8List> sigList = [];

    int index = 0;
    int length = 0;
    while (index < res.length) {
      length = res[index];
      index++;
      sigList.add(Uint8List.fromList(res.sublist(index, index + length)));
      index += length;
    }

    return sigList;
  }

  @override
  Future<PST?> getSignedPST(
    PST? pst,
    Tx? tx,
    String coinName, {
    CoinSigningOptions? coinOptions,
    Bip32KeyNetVersions? keyNetVersions,
  }) async {
    await signPST(pst, tx, coinName, false, coinOptions: coinOptions);

    return null;
  }

  Future<Uint8List?> signPST(
    PST? pst,
    Tx? tx,
    String coinName,
    bool getRawSignature, {
    CoinSigningOptions? coinOptions,
  }) async {
    CoinApplet? app = coinAppletList[coinName];
    if (app == null) {
      return null;
    }

    String pstStr =
        (pst != null) ? String.fromCharCodes(pst.getRawBytes()) : "";
    String txStr = (tx != null) ? String.fromCharCodes(tx.getRawTX()) : "";

    Map<String, Uint8List>? res;
    try {
      res = await app.signPST(
        pstStr,
        txStr,
        getRawSignature,
        signingOptions: coinOptions,
      );
    } catch (e) {
      return null;
    }

    if (res == null) {
      return null;
    }

    return res["SIGNATURE"];
  }

  Future<VerifyPINResult?> verifyPIN(String pin) async {
    Map<String, Uint8List>? res;
    try {
      res = await core.verifyPin(pin);
    } catch (e) {
      print("TejoryCard.verifyPIN error. ${e}");
      return null;
    }

    if (res == null) {
      return null;
    }

    if (isError(res)) {
      if (res["_SW"] == null) {
        return null;
      }
      var sw = Channel.swToInt(res["_SW"]);
      if (sw == AppletSWResponse.SW_INVALID_PIN) {
        return VerifyPINResult.InvalidPIN;
      } else if (sw == AppletSWResponse.SW_LOCKED_PIN) {
        return VerifyPINResult.LockedPIN;
      }
      return null;
    }

    pinVerified = true;
    return VerifyPINResult.OK;
  }

  bool isError(Map<String, Uint8List> response) {
    return response.containsKey("_ERROR_MSG");
  }

  @override
  setMediumSession(session) {
    ch.setTag(session);
    core.selected = false;
    for (var key in coinAppletList.keys) {
      coinAppletList[key]!.resetSelected();
    }

    // TODO: unselect all coin applets
  }

  @override
  Future<bool> startSession(
    BuildContext? context,
    NFCSessionCallbackFunction callback, {
    String? baseClassUI,
    List<int>? PIN,
    List<int>? newPIN,
    bool isNewPIN = false,
    bool changePIN = false,
    String enterPINMessage = "Enter your PIN",
    String enterPIN2Message = "Please confirm your PIN again",
  }) async {
    return await medium.startSession(
      context,
      callback,
      baseClassUI: baseClassUI,
      PIN: PIN,
      newPIN: newPIN,
      isNewPIN: isNewPIN,
      changePIN: changePIN,
      enterPINMessage: enterPINMessage,
      enterPIN2Message: enterPIN2Message,
    );
  }
}
