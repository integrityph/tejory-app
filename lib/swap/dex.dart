import 'package:tejory/coins/crypto_coin.dart';
import 'package:tejory/coins/tx.dart';

abstract class DEX {
  bool canSwap(CryptoCoin currency0, CryptoCoin currency1);
	List<CryptoCoin> getSwapList(CryptoCoin currency);
	Future<BigInt> swapRate(CryptoCoin currency0, CryptoCoin currency1, BigInt amountIn, {bool zeroForOne=true});
	Future<Tx?> swap(CryptoCoin currency0, CryptoCoin currency1, BigInt amountIn, BigInt minAmountOut);
  Future<bool> checkToken(CryptoCoin token);
  Future<List<Tx>?> unlockToken(CryptoCoin token);
}