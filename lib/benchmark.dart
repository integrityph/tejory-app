
// ignore_for_file: unused_local_variable

import 'package:advance_math/advance_math.dart';
import 'package:blockchain_utils/bip/bip.dart';
import 'package:blockchain_utils/hex/hex.dart';
import 'package:collection/collection.dart';
import 'package:cryptography/cryptography.dart' as crypto;
import 'package:tejory/bip32/derivation_bip32_key.dart';
import 'package:tejory/ui/setup/seed_dropdown.dart';
import 'package:tejory/ui/setup/word_list.dart';

// Future<void> benchmarkMnemonicsToSeed(int iterations) async {
//   print("=============================");
//   print("Benchmarking Mnemonic to Seed");
//   print("=============================");
//   List<String> mnemonicList;
//   String mnemonicPhrase;
//   var rand = Random.secure();
//   Map<int, List<num>> results = Map.fromEntries(
//     seedList.map(
//       (seed) => MapEntry(seed.phraseLength, List.filled(iterations, 0)),
//     ),
//   );
//   for (int iteration = 0; iteration < iterations; iteration++) {
//     for (final int length in seedList.map((seed) => seed.phraseLength)) {
//       mnemonicList = List.generate(
//         length,
//         (i) => wordList[rand.nextInt(wordList.length)],
//       );
//       mnemonicPhrase = mnemonicList.join(" ");
//       Stopwatch stopwatch = Stopwatch()..start();
//       Uint8List seedArr = bip39.mnemonicToSeed(mnemonicPhrase);
//       print(
//         'mnemonicToSeed length $length took: ${stopwatch.elapsedMilliseconds} ms',
//       );
//       results[length]![iteration] = stopwatch.elapsedMilliseconds;
//     }
//   }
//   print("Mnemonic to Seed aggregate results for ${iterations} iterations:");
//   List<num> all = [];
//   for (final int length in seedList.map((seed) => seed.phraseLength)) {
//     all.addAll(results[length]!);
//     print("Mnemonic to Seed aggregate results for length ${length}:");
//     print(" - avg: ${results[length]!.average} ms");
//     print(" - med: ${median(results[length]!)} ms");
//     print(" - max: ${results[length]!.max} ms");
//     print(" - min: ${results[length]!.min} ms");
//     print(" - std: ${stdDev(results[length]!)} ms");
//   }

//   print("Mnemonic to Seed aggregate results for all results:");
//   print(" - avg: ${all.average} ms");
//   print(" - med: ${median(all)} ms");
//   print(" - max: ${all.max} ms");
//   print(" - min: ${all.min} ms");
//   print(" - std: ${stdDev(all)} ms");
//   return;
// }

Future<void> benchmarkMnemonicsToSeedBU(int iterations) async {
  print("==================================");
  print("Benchmarking Mnemonic to Seed (BU)");
  print("==================================");
  List<int> entropy;
  Map<int, int> entrpyLengthMap = {12: 128, 15: 160, 18: 192, 21: 224, 24: 256};
  Mnemonic mnemonic;
  var rand = Random.secure();
  Map<int, List<num>> results = Map.fromEntries(
    seedList.map(
      (seed) => MapEntry(seed.phraseLength, List.filled(iterations, 0)),
    ),
  );
  for (int iteration = 0; iteration < iterations; iteration++) {
    for (final int length in seedList.map((seed) => seed.phraseLength)) {
      entropy = List.generate(
        entrpyLengthMap[length]! ~/ 8,
        (_) => rand.nextInt(256),
      );
      Stopwatch stopwatch = Stopwatch()..start();
      // Uint8List seedArr = bip39.mnemonicToSeed(mnemonicPhrase);
      mnemonic = Bip39MnemonicGenerator().fromEntropy(entropy);
      List<int> seedArr = Bip39SeedGenerator(mnemonic).generate();
      print(
        'mnemonicToSeed length $length took: ${stopwatch.elapsedMilliseconds} ms',
      );
      results[length]![iteration] = stopwatch.elapsedMilliseconds;
    }
  }
  print("Mnemonic to Seed aggregate results for ${iterations} iterations:");
  List<num> all = [];
  for (final int length in seedList.map((seed) => seed.phraseLength)) {
    all.addAll(results[length]!);
    print("Mnemonic to Seed aggregate results for length ${length}:");
    print(" - avg: ${results[length]!.average} ms");
    print(" - med: ${median(results[length]!)} ms");
    print(" - max: ${results[length]!.max} ms");
    print(" - min: ${results[length]!.min} ms");
    print(" - std: ${stdDev(results[length]!)} ms");
  }

  print("Mnemonic to Seed aggregate results for all results:");
  print(" - avg: ${all.average} ms");
  print(" - med: ${median(all)} ms");
  print(" - max: ${all.max} ms");
  print(" - min: ${all.min} ms");
  print(" - std: ${stdDev(all)} ms");
  return;
}

Future<void> benchmarkMnemonicsToSeedCrypto(int iterations) async {
  print("======================================");
  print("Benchmarking Mnemonic to Seed (Crypto) ");
  print("======================================");
  List<String> mnemonicList;
  String mnemonicPhrase;
  var rand = Random.secure();
  Map<int, List<num>> results = Map.fromEntries(
    seedList.map(
      (seed) => MapEntry(seed.phraseLength, List.filled(iterations, 0)),
    ),
  );
  for (int iteration = 0; iteration < iterations; iteration++) {
    for (final int length in seedList.map((seed) => seed.phraseLength)) {
      mnemonicList = List.generate(
        length,
        (i) => wordList[rand.nextInt(wordList.length)],
      );
      mnemonicPhrase = mnemonicList.join(" ");
      String salt = "mnemonic" + ""; // BIP39 salt
      // Uint8List mnemonicBytes = Uint8List.fromList(utf8.encode(mnemonicPhrase)); // Ensure correct encoding
      // Uint8List saltBytes = Uint8List.fromList(utf8.encode(salt));

      // Assuming flutter_openssl_crypto has a pbkdf2HmacSha512 function
      // You'd need to check its exact API for parameters like dklen (64 bytes for BIP39 seed)

      Stopwatch stopwatch = Stopwatch()..start();
      var pb = crypto.Pbkdf2(
        macAlgorithm: crypto.Hmac(crypto.Sha512()),
        iterations: 2048,
        bits: 68 * 8,
      );
      var pass = await pb.deriveKeyFromPassword(
        password: mnemonicPhrase,
        nonce: salt.codeUnits,
      );
      List<int> seedArr = await pass.extractBytes();
      //       Uint8List seedArr = await openssl.pbkdf2( // Or similar function name
      //     password: mnemonicBytes,
      //     salt: saltBytes,
      //     iterations: 2048,
      //     keyLength: 64,
      //     hashAlgorithm: openssl.HashAlgorithm.sha512 // Or however it specifies HMAC-SHA512
      // );
      print(
        'mnemonicToSeed length $length took: ${stopwatch.elapsedMilliseconds} ms',
      );
      results[length]![iteration] = stopwatch.elapsedMilliseconds;
    }
  }
  print("Mnemonic to Seed aggregate results for ${iterations} iterations:");
  List<num> all = [];
  for (final int length in seedList.map((seed) => seed.phraseLength)) {
    all.addAll(results[length]!);
    print("Mnemonic to Seed aggregate results for length ${length}:");
    print(" - avg: ${results[length]!.average} ms");
    print(" - med: ${median(results[length]!)} ms");
    print(" - max: ${results[length]!.max} ms");
    print(" - min: ${results[length]!.min} ms");
    print(" - std: ${stdDev(results[length]!)} ms");
  }

  print("Mnemonic to Seed aggregate results for all results:");
  print(" - avg: ${all.average} ms");
  print(" - med: ${median(all)} ms");
  print(" - max: ${all.max} ms");
  print(" - min: ${all.min} ms");
  print(" - std: ${stdDev(all)} ms");
  return;
}

// double varianceX(List<int> list) {
//   double m = list.average;
//   return list.map((int x) => math.pow(x - m, 2)).reduce((a, b) => a + b) /
//       (list.length);
// }

// double std(List<int> list) {
//   double v = varianceX(list);
//   return sqrt(v);
// }

Future<void> benchmarkMasterHDFromSeed(int iterations) async {
  print("================================");
  print("Benchmarking Master HD from Seed");
  print("================================");
  List<int> seedArr;
  Bip32KeyNetVersions netVersions = Bip32KeyNetVersions(
    [0x04, 0x35, 0x87, 0xCF],
    [0x04, 0x35, 0x83, 0x94],
  );
  var rand = Random.secure();
  List<num> results = List.filled(iterations, 0);
  for (int iteration = 0; iteration < iterations; iteration++) {
    seedArr = List.generate(32, (i) => rand.nextInt(256));
    Stopwatch stopwatch = Stopwatch()..start();
    var hdw = Bip32Slip10Secp256k1.fromSeed(seedArr, netVersions);
    print('Master HD from Seed took: ${stopwatch.elapsedMilliseconds} ms');
    results[iteration] = stopwatch.elapsedMilliseconds;
  }

  print("Master HD from Seed aggregate results for all results:");
  print(" - avg: ${results.average} ms");
  print(" - med: ${median(results)} ms");
  print(" - max: ${results.max} ms");
  print(" - min: ${results.min} ms");
  print(" - std: ${stdDev(results)} ms");
  return;
}

Future<void> benchmarkMasterHDFromSeedFFI(int iterations) async {
  print("======================================");
  print("Benchmarking Master HD from Seed (FFI)");
  print("======================================");
  List<int> seedArr;
  Bip32KeyNetVersions netVersions = Bip32KeyNetVersions(
    [0x04, 0x35, 0x87, 0xCF],
    [0x04, 0x35, 0x83, 0x94],
  );
  var rand = Random.secure();
  List<num> results = List.filled(iterations, 0);
  for (int iteration = 0; iteration < iterations; iteration++) {
    seedArr = List.generate(32, (i) => rand.nextInt(256));
    Stopwatch stopwatch = Stopwatch()..start();
    var hdw = DerivationBIP32Key.fromSeed(seedBytes: seedArr, keyNetVersions:netVersions);
    print('Master HD from Seed took: ${stopwatch.elapsedMilliseconds} ms');
    results[iteration] = stopwatch.elapsedMilliseconds;
  }

  print("Master HD from Seed aggregate results for all results:");
  print(" - avg: ${results.average} ms");
  print(" - med: ${median(results)} ms");
  print(" - max: ${results.max} ms");
  print(" - min: ${results.min} ms");
  print(" - std: ${stdDev(results)} ms");
  return;
}

Future<void> benchmarkKeyDerivation(int iterations) async {
  print("===================================");
  print("Benchmarking derivePath for one key");
  print("===================================");
  List<int> seedArr;
  Bip32KeyNetVersions netVersions = Bip32KeyNetVersions(
    [0x04, 0x35, 0x87, 0xCF],
    [0x04, 0x35, 0x83, 0x94],
  );
  var rand = Random.secure();
  List<num> results = List.filled(iterations, 0);
  // seedArr = List.generate(32, (i) => rand.nextInt(256));
  // var hdw = Bip32Slip10Secp256k1.fromSeed(seedArr, netVersions);
  seedArr = List.generate(32, (i) => (i * 7 + 11) % 256);
  var hdw = Bip32Slip10Secp256k1.fromSeed(seedArr, netVersions);
  for (int iteration = 0; iteration < iterations; iteration++) {
    String path = "m/84'/0'/0'/${iteration}'";
    Stopwatch stopwatch = Stopwatch()..start();
    Bip32PublicKey derivedPubKey = hdw.derivePath(path).publicKey;
    print('derivePath for one key took: ${stopwatch.elapsedMilliseconds} ms');
    print(
      "${path}: ${hex.encode(derivedPubKey.pubKey.compressed)} ${hex.encode(derivedPubKey.chainCode.toBytes())}",
    );
    results[iteration] = stopwatch.elapsedMilliseconds;
  }

  print(
    "derivePath for one key aggregate results for all $iterations results:",
  );
  print(" - avg: ${results.average} ms");
  print(" - med: ${median(results)} ms");
  print(" - max: ${results.max} ms");
  print(" - min: ${results.min} ms");
  print(" - std: ${stdDev(results)} ms");
  return;
}

Future<void> benchmarkKeyDerivationB44(int iterations) async {
  print("=========================================");
  print("Benchmarking derivePath for one key (B44)");
  print("=========================================");
  List<int> seedArr;
  Bip32KeyNetVersions netVersions = Bip32KeyNetVersions(
    [0x04, 0x35, 0x87, 0xCF],
    [0x04, 0x35, 0x83, 0x94],
  );
  var rand = Random.secure();
  List<num> results = List.filled(iterations, 0);
  for (int iteration = 0; iteration < iterations; iteration++) {
    seedArr = List.generate(32, (i) => rand.nextInt(256));
    var hdw = Bip32Slip10Secp256k1.fromSeed(seedArr, netVersions);
    String path = "m/84'/0'/0'/0/${iteration}";
    Stopwatch stopwatch = Stopwatch()..start();
    Bip32PublicKey derivedPubKey = hdw.derivePath(path).publicKey;
    print('derivePath for one key took: ${stopwatch.elapsedMilliseconds} ms');
    results[iteration] = stopwatch.elapsedMilliseconds;
  }

  print(
    "derivePath for one key aggregate results for all $iterations results:",
  );
  print(" - avg: ${results.average} ms");
  print(" - med: ${median(results)} ms");
  print(" - max: ${results.max} ms");
  print(" - min: ${results.min} ms");
  print(" - std: ${stdDev(results)} ms");
  return;
}

Future<void> benchmarkKeyDerivationFFI(int iterations) async {
  print("============================================");
  print("Benchmarking derivePath for one key (FFI)   ");
  print("============================================");
  List<int> seedArr;
  Bip32KeyNetVersions netVersions = Bip32KeyNetVersions(
    [0x04, 0x35, 0x87, 0xCF],
    [0x04, 0x35, 0x83, 0x94],
  );
  var rand = Random.secure();
  List<num> results1 = List.filled(iterations, 0);
  List<num> results2 = List.filled(iterations, 0);
  List<num> results = List.filled(iterations, 0);
  seedArr = List.generate(32, (i) => (i * 7 + 11) % 256);
  var hdw = DerivationBIP32Key.fromSeed(seedBytes: seedArr, keyNetVersions:netVersions);
  for (int iteration = 0; iteration < iterations; iteration++) {
    String path = "m/84'/0'/0'/${iteration}'";
    Stopwatch stopwatch = Stopwatch()..start();
    DerivationBIP32Key? derivedPubKey = await hdw.derivePath(path);
    stopwatch.stop();
    print('derivePath for one key took: ${stopwatch.elapsedMilliseconds} ms');
    Stopwatch stopwatch2 = Stopwatch()..start();
    var publicKey = derivedPubKey!.publicKey;
    stopwatch2.stop();
    print('public key derivation took: ${stopwatch2.elapsedMilliseconds} ms');
    results1[iteration] = stopwatch.elapsedMilliseconds;
    results2[iteration] = stopwatch2.elapsedMilliseconds;
    results[iteration] =
        stopwatch.elapsedMilliseconds + stopwatch2.elapsedMilliseconds;
    print(
      "${path}: ${hex.encode(publicKey)} ${hex.encode(derivedPubKey.chainCode?.toBytes()??[])}",
    );
  }

  print(
    "derivePath for one key aggregate results for all $iterations results:",
  );
  print(" - avg: ${results1.average} ms");
  print(" - med: ${median(results1)} ms");
  print(" - max: ${results1.max} ms");
  print(" - min: ${results1.min} ms");
  print(" - std: ${stdDev(results1)} ms");
  print(
    "public key derivation for one key aggregate results for all $iterations results:",
  );
  print(" - avg: ${results2.average} ms");
  print(" - med: ${median(results2)} ms");
  print(" - max: ${results2.max} ms");
  print(" - min: ${results2.min} ms");
  print(" - std: ${stdDev(results2)} ms");
  print(
    "path + public key derivation for one key aggregate results for all $iterations results:",
  );
  print(" - avg: ${results.average} ms");
  print(" - med: ${median(results)} ms");
  print(" - max: ${results.max} ms");
  print(" - min: ${results.min} ms");
  print(" - std: ${stdDev(results)} ms");
  return;
}