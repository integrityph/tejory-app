class CoresInstruction {
  static const int INS_INITIAL_SETUP = 0x01;
  static const int INS_REPLACE_HD_SEED = 0x02;
  static const int INS_HD_PUB_KEY_DERIVE = 0x03;
  static const int INS_SET_PRIV_KEY = 0x04;
  static const int INS_GET_PUB_KEY = 0x05;
  static const int INS_CHANGE_PIN = 0x06;
  static const int INS_GET_STATUS = 0x07;
  static const int INS_CARD_AUTH_VERIFY = 0x08;
  static const int INS_CARD_RESET = 0x09;
  static const int INS_MANAGE_APPLETS_ACL = 0x0A;
  static const int INS_VERIFY_PIN = 0x0B;
}
