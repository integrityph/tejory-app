import 'dart:typed_data';
import 'package:bech32/bech32.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:crypto/crypto.dart';
import 'package:tejory/ui/setup/word_list.dart';

class HDWalletHelpers {
  static Uint8List serializeHDPath(String path,
      {Endian endian = Endian.little}) {
    //5400008000000080000000800000000000000000
    List<int> pathBytes = [];
    var pathParts = path.split("/");
    String part = "";
    int extra = 0;
    for (int i = 1; i < pathParts.length; i++) {
      part = pathParts[i];
      extra = 0;
      if (part.endsWith("'")) {
        part = part.substring(0, part.length - 1);
        extra = 1 << 31;
      }
      extra += int.parse(part);
      pathBytes += Uint8List(4)
        ..buffer.asByteData().setUint32(0, extra, endian);
    }
    print("pathBytes: ${hex.encode(pathBytes)}");

    return Uint8List.fromList(pathBytes);
  }

  static List<int> entropyToMnemonicValues(List<int> entropy) {
    List<int> mnemonicsList = [];
    String entropyString = "";

    for (int i = 0; i < entropy.length; i++) {
      entropyString += entropy[i].toRadixString(2).padLeft(8, "0");
    }
    // add the checksum
    int checksumLength = entropyString.length ~/ 32;
    int shaChecksum = sha256.convert(Uint8List.fromList(entropy)).bytes[0] >>
        (8 - checksumLength);
    entropyString += shaChecksum.toRadixString(2).padLeft(checksumLength, "0");

    int index = 0;
    while (index < entropyString.length) {
      mnemonicsList
          .add(int.parse(entropyString.substring(index, index + 11), radix: 2));
      index += 11;
    }

    return mnemonicsList;
  }

  static List<String> entropyToMnemonicStrings(List<int> entropy) {
    List<int> values = entropyToMnemonicValues(entropy);
    List<String> phrase = [];

    for (int i = 0; i < values.length; i++) {
      phrase.add(wordList[values[i]]);
    }

    return phrase;
  }

  static List<int> MnemonicValuesToEntropy(List<int> mnemonicValues) {
    List<int> valuesList = [];
    String entropyString = "";

    for (int i = 0; i < mnemonicValues.length; i++) {
      entropyString += mnemonicValues[i].toRadixString(2).padLeft(11, "0");
    }

    // optional: check the checksum

    // remove the checksum
    int checksumLength = entropyString.length ~/ 32;
    entropyString =
        entropyString.substring(0, entropyString.length - checksumLength);

    int index = 0;
    while (index < entropyString.length) {
      valuesList
          .add(int.parse(entropyString.substring(index, index + 8), radix: 2));
      index += 8;
    }

    return valuesList;
  }

  static List<int> MnemonicStringsToEntropy(List<String> mnemonicStrings) {
    List<int> valuesList = [];
    for (int i = 0; i < mnemonicStrings.length; i++) {
      valuesList.add(wordList.indexOf(mnemonicStrings[i]));
    }

    return MnemonicValuesToEntropy(valuesList);
  }

  static String getAddressFromBytes(Uint8List address, String bechHRP) {
    String b = address.map((i) => i.toRadixString(2).padLeft(8, '0')).join();

    // Convert the binary string to a list of 5-bit integers
    List<int> valueList = [0];
    int index = 0;
    while (index < b.length) {
      valueList.add(int.parse(b.substring(index, index + 5), radix: 2));
      index += 5;
    }
    var bech32 = Bech32Codec();
    var bech32Data = Bech32(bechHRP, valueList);
    String receivingAddress = bech32.encode(bech32Data);

    return receivingAddress;
  }

  static Bip32KeyNetVersions getDefaultNetVersion() {
    return Bip32KeyNetVersions(
        [0x04, 0x35, 0x87, 0xCF], [0x04, 0x35, 0x83, 0x94]);
    //[0x04, 0x35, 0x87, 0xCF], [0x04, 0x35, 0x83, 0x94]);
  }
}
