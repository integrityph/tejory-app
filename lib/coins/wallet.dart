import 'dart:async';
import 'dart:typed_data';

import 'package:blockchain_utils/bip/bip.dart';
import 'package:isar/isar.dart';
import 'package:tejory/bip32/derivation_bip32_key.dart';
import 'package:tejory/collections/wallet_db.dart';
import 'package:tejory/isar_models.dart';
import 'package:tejory/singleton.dart';
import 'package:tejory/wallets/iwallet.dart';
import 'package:tejory/wallets/softwarewallet/software_wallet.dart';
import 'package:tejory/wallets/tejorycard/tejory_card.dart';

class Wallet {
  int? id;
  String? extendedPrivKey;
  WalletType type = WalletType.unknown;
  String name = "";
  String? fingerprint;
  bool? easyImport;
  DateTime? startYear;
  String? serialNumber;
  IWallet? signingWallet;
  Completer<void> loaded;

  Wallet({int? this.id}) : loaded = Completer() {
    if (this.id != null) {
      // creat it from the db
      // Isar isar = Singleton.getDB();
      // WalletDB? walletDB =
      //     isar.walletDBs.filter().idEqualTo(this.id!).findFirstSync();
      () async {
        WalletDB? walletDB = await Models.walletDB.getById(this.id!);
        if (walletDB == null) {
          if (id != 0) {
            print("WARNING: Wallet was not able to find wallet id $id");
          }
          return;
        }

        // id = walletDB.id;
        extendedPrivKey = walletDB.extendedPrivKey;
        type = walletDB.type;
        fingerprint = walletDB.fingerPrint;
        easyImport = walletDB.easyImport;
        startYear = walletDB.startYear;
        serialNumber = walletDB.serialNumber;
        name = walletDB.name ?? "";

        // create the signing wallet object
        if (type == WalletType.phone) {
          signingWallet = SoftwareWallet();
        } else if (type == WalletType.tejoryCard) {
          signingWallet = TejoryCard();
        }
        loaded.complete();
      }();
    }
  }

  Future<int> save() async {
    loaded = Completer();

    // change seed to extended private key
    int seedLength = extendedPrivKey?.length ?? 0;
    if (seedLength >= 16 && seedLength <= 32) {
      // assume this is entropy and change it to extended private key
      // var mnemonic =
      //     HDWalletHelpers.entropyToMnemonicStrings(extendedPrivKey!.codeUnits)
      //         .join(" ");
      var mnemonic = Bip39MnemonicGenerator().fromEntropy(
        extendedPrivKey!.codeUnits,
      );
      var seedArr = Uint8List.fromList(Bip39SeedGenerator(mnemonic).generate());
      // var x = Bip32Slip10Secp256k1.fromSeed([]);
      // x.publicKey.toExtended
      // var seedArr = bip39.mnemonicToSeed(mnemonic);
      var hdw = DerivationBIP32Key.fromSeed(
        seedBytes: seedArr,
        keyNetVersions: Bip32KeyNetVersions(
          [0x04, 0x35, 0x87, 0xCF],
          [0x04, 0x35, 0x83, 0x94],
        ),
      );
      extendedPrivKey = hdw.extendedPrivateKey;
    }

    // Isar isar = Singleton.getDB();
    WalletDB walletDB = WalletDB();
    if (id != null) {
      // walletDB = await isar.walletDBs.get(id!) ?? WalletDB();
      walletDB = await Models.walletDB.getById(id!) ?? WalletDB();
    }

    walletDB.name = name;
    walletDB.type = type;
    walletDB.extendedPrivKey = extendedPrivKey;
    walletDB.fingerPrint = fingerprint;
    walletDB.easyImport = easyImport;
    walletDB.startYear = startYear;
    walletDB.serialNumber = serialNumber;

    // await isar.writeTxn(await () async {
    //   id = await isar.walletDBs.put(walletDB);
    // });
    id = await walletDB.save();

    if (signingWallet == null) {
      if (type == WalletType.phone) {
        signingWallet = SoftwareWallet();
      } else if (type == WalletType.tejoryCard) {
        signingWallet = TejoryCard();
      }
    }
    loaded.complete();
    return id ?? 0;
  }
}
