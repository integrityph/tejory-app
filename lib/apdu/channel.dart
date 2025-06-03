// ignore_for_file: prefer_const_constructors, unused_field, non_constant_identifier_names, prefer_final_fields

import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:nfc_manager/nfc_manager_ios.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:tejory/apdu/channelWrapper.dart';
import 'dart:io' show Platform;

class Channel {
  ChannelWrapper? _wrapper;
  IsoDepAndroid? _isoDep;
  Iso7816Ios? _iso7816;
  bool _debug = false;
  List<String> logs = [];
  String os = Platform.operatingSystem;

  Channel(NfcTag? tag, {ChannelWrapper? wrapper, bool debug = false}) {
    _wrapper = wrapper;
    _debug = debug;
    if (tag != null) {
      if (Platform.isAndroid) {
        _isoDep = IsoDepAndroid.from(tag);
      } else if (Platform.isIOS) {
        _iso7816 = Iso7816Ios.from(tag);
      }
    }
  }

  void setTag(NfcTag tag) {
    if (Platform.isAndroid) {
      _isoDep = IsoDepAndroid.from(tag);
    } else if (Platform.isIOS) {
      _iso7816 = Iso7816Ios.from(tag);
    }
  }

  void log(String val) {
    if (_debug) {
      print("DEBUG: $val");
      logs.add(val);
    }
  }

  static Uint8List lengthToArray(int val, {bool omitZero = true}) {
    List<int> buf = [];
    if (val == 0) {
      if (omitZero) {
        buf = [];
      } else {
        buf = [val];
      }
    } else if (val < 256) {
      buf = [val];
    } else {
      buf = [0, 0, 0];
      buf[1] = (val & 0xff00) >> 8;
      buf[0] = val & 0xff;
    }
    return Uint8List.fromList(buf);
  }

  static int arrayToLength(Uint8List? buf) {
    int val = 0;
    if (buf == null || buf.isEmpty) {
      val = 0;
    } else if (buf.length == 1) {
      val = buf[0];
    } else {
      val += buf[1] << 8;
      val += buf[0];
    }
    return val;
  }

  static int swToInt(Uint8List? buf) {
    if (buf == null) {
      return 0;
    }
    if (buf.length < 2) {
      return 0;
    }
    int val = 0;
    val += buf[buf.length - 2] << 8;
    val += buf[buf.length - 1];

    return val;
  }

  static Uint8List intToSW(int val) {
    return Uint8List.fromList([(val & 0xff00) >> 8, val & 0xff]);
  }

  Future<bool> initializeWrapper() async {
    log("initializing wrapper");

    if (_wrapper == null) {
      return true;
    }
    try {
      Tuple<Uint8List?, bool> wrapperCommand =
          Tuple<Uint8List?, bool>(null, false);
      Uint8List? response;
      for (int i = 0; i < 4; i++) {
        wrapperCommand = _wrapper!.getInitializeBytes(response);
        if (wrapperCommand.item2 == true) {
          return true;
        }

        response = await sendRawBytes(wrapperCommand.item1!);
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<Uint8List?> sendAPDU(
      int cla, int ins, int p1, int p2, int lc, Uint8List cdata, int le,
      {bool wrap = false}) async {
    if (wrap && _wrapper != null && !_wrapper!.isInitialized()) {
      bool successful = await initializeWrapper();

      if (!successful) {
        return null;
      }
    }

    var lcArray = lengthToArray(lc);
    var leArray = lengthToArray(le, omitZero: false);

    Uint8List buffer;
    if (wrap && _wrapper != null) {
      buffer = _wrapper!.wrapCommand(cla, ins, p1, p2, lcArray, cdata, leArray);
    } else {
      List<int> command = [
        cla,
        ins,
        p1,
        p2,
      ];
      command.addAll(lcArray);
      command.addAll(cdata);
      command.addAll(leArray);
      buffer = Uint8List.fromList(command);
    }

    return await sendRawBytes(buffer);
  }

  Future<Uint8List> sendRawBytes(Uint8List buffer) async {
    log("sending command ${hex.encode(buffer)}");
    Uint8List response;
    try {
      if (Platform.isAndroid) {
        response = await _isoDep!.transceive(buffer);
      } else if (Platform.isIOS) {
        var isoRes = await _iso7816!.sendCommandRaw(data: buffer);
        
        response = Uint8List.fromList([...isoRes.payload, isoRes.statusWord1, isoRes.statusWord2]);
      } else {
        response = Uint8List(0);
      }
    } catch (error) {
      print(error);
      return Uint8List(0);
    }

    log("response ${hex.encode(response)}");
    return response;
  }
}
