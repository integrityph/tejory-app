import 'dart:typed_data';

import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:tejory/coins/psbt.dart';
import 'package:tejory/coins/pst.dart';
import 'package:tejory/coins/bitcoin_tx.dart';
import 'package:tejory/coins/tx.dart';
import 'package:tejory/comms/medium.dart';
import 'package:tejory/crypto-helper/hd_wallet.dart';
import 'package:tejory/wallets/coin_signing_options.dart';
import 'package:tejory/wallets/iwallet.dart';
import 'package:tejory/wallets/wallet_setup_response.dart';
import 'package:tejory/wallets/wallet_status.dart';

class SoftwareWallet implements IWallet {
  String _extendedPrivateKey = "";
  @override
  void changePINCode(CodeType oldCodeType, String oldCode, CodeType newCodeType,
      String newCode) {
    return;
  }

  @override
  Future<Bip32PublicKey?> deriveHDKey(String path,
      {bool getExtended = false,
      Bip32KeyNetVersions? keyNetVersions,
      Uint8List? bip32Seed}) async {
    // TODO: implement deriveHDKey
    throw UnimplementedError();
  }

  Uint8List getPrivateKey(String path, Bip32KeyNetVersions keyNetVersions) {
    final hdw = Bip32Slip10Secp256k1.fromExtendedKey(
        _extendedPrivateKey, keyNetVersions);
    // final hdw = Bip32Slip10Secp256k1.fromSeed(__seed);
    var account = hdw.derivePath(path);

    return Uint8List.fromList(account.privateKey.raw);
  }

  @override
  Future<List<Uint8List>?> getPSTSignature(PST? pst, Tx? tx, String coinName,
      {CoinSigningOptions? coinOptions,
      Bip32KeyNetVersions? keyNetVersions}) async {
    PSBT psbt = pst as PSBT;
    BitcoinTx btcTX = tx as BitcoinTx;

    // figureout the path of the input
    List<String> paths = [];
    List<ECPrivate> privateKeys = [];
    for (int j = 0; j < psbt.inputs.length; j++) {
      List<String> pathList = ["m"];

      for (int i = 4; i < psbt.inputs[j][6]!["valuedata"]!.length; i += 4) {
        int tempNumber = psbt.inputs[j][6]!["valuedata"]![i];
        tempNumber += psbt.inputs[j][6]!["valuedata"]![i + 1] << (8 * 1);
        tempNumber += psbt.inputs[j][6]!["valuedata"]![i + 2] << (8 * 2);
        tempNumber +=
            (psbt.inputs[j][6]!["valuedata"]![i + 3] & 0x7f) << (8 * 3);
        pathList.add(tempNumber.toString());

        if ((psbt.inputs[j][6]!["valuedata"]![i + 3] & 128) == 128) {
          pathList.last += "'";
        }
      }
      String path = pathList.join("/");
      paths.add(path);
      Uint8List privateKeyBytes = getPrivateKey(path, keyNetVersions!);
      final privateKey = ECPrivate.fromBytes(privateKeyBytes);
      privateKeys.add(privateKey);
    }

    // print(privateKeyBytes);

// Sign an input using the private key

    final b = BitcoinTransactionBuilder(
        outPuts: () {
          List<BitcoinBaseOutput> outputs = [];
          for (int i = 0; i < btcTX.outputs.length; i++) {
            outputs.add(BitcoinOutput(
                address: P2wpkhAddress.fromAddress(
                    address: HDWalletHelpers.getAddressFromBytes(
                        btcTX.outputs[i].getAddress(), "bcrt"),
                    network: BitcoinNetwork.mainnet),
                value: btcTX.outputs[i].value));
          }
          return outputs;
        }(),
        fee: btcTX.fee,
        network: BitcoinNetwork.mainnet,
        utxos: () {
          List<UtxoWithAddress> utxos = [];

          for (int i = 0; i < psbt.inputs.length; i++) {
            utxos.add(UtxoWithAddress(
                utxo: BitcoinUtxo(
                  /// Transaction hash uniquely identifies the referenced transaction
                  txHash: hex.encode(
                      btcTX.inputs[i].previousOutHash.reversed.toList()),

                  /// Value represents the amount of the UTXO in satoshis.
                  value: btcTX.inputs[i].utx.value,

                  /// Vout is the output index of the UTXO within the referenced transaction
                  vout: btcTX.inputs[i].previousOutIndex,

                  /// Script type indicates the type of script associated with the UTXO's address
                  scriptType: SegwitAddressType.p2wpkh,
                ),

                /// Include owner details with the public key and address associated with the UTXO
                ownerDetails: UtxoAddressDetails(
                    publicKey: psbt.inputs[i][6]!["keydata"].toString(),
                    address: privateKeys[i].getPublic().toAddress())));
          }
          return utxos;
        }());

    List<Uint8List> sigList = [];
    print("expecting ${privateKeys.length} inputs");
    b.buildTransaction((trDigest, utxo, publicKey, int sighash) {
      /// For each input in the transaction, locate the corresponding private key
      /// and sign the transaction digest to construct the unlocking script.
      for (int i = 0; i < privateKeys.length; i++) {
        print(
            "checking: ${privateKeys[i].getPublic().toHex()} with $publicKey");
        if (privateKeys[i].getPublic().toHex() != publicKey) {
          continue;
        }
        print("put a key, for $i");
        // sigList.add(
        //     Uint8List.fromList(privateKeys[i].signInput(trDigest).codeUnits));
        return String.fromCharCodes(sigList.last);
      }
      print("ERROR ERROR !!!!!!! $publicKey");
      return "";
    });

    return sigList;
  }

  @override
  Uint8List? getPublicKey(int keyID) {
    // TODO: implement getPublicKey
    throw UnimplementedError();
  }

  @override
  Future<PST?> getSignedPST(PST pst, Tx tx, String coinName,
      {CoinSigningOptions? coinOptions, Bip32KeyNetVersions? keyNetVersions}) {
    // TODO: implement getSignedPST
    throw UnimplementedError();
  }

  @override
  WalletStatus? getStatus(bool getPrivileged) {
    // TODO: implement getStatus
    throw UnimplementedError();
  }

  @override
  Future<WalletSetupResponse?> initialSetup(String name, Uint8List bip32Seed,
      {String pin = "", String puk = ""}) {
    // TODO: implement initialSetup
    throw UnimplementedError();
  }

  @override
  void replaceHDWalletSeed(Uint8List BIP32Seed) {
    // TODO: implement replaceHDWalletSeed
  }

  // @override
  // void setMedium(Medium medium) {
  //   // TODO: implement setMedium
  // }

  @override
  void setPrivateKey(Uint8List privKey, int keyID) {
    // TODO: implement setPrivateKey
  }

  @override
  Future<Uint8List?> signTX(Uint8List tx, String coinName, bool getRawSignature,
      {List<String>? paths,
      List<int>? keyIDs,
      CoinSigningOptions? coinOptions}) {
    // TODO: implement signTX
    throw UnimplementedError();
  }

  @override
  Future<bool> verifyPIN(String pin) {
    // TODO: implement verifyPIN
    throw UnimplementedError();
  }

  @override
  Medium getMedium() {
    // TODO: implement getMedium
    throw UnimplementedError();
  }

  @override
  setMediumSession(session) {}

  @override
  Future<bool> startSession(BuildContext? context,
    NFCSessionCallbackFunction callback, {
    String? baseClassUI,
    List<int>? PIN,
    bool isNewPIN = false,
    bool changePIN = false,
    String enterPINMessage = "Enter your PIN",
    String enterPIN2Message = "Please confirm your PIN again",
  }) {
    // TODO: implement startSession
    throw UnimplementedError();
  }
}
