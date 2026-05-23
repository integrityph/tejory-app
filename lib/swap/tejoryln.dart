// import 'package:tejory/coins/bitcoin.dart';
// import 'package:tejory/coins/btcln.dart' show BTCLN;
// import 'package:tejory/coins/crypto_coin.dart';
// import 'package:tejory/coins/tx.dart';
// import 'package:tejory/singleton.dart';
// import 'package:tejory/swap/dex.dart';

// class TejoryLN implements DEX {
//   @override
//   bool canSwap(CryptoCoin currency0, CryptoCoin currency1) {
//     if (currency0.symbol() == "BTC" && currency1.symbol() == "BTCLN") {
//       return true;
//     }
//     if (currency0.symbol() == "BTCLN" && currency1.symbol() == "BTC") {
//       return true;
//     }
//     return false;
//   }

//   @override
//   Future<bool> checkToken(CryptoCoin token) async {
//     return true;
//   }

//   @override
//   List<CryptoCoin> getSwapList(CryptoCoin currency) {
//     if (currency.symbol() == "BTC") {
//       return [Singleton.assetList.assetListState.findAsset("BTCLN")!.coins[0]];
//     } else if (currency.symbol() == "BTCLN") {
//       return [Singleton.assetList.assetListState.findAsset("BTC")!.coins[0]];
//     }
//     return [];
//   }

//   @override
//   Future<Tx?> swap(CryptoCoin currency0, CryptoCoin currency1, BigInt amountIn, BigInt minAmountOut) async {
//     CryptoCoin currencyIn = currency0;
//     CryptoCoin currencyOut = currency1;

//     if (currencyIn.symbol() == "BTCLN" && currencyOut.symbol() == "BTC") {
//       // this is a loop out
//       BTCLN btcln = currencyIn as BTCLN;
//       Bitcoin btc = currencyOut as Bitcoin;
//       var address = await btc.getReceivingAddress();
//       return await btcln.makeTransaction(address, amountIn);
//     } else if (currencyIn.symbol() == "BTC" && currencyOut.symbol() == "BTCLN") {
//       BTCLN btcln = currencyOut as BTCLN;
//       Bitcoin btc = currencyIn as Bitcoin;
//       // var address = await btc.getReceivingAddress();
//       var address = await btcln.loopIn(amountIn);
//       if (address == null) {
//         return null;
//       }
//       print("HTLC address: ${address}");
//       return await btc.makeTransaction(address, amountIn);
//     }
//     return null;
//   }

//   @override
//   Future<BigInt> swapRate(CryptoCoin currency0, CryptoCoin currency1, BigInt amountIn, {bool zeroForOne = true}) async {
//     CryptoCoin currencyIn = currency0;
//     CryptoCoin currencyOut = currency1;

//     if (!zeroForOne){
//       currencyIn = currency1;
//       currencyOut = currency0;
//     }

//     if (currencyIn.symbol() == "BTCLN" && currencyOut.symbol() == "BTC") {
//       // this is a loop out
//       BTCLN btcln = currencyIn as BTCLN;
//       var fees = await btcln.getLoopOutFees(amountIn);
//       if (fees == null) {
//         return BigInt.zero;
//       }
//       return amountIn - fees;
//     } else if (currencyIn.symbol() == "BTC" && currencyOut.symbol() == "BTCLN") {
//       // this is a loop out
//       BTCLN btcln = currencyOut as BTCLN;
//       var fees = await btcln.getLoopInFees(amountIn);
//       if (fees == null) {
//         return BigInt.zero;
//       }
//       return amountIn - fees;
//     }
//     return BigInt.zero;
//   }

//   @override
//   Future<List<Tx>?> unlockToken(CryptoCoin token) async {
//     return [];
//   }
  
//   @override
//   String estimatedTime() {
//     return "Up to 24 hours";
//   }
// }