class VisualTx {
  int amount = 0;
  int spentAmount = 0;
  int earnedAmount = 0;
  int fee = 0;
  double usdAmount = 0;
  DateTime? time = DateTime.now();
  String inAddress = "";
  String outAddress = "";
  bool isDeposit = true;
}