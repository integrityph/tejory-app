import 'package:tejory/wallets/wallet_app.dart';

class WalletStatus {
  bool setupCompleted = true;
  bool pinLocked = false;
  String serialNumber = "";
  String version = "";
  String apiVersion = "";
  Map<int, bool> availableKeys = {};
  int installedAppsCount = 0;
  List<WalletApp> installedApps = [];
}
