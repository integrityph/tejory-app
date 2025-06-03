import 'dart:typed_data';

import 'package:tejory/swap/abi.dart';
import 'package:tejory/swap/abi_encoder.dart';
import 'package:tejory/swap/pool_key.dart';

class ExactInputSingleParams implements AbiEncoder {
    PoolKey poolKey;
    bool zeroForOne;
    BigInt amountIn;
    BigInt amountOutMinimum;
    Uint8List hookData;

    ExactInputSingleParams(
      this.poolKey,
      this.zeroForOne,
      this.amountIn,
      this.amountOutMinimum,
      this.hookData,
    );

    List<int> encode() {
      List<int> result = [];
      // result.addAll(Abi.encode(0x20)); // poolKey (tuple)
      result.addAll(poolKey.encode());
      result.addAll(Abi.encode(zeroForOne));
      result.addAll(Abi.encode(amountIn));
      result.addAll(Abi.encode(amountOutMinimum));
      result.addAll(Abi.encode(hookData));
      return result;
    }
}
