import 'package:tejory/coins/crypto_coin.dart';
import 'package:tejory/swap/abi.dart';
import 'package:tejory/swap/abi_encoder.dart';
import 'package:tejory/swap/get_contract_hash.dart';

class PoolKey implements AbiEncoder {
  CryptoCoin currency0;
  CryptoCoin currency1;
  BigInt fee;
  BigInt tickSpacing;
  String hooks;

  PoolKey(this.currency0,this.currency1,this.fee,this.tickSpacing, this.hooks);
  
  @override
  List<int> encode() {
    List<int> result = [];
    result.addAll(Abi.encode(0x20)); // poolKey (tuple)
    result.addAll(getContractHash(currency0));
    result.addAll(getContractHash(currency1));
    result.addAll(Abi.encode(fee));
    result.addAll(Abi.encode(tickSpacing));
    result.addAll(Abi.encode(hooks));
    return result;
  }
}