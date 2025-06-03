import 'package:flutter/material.dart';

enum MediumType {
  Unknown(0x00),
  NFC(0x01);

  const MediumType(this.value);
  final int value;

  static MediumType getByValue(int i) {
    return MediumType.values.firstWhere((x) => x.value == i);
  }
}

typedef NFCSessionCallbackFunction = Future<bool> Function(dynamic session, {List<int>? pinCode, List<int>? pinCodeNew});

abstract class Medium {
  MediumType type = MediumType.Unknown;
  Medium(var _session);
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
