// import 'dart:ffi';
import 'dart:typed_data';

// import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:tejory/coins/bitcoin_tx_out.dart';
import 'package:tejory/coins/btc_helper.dart';
// import 'package:tejory/coins/transaction.dart';

class BitcoinTxIn {
  Uint8List previousOutHash = Uint8List(0);
  int previousOutIndex = 0;
  Uint8List scriptSig = Uint8List(0);
  List<Uint8List> witnesses = [];
  int sequence = 0;
  // BitcoinTx utx = BitcoinTx();
  BitcoinTxOut utx = BitcoinTxOut();

  BitcoinTxIn();

  Uint8List getRawBytes() {
    List<int> raw = [];
    raw += previousOutHash;
    raw += Uint8List(4)
      ..buffer.asByteData().setUint32(0, previousOutIndex, Endian.little);
    raw += makeVarint(BigInt.from(scriptSig.length));
    raw += scriptSig;
    raw += Uint8List(4)
      ..buffer.asByteData().setUint32(0, sequence, Endian.little);
    return Uint8List.fromList(raw);
  }
}
