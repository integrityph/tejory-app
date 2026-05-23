import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tejory/coins/bitcoin_tx.dart';
import 'package:tejory/coins/btkn.dart';
import 'package:tejory/coins/crypto_coin.dart';
import 'package:tejory/coins/spark_btc.dart';
import 'package:tejory/coins/tx.dart';
import 'package:tejory/singleton.dart';
import 'package:tejory/swap/dex.dart';

class Flashnet implements DEX {
  SparkBTC? spark;
  final BTC_ID = "020202020202020202020202020202020202020202020202020202020202020202";

  @override
  Future<bool> checkToken(CryptoCoin token) async {
    if (token is SparkBTC || token is BTKN) {
      return true;
    }
    return false;
  }

  @override
  Future<List<Tx>?> unlockToken(CryptoCoin token) async {
    return null;
  }

  @override
	bool canSwap(CryptoCoin currency0, CryptoCoin currency1) {
		if (currency0 is SparkBTC || currency1 is BTKN) {
      return true;
    } else if (currency0 is BTKN || currency1 is SparkBTC) {
      return true;
    }
    return false;
	}

  @override
	List<CryptoCoin> getSwapList(CryptoCoin currency) {
		return [];
	}

  @override
	Future<BigInt> swapRate(CryptoCoin currency0, CryptoCoin currency1, BigInt amountIn, {bool zeroForOne=true}) async {
    initSpark();
    // get LiquidityPool
    var pool = Singleton.swap.getLPForPair(currency0, currency1);
    if (pool == null) {
      return BigInt.zero;
    }

    String assetInId;
    String assetOutId;
    if (currency0 is SparkBTC && currency1 is BTKN) {
      assetInId = BTC_ID;
      assetOutId = currency1.getBTKNHex()!;
    } else if (currency0 is BTKN && currency1 is SparkBTC) {
      assetInId = currency0.getBTKNHex()!;
      assetOutId = BTC_ID;
    } else {
      // unknown combination
      return BigInt.zero;
    }

    final response = await spark!.simulateSwap(pool.address, assetInId, assetOutId, amountIn, zeroForOne: zeroForOne);

    if (response == null) {
      return BigInt.zero;
    }
    
		return BigInt.parse(response.amountOut);
	}

	Future<Tx?> swap(CryptoCoin currency0, CryptoCoin currency1, BigInt amountIn, BigInt minAmountOut) async {
    initSpark();
    // get LiquidityPool
    var pool = Singleton.swap.getLPForPair(currency0, currency1);
    if (pool == null) {
      return null;
    }
    
    String assetInId;
    String assetOutId;
    if (currency0 is SparkBTC && currency1 is BTKN) {
      assetInId = BTC_ID;
      assetOutId = currency1.getBTKNHex()!;
    } else if (currency0 is BTKN && currency1 is SparkBTC) {
      assetInId = currency0.getBTKNHex()!;
      assetOutId = BTC_ID;
    } else {
      // unknown combination
      return null;
    }

    final poolId = pool.address;
    // First simulate to get expected output
    final simulation = await spark!.simulateSwap(
      poolId,
      assetInId,
      assetOutId,
      amountIn,
    );

    if (simulation == null) {
      return null;
    }

    // Calculate minimum output with slippage tolerance
    final amountOut = BigInt.parse(simulation.amountOut);
    final minAmountOut = amountOut - (amountOut ~/ BigInt.from(100));

    // Execute the swap
    final swap = await spark!.executeSwap(
      poolId: poolId,
      assetInAddress: assetInId,
      assetOutAddress: assetOutId,
      amountIn: amountIn.toString(),
      minAmountOut: minAmountOut.toString(),
      maxSlippageBps: 100, // 1% max slippage
    );
		
    if (swap == null) {
      return null;
    }

    if (!swap.accepted) {
      // swap failed
      debugPrint("Swap failed: ${swap.error}");
      return null;
    }

		return BitcoinTx();
	}

  void initSpark() {
    if (spark != null) {
      return;
    }
    spark = Singleton.assetList.assetListState.findAsset("SPKBTC")!.coins[0] as SparkBTC;
  }

  @override
  String estimatedTime() {
    return "> 10 seconds";
  }
}