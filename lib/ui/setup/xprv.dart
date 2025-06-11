// ignore_for_file: unused_element

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:tejory/coins/wallet.dart';
import 'package:tejory/collections/wallet_db.dart';
import 'package:tejory/comms/nfc.dart';
import 'package:base58check/base58.dart' as base58;
import 'package:tejory/crypto-helper/hd_wallet.dart';

NFC nfc = NFC();

class Xprv extends StatefulWidget {
  @override
  _Xprv createState() => _Xprv();
}

class _Xprv extends State<Xprv> {
  final _Xprvcontroller = TextEditingController();
  String result = '';
  String sendDialogMessage = "";
  final String msgSigning =
      "NFC Signing Transaction. Put your phone on the hardware wallet";

  bool validateXprv(String xprv) {
    try {
      // Decode from Base58
      final decoded = base58.Base58Decoder(
              '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz')
          .convert(xprv);

      // Check the length
      if (decoded.length != 82) {
        return false;
      }

      final key = decoded.sublist(0, 78);
      final checksum = decoded.sublist(78);

      // Calculate the checksum
      final hash = sha256.convert(sha256.convert(key).bytes).bytes;

      // Compare the calculated checksum with the provided checksum
      if (!ListEquality().equals(hash.sublist(0, 4), checksum)) {
        return false;
      }

      // Check the version byte
      final versionBytes = key.sublist(0, 4);
      // bip32
      final List<int> bip32mainNetVersionBytes = [0x04, 0x88, 0xAD, 0xE4];
      final List<int> bip32testNetVersionBytes = [0x04, 0x35, 0x83, 0x94];
      int masterDepth = 0x00;
      final List<int> masterFingerPrint = [0x00, 0x00, 0x00, 0x00];
      final List<int> childNumber = [0x00, 0x00, 0x00, 0x00];

      if ((!ListEquality().equals(versionBytes, bip32mainNetVersionBytes)) &&
          (!ListEquality().equals(versionBytes, bip32testNetVersionBytes))) {
        return false;
      }

      if (masterDepth != key[4]) {
        return false;
      }

      if (!ListEquality().equals(masterFingerPrint, key.sublist(5, 9))) {
        return false;
      }

      if (!ListEquality().equals(childNumber, key.sublist(10, 13))) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  void _checkXprv() {
    setState(() {
      final xprv = _Xprvcontroller.text;
      result = validateXprv(xprv) ? 'Valid Xprv key' : 'Invalid Xprv key';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Import Expanded Private Key',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blue),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 200),
          child: Column(
            children: [_xprv(), _textField(), _btn(), _validation()],
          ),
        ),
      ),
    );
  }

  Widget _xprv() {
    return Text(
      'Paste your Extended Private Key here :',
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
    );
  }

  Widget _textField() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SizedBox(
        width: 350,
        height: 50,
        child: TextField(
          enableIMEPersonalizedLearning: false,
          controller: _Xprvcontroller,
          decoration: InputDecoration(border: OutlineInputBorder()),
        ),
      ),
    );
  }

  Widget _btn() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: ElevatedButton(
          onPressed: () async {
            // _checkXprv();
            result = 'Valid Xprv';
            if (result == 'Valid Xprv') {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const Password(),
              //   ),
              // );
              if (!await nfc.isAvailable()) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(
                          'NFC is disabled. Please enable it to sign the transaction'),
                    );
                  },
                );
                return;
              }

              var hdw = Bip32Slip10Secp256k1.fromExtendedKey(
                  _Xprvcontroller.text, HDWalletHelpers.getDefaultNetVersion());

              Wallet wallet = Wallet();
              wallet.name = "my wallet";
              wallet.type = WalletType.tejoryCard;
              wallet.fingerprint =
                  hex.encode(hdw.publicKey.fingerPrint.toBytes());
              await wallet.save();

              // WalletSetupResponse? res;
              await wallet.signingWallet!.startSession(
                  context,
                  await (dynamic session, {List<int>? pinCode, List<int>? pinCodeNew}) async {
                    // TODO: add card support for importing extended private key
                    // wallet.signingWallet!.setMediumSession(session);
                    // res = await wallet.signingWallet!.initialSetup("", );
                    return true;
                  });

              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Text(
                        'Unable to import wallet. invalid response from the wallet'),
                  );
                },
              );
              return;

              // showDialog(
              //   context: context,
              //   builder: (context) {
              //     return AlertDialog(
              //       content: Text('Wallet Imported!'),
              //     );
              //   },
              // );
            }
          },
          child: Text(
            'Confirm',
            style: TextStyle(fontSize: 15),
          )),
    );
  }

  Widget _validation() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(
        result,
        style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: result == 'Valid Xprv key' ? Colors.green : Colors.red),
      ),
    );
  }
}
