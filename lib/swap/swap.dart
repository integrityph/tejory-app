import 'package:blockchain_utils/helper/helper.dart';
import 'package:tejory/coins/crypto_coin.dart';
import 'package:tejory/coins/tx.dart';
import 'package:tejory/swap/dex.dart';
import 'package:tejory/swap/liquidity_pool.dart';
import 'package:tejory/swap/uniswap.dart';

class Swap {
  Map<String, DEX> dexList = {"uniswap_v4": UniswapV4()};
  Map<String, List<LiquidityPool>> lpList = {};

  bool canSwap(CryptoCoin currency0, CryptoCoin currency1) {
		return getDexForPair(currency0, currency1) != null;
	}

	List<CryptoCoin> getSwapList(CryptoCoin currency) {
    List<LiquidityPool> pools = [];
    for (final key in lpList.keys) {
      pools.addAll(lpList[key]!.where((v){
        return v.currency0.id == currency.id! || v.currency1.id == currency.id!;
      }));
    }
    Set<CryptoCoin> coins = {};
    for (final pool in pools) {
      if (pool.currency0.id == currency.id) {
        coins.add(pool.currency1);
      } else {
        coins.add(pool.currency0);
      }
    }
		return coins.toList();
	}

  List<CryptoCoin> getFullSwapList() {
    List<LiquidityPool> pools = [];
    for (final key in lpList.keys) {
      pools.addAll(lpList[key]!);
    }
    Set<CryptoCoin> coins = {};
    for (final pool in pools) {
        coins.add(pool.currency1);
        coins.add(pool.currency0);
    }
		return coins.toList();
	}

	Future<BigInt> swapRate(CryptoCoin currency0, CryptoCoin currency1, {BigInt? baseAmountIn, double? doubleAmountIn, bool zeroForOne=true}) async {
    LiquidityPool? lp = getLPForPair(currency0, currency1);
    DEX? dex = getDexForPair(currency0, currency1);
    if (dex == null) {
      return BigInt.zero;
    }
    if (lp!.currency0.id != currency0.id) {
      zeroForOne = false;
      if (baseAmountIn == null) {
        baseAmountIn = currency0.getBaseAmount(doubleAmountIn!);
      }
      return await dex.swapRate(currency1, currency0, baseAmountIn, zeroForOne:zeroForOne);
    }
    baseAmountIn = currency0.getBaseAmount(doubleAmountIn!);
		return await dex.swapRate(currency0, currency1, baseAmountIn, zeroForOne:zeroForOne);
	}

	Future<Tx?> swap(CryptoCoin currency0, CryptoCoin currency1, BigInt amountIn, BigInt minAmountOut) async {
		DEX? dex = getDexForPair(currency0, currency1);
    if (dex == null) {
      return null;
    }
    return await dex.swap(currency0, currency1, amountIn, minAmountOut);
	}

  DEX? getDexForPair(CryptoCoin currency0, CryptoCoin currency1) {
    LiquidityPool? pool = null;
    for (final key in lpList.keys) {
      pool = lpList[key]!.firstWhereNullable((v){
        return (
          v.currency0.id == currency0.id! && v.currency1.id == currency1.id! ||
          v.currency0.id == currency1.id! && v.currency1.id == currency0.id!
        );
      });
      if (pool != null) {
        return dexList[key];
      }
    }
    return null;
  }

  LiquidityPool? getLPForPair(CryptoCoin currency0, CryptoCoin currency1) {
    LiquidityPool? pool = null;
    for (final key in lpList.keys) {
      pool = lpList[key]!.firstWhereNullable((v){
        return (
          v.currency0.id == currency0.id! && v.currency1.id == currency1.id! ||
          v.currency0.id == currency1.id! && v.currency1.id == currency0.id!
        );
      });
      if (pool != null) {
        return pool;
      }
    }
    return null;
  }

  Future<bool?> checkToken(CryptoCoin currency0, currency1) async {
    DEX? dex = getDexForPair(currency0, currency1);
    if (dex == null) {
      return null;
    }
    return await dex.checkToken(currency0);
  }

  Future<List<Tx>?> unlockToken(CryptoCoin currency0, currency1) async {
    DEX? dex = getDexForPair(currency0, currency1);
    if (dex == null) {
      return null;
    }
    return await dex.unlockToken(currency0);
  }
}