import 'dart:convert';
import 'dart:math';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tejory/coins/wallet.dart';
import 'package:tejory/crypto-helper/se_helper.dart';
import 'package:tejory/objectbox/balance.dart';
import 'package:tejory/objectbox/block.dart';
import 'package:tejory/objectbox/key.dart' as keyCollection;
import 'package:tejory/crypto-helper/hd_wallet.dart';
import 'package:tejory/singleton.dart';
import 'package:tejory/wallets/wallet_setup_response.dart';
import 'package:tejory/wallets/wallet_type.dart';
import 'package:boringssl_ffi/boringssl_ffi.dart' as bssl;
import 'package:secp256k1_ffi/secp256k1_ffi.dart';
import 'package:bip32_key_derivation/bip32_key_derivation.dart';

class DownloadPage extends StatefulWidget {
  final List<int> entropy;
  final bool isNew;
  final bool isSoftware;
  final bool? easyImport;
  final int? startYear;
  final bool reprogramOnly;
  DownloadPage({
    super.key,
    required bool this.isSoftware,
    required List<int> this.entropy,
    required this.isNew,
    this.easyImport,
    this.startYear,
    this.reprogramOnly = false,
  });

  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  bool option = false;
  bool terms = true;
  List<({int coinId, String path, bool getPrivateKeyDerivation})> derivationPathList = [];
  int walletId = 0;
  bool programmed = false;
  late Future<bool> done;
  String PUK = "";
  @override
  void initState() {
    super.initState();

    if (widget.reprogramOnly) {
      done = processWalletCreation(
        widget.isNew,
        widget.isSoftware,
        widget.entropy,
        easyImport: widget.easyImport,
        startYear: widget.startYear,
        reprogramOnly: true,
      );
      return;
    }

    done = processWalletCreation(
      widget.isNew,
      widget.isSoftware,
      widget.entropy,
      easyImport: widget.easyImport,
      startYear: widget.startYear,
    );

    done.then((_) {
      Singleton.initialSetup = true;
      Singleton.assetList.assetListState.postCreationProcess(
        widget.easyImport,
        walletId,
      );
    });
  }

  String sendDialogMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Downloading Blocks',
          style: TextStyle(fontSize: 24, color: Colors.blue),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: FutureBuilder(
          future: done,
          builder: (context, v) {
            if (!v.hasData) {
              return Container(child: Center(child: Text("Please Wait....")));
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _downloadInfoCard(),
                Visibility(visible: option, child: _seedphrase()),
                // _seedphrase(),
                _puk(),
                Visibility(visible: option, child: _checkBox()),
                // _checkBox(),
                _downloadButton(),
                SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _downloadInfoCard() {
    return Card(
      child: ListTile(
        title: Text(
          'Your wallet was ${widget.isNew ? "created" : "imported"} 🚀🌑',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        // subtitle: (widget.reprogramOnly)?null: Padding(
        //   padding: const EdgeInsets.only(top: 10),
        //   child: Text(
        //     'Click continue to proceed to your wallet ${widget.isNew ? "" : "while your data is being updated from the blockchain"}',
        //     textAlign: TextAlign.center,
        //   ),
        // ),
      ),
    );
  }

  Widget _seedphrase() {
    List<String> mnemonics = HDWalletHelpers.entropyToMnemonicStrings(
      widget.entropy,
    );
    return Card(
      child: Column(
        children: List.generate((mnemonics.length / 3).ceil(), (index) {
          return Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(3, (innerIndex) {
                int wordIndex = index * 3 + innerIndex + 1;
                if (wordIndex > mnemonics.length) {
                  return SizedBox.shrink(); // Empty space for extra cells
                }

                return Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: SizedBox(
                    width: 100,
                    height: 34,
                    child: Row(
                      children: [
                        Text(
                          '${(wordIndex < 10) ? " $wordIndex" : "$wordIndex"}.',
                          style: TextStyle(
                            fontFamily: "monospace",
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${mnemonics[wordIndex - 1]}',
                          style: TextStyle(
                            fontFamily: "monospace",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _puk() {
    return Column(
      children: [
        Text(
          "PUK: ${PUK}",
          style: TextStyle(
            fontFamily: "monospace",
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "If you forgot your PIN, use PUK to reset it",
        ),
      ],
    );
  }

  // Widget _checkBox() {
  //   return Row(
  //     children: [
  //       Checkbox(
  //         value: terms,
  //         onChanged: (bool? value) {
  //           setState(() {
  //             terms = value!;
  //           });
  //         },
  //       ),
  //       Text(
  //         'I have saved my Seed Phrase in a safe place.',
  //         style: TextStyle(fontSize: 14),
  //       ),
  //     ],
  //   );
  // }

  Widget _checkBox() {
  return CheckboxListTile(
    title: Text(
      'I have saved my Seed Phrase in a safe place.',
      style: TextStyle(fontSize: 14),
    ),
    value: terms,
    onChanged: (bool? value) {
      setState(() {
        terms = value!;
      });
    },
    controlAffinity: ListTileControlAffinity.leading, // Moves checkbox to the left
    contentPadding: EdgeInsets.zero, // Removes default extra padding
  );
}

  Widget _downloadButton() {
    return AbsorbPointer(
      absorbing: !terms,
      child: ElevatedButton(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith<Color>((
            Set<WidgetState> states,
          ) {
            if (terms) {
              return (Theme.of(context).brightness == Brightness.dark)
                  ? Colors.white
                  : Colors.black;
            }
            return (Theme.of(context).brightness == Brightness.dark)
                ? Color.fromARGB(255, 50, 50, 50)
                : Color.fromARGB(255, 200, 200, 200);
          }),
          // backgroundColor: ,
        ),
        onPressed: () {
          if (widget.reprogramOnly) {
            Navigator.popUntil(
              context,
              ModalRoute.withName(Navigator.defaultRouteName),
            );
            return;
          }

          Navigator.popUntil(
            context,
            ModalRoute.withName(Navigator.defaultRouteName),
          );
        },
        child: Text('Confirm'),
      ),
    );
  }

  Future<bool> processWalletCreation(
    bool isNew,
    bool isSoftware,
    List<int> entropy, {
    bool? easyImport,
    int? startYear,
    bool reprogramOnly = false,
  }) async {
    Map<String, dynamic> result;
    if (isSoftware) {
      result = await createSoftwareWallet(isNew, entropy);
    } else {
      result = await createHardwareWallet(isNew, entropy, reprogramOnly);
    }

    if (result.containsKey("error")) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              children: [
                Text(result["error"]),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        () {
                          return processWalletCreation(
                            isNew,
                            isSoftware,
                            entropy,
                            easyImport: easyImport,
                            startYear: startYear,
                            reprogramOnly: reprogramOnly,
                          );
                        }();
                      },
                      child: Text("Try Again"),
                    ),
                    ElevatedButton(onPressed: () {}, child: Text("Cancel")),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }

    if (reprogramOnly) {
      return true;
    }

    Wallet wallet = result["wallet"] as Wallet;
    if (isNew) {
      setState(() {
        option = true;
        terms = false;
      });
    }

    if (!isSoftware) {
      // Remove the seed from the Walet object if this is a hardware wallet
      wallet.extendedPrivKey = null;
    }

    wallet.easyImport = easyImport;
    wallet.startYear = DateTime(startYear ?? DateTime.now().year);
    walletId = await wallet.save();

    Singleton.assetList.assetListState.myWalletId = walletId;

    int? lastBlockHeight;

    // Get the first block for this wallet
    for (var asset in Singleton.assetList.assetListState.assets) {
      Block? block = await asset.coinTemplate!.getStartBlock(
        isNew,
        easyImport ?? true,
        startYear,
        blockHeight: lastBlockHeight,
      );

      Balance balance = Balance();
      balance.coin = asset.coinId;
      balance.wallet = walletId;
      balance.coinBalance = 0;
      balance.lastBlockUpdate = block?.hash;
      balance.lastUpdate = block?.time;
      await balance.save();
    }
    print("Done initializing the wallet");
    return true;
  }

  static Future<List<Map<String, String?>>> _deriveKeysInBackground(
    Map<String, dynamic> args,
  ) async {
    Bip32KeyNetVersions netVersions = args['netVersions'] as Bip32KeyNetVersions;
    BIP32DerivationKey dKey;
    try {
      dKey = BIP32DerivationKey.fromSeed(
        seedBytes: args['seedArr'] as List<int>,
        keyNetVersions: netVersions,
      );
    } catch (e) {
      print("_deriveKeysInBackground.DerivationBIP32Key.fromSeed ${e}");
      return [];
    }

    final derivationPathList = args['paths'] as List<({int coinId, String path, bool getPrivateKeyDerivation})>;
    var lnPrivKey = hex.encode((await dKey.derivePath("m/9011'/0"))!.privateKey!);
    List<Map<String, String?>> results = [
      {'fingerprint': dKey.fingerPrint.toHex()},
    ];

    for (var pathTuple in derivationPathList) {
      try {
        BIP32DerivationKey? derivedPubKey = await dKey.derivePath(
          pathTuple.path,
        );

        // getPrivateKeyDerivation is always false for HODL coins. It's only true for hot coins like Spark.
        // These private keys are encrypted inside the Spark SDK using the phone's hardware encryption with
        // a key that's not available in the app.
        results.add({
          'path': pathTuple.path,
          'coinId': pathTuple.coinId.toString(),
          'pubKeyHex': hex.encode(derivedPubKey!.publicKey), // Raw pubkey hex
          'chainCodeHex': derivedPubKey.chainCode!.toHex(),
          'privateKey': pathTuple.getPrivateKeyDerivation ? hex.encode(derivedPubKey.privateKey!) : null,
        });
        // adjust for LN
        if (pathTuple.path == "m/9011'/0") {
          results.last["chainCodeHex"] = lnPrivKey;
        }
      } catch (e) {
        results.add({
          'path': pathTuple.path,
          'coinId': pathTuple.coinId.toString(),
          'error': e.toString(),
        });
      }
    }
    return results;
  }

  Future<Map<String, dynamic>> createHardwareWallet(
    bool isNew,
    List<int> entropy,
    bool reprogramOnly,
  ) async {
    Map<String, dynamic> result = {};
    final mnemonic = HDWalletHelpers.entropyToMnemonicStrings(
      widget.entropy,
    ).join(" ");
    final salt = Uint8List.fromList("mnemonic".codeUnits);
    Uint8List? seedArr = bssl.pbkdf2HMAC.deriveKeySHA512(utf8.encode(mnemonic), salt, 2048, 64);

    List<String> pathList;
    Wallet wallet = Wallet();
    Future<dynamic> derivationDone;
    List<keyCollection.Key> dbKeyList = [];

    derivationDone = () async {
      print("DownloadPage.createHardwareWallet derivationDone reprogramOnly: $reprogramOnly");
      if (reprogramOnly) {
        return null;
      }
      for (final asset in Singleton.assetList.assetListState.assets) {
        pathList = asset.coinTemplate!.getInitialDerivationPaths();
        for (final path in pathList) {
          derivationPathList.add((
            coinId: asset.coinId ?? 0,
            path: path,
            getPrivateKeyDerivation: asset.coinTemplate!.getPrivateKeyDerivation
          ));
        }
      }
      List<Map<String, String?>> derivationData = await compute(
        _deriveKeysInBackground,
        {
          'seedArr': seedArr,
          'paths': derivationPathList,
          'netVersions': Bip32KeyNetVersions(
            [0x04, 0x35, 0x87, 0xCF],
            [0x04, 0x35, 0x83, 0x94],
          ),
        },
      );

      wallet.name = isNew ? "my new card wallet" : "my imported card wallet";
      wallet.fingerprint = derivationData[0]['fingerprint']!;

      for (var keyData in derivationData) {
        if (keyData.containsKey('error')) continue;
        if (!keyData.containsKey('path')) continue;
        final encryptPrivateKey = (keyData['privateKey']==null) 
          ? null 
          : SEHelper.encrypt(Uint8List.fromList(hex.decode(keyData['privateKey']!)));
        keyCollection.Key keyObj = keyCollection.Key();
        keyObj.coin = int.tryParse(keyData['coinId']!);
        keyObj.wallet = wallet.id;
        keyObj.path = keyData['path'];
        keyObj.pubKey = keyData['pubKeyHex'];
        keyObj.chainCode = keyData['chainCodeHex'];
        keyObj.privateKey = (encryptPrivateKey==null) ? null : hex.encode(encryptPrivateKey) ;
        dbKeyList.add(keyObj);
        await keyObj.save();
      }
    }();

    wallet.type = widget.isSoftware ? WalletType.phone : WalletType.tejoryCard;
    print("DownloadPage.createHardwareWallet reprogramOnly: $reprogramOnly");
    if (reprogramOnly) {
      wallet = Wallet(id: 1);
    }
    // we need to save to ensure the signing wallet is in side the wallet object
    print("DownloadPage.createHardwareWallet 1");
    await wallet.save();
    print("DownloadPage.createHardwareWallet 2");

    WalletSetupResponse? res;
    bool successful = false;
    List<int> puk = List.generate(4, (_) => Random.secure().nextInt(10));
    PUK = puk.join("");
    print("DownloadPage.createHardwareWallet 3");
    while (!successful) {
      res = null;
      print("DownloadPage.createHardwareWallet NFC loop ${wallet.type}");
      try {
        if (wallet.type == WalletType.tejoryCard) {
          Navigator.of(context).popUntil(ModalRoute.withName("DownloadPage"));
          await wallet.signingWallet!.startSession(
            context,
            await (
              dynamic session, {
              List<int>? pinCode,
              List<int>? pinCodeNew,
            }) async {
              wallet.signingWallet!.setMediumSession(session);
              print("pinCode: ${pinCode}");
              res = await wallet.signingWallet!.initialSetup(
                "",
                Uint8List.fromList(seedArr!),
                pin: String.fromCharCodes(pinCode!),
                puk: String.fromCharCodes(puk),
              );
              return true;
            },
            baseClassUI: "DownloadPage",
            enterPINMessage: "Create a PIN Code",
            isNewPIN: true
          );
        }

        if (res == null) {
          print("continue");
          continue;
        }

        wallet.serialNumber = hex.encode(res!.serialNumber!.codeUnits);
        await wallet.save();
        successful = true;
      } catch (e) {
        print("error ${e}");
        Navigator.of(context).popUntil(ModalRoute.withName("DownloadPage"));
      }
    }

    result["wallet"] = wallet;
    result["keys"] = dbKeyList;

    // print(res?.serialNumber ?? "null response");
    await derivationDone;
    return result;
  }

  Future<Map<String, dynamic>> createSoftwareWallet(
    bool isNew,
    List<int> entropy,
  ) async {
    Map<String, dynamic> result = {};

    return result;
  }
}
