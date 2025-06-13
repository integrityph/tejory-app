import 'package:tejory/coins/crypto_coin.dart';
import 'package:tejory/objectbox/lp.dart';
import 'package:tejory/singleton.dart';

class LiquidityPool {
  CryptoCoin currency0;
  CryptoCoin currency1;
  BigInt fee;
  BigInt tickSpacing;
  String address;
  String dex;

  LiquidityPool(this.currency0, this.currency1, this.fee, this.tickSpacing, this.address, this.dex);

  factory LiquidityPool.fromJson(Map<String, dynamic> json) {
    CryptoCoin currency0 = Singleton.assetList.assetListState.findAsset(json['currency0'])!.coinTemplate!;
    CryptoCoin currency1 = Singleton.assetList.assetListState.findAsset(json['currency1'])!.coinTemplate!;
    BigInt fee = BigInt.from(json['fee']);
    BigInt tickSpacing = BigInt.from(json['tickSpacing']);
    String address = json['address'];
    String dex = json['dex'];

    LiquidityPool pool = LiquidityPool(
      currency0,
      currency1,
      fee,
      tickSpacing,
      address,
      dex,
    );
    return pool;
  }

  factory LiquidityPool.fromLP(LP lp) {
    CryptoCoin currency0 = Singleton.assetList.assetListState.findAsset(lp.currency0!)!.coinTemplate!;
    CryptoCoin currency1 = Singleton.assetList.assetListState.findAsset(lp.currency1!)!.coinTemplate!;
    BigInt fee = BigInt.from(lp.fee!);
    BigInt tickSpacing = BigInt.from(lp.tickSpacing!);
    String address = lp.address!;
    String dex = lp.dex!;

    LiquidityPool pool = LiquidityPool(
      currency0,
      currency1,
      fee,
      tickSpacing,
      address,
      dex,
    );
    return pool;
  }
}

class LiquidityPoolData {
  final List<LiquidityPool> pools;
  final int version;

  LiquidityPoolData({required this.pools, required this.version});

  factory LiquidityPoolData.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<LiquidityPool> poolList = list.map((i) => LiquidityPool.fromJson(i)).toList();
    return LiquidityPoolData(pools: poolList, version: json['version'] ?? 0);
  }
}