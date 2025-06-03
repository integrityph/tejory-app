// ignore_for_file: unused_field, prefer_const_constructors

import 'dart:math';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:dart_des/dart_des.dart';
import 'package:flutter/foundation.dart';
import 'package:tejory/apdu/channel.dart';
import 'package:tejory/apdu/channelWrapper.dart';
import 'package:tejory/apdu/global-platform/gp.dart';
import 'package:tejory/apdu/iso7816/iso7816.dart';

enum SCP02Phase {
  UNSECURE,
  SD_SELECT,
  INITIALIZE_UPDATE,
  EXTERNAL_AUTHENTICATE,
  SECURE_CMAC
}

class SCP02 extends ChannelWrapper {
  bool _isInitialized = false;
  List<int> _hostChallenge = [];
  List<int> _keyDiversification = [];
  List<int> _seqCounter = [];
  List<int> _cardCryptogram = [];
  List<int>? _hostCryptogram = [];
  List<int>? _CMAC;
  List<int> _encBaseKey = [];
  List<int> _macBaseKey = [];
  List<int> _dekBaseKey = [];
  List<int>? _encSessionKey;
  List<int>? _macSessionKey;
  List<int>? _dekSessionKey;
  List<int>? cardChallenge;
  SCP02Phase authState = SCP02Phase.UNSECURE;

  final List<int> _MAC_CONST = [0x01, 0x01];
  final List<int> _ENC_CONST = [0x01, 0x82];

  SCP02({Uint8List? enc, Uint8List? mac, Uint8List? dek, Uint8List? key}) {
    if (key == null) {
      if (enc == null || mac == null || dek == null) {
        throw Exception(
            "no suffcient keys provided. Either provide key or enc,mac,dek");
      }
      _encBaseKey = enc.toList();
      _macBaseKey = mac.toList();
      _dekBaseKey = dek.toList();
    } else {
      _encBaseKey = key.toList();
      _macBaseKey = key.toList();
      _dekBaseKey = key.toList();
    }
  }

  @override
  Tuple<Uint8List?, bool> getInitializeBytes(Uint8List? previousResponse) {
    // First SELECT command
    List<int> buffer;
    if (authState == SCP02Phase.UNSECURE) {
      print("Phase UNSECURE, sending SELECT");
      buffer = [ISO7816.CLA_ISO, ISO7816.INS_SELECT, 0x04, 0x00, 0x00];
      authState = SCP02Phase.SD_SELECT;
      return Tuple<Uint8List?, bool>(Uint8List.fromList(buffer), false);
    }

    // Second INITIALIZE UPDATE command
    if (authState == SCP02Phase.SD_SELECT) {
      print("Phase SD_SELECT, starting");
      // check previous reponse
      if (previousResponse == null || previousResponse.length < 2) {
        print("Phase SD_SELECT, previousResponse is null");
        authState = SCP02Phase.UNSECURE;
        return Tuple<Uint8List?, bool>(null, false);
      }

      List<int> SW =
          previousResponse.toList().sublist(previousResponse.length - 2);

      if (SW[0] != 0x90 || SW[1] != 0x00) {
        print("Phase SD_SELECT, previousResponse SW is not 9000");
        authState = SCP02Phase.UNSECURE;
        return Tuple<Uint8List?, bool>(null, false);
      }

      // Generate hostChallenge
      var random = Random.secure();

      _hostChallenge = [];
      for (int i = 0; i < 8; i++) {
        _hostChallenge.add(random.nextInt(256));
      }

      buffer = [GP.CLA_GP, GP.INS_INITIALIZE_UPDATE, 0x00, 0x00, 0x08];
      buffer.addAll(_hostChallenge);
      buffer.add(0x00); // le
      print("Phase SD_SELECT, sending INITIALIZE_UPDATE");
      authState = SCP02Phase.INITIALIZE_UPDATE;
      return Tuple<Uint8List?, bool>(Uint8List.fromList(buffer), false);
    }

    // Third EXTERNAL AUTHENTICATE Command
    if (authState == SCP02Phase.INITIALIZE_UPDATE) {
      if (previousResponse == null) {
        throw Exception("null response from INITIALIZE_UPDATE");
      }
      if (previousResponse.length != 30) {
        throw Exception(
            "Invalid response length from INITIALIZE_UPDATE. Expected 30, got ${previousResponse.length}");
      }

      List<int> SW = previousResponse.sublist(previousResponse.length - 2);

      if (SW[0] != 0x90 || SW[1] != 0x00) {
        throw Exception(
            "Invalid SW response length from INITIALIZE_UPDATE. Expected 9000, got ${hex.encode(SW)}");
      }

      _keyDiversification = previousResponse.sublist(0, 10);
      int scpVersion = previousResponse[11];
      if (scpVersion != 2) {
        throw Exception("Unknown SCP version $scpVersion");
      }
      _seqCounter = previousResponse.sublist(12, 14);
      cardChallenge = previousResponse.sublist(14, 20);
      _cardCryptogram = previousResponse.sublist(20, 28);

      // Calcualte ENC Session key
      List<int> data = [];
      data.addAll(_ENC_CONST);
      data.addAll(_seqCounter);
      data.addAll(List.filled(12, 0));

      DES3 desECB = DES3(
          key: _encBaseKey,
          mode: DESMode.CBC,
          iv: List.filled(8, 0),
          paddingType: DESPaddingType.None);
      _encSessionKey = desECB.encrypt(data);

      // Calculate card cryptogram
      data = [];
      data.addAll(_hostChallenge);
      data.addAll(_seqCounter);
      data.addAll(cardChallenge!);
      data = pad80(data, 8);

      desECB = DES3(
          key: _encSessionKey!,
          mode: DESMode.CBC,
          iv: List.filled(8, 0),
          paddingType: DESPaddingType.None);
      List<int> cardCryptogramCal = desECB.encrypt(data);
      cardCryptogramCal =
          cardCryptogramCal.sublist(cardCryptogramCal.length - 8);

      if (!listEquals(cardCryptogramCal, _cardCryptogram)) {
        throw Exception(
            "card cryptogram is invalid. Calculated ${hex.encode(cardCryptogramCal)}, received ${hex.encode(_cardCryptogram)}");
      }

      List<int> command = [
        GP.CLA_GP_SECURE_CMAC,
        GP.INS_EXTERNAL_AUTHENTICATE,
        0x01,
        0x00,
        0x10
      ];

      getHostCryptogram();
      command.addAll(_hostCryptogram!);

      getCMAC(command);
      command.addAll(_CMAC!);

      command.add(0x00); //le
      authState = SCP02Phase.EXTERNAL_AUTHENTICATE;
      return Tuple<Uint8List?, bool>(Uint8List.fromList(command), false);
    }

    // check the response of EXTERNAL AUTHENTICATE Command, then return true or false
    if (authState == SCP02Phase.EXTERNAL_AUTHENTICATE) {
      if (previousResponse == null) {
        throw Exception("XXXX");
      }

      if (previousResponse.length < 2) {
        throw Exception("TTTTTT");
      }

      List<int> SW = previousResponse.sublist(previousResponse.length - 2);

      if (SW[0] != 0x90 || SW[1] != 0x00) {
        throw Exception("SDDSSSSSS");
      }
      authState = SCP02Phase.SECURE_CMAC;
      return Tuple<Uint8List?, bool>(null, true);
    }

    return Tuple<Uint8List?, bool>(null, false);
  }

  @override
  bool isInitialized() {
    return _isInitialized;
  }

  @override
  Uint8List wrapCommand(int cla, int ins, int p1, int p2, Uint8List lc,
      Uint8List cdata, Uint8List le) {
    if (authState == SCP02Phase.SECURE_CMAC) {
      if (cdata.length > (256 - 8)) {
        throw Exception("CDATA shoule be less than 256-8");
      }
      int lcTotal = Channel.arrayToLength(lc);
      lcTotal = cdata.length + 8;
      lc = Channel.lengthToArray(lcTotal);

      List<int> command = [cla, ins, p1, p2];
      command.addAll(lc);
      command.addAll(cdata);

      // calculate C-MAC
      getCMAC(command);

      command.addAll(_CMAC!);
      command.add(0x00); //le

      return Uint8List.fromList(command);
    }

    List<int> command = [cla, ins, p1, p2];
    command.addAll(lc);
    command.addAll(cdata);
    command.add(0x00); //le

    return Uint8List.fromList(command);
  }

  List<int> getHostCryptogram() {
    if (_encSessionKey != null) {
      var desECB = DES3(
          key: _encSessionKey!,
          mode: DESMode.CBC,
          iv: List.filled(8, 0),
          paddingType: DESPaddingType.None);
      List<int> data = [];
      data.addAll(_seqCounter);
      data.addAll(cardChallenge!);
      data.addAll(_hostChallenge);
      data = pad80(data, 8);

      _hostCryptogram = desECB.encrypt(data);
    }

    if (_hostCryptogram == null) {
      throw Exception("Unable to calculate Host Cryptogram");
    }

    _hostCryptogram = _hostCryptogram!.sublist(_hostCryptogram!.length - 8);

    return _hostCryptogram!;
  }

  List<int> getCMAC(List<int> apduCommandBytes) {
    if (_macSessionKey == null) {
      var desECB = DES3(
          key: _macBaseKey,
          mode: DESMode.CBC,
          iv: List.filled(8, 0),
          paddingType: DESPaddingType.None);
      List<int> data = [];
      data.addAll(_MAC_CONST);
      data.addAll(_seqCounter);
      data.addAll(List.filled(12, 0));

      _macSessionKey = desECB.encrypt(data);
    }

    List<int> data = pad80(apduCommandBytes, 8);
    _CMAC = macIso9797Alg3(_macSessionKey!, data, iv: _CMAC);

    if (_CMAC == null) {
      throw Exception("Unable to calculate CMAC");
    }

    return _CMAC!;
  }

  List<int> pad80(List<int> text, int blocksize) {
    int total = ((text.length ~/ blocksize) + 1) * blocksize;
    List<int> result = List.from(text);
    result.addAll(List.filled(total - text.length, 0));

    result[text.length] = 0x80;
    return result;
  }

  List<int>? macIso9797Alg3(List<int> key, List<int> msg, {List<int>? iv}) {
    if (key.length != 16) {
      // print("Key length should be 16 bytes");
      return null;
    }

    var keya = key.sublist(0, 8);
    var keyb = key.sublist(8);

    DES desECB;
    if (iv == null) {
      iv = List.filled(8, 0);
    } else {
      desECB = DES(
          key: keya,
          mode: DESMode.CBC,
          iv: List.filled(8, 0),
          paddingType: DESPaddingType.None);
      iv = desECB.encrypt(iv);
    }

    desECB = DES(
        key: keya, mode: DESMode.CBC, iv: iv, paddingType: DESPaddingType.None);
    List<int> res = desECB.encrypt(msg);

    if (res.length > 8) {
      res = res.sublist(res.length - 8);
    }

    desECB =
        DES(key: keyb, mode: DESMode.ECB, paddingType: DESPaddingType.None);
    res = desECB.decrypt(res);

    desECB =
        DES(key: keya, mode: DESMode.ECB, paddingType: DESPaddingType.None);
    res = desECB.encrypt(res);

    return res;
  }
}
