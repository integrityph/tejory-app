import 'dart:typed_data';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:tejory/wallets/tejorycard/applet/applet_aid.dart';

class AppletObject {
  AppletAID AID;
  int appletVersion = 0;
  int functionACL = 0;
  Uint8List allowedPathMask = Uint8List(0);
  Uint8List allowedPath = Uint8List(0);

  AppletObject(this.AID);

  AppletObject.fromAIDBytes(Uint8List aidBytes) : AID = AppletAID(aidBytes);

  static Tuple<AppletObject, int> parseBytes(Uint8List buf, int offset) {
    if (buf.length < 5 + offset) {
      throw Exception(
          "Unable to parse AppletObject while reading AID. The length should be at least ${5 + offset} bytes but got ${buf.length}");
    }
    AppletAID aid = AppletAID(buf.sublist(offset, offset + 5));
    AppletObject temp = AppletObject(aid);
    offset += 5;

    if (buf.length < 2 + offset) {
      throw Exception(
          "Unable to parse AppletObject while reading Applet Version. The length should be at least ${2 + offset} bytes but got ${buf.length}");
    }
    temp.appletVersion = buf[offset] << 8;
    temp.appletVersion += buf[offset + 1];
    offset += 2;

    if (buf.length < 4 + offset) {
      throw Exception(
          "Unable to parse AppletObject while reading Function ACL. The length should be at least ${4 + offset} bytes but got ${buf.length}");
    }
    temp.functionACL = buf[offset + 0] << (8 * 3);
    temp.functionACL += buf[offset + 1] << (8 * 2);
    temp.functionACL += buf[offset + 2] << (8 * 1);
    temp.functionACL += buf[offset + 3] << (8 * 0);
    offset += 4;

    if (buf.length < 1 + offset) {
      throw Exception(
          "Unable to parse AppletObject while reading Allowed Path Length. The length should be at least ${1 + offset} bytes but got ${buf.length}");
    }
    int pathLength = buf[offset];
    offset += 1;

    if (buf.length < pathLength + offset) {
      throw Exception(
          "Unable to parse AppletObject while reading Allowed Path Mask. The length should be at least ${pathLength + offset} bytes but got ${buf.length}");
    }
    temp.allowedPathMask = buf.sublist(offset, offset + pathLength);
    offset += pathLength;

    if (buf.length < pathLength + offset) {
      throw Exception(
          "Unable to parse AppletObject while reading Allowed Path. The length should be at least ${pathLength + offset} bytes but got ${buf.length}");
    }
    temp.allowedPath = buf.sublist(offset, offset + pathLength);
    offset += pathLength;

    return Tuple<AppletObject, int>(temp, offset);
  }

  static List<AppletObject> parseAppListFromBytes(Uint8List buf, int offset) {
    List<AppletObject> appList = [];

    while (buf.length - offset < 5) {
      var app = parseBytes(buf, offset);
      appList.add(app.item1);
      offset = app.item2;
    }

    return appList;
  }
}
