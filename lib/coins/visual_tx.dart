import 'package:tejory/crypto-helper/other_helpers.dart';
import 'package:tejory/ui/asset.dart';

class VisualTx {
  int amount = 0;
  int spentAmount = 0;
  int earnedAmount = 0;
  int fee = 0;
  double? usdAmount = 0;
  DateTime? time = DateTime.now();
  String inAddress = "";
  String outAddress = "";
  bool isDeposit = true;

  String getFiatValue(Asset asset) {
    if (usdAmount == null) {
      return "---";
    }
    return "${OtherHelpers.humanizeMoney(asset.getDecimalAmountInDouble(BigInt.from((amount > 0 ? amount : -amount))) * usdAmount!, isFiat: true)}";
  }

  String getFiatRate (Asset asset) {
    if (usdAmount == null) {
      return "1${asset.symbol} = ???";
    }
    return "1${asset.symbol} = ${OtherHelpers.humanizeMoney(usdAmount!, isFiat: true)}";
  }
}