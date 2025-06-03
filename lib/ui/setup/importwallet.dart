import 'package:flutter/material.dart';
import 'package:tejory/ui/setup/page_animation.dart';
import 'package:tejory/ui/setup/xprv.dart';
import 'package:tejory/ui/setup/seedphrase.dart';
import 'package:tejory/ui/setup/seed_dropdown.dart';

class ImportWallet extends StatefulWidget {
  @override
  _ImportWallet createState() => _ImportWallet();
}

class _ImportWallet extends State<ImportWallet> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Import Wallet',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blue),
        ),
      ),
      body: Column(
        children: [_importingMethod(), _importSeed(), _importExtendedKey()],
      ),
    );
  }

  Widget _importingMethod() {
    return Padding(
      padding: EdgeInsets.only(top: 10, right: 20, left: 40),
      child: Text(
        'Choose a method of importing your existing wallet',
        style: TextStyle(fontSize: 25),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _importSeed() {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Card(
        child: InkWell(
          onTap: () {
            FadeNavigator(context).navigateTo(SeedPhrase(
              seedList: seedList,
              initialPhraseLength: 24,
              entropy: [],
            ));
          },
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.abc),
                title: Text(
                  'Import Mnemonic Phrase',
                  style: TextStyle(
                      fontWeight: FontWeight.w900, color: Colors.blue),
                ),
                subtitle: Text(
                    'Enter your mnemonic phrase from your existing wallet'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _importExtendedKey() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Card(
        child: InkWell(
          onTap: () {
            FadeNavigator(context).navigateTo(Xprv());
          },
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.abc),
                title: Text('Import Extended Private Key',
                    style: TextStyle(
                        fontWeight: FontWeight.w900, color: Colors.blue)),
                subtitle: Text(
                    'Enter your Extended Private Key from your existing wallet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
