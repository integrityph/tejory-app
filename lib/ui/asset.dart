import 'dart:typed_data';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:tejory/coins/asset_isolate.dart';
import 'package:tejory/coins/bitcoin.dart';
import 'package:tejory/coins/btcln.dart';
import 'package:tejory/coins/crypto_coin.dart';
import 'package:tejory/coins/erc-20.dart';
import 'package:tejory/coins/ether.dart';
import 'package:tejory/coins/pst.dart';
import 'package:tejory/coins/tx.dart';
import 'package:tejory/coins/visual_tx.dart';
import 'package:tejory/coins/wallet.dart';
import 'package:tejory/objectbox.g.dart';
import 'package:tejory/objectbox/balance.dart';
import 'package:tejory/objectbox/coin.dart';
import 'package:tejory/objectbox/tx.dart';
import 'package:tejory/objectbox/wallet_db.dart';
import 'package:tejory/box_models.g.dart';
import 'package:tejory/singleton.dart';
import 'package:tejory/wallets/wallet_type.dart';

class Asset with ChangeNotifier {
  final String id;
  final String name;
  final String symbol;
  int amount = 0;
  double priceUsd;
  double changePercent24Hr;
  double lastChange = 0.0;
  String _hrpBech32 = "";
  late int decimals;
  String yahooFinance = "";
  int hdCode = 0;
  String webId = "";
  String peerSeedType = "";
  String peerSource = "";
  int defaultPort = 0;
  String magic = "";
  List<CryptoCoin> coins = [];
  CryptoCoin? coinTemplate;
  int? walletId;
  String? blockZeroHash;
  int? coinId;
  String? netVersionPublicHex;
  String? netVersionPrivateHex;
  String? contractHash;
  String? template;
  bool initialRateSaved = false;
  AssetIsolate? isolate;
  int assetIndex = 0;
  Widget iconOnline = Container(width: 40, height: 40);
  Widget iconOffline = Container(width: 40, height: 40);
  bool active = true;
  bool workerIsolateRequired = false;
  List<void Function()?> _listeners = [];

  Asset({
    required this.id,
    required this.name,
    required this.symbol,
    required this.priceUsd,
    required this.changePercent24Hr,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    try {
      Asset asset = Asset(
        id: json['id'],
        name: json['name'],
        symbol: json['symbol'],
        priceUsd: double.tryParse(json['priceUsd'] ?? '0') ?? 0,
        changePercent24Hr:
            double.tryParse(json['changePercent24Hr'] ?? '0') ?? 0,
      );
      asset._hrpBech32 = json['hrpBech32'] ?? '';
      asset.decimals = json['decimals'] ?? 8;
      asset.yahooFinance = json['yahooFinance'] ?? '';
      asset.hdCode = json['hdCode'] ?? 0;
      asset.webId = json['webId'] ?? (json['id'] ?? '');
      asset.peerSeedType = json['peerSeedType'] ?? '';
      asset.peerSource = json['peerSource'] ?? '';
      asset.defaultPort = json['defaultPort'] ?? 0;
      asset.magic = json['magic'] ?? '';
      asset.blockZeroHash = json['blockZeroHash'] ?? '';
      asset.netVersionPublicHex = json['netVersionPublicHex'] ?? '';
      asset.netVersionPrivateHex = json['netVersionPrivateHex'] ?? '';
      asset.contractHash = json['contractHash'] ?? '';
      asset.template = json['template'] ?? '';
      asset.active = json['active'] ?? true;
      asset.workerIsolateRequired = json['workerIsolateRequired'] ?? false;
      return asset;
    } catch (e) {
      throw e;
    }
  }

  void loadIcons(BuildContext context) async {
    iconOnline = Image.asset(
      'assets/${symbol.toLowerCase()}.png',
      width: 40,
      height: 40,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.error);
      },
    );

    iconOffline = Image.asset(
      'assets/${symbol.toLowerCase()}.png',
      width: 40,
      height: 40,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.error);
      },
      colorBlendMode: BlendMode.saturation,
      color: Theme.of(context).colorScheme.secondary,
    );
  }

  void updatePrice(Asset newPriceData) {
    bool priceActuallyChanged = (this.priceUsd != newPriceData.priceUsd);
    this.lastChange = newPriceData.priceUsd - this.priceUsd;

    if (priceActuallyChanged) {
      this.priceUsd = newPriceData.priceUsd;
    }
    this.changePercent24Hr = newPriceData.changePercent24Hr;

    if (!this.initialRateSaved) {
      // Check if we've already done the initial save
      this.initialRateSaved = true;
      // Future<Coin?> coinFtr =
      //     Singleton.getDB().coins.filter().idEqualTo(this.coinId!).findFirst();
      Coin? coin = Models.coin.getById(this.coinId!);

      if (coin != null) {
        coin.usdPrice = this.priceUsd; // Save the current price
        coin.save();
      }
    }

    if (priceActuallyChanged) {
      notifyListeners();
    }
  }

  void updateUsdPrice(double newPrice) {
    lastChange = newPrice - priceUsd;
    if (priceUsd != newPrice) {
      priceUsd = newPrice;
      notifyListeners();
    }
  }

  void setBech32HRP(String hrp) {
    _hrpBech32 = hrp;
    for (int i = 0; i < coins.length; i++) {
      coins[i].hrp = hrp;
    }
  }

  String getBech32HRP() {
    return _hrpBech32;
  }

  Future<void> initWorker() async {
    if (!active || !workerIsolateRequired) {
      if (isolate != null) {
        isolate!.kill().then((_) {
          isolate = null;
        });
      }
      return;
    }
    if (isolate != null && isolate!.initializedCoinCount == coins.length) {
      return;
    }
    isolate = AssetIsolate(coins);
    return isolate!.ready();
  }

  Future<void> initCoin(List<WalletDB> wallets, {bool online = true}) async {
    // var isar = Singleton.getDB();
    Map<String, dynamic> configMap = {
      "symbol": symbol,
      "walletId": 0,
      "walletType": WalletType.unknown,
      "magic": hex.decode(magic),
      "port": defaultPort,
      "peerSeedType": peerSeedType,
      "peerSource": peerSource,
      "coinId": coinId,
      "netVersionPublicHex": netVersionPublicHex,
      "netVersionPrivateHex": netVersionPrivateHex,
      "decimals": decimals,
      "name": name,
      "contractHash": contractHash,
      "template": template,
      "id": coinId,
      "active": active,
      "workerIsolateRequired": workerIsolateRequired,
    };
    coinTemplate = fromConfig(configMap);

    for (int i = 0; i < wallets.length; i++) {
      if (coins.length < i + 1) {
        configMap["walletId"] = wallets[i].id;
        coins.add(fromConfig(configMap)!);
      }
      coins[i].walletId = wallets[i].id;
      coins[i].walletType = wallets[i].type;
      coins[i].hrp = _hrpBech32;
      coins[i].decimals = decimals;
      coins[i].online = online;
      coins[i].assetIndex = assetIndex;
      coins[i].coinIndex = i;
      _listeners.forEach((listener) => coins[i].addListener(listener!));
    }

    // initialize workers and initialize coins after that
    await initWorker().then((_) async {
      for (int i = 0; i < coins.length; i++) {
        // Load tx
        // Future<List<TxDB>> txListFtr =
        //     isar.txDBs
        //         .filter()
        //         .coinEqualTo(coinId)
        //         .walletEqualTo(wallets[i].id)
        //         .findAll();
        // Future<List<TxDB>?> txListFtr = Models.txDB.find(q:FilterGroup.and([
        //   FilterCondition.equalTo(property: "coin", value: coinId),
        // ]));
        List<TxDB>? txList = Models.txDB.find(q: TxDB_.coin.equals(coinId!));

        // Future<Balance?> balanceFtr = isar.balances.getByCoinWallet(
        //   coinId,
        //   coins[i].walletId,
        // );
        Balance? balance = Models.balance.getUnique(coinId, coins[i].walletId);
        await coins[i].initCoin(
          blocks: null,
          txList: txList,
          balanceDB: balance,
        );
      }
    });
  }

  static CryptoCoin? fromConfig(Map<String, dynamic> config) {
    CryptoCoin? coin;
    switch (config["symbol"]) {
      case "BTC":
        coin = Bitcoin(
          config["walletId"],
          walletType: config["walletType"],
          magic: config["magic"],
          port: config["port"],
          peerSeedType: config["peerSeedType"],
          peerSource: config["peerSource"],
          coinId: config["coinId"],
          netVersionPublicHex: config["netVersionPublicHex"],
          netVersionPrivateHex: config["netVersionPrivateHex"],
        );
        break;
      case "ETH":
        coin = Ether(
          config["walletId"],
          walletType: config["walletType"],
          magic: config["magic"],
          port: config["port"],
          peerSeedType: config["peerSeedType"],
          peerSource: config["peerSource"],
          coinId: config["coinId"],
          netVersionPublicHex: config["netVersionPublicHex"],
          netVersionPrivateHex: config["netVersionPrivateHex"],
        );
        break;
      case "BTCLN":
        coin = BTCLN(
          config["walletId"],
          walletType: config["walletType"],
          magic: config["magic"],
          port: config["port"],
          peerSeedType: config["peerSeedType"],
          peerSource: config["peerSource"],
          coinId: config["coinId"],
          netVersionPublicHex: config["netVersionPublicHex"],
          netVersionPrivateHex: config["netVersionPrivateHex"],
        );
        break;
      default:
        if ((config["template"] ?? "") == "ERC-20") {
          coin = ERC20(
            config["walletId"],
            walletType: config["walletType"],
            magic: config["magic"],
            port: config["port"],
            peerSeedType: config["peerSeedType"],
            peerSource: config["peerSource"],
            decimals: config["decimals"],
            coinId: config["coinId"],
            netVersionPublicHex: config["netVersionPublicHex"],
            netVersionPrivateHex: config["netVersionPrivateHex"],
            coinName: config["name"],
            coinSymbol: config["symbol"],
            contractHash: config["contractHash"],
          );
        }
        break;
    }

    if (coin == null) {
      return null;
    }
    coin.id = config["coinId"];
    coin.template = config["template"] ?? null;
    coin.walletId = config["walletId"];
    coin.hrp = config["hrp"] ?? "";
    coin.decimals = config["decimals"];
    coin.online = config["online"] ?? false;
    coin.assetIndex = config["assetIndex"] ?? 0;
    coin.coinIndex = config["coinIndex"] ?? 0;

    return coin;
  }

  BigInt getBalance({bool notify = false}) {
    BigInt balance = BigInt.zero;
    if (walletId != null) {
      for (int i = 0; i < coins.length; i++) {
        if (coins[i].walletId == walletId) {
          balance = coins[i].getBalance();
          break;
        }
      }
    } else {
      for (int i = 0; i < coins.length; i++) {
        balance += coins[i].getBalance();
      }
    }
    // print("asset.getBalance balance: ${balance.toInt()}");
    if (notify) {
      notifyListeners();
    }

    return balance;
  }

  int getWalletId() {
    int? usedWalletId;
    if (walletId != null) {
      usedWalletId = walletId;
    } else {
      usedWalletId = int.parse(Singleton.settings["DefaultWalletId"] ?? "1");
    }
    return usedWalletId!;
  }

  Future<Wallet> getWallet() async {
    int tempWalletId = getWalletId();
    Wallet wallet = Wallet(id: tempWalletId);
    await wallet.loaded.future;
    return wallet;
  }

  WalletType getWalletType() {
    CryptoCoin? coin = getCoinByWalletId(getWalletId());
    if (coin == null) {
      return WalletType.unknown;
    }
    return coin.walletType;
  }

  CryptoCoin? getCoinByWalletId(int usedWalletId) {
    for (int i = 0; i < coins.length; i++) {
      if (coins[i].walletId == usedWalletId) {
        return coins[i];
      }
    }
    return null;
  }

  Future<Tx?> makeTransaction(
    String toAddress,
    BigInt amount, {
    noChange = false,
  }) async {
    int usedWalletId = getWalletId();
    CryptoCoin? usedCoin = getCoinByWalletId(usedWalletId);
    return usedCoin?.makeTransaction(toAddress, amount, noChange: noChange);
  }

  PST makePST(Tx tx) {
    int usedWalletId = getWalletId();
    CryptoCoin? usedCoin = getCoinByWalletId(usedWalletId);
    return usedCoin!.makePST(tx);
  }

  Future<Uint8List?> signPST(PST? pst, Tx? tx, BuildContext? context) {
    int usedWalletId = getWalletId();
    CryptoCoin? usedCoin = getCoinByWalletId(usedWalletId);
    return usedCoin!.signPST(pst, tx, context);
  }

  Future<Uint8List?> signTx(PST? pst, Tx? tx, BuildContext? context) {
    int usedWalletId = getWalletId();
    CryptoCoin? usedCoin = getCoinByWalletId(usedWalletId);
    return usedCoin!.signTx(pst, tx, context);
  }

  Future<Map<String, dynamic>?> transmitTxBytes(Uint8List buf) async {
    return coins[0].sendTxBytes(buf);
  }

  Uint8List getAddressBytes(String address) {
    return coins[0].getAddressBytes(address);
  }

  BigInt getBaseAmount(double val) {
    return coins[0].getBaseAmount(val);
  }

  String getDecimalAmount(BigInt val) {
    if (coins.length == 0) {
      return "0";
    }
    return coins[0].getDecimalAmount(val);
  }

  String getDecimalAmountFromDouble(double val) {
    if (coins.length == 0) {
      return "0";
    }
    return coins[0].getDecimalAmount(coins[0].getBaseAmount(val));
  }

  double getDecimalAmountInDouble(BigInt val) {
    if (coins.length == 0) {
      return 0;
    }
    return double.parse(coins[0].getDecimalAmount(val));
  }

  BigInt? getAmountFromAddress(String address) {
    if (coins.length == 0) {
      print("getAmountFromAddress no coins");
      return null;
    }
    return coins[0].getAmountFromAddress(address);
  }

  Future<void> updateBalance() {
    int usedWalletId = getWalletId();
    CryptoCoin? usedCoin = getCoinByWalletId(usedWalletId);
    return usedCoin!.updateBalance();
  }

  Future<String> getReceivingAddress({String? network, BigInt? amount}) async {
    int usedWalletId = getWalletId();
    CryptoCoin? usedCoin = getCoinByWalletId(usedWalletId);
    var address = await usedCoin!.getReceivingAddress(
      network: network,
      amount: amount,
    );
    return address;
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);

    _listeners.add(listener);

    for (int i = 0; i < coins.length; i++) {
      coins[i].addListener(listener);
    }
  }

  void triggerNotifier() {
    notifyListeners();
  }

  String getFeeSymbol() {
    if (template != null && template == "ERC-20") {
      return "ETH";
    }
    return symbol;
  }

  Future<BigInt> calculateFee(
    String toAddress,
    BigInt amount, {
    noChange = false,
  }) async {
    return await coins[0].calculateFee(toAddress, amount, noChange: noChange);
  }

  void storeTransaction(
    Tx tx, {
    PST? pst,
    bool confirmed = true,
    bool verified = true,
    bool failed = false,
  }) async {
    int usedWalletId = getWalletId();
    CryptoCoin? usedCoin = getCoinByWalletId(usedWalletId);
    usedCoin!.storeTransaction(
      tx,
      pst: pst,
      confirmed: confirmed,
      verified: verified,
      failed: failed,
    );
  }

  List<VisualTx> getVisualTxList(List<TxDB> txDBList) {
    int usedWalletId = getWalletId();
    CryptoCoin? usedCoin = getCoinByWalletId(usedWalletId);
    return usedCoin!.getVisualTxList(txDBList);
  }

  bool isValidAddress(String address) {
    int usedWalletId = getWalletId();
    CryptoCoin? usedCoin = getCoinByWalletId(usedWalletId);
    return usedCoin!.isValidAddress(address);
  }

  String getTrackingURL(String txHash) {
    int usedWalletId = getWalletId();
    CryptoCoin? usedCoin = getCoinByWalletId(usedWalletId);
    return usedCoin!.getTrackingURL(txHash);
  }
}

class AssetsData {
  final List<Asset> assets;
  final int version;

  AssetsData({required this.assets, required this.version});

  factory AssetsData.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<Asset> assetsList = list.map((i) => Asset.fromJson(i)).toList();
    return AssetsData(assets: assetsList, version: json['version'] ?? 0);
  }
}
