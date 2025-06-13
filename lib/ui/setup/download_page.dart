import 'dart:math';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cryptography/cryptography.dart' as crypto;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tejory/bip32/derivation_bip32_key.dart';
import 'package:tejory/coins/wallet.dart';
import 'package:tejory/objectbox/balance.dart';
import 'package:tejory/objectbox/block.dart';
import 'package:tejory/objectbox/wallet_db.dart';
import 'package:tejory/objectbox/key.dart' as keyCollection;
import 'package:tejory/crypto-helper/hd_wallet.dart';
import 'package:tejory/libsecp256k1ffi/libsecp256k1ffi.dart';
import 'package:tejory/singleton.dart';
import 'package:tejory/wallets/wallet_setup_response.dart';
import 'package:tejory/wallets/wallet_type.dart';

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
  List<Tuple<int, String>> derivationPathList = [];
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
        padding: const EdgeInsets.symmetric(horizontal: 10),
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
                    height: 40,
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

  Widget _checkBox() {
    return Row(
      children: [
        Checkbox(
          value: terms,
          onChanged: (bool? value) {
            setState(() {
              terms = value!;
            });
          },
        ),
        Text(
          'I have saved my Seed Phrase in a safe place.',
          style: TextStyle(fontSize: 14),
        ),
      ],
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
    print("_deriveKeysInBackground 0.0");
    await LibSecp256k1FFI.init();
    print("_deriveKeysInBackground 0.1");
    Bip32KeyNetVersions netVersions =
        args['netVersions'] as Bip32KeyNetVersions;
    print("_deriveKeysInBackground 0.2");
    DerivationBIP32Key dKey;
    try {
      dKey = DerivationBIP32Key.fromSeed(
        seedBytes: args['seedArr'] as List<int>,
        keyNetVersions: netVersions,
      );
    } catch (e) {
      print("_deriveKeysInBackground.DerivationBIP32Key.fromSeed ${e}");
      return [];
    }

    print("_deriveKeysInBackground 1");

    List<Tuple<int, String>> derivationPathList =
        args['paths'] as List<Tuple<int, String>>;
    // var lnPrivKey = dKey.derivePath("m/9011'/0").privateKey.toHex();
    var lnPrivKey = hex.encode(
      (await dKey.derivePath("m/9011'/0"))!.privateKey!,
    );
    List<Map<String, String?>> results = [
      {'fingerprint': dKey.fingerPrint.toHex()},
    ];

    print("_deriveKeysInBackground 2");

    for (var pathTuple in derivationPathList) {
      print("_deriveKeysInBackground ${pathTuple.item2}");
      try {
        DerivationBIP32Key? derivedPubKey = await dKey.derivePath(
          pathTuple.item2,
        );
        results.add({
          'path': pathTuple.item2,
          'coinId': pathTuple.item1.toString(),
          'pubKeyHex': hex.encode(derivedPubKey!.publicKey), // Raw pubkey hex
          'chainCodeHex': derivedPubKey.chainCode!.toHex(),
        });
        // adjust for LN
        if (pathTuple.item2 == "m/9011'/0") {
          results.last["chainCodeHex"] = lnPrivKey;
        }
      } catch (e) {
        results.add({
          'path': pathTuple.item2,
          'coinId': pathTuple.item1.toString(),
          'error': e.toString(),
        });
      }
    }
    print("_deriveKeysInBackground DONE");
    return results;
  }

  Future<Map<String, dynamic>> createHardwareWallet(
    bool isNew,
    List<int> entropy,
    bool reprogramOnly,
  ) async {
    Map<String, dynamic> result = {};

    var mnemonic = HDWalletHelpers.entropyToMnemonicStrings(
      widget.entropy,
    ).join(" ");
    String salt = "mnemonic";
    var pb = crypto.Pbkdf2(
      macAlgorithm: crypto.Hmac(crypto.Sha512()),
      iterations: 2048,
      bits: 64 * 8,
    );
    var pass = await pb.deriveKeyFromPassword(
      password: mnemonic,
      nonce: salt.codeUnits,
    );
    List<int> seedArr = await pass.extractBytes();

    List<String> pathList;
    Wallet wallet = Wallet();
    Future<dynamic> derivationDone;
    List<keyCollection.Key> dbKeyList = [];

    derivationDone = () async {
      if (reprogramOnly) {
        return null;
      }
      for (final asset in Singleton.assetList.assetListState.assets) {
        pathList = asset.coinTemplate!.getInitialDerivationPaths();
        for (final path in pathList) {
          derivationPathList.add(Tuple<int, String>(asset.coinId ?? 0, path));
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
          ), // Make sure this is correctly passed
        },
      );

      wallet.name = isNew ? "my new card wallet" : "my imported card wallet";
      wallet.fingerprint = derivationData[0]['fingerprint']!;

      for (var keyData in derivationData) {
        if (keyData.containsKey('error')) continue;
        if (!keyData.containsKey('path')) continue;
        keyCollection.Key keyObj = keyCollection.Key();
        keyObj.coin = int.tryParse(keyData['coinId']!);
        keyObj.wallet = wallet.id;
        keyObj.path = keyData['path'];
        keyObj.pubKey = keyData['pubKeyHex'];
        keyObj.chainCode = keyData['chainCodeHex'];
        dbKeyList.add(keyObj);
        await keyObj.save();
      }
    }();

    wallet.type = widget.isSoftware ? WalletType.phone : WalletType.tejoryCard;
    if (reprogramOnly) {
      wallet = Wallet(id: 1);
    }
    // we need to save to ensure the signing wallet is in side the wallet object
    await wallet.save();

    WalletSetupResponse? res;
    bool successful = false;
    List<int> puk = List.generate(4, (_) => Random.secure().nextInt(10));
    PUK = puk.join("");
    while (!successful) {
      res = null;
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
                Uint8List.fromList(seedArr),
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
