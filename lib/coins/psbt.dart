import 'dart:typed_data';
import 'package:tejory/coins/pst.dart';
import 'package:tejory/coins/bitcoin_tx.dart';

typedef PSBTMap = Map<int, Map<String, Uint8List>>;

class PSBT implements PST {
  final Uint8List magic = Uint8List.fromList([0x70, 0x73, 0x62, 0x74, 0xFF]);
  PSBTMap global = {};
  List<PSBTMap> inputs = [];
  List<PSBTMap> outputs = [];

  BitcoinTx tx = BitcoinTx();

  Uint8List getRawBytes() {
    /*
 <psbt> := <magic> <global-map> <input-map>* <output-map>*
 <magic> := 0x70 0x73 0x62 0x74 0xFF
 <global-map> := <keypair>* 0x00
 <input-map> := <keypair>* 0x00
 <output-map> := <keypair>* 0x00
 <keypair> := <key> <value>
 <key> := <keylen> <keytype> <keydata>
 <value> := <valuelen> <valuedata>
    */
    List<int> raw = magic;
    int keyLength = 0;
    List<int> key = [];
    List<int> value = [];

    // add global map
    global.keys.forEach((k) {
      // Map is
      keyLength = 1;
      if (global[k]!.containsKey("keydata")) {
        keyLength += global[k]!["keydata"]!.length;
        key = [keyLength, k] + global[k]!["keydata"]!;
      } else {
        key = [keyLength, k];
      }
      value = [global[k]!["valuedata"]!.length] + global[k]!["valuedata"]!;
      raw += key + value;
    });
    raw += [0x00];

    // add inputs map
    // one input map for each input separated by 0x00
    for (int i = 0; i < inputs.length; i++) {
      inputs[i].keys.forEach((k) {
        // Map is
        keyLength = 1;
        if (inputs[i][k]!.containsKey("keydata")) {
          keyLength += inputs[i][k]!["keydata"]!.length;
          key = [keyLength, k] + inputs[i][k]!["keydata"]!;
        } else {
          key = [keyLength, k];
        }
        value =
            [inputs[i][k]!["valuedata"]!.length] + inputs[i][k]!["valuedata"]!;
        raw += key + value;
      });
      raw += [0x00];
    }

    // add outputs map
    for (int i = 0; i < outputs.length; i++) {
      outputs[i].keys.forEach((k) {
        // Map is
        keyLength = 1;
        if (outputs[i][k]!.containsKey("keydata")) {
          keyLength += outputs[i][k]!["keydata"]!.length;
          key = [keyLength, k] + outputs[i][k]!["keydata"]!;
        } else {
          key = [keyLength, k];
        }
        value = [outputs[i][k]!["valuedata"]!.length] +
            outputs[i][k]!["valuedata"]!;
        raw += key + value;
      });
      raw += [0x00];
    }

    return Uint8List.fromList(raw);
  }

  Uint8List getSignedTxFromPST(Uint8List buf) {
    List<int> unsignedTx = buf.sublist(8, 8 + buf[7]);
    int keyLength = buf[8 + buf[7] + 1] - 1;

    List<int> pubkey =
        buf.sublist(8 + buf[7] + 1 + 2, 8 + buf[7] + 1 + 2 + keyLength);
    int sigLength = buf[8 + buf[7] + 1 + 2 + keyLength];
    List<int> sig = buf.sublist(8 + buf[7] + 1 + 2 + keyLength + 1,
        8 + buf[7] + 1 + 2 + keyLength + 1 + sigLength);
    List<int> witness = [2, sig.length] + sig + [pubkey.length] + pubkey;
    List<int> signedBytes = unsignedTx.sublist(0, 4) +
        [0, 1] +
        unsignedTx.sublist(4, unsignedTx.length - 4) +
        witness +
        unsignedTx.sublist(unsignedTx.length - 4);

    return Uint8List.fromList(signedBytes);
  }

  // Uint8List getSignedTxFromPSTNW(Uint8List buf) {
  //   List<int> unsignedTx = buf.sublist(8, 8 + buf[7]);
  //   int keyLength = buf[8 + buf[7] + 1] - 1;

  //       buf.sublist(8 + buf[7] + 1 + 2, 8 + buf[7] + 1 + 2 + keyLength);

  //   List<int> signedBytes = unsignedTx.sublist(0, 4) +
  //       [0, 1] +
  //       unsignedTx.sublist(4, unsignedTx.length - 4) +
  //       unsignedTx.sublist(unsignedTx.length - 4);

  //   return Uint8List.fromList(signedBytes);
  // }

  // Uint8List getSignedTxFromPST(Uint8List buf) {
  //   // Add condition to check if buf is empty or not
  //   // Empty buf will return a list that contains 0
  //   if (buf.length > 0) {
  //     List<int> unsignedTx = buf.sublist(8, 8 + buf[7]);
  //     int keyLength = buf[8 + buf[7] + 1] - 1;

  //     List<int> pubkey =
  //         buf.sublist(8 + buf[7] + 1 + 2, 8 + buf[7] + 1 + 2 + keyLength);
  //     int sigLength = buf[8 + buf[7] + 1 + 2 + keyLength];
  //     List<int> sig = buf.sublist(8 + buf[7] + 1 + 2 + keyLength + 1,
  //         8 + buf[7] + 1 + 2 + keyLength + 1 + sigLength);
  //     List<int> witness = [2, sig.length] + sig + [pubkey.length] + pubkey;
  //     List<int> signedBytes = unsignedTx.sublist(0, 4) +
  //         [0, 1] +
  //         unsignedTx.sublist(4, unsignedTx.length - 4) +
  //         witness +
  //         unsignedTx.sublist(unsignedTx.length - 4);

  //     return Uint8List.fromList(signedBytes);
  //   }
  //   return Uint8List.fromList(List.from([0]));
  // }
}
