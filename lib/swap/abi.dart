import 'package:blockchain_utils/hex/hex.dart';
import 'package:tejory/coins/erc-20.dart';
import 'package:tejory/coins/ether.dart';
import 'package:tejory/swap/abi_encoder.dart';
import 'package:tejory/swap/get_contract_hash.dart';

class Abi {
  static List<int> encodePacked(dynamic val, int length) {
    String hexVal = "";
    switch (val.runtimeType) {
      case int:
      hexVal = (val as int).toRadixString(16).padLeft(length*2, "0");
    }

    return hex.decode(hexVal);
  }

	static List<int> encode(dynamic v, {bool padLeft=true}) {
    String hexVal = "";
    // print(v.runtimeType == const(List<int>));
    switch (v) {
      case AbiEncoder val:
				return val.encode();
      case int val:
      	hexVal = val.toRadixString(16).padLeft(64, "0");
      case BigInt val:
      	hexVal = val.toRadixString(16).padLeft(64, "0");
      case String val:
      	hexVal = hex.encode(val.codeUnits).padRight(64, "0");
			case List<int> val:
        if (padLeft) {
          hexVal = hex.encode(val).padLeft(64, "0");
        } else {
          hexVal = hex.encode(val).padRight(64, "0");
        }
      // case Uint8List val:
      //   if (padLeft) {
      //     hexVal = hex.encode(val).padLeft(64, "0");
      //   } else {
      //     hexVal = hex.encode(val).padRight(64, "0");
      //   }
      case bool val:
        hexVal = ((val == true) ? "1" : "0").padLeft(64, "0");
      case ERC20 val:
        return getContractHash(val);
      case Ether val:
        return getContractHash(val);
    }

    return hex.decode(hexVal);
  }
}