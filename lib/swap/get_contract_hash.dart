import 'package:blockchain_utils/hex/hex.dart';
import 'package:tejory/coins/crypto_coin.dart';
import 'package:tejory/coins/erc-20.dart';
import 'package:tejory/coins/ether.dart';
import 'package:tejory/swap/abi.dart';

List<int> getContractHash(CryptoCoin coin) {
  if (coin is Ether) {
    return Abi.encode(0x00);
  } else if (coin is ERC20) {
    return Abi.encode(hex.decode(coin.contractHash!));
  }
  return [];
}