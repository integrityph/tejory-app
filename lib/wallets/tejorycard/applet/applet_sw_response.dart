import 'dart:typed_data';

import 'package:blockchain_utils/blockchain_utils.dart';

class AppletSWResponse {
  // Define constants for status codes for better readability
  static const int SW_SUCCESS = 0x9000;
  static const int SW_SETUP_ALREADY_DONE = 0x6F01;
  static const int SW_INVALID_PIN = 0x6F02;
  static const int SW_LOCKED_PIN = 0x6F03;
  static const int SW_WRONG_LENGTH = 0x6F04;
  static const int SW_NOT_SET = 0x6F05;
  static const int REFERENCED_DATA_NOT_FOUND = 0x6a88;

  // Using a Map for better readability and faster lookup
  static const Map<int, String> statusMessages = {
    SW_SUCCESS: "SUCCESS",
    SW_SETUP_ALREADY_DONE: "SW SETUP ALREADY DONE",
    SW_INVALID_PIN: "SW INVALID PIN",
    SW_LOCKED_PIN: "SW LOCKED PIN",
    SW_WRONG_LENGTH: "SW WRONG LENGTH",
    SW_NOT_SET: "SW NOT SET",
    REFERENCED_DATA_NOT_FOUND: "REFERENCED DATA NOT FOUND",
  };

  // Retrieve the message based on the status code, return "UNKNOWN" if not found
  static String getSWResponse(int sw, Uint8List swBytes) {
    return statusMessages[sw] ??
        "Invalid SW, expected 0x9000, got 0x${hex.encode(swBytes)}";
  }
}
