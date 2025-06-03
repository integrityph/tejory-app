import 'dart:typed_data';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:tejory/coins/pst.dart';
import 'package:tejory/coins/tx.dart';
import 'package:tejory/comms/medium.dart';
import 'package:tejory/wallets/coin_signing_options.dart';
import 'package:tejory/wallets/wallet_setup_response.dart';
import 'package:tejory/wallets/wallet_status.dart';

enum CodeType {
  PIN(1),
  PUK(2);

  const CodeType(this.value);
  final int value;

  static CodeType getByValue(int i) {
    return CodeType.values.firstWhere((x) => x.value == i);
  }
}

abstract class IWallet {
  IWallet({String pin = "", String puk = ""});

  // returns the serial number of the wallet
  Future<WalletSetupResponse?> initialSetup(String name, Uint8List bip32Seed,
      {String pin = "", String puk = ""});

  void replaceHDWalletSeed(Uint8List BIP32Seed);

  Future<Bip32PublicKey?> deriveHDKey(String path,
      {bool getExtended = false,
      Bip32KeyNetVersions? keyNetVersions,
      Uint8List? bip32Seed});

  void setPrivateKey(Uint8List privKey, int keyID);

  Uint8List? getPublicKey(int keyID);

  void changePINCode(CodeType oldCodeType, String oldCode, CodeType newCodeType,
      String newCode);

  WalletStatus? getStatus(bool getPrivileged);

  Medium getMedium();
  setMediumSession(dynamic session);

  Future<Uint8List?> signTX(Uint8List tx, String coinName, bool getRawSignature,
      {List<String>? paths,
      List<int>? keyIDs,
      CoinSigningOptions? coinOptions});

  Future<PST?> getSignedPST(PST pst, Tx tx, String coinName,
      {CoinSigningOptions? coinOptions, Bip32KeyNetVersions? keyNetVersions});

  Future<List<Uint8List>?> getPSTSignature(PST? pst, Tx? tx, String coinName,
      {CoinSigningOptions? coinOptions, Bip32KeyNetVersions? keyNetVersions});

  Future<bool> verifyPIN(String pin);
  Future<bool> startSession(
    BuildContext? context,
    NFCSessionCallbackFunction callback, {
    String? baseClassUI,
    List<int>? PIN,
    bool isNewPIN = false,
    bool changePIN = false,
    String enterPINMessage = "Enter your PIN",
    String enterPIN2Message = "Please confirm your PIN again",
  });
}
