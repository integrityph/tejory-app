import 'package:tejory/wallets/wallet_app.dart';

class WalletStatus {
  bool setupCompleted = true;
  int pinRemainingTries = 0;
  int pukRemainingTries = 0;
  String serialNumber = "";
  String version = "";
  String apiVersion = "";
  Map<int, bool> availableKeys = {};
  int installedAppsCount = 0;
  List<WalletApp> installedApps = [];
}
