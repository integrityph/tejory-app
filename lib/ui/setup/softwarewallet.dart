import 'package:flutter/material.dart';
import 'package:tejory/crypto-helper/hd_wallet.dart';

class SoftwareWallet extends StatelessWidget {
  final List<int> entropy;
  late final List<String> mnemonics;
  final bool isSoftware;

  SoftwareWallet(
      {super.key, required this.entropy, required bool this.isSoftware}) {
    mnemonics = HDWalletHelpers.entropyToMnemonicStrings(entropy);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Wallet',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                _seedPhrase(),
                _seedList(),
              ],
            ),
            _continueButton(context)
          ],
        ),
      ),
    );
  }

  Widget _seedPhrase() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Text(
        'Please Write Down Your Seed Phrase and Keep it in a Safe Place',
        style: TextStyle(fontSize: 25),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _seedList() {
    return Padding(
      padding: const EdgeInsets.only(top: 25.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border(
                top: BorderSide(style: BorderStyle.solid),
                bottom: BorderSide(style: BorderStyle.solid))),
        child: () {
          List<List<Widget>> colChildren = [[], [], []];
          for (int i = 0; i < mnemonics.length; i++) {
            // colChildren[i %3].add(Row(
            colChildren[i ~/ 8].add(Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Text(
                    "${(i + 1).toString().padLeft(2, " ")}.",
                    style: TextStyle(fontSize: 14, fontFamily: "monospace"),
                  ),
                  Text(
                    "${mnemonics[i]}",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        fontFamily: "monospace"),
                  ),
                ],
              ),
            ));
          }
          List<Column> cols = [
            Column(
              children: colChildren[0],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            Column(
              children: colChildren[1],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            Column(
              children: colChildren[2],
              crossAxisAlignment: CrossAxisAlignment.start,
            )
          ];
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: cols,
            ),
          );
        }(),
      ),
    );
  }

  Widget _continueButton(context) {
    return ElevatedButton(
      child: Text('Continue'),
      onPressed: () async {
        // Create the actual wallet
        // Wallet wallet = Wallet();
        // wallet.name = "my wallet";
        // wallet.type = WalletType.phone;
        // wallet.extendedPrivKey = String.fromCharCodes(entropy);
        // await wallet.save();

        Navigator.popUntil(
            context, ModalRoute.withName(Navigator.defaultRouteName));
      },
    );
  }
}
