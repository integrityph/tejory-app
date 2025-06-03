import 'dart:typed_data';

class AppletAID {
  // all AID flags are for byte 0
  static const _AID_FLAG_IS_CORE = 0x80;
  static const _AID_FLAG_IS_COIN = 0x40;
  static const _AID_LENGTH = 8;
  static const _CLASSIFICATION_BYTE_INDEX = 2;

  late Uint8List _value;

  AppletAID(Uint8List aid) {
    if (aid.length < _AID_LENGTH) {
      throw Exception("AID is less than $_AID_LENGTH bytes");
    }
    _value = aid;
  }

  bool isCoreApplet() {
    return (_value[_CLASSIFICATION_BYTE_INDEX] & _AID_FLAG_IS_CORE ==
        _AID_FLAG_IS_CORE);
  }

  bool isCoinApplet() {
    return (!isCoreApplet() &
        (_value[_CLASSIFICATION_BYTE_INDEX] & _AID_FLAG_IS_COIN ==
            _AID_FLAG_IS_COIN));
  }

  Uint8List getCoinID() {
    return _value.sublist(3, 7);
  }
}
