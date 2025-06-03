import 'package:flutter/material.dart';
import 'package:tejory/ui/setup/phrase.dart';
import 'seed_dropdown.dart';

class SeedPhrase extends StatefulWidget {
  final List<int> entropy;
  final List<String> mnemonics = [];
  final int initialPhraseLength;
  final Set<Seed> seedList;
  final bool reprogramOnly;

  SeedPhrase(
      {super.key,
      required this.seedList,
      required this.initialPhraseLength,
      required this.entropy,
      this.reprogramOnly=false});

  @override
  _SeedPhrase createState() => _SeedPhrase();
}

class _SeedPhrase extends State<SeedPhrase> {
  late String selectedSeed;
  late int phraseLength;

  @override
  void initState() {
    super.initState();
    final initialSeedItem = widget.seedList.firstWhere(
      (seed) => seed.phraseLength == widget.initialPhraseLength,
      orElse: () => widget.seedList.first,
    );
    selectedSeed = initialSeedItem.seedRange;
    phraseLength = initialSeedItem.phraseLength;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Select Wallet',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blue),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10, left: 25, right: 25),
        child: Column(
          children: [
            _secretRecoveryPhrase(),
            _dropdownPhraseLength(),
            _phrase()
          ],
        ),
      ),
    );
  }

  Widget _secretRecoveryPhrase() {
    return Center(
      child: Text(
        'Import Wallet using Mnemonic Recovery Phrase',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _dropdownPhraseLength() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: DropdownButton<String>(
        value: selectedSeed,
        isExpanded: true,
        icon: Icon(Icons.arrow_drop_down),
        underline: Container(
          height: 0.5,
          color: Colors.white,
        ),
        onChanged: (String? value) {
          setState(() {
            selectedSeed = value!;
            phraseLength = widget.seedList
                .firstWhere((seed) => seed.seedRange == selectedSeed)
                .phraseLength;
          });
        },
        items: widget.seedList.map<DropdownMenuItem<String>>((Seed seed) {
          return DropdownMenuItem<String>(
            value: seed.seedRange,
            child: Text(seed.seedRange),
          );
        }).toList()
          ..insert(
            0,
            DropdownMenuItem<String>(
              value: "",
              child: Text("Select Phrase Length"),
            ),
          ),
      ),
    );
  }

  Widget _phrase() {
    return SingleChildScrollView(
      child: SizedBox(
        height: 500,
        child: Phrase(
          phraseLength: phraseLength,
          reprogramOnly: widget.reprogramOnly,
        ),
      ),
    );
  }
}
