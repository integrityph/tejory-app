import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:blockchain_utils/hex/hex.dart';
import 'package:tejory/coins/btc_helper.dart';

class BitcoinBlock {
  Uint8List header = Uint8List(80);
  Uint8List body = Uint8List(0);
  Uint8List hash = Uint8List(0);
  Uint8List version = Uint8List(0);
  Uint8List prevHash = Uint8List(0);
  Uint8List merkleRootHash = Uint8List(0);
  DateTime timestamp = DateTime.now();
  Uint8List nBits = Uint8List(0);
  Uint8List nonce = Uint8List(0);
  List<String> txList = [];
  int txCount = 0;
  int merkleTxCount = 0;

  BitcoinBlock();
  BitcoinBlock.fromBlockBytes(Uint8List buffer);

  BitcoinBlock.fromMerkleBlockBytes(Uint8List buffer) {
    header = buffer.sublist(0, 80);
    body = buffer.sublist(80);

    version = header.sublist(0, 4);
    int offset = 4;
    prevHash = header.sublist(offset, offset + 32);
    offset += 32;
    merkleRootHash = header.sublist(offset, offset + 32);
    offset += 32;
    int rawTimestamp = ByteData.sublistView(header.sublist(offset, offset + 4))
        .getUint32(0, Endian.little);
    timestamp = DateTime.fromMillisecondsSinceEpoch(rawTimestamp * 1000);
    offset += 4;
    nBits = header.sublist(offset, offset + 4);
    offset += 4;
    nonce = header.sublist(offset, offset + 4);

    hash =
        Uint8List.fromList(sha256.convert(sha256.convert(header).bytes).bytes);

    // body strucure refence from this URL:
    // https://en.bitcoin.it/wiki/Protocol_documentation#filterload,_filteradd,_filterclear,_merkleblock
    int hashCount, byteCount;
    offset = 4;
    (hashCount, byteCount) = parseVarint(body, offset);
    merkleTxCount = hashCount;

    offset += byteCount;
    txList = [];
    for (int i = 0; i < hashCount; i++) {
      txList.add(hex.encode(body.sublist(offset, offset + 32)));
      offset += 32;
    }
  }

  String getHashHex() {
    return hex.encode(hash.reversed.toList());
  }

  String getprevHashHex() {
    return hex.encode(prevHash.reversed.toList());
  }
}

class toHex {
  static String encode(Uint8List data) {
    return data.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }
}
