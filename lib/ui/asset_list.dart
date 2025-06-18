import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:tejory/coindesk/api.dart' as coindesk;
import 'package:tejory/objectbox.g.dart';
import 'package:tejory/objectbox/block.dart';
import 'package:tejory/objectbox/coin.dart';
import 'package:tejory/objectbox/data_version.dart';
import 'package:tejory/objectbox/lp.dart';
import 'package:tejory/objectbox/wallet_db.dart';
import 'package:tejory/crypto-helper/blockchain_api.dart';
import 'package:tejory/crypto-helper/other_helpers.dart';
import 'package:tejory/box_models.g.dart';
import 'package:tejory/singleton.dart';
import 'package:tejory/swap/liquidity_pool.dart';
import 'package:tejory/ui/currency.dart';
import 'package:tejory/ui/setup/start_setup.dart';
import 'package:tejory/ui/setup/page_animation.dart';
import 'package:tejory/ui/token_details.dart';
import 'asset.dart';
import 'package:flutter/services.dart' show rootBundle, ByteData;

class AssetList extends StatefulWidget {
  AssetList.newBlank({super.key});
  AssetList({super.key, required this.humanizeMoney});

  late final String Function(double, {bool isFiat}) humanizeMoney;
  late final TextEditingController searchController;
  final _AssetListState assetListState = _AssetListState();

  @override
  State<AssetList> createState() => assetListState;
}

class _AssetListState extends State<AssetList> with ChangeNotifier {
  Future<AssetsData?>? futureData;
  List<Asset> assets = [];
  List<WalletDB> walletList = [];
  List<Asset> filteredAssets = [];
  int? myWalletId;
  List<VoidCallback> listeners = [];
  // Future<bool>? assetsLoaded;
  List<Currency> currencyList = [];
  bool privacy = true;

  void setWalletId(int? walletId) {
    myWalletId = walletId;
    for (int i = 0; i < assets.length; i++) {
      assets[i].walletId = walletId;
    }
  }

  void setAmount(int amount, int index) {
    assets[index].amount = amount;
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    listeners.add(listener);

    for (final asset in assets) {
      asset.addListener(listener);
    }
  }

  refreshListeners() {
    for (var listener in listeners) {
      for (final asset in assets) {
        asset.addListener(listener);
      }
    }
    notifyListeners();
  }

  Future<void> setCurrency(Currency currency) async {
    if (currency.isoName == "USD") {
      Singleton.currentCurrency = currency;
      Singleton.currentCurrency.usdMultiplier = 1.0;
      return;
    }
    var usdMultiplier = await getBlockchainAPIHistoricPrice(
      "USD${currency.isoName}=X",
      DateTime.now(),
    );
    if (usdMultiplier == 0.0) {
      return;
    }
    Singleton.currentCurrency = currency;
    Singleton.currentCurrency.usdMultiplier = usdMultiplier!;

    notifyListeners();
  }

  @override
  void initState() {
    super.initState();

    widget.searchController.addListener(_debounceFilter);

    Singleton.loaded!.then((bool val) async {
      if (Singleton.assetList.assetListState.walletList.isEmpty) {
        if (!mounted) {
          print("assetList.initState ERROR. context not mounted");
          return; // Widget is gone, do nothing more from this callback.
        }
        FadeNavigator(context).navigateTo(StartSetup());
      }
      updatePrices(fetch: false, rebuildList: true);
      streamPrices();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // load icons
    Singleton.assetList.assetListState.assets.forEach((final Asset asset) {
      asset.loadIcons(context);
    });
  }

  setPrivacy(bool val) {
    privacy = val;
    for (final asset in assets) {
      asset.triggerNotifier();
    }
    notifyListeners();
  }

  postCreationProcess(bool? easyImport, int walletId) {
    Singleton.assetList.assetListState
        .updateWalletList(online: true, awaitWorkers: false)
        .then((_) async {
          if (easyImport ?? false) {
            for (var asset in Singleton.assetList.assetListState.assets) {
              await asset.isolate?.ready();
              var coin = asset.getCoinByWalletId(walletId);
              if (coin == null) {
                continue;
              }
              coin.setupTransactionsForPathChildren(
                coin.getInitialEasyImportPaths(),
              );
            }
          }
        });
  }

  Future<void> updatePrices({
    bool fetch = true,
    bool rebuildList = false,
  }) async {
    futureData = coindesk.getPrices();
    Singleton.assetList.assetListState.futureData!
        .then((data) {
          if (data == null) {
            if (rebuildList) {
              notifyListeners();
              Singleton.assetList.assetListState.futureData!.then((v) {
                Singleton.assetList.assetListState.refreshListeners();
              });
            }
            return;
          }
          Singleton.assetList.assetListState.filteredAssets =
              Singleton.assetList.assetListState.assets
                  .where((Asset asset) => asset.active)
                  .toList();
          for (
            int i = 0;
            i < Singleton.assetList.assetListState.assets.length;
            i++
          ) {
            for (int j = 0; j < data.assets.length; j++) {
              if (Singleton.assetList.assetListState.assets[i].webId ==
                      data.assets[j].id ||
                  Singleton.assetList.assetListState.assets[i].yahooFinance ==
                      data.assets[j].id) {
                Singleton.assetList.assetListState.assets[i].updatePrice(
                  data.assets[j],
                );
              }
            }
          }

          Singleton.assetList.assetListState.filteredAssets =
              Singleton.assetList.assetListState.assets
                  .where((Asset asset) => asset.active)
                  .toList();
          if (rebuildList) {
            notifyListeners();
            Singleton.assetList.assetListState.futureData!.then((v) {
              Singleton.assetList.assetListState.refreshListeners();
            });
          }
          // });
        })
        .onError((error, stackTrace) {});
  }

  Future<bool> loadAssets() async {
    if (Singleton.settings["WalletViewMode"] == "separated") {
      int defaultWalletId = int.parse(
        Singleton.settings["DefaultWalletId"] ?? "1",
      );
      Singleton.assetList.assetListState.setWalletId(defaultWalletId);
    }
    if (Singleton.assetList.assetListState.assets.isEmpty) {
      await Singleton.assetList.assetListState.getInitialAssets();
    }
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    super.dispose();
    widget.searchController.removeListener(_debounceFilter);
    widget.searchController.dispose();
  }

  void streamPriceCallback(String symbol, double price) {
    assets
        .where((asset) {
          return asset.yahooFinance == symbol;
        })
        .forEach((asset) async {
          asset.updateUsdPrice(price);
        });
  }

  void streamPrices() async {
    Set<String> symbolList = {};
    assets.forEach((v) {
      symbolList.add(v.yahooFinance);
    });
    coindesk.streamPrices(symbolList.toList(), Singleton.assetList.assetListState.streamPriceCallback);
  }

  Future<String> getAssetPath(String filePath) async {
    Directory dir = await getApplicationDocumentsDirectory();
    String localPath = '${dir.path}/$filePath';
    final file = File(localPath);
    if (await file.exists()) {
      return localPath;
    }

    ByteData data = await rootBundle.load(filePath);
    await file.create(recursive:true);
    await file.writeAsBytes(data.buffer.asUint8List());
    return localPath;
  }

  Future<void> initCoinData() async {
    // String filePath = "assets/coindata.json";

    // String data = await rootBundle.loadString(filePath);
    String filePath = await getAssetPath("assets/coindata.json");
    String data = await File(filePath).readAsString();
    JsonDecoder decoder = JsonDecoder();
    final Map<String, dynamic> jsonMap = decoder.convert(data);

    AssetsData initialAssets = AssetsData.fromJson(jsonMap);

    // Isar isar = Singleton.getDB();
    // DataVersion? coinsVersion = await isar.dataVersions.getByName("coins");
    DataVersion? coinsVersion = await Models.dataVersion.getUnique("coins");

    if ((coinsVersion?.counter ?? 0) >= initialAssets.version) {
      return;
    }

    for (int i = 0; i < initialAssets.assets.length; i++) {
      // Coin coin =
      //     await isar.coins.getByName(initialAssets.assets[i].name) ?? Coin();
      Coin coin = await Models.coin.getUnique(initialAssets.assets[i].name) ?? Coin();
      coin.hrpBech32 = initialAssets.assets[i].getBech32HRP();
      coin.decimals = initialAssets.assets[i].decimals;
      coin.image = "assets/${initialAssets.assets[i].symbol.toLowerCase()}.png";
      coin.name = initialAssets.assets[i].name;
      coin.symbol = initialAssets.assets[i].symbol;
      coin.yahooFinance = initialAssets.assets[i].yahooFinance;
      coin.hdCode = initialAssets.assets[i].hdCode;
      coin.webId = initialAssets.assets[i].webId;
      coin.peerSeedType = initialAssets.assets[i].peerSeedType;
      coin.peerSource = initialAssets.assets[i].peerSource;
      coin.defaultPort = initialAssets.assets[i].defaultPort;
      coin.magic = initialAssets.assets[i].magic;
      coin.blockZeroHash = initialAssets.assets[i].blockZeroHash;
      coin.netVersionPublicHex = initialAssets.assets[i].netVersionPublicHex;
      coin.netVersionPrivateHex = initialAssets.assets[i].netVersionPrivateHex;
      coin.contractHash = initialAssets.assets[i].contractHash;
      coin.template = initialAssets.assets[i].template;
      coin.active = initialAssets.assets[i].active;
      coin.workerIsolateRequired =
          initialAssets.assets[i].workerIsolateRequired;
      int? coinId = await coin.save();

      if (coin.blockZeroHash != null && coin.blockZeroHash!.isNotEmpty) {
        // int blockCount = await isar.blocks.filter().coinEqualTo(coinId).count();
        // int? blockCount = await Models.block.count(q:FilterGroup.and([
        //   FilterCondition.equalTo(property: "coin", value: coinId),
        // ]));
        int? blockCount = await Models.block.count(q:
          Block_.coin.equals(coinId!),
        );
        if (blockCount == null || blockCount == 0) {
          Block block = Block();
          block.coin = coinId;
          block.hash = coin.blockZeroHash;
          block.height = 0;
          await block.save();
        }
      }
    }

    if (coinsVersion == null) {
      coinsVersion = new DataVersion();
    }

    coinsVersion.name = "coins";
    coinsVersion.counter = initialAssets.version;
    coinsVersion.save();
  }

  Future<void> initLPData() async {
    String filePath = "assets/lpdata.json";
    String data = await rootBundle.loadString(filePath);
    JsonDecoder decoder = JsonDecoder();
    final Map<String, dynamic> jsonMap = decoder.convert(data);

    LiquidityPoolData initialLPs = LiquidityPoolData.fromJson(jsonMap);

    // Isar isar = Singleton.getDB();

    // DataVersion? lpsVersion = await isar.dataVersions.getByName("lps");
    DataVersion? lpsVersion = await Models.dataVersion.getUnique("lps");

    if ((lpsVersion?.counter ?? 0) >= initialLPs.version) {
      return;
    }

    for (int i = 0; i < initialLPs.pools.length; i++) {
      // LP lp =
      //     await isar.lPs.getByCurrency0Currency1(
      //       initialLPs.pools[i].currency0.name(),
      //       initialLPs.pools[i].currency1.name(),
      //     ) ??
      //     LP();
      LP lp = await Models.lP.getUnique(
        initialLPs.pools[i].currency0.name(),
        initialLPs.pools[i].currency1.name()) ?? LP();
      lp.currency0 = initialLPs.pools[i].currency0.name();
      lp.currency1 = initialLPs.pools[i].currency1.name();
      lp.fee = initialLPs.pools[i].fee.toInt();
      lp.tickSpacing = initialLPs.pools[i].tickSpacing.toInt();
      lp.address = initialLPs.pools[i].address;
      lp.dex = initialLPs.pools[i].dex;
      await lp.save();
    }

    if (lpsVersion == null) {
      lpsVersion = new DataVersion();
    }

    lpsVersion.name = "lps";
    lpsVersion.counter = initialLPs.version;
    lpsVersion.save();
  }

  Future<void> getInitialAssets() async {
    await initCoinData();

    // Isar isar = Singleton.getDB();
    // final allCoins = await isar.coins.where().findAll();
    final allCoins = await Models.coin.find();
    // final allWallets = await isar.walletDBs.where().findAll();
    final allWallets = await Models.walletDB.find();
    walletList = allWallets ?? [];

    assets = [];
    for (int i = 0; i < (allCoins?.length??0); i++) {
      Coin coin = allCoins![i];
      Asset asset = Asset(
        id: coin.symbol!.toLowerCase(),
        name: coin.name!,
        symbol: coin.symbol!,
        priceUsd: 0,
        changePercent24Hr: 0,
      );

      asset.setBech32HRP(coin.hrpBech32!);
      asset.decimals = coin.decimals!;
      asset.yahooFinance = coin.yahooFinance!;
      asset.hdCode = coin.hdCode!;
      asset.webId = coin.webId!;
      asset.peerSeedType = coin.peerSeedType!;
      asset.peerSource = coin.peerSource!;
      asset.defaultPort = coin.defaultPort!;
      asset.magic = coin.magic!;
      asset.blockZeroHash = coin.blockZeroHash!;
      asset.coinId = coin.id;
      asset.netVersionPublicHex = coin.netVersionPublicHex;
      asset.netVersionPrivateHex = coin.netVersionPrivateHex;
      asset.contractHash = coin.contractHash;
      asset.template = coin.template;
      asset.priceUsd = coin.usdPrice ?? 0.0;
      asset.active = coin.active ?? true;
      asset.workerIsolateRequired = coin.workerIsolateRequired ?? false;
      asset.walletId = myWalletId;
      asset.assetIndex = i;
      asset.initCoin(walletList);

      for (final listener in listeners) {
        asset.addListener(listener);
      }
      assets.add(asset);
    }
    filteredAssets = assets.where((Asset asset) => asset.active).toList();

    notifyListeners();

    await initLPData();

    // final allLPs = await isar.lPs.where().findAll();
    final allLPs = await Models.lP.find();
    for (int i = 0; i < (allLPs?.length??0); i++) {
      LiquidityPool pool = LiquidityPool.fromLP(allLPs![i]);

      if (!Singleton.swap.lpList.containsKey(pool.dex)) {
        Singleton.swap.lpList[pool.dex] = [];
      }
      Singleton.swap.lpList[pool.dex]!.add(pool);
    }
  }

  Future<dynamic> updateWalletList({
    bool online = true,
    bool awaitWorkers = false,
  }) async {
    // Isar isar = Singleton.getDB();

    // final allWallets = await isar.walletDBs.where().findAll();
    final allWallets = await Models.walletDB.find();
    walletList = allWallets??[];

    for (var asset in assets) {
      asset.walletId = myWalletId;
      asset.initCoin(walletList, online: online);

      for (final listener in listeners) {
        asset.addListener(listener);
      }
    }
    filteredAssets = assets.where((Asset asset) => asset.active).toList();
    notifyListeners();
    if (awaitWorkers) {
      return Future.wait(assets.map((asset) => asset.isolate!.ready()));
    }
  }

  double getTotalBalance() {
    double total = 0.0;
    BigInt amount;
    for (int i = 0; i < filteredAssets.length; i++) {
      amount = filteredAssets[i].getBalance(notify: false);
      total +=
          (filteredAssets[i].priceUsd) *
          double.parse(filteredAssets[i].getDecimalAmount(amount));
    }
    return total;
  }

  Asset? findAsset(String searchName) {
    for (Asset v in assets) {
      if (v.name == searchName ||
          v.symbol == searchName ||
          v.id == searchName ||
          v.webId == searchName) {
        return v;
      }
    }
    return null;
  }

  void refreshAssetsBalance() async {}

  Future<List<Map<String, dynamic>>?> fetchChartData(
    String assetId, {
    String interval = "h1",
  }) async {
    List<Map<String, dynamic>> result = [];
    try {
      final url = Uri.parse(
        'https://api.coincap.io/v2/assets/$assetId/history?interval=$interval',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        List<dynamic> prices = jsonData['data'];

        int totalElements = prices.length;
        int maxPoints = 30;
        int intervalElements = totalElements ~/ maxPoints;
        int index = 0;

        for (var price in prices) {
          var date = DateTime.parse(price['date']);
          var closePrice = double.parse(price['priceUsd']);

          if (index % intervalElements == 0) {
            result.add({'date': date, 'close': closePrice});
          }

          index++;
        }
        return result;
      } else {}
    } catch (e) {
      //
    }
    return result;
  }

  Timer? _debounce;
  void _debounceFilter() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 300), () {
      filterAssets();
    });
  }

  void filterAssets() {
    String query = widget.searchController.text.toLowerCase();
    setState(() {
      filteredAssets =
          assets.where((asset) {
            if (!asset.active) {
              return false;
            }
            return asset.name.toLowerCase().contains(query) ||
                asset.symbol.toLowerCase().contains(query);
          }).toList();
    });
  }

  void updateWallets({int? newWalletId}) {
    if (newWalletId != null) {
      setWalletId(newWalletId);
    }
    getInitialAssets();
  }

  Asset? getAssetById(int id) {
    for (var asset in assets) {
      if (asset.coinId! == id) {
        return asset;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool?>(
      future: Singleton.loaded,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          //if (snapshot.hasData) {
          // print("assets.length: ${assets.length}");
          // filteredAssets = assets.where((Asset asset)=>asset.active).toList();
          return ListView.builder(
            itemCount: filteredAssets.length,
            itemBuilder: (context, index) {
              final asset = filteredAssets[index];
              return ListenableBuilder(
                builder: (context, child) {
                  return InkWell(
                    child: Card(
                      child: ListTile(
                        leading:
                            (asset.coins.isEmpty || !asset.coins[0].isConnected)
                                ? asset.iconOffline
                                : asset.iconOnline,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              asset.name,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              privacy
                                  ? "∗∗∗∗"
                                  : asset
                                      .getDecimalAmountInDouble(
                                        asset.getBalance(notify: false),
                                      )
                                      .toStringAsFixed(8),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${(asset.lastChange == 0)
                                      ? " "
                                      : (asset.lastChange >= 0)
                                      ? "▲"
                                      : "▼"} ${OtherHelpers.humanizeMoney(asset.priceUsd, isFiat: true, addFiatSymbol: true)}",
                                  style: TextStyle(
                                    color:
                                        (asset.lastChange == 0)
                                            ? null
                                            : (asset.lastChange >= 0)
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                ),
                                Text(
                                  privacy
                                      ? "∗∗∗∗"
                                      : '~ ${widget.humanizeMoney((asset.priceUsd) * (asset.getDecimalAmountInDouble(asset.getBalance(notify: false))), isFiat: true)}',
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "  ${asset.changePercent24Hr.toStringAsFixed(1)}%",
                                  style: TextStyle(
                                    color:
                                        (asset.changePercent24Hr == 0)
                                            ? null
                                            : (asset.changePercent24Hr >= 0)
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                ),
                                Text(''),
                              ],
                            ),
                          ],
                        ),
                        onTap: () async {
                          try {
                            FadeNavigator(
                              context,
                            ).navigateTo(TokenDetails(asset: asset));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error fetching chart data'),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
                // listenable: asset,
                listenable: asset,
              );
            },
          );
        } //else {
        //return Center(child: Text('No data found'));
        //}
      },
    );
  }

  int getERC20Id() {
    for (final asset in assets) {
      if (asset.symbol == "ETH") {
        return asset.coinId!;
      }
    }
    return 0;
  }
}
