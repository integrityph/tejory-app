import 'package:flutter/material.dart';
import 'package:tejory/crypto-helper/hd_wallet.dart';
import 'package:tejory/ui/setup/download_page.dart';
import 'package:tejory/ui/setup/hardware_software.dart';
import 'package:tejory/ui/setup/page_animation.dart';
import 'package:tejory/ui/setup/word_list.dart';

class Phrase extends StatefulWidget {
  final int phraseLength;
  final bool reprogramOnly;

  final _PhraseState phraseState = _PhraseState();

  Phrase({super.key, required this.phraseLength, this.reprogramOnly = false});

  @override
  _PhraseState createState() => _PhraseState();
}

class _PhraseState extends State<Phrase> {
  List<TextEditingController> wordControllerList = [];
  List<TextFormField> wordFieldList = [];
  final _formKey = GlobalKey<FormState>();
  List<String> mnemonics = [];

  void checkWord(int index) {
    if(wordControllerList[index].text.contains(" ")) {
      var words = wordControllerList[index].text.split(" ");
      for (int i=index; i<words.length; i++) {
        wordControllerList[i].text = words[i];
        FocusManager.instance.primaryFocus?.nextFocus();
      }
    };
    _formKey.currentState?.validate();
  }

  String? checkWord2(String? text) {
    if (text == null || text == "") {
      return null;
    }
    bool invalid = false;
    if (!wordMap.keys.contains(text)) {
      invalid = true;
    }

    if (invalid) {
      return "invalid";
    }
    return null;
  }

  @override
  void initState() {
    super.initState();

    generateFields();
  }

  @override
  void didUpdateWidget(covariant Phrase oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the phraseLength property has actually changed
    if (widget.phraseLength != oldWidget.phraseLength) {
      // If it changed, re-initialize the controllers and call setState
      // to trigger a rebuild with the new set of TextFormFields.
      setState(() {
        generateFields();
      });
    }
  }

  @override
  void dispose() {
    // Dispose all TextEditingControllers when the state is disposed
    for (final controller in wordControllerList) {
      controller.dispose();
    }
    wordControllerList.clear(); // Good practice to clear the list too
    super.dispose();
  }

  void generateFields() {
    wordControllerList.clear();
    wordFieldList.clear();
    for (int i = 0; i < widget.phraseLength; i++) {
      wordControllerList.add(TextEditingController());
      wordControllerList.last.addListener(() {checkWord(i);});
      wordFieldList.add(
        TextFormField(
          enableIMEPersonalizedLearning: false,
          controller: wordControllerList[i],
          validator: checkWord2,
          autovalidateMode: AutovalidateMode.always,
          decoration: InputDecoration(
            errorStyle: TextStyle(
              fontSize: 9,
              height: .07,
              fontWeight: FontWeight.w900,
              // letterSpacing: 8,
            ),
          ),
          autofillHints: wordList,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(children: [_wordField(), _confirmButton()]),
      ),
    );
  }

  Widget _wordField() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: List.generate((widget.phraseLength / 3).ceil(), (index) {
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(3, (innerIndex) {
                  int wordIndex = index * 3 + innerIndex + 1;
                  if (wordIndex > widget.phraseLength) {
                    return SizedBox.shrink(); // Empty space for extra cells
                  }

                  return Row(
                    children: [
                      Text('$wordIndex.'),
                      SizedBox(
                        width: 80,
                        height: 50,
                        child: wordFieldList[wordIndex - 1],
                      ),
                    ],
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _confirmButton() {
    return ElevatedButton(
      child: Text('Confirm'),
      onPressed: () {
        mnemonics = [];
        for (int i = 0; i < wordControllerList.length; i++) {
          if (wordControllerList[i].text == "") {
            continue;
          }
          String words = wordControllerList[i].text;
          List<String> wordList = words.split(' ');
          mnemonics += wordList;
        }

        if (mnemonics.length != widget.phraseLength) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(content: Text('Incorrect number of words'));
            },
          );
          return;
        }

        var entropy = HDWalletHelpers.MnemonicStringsToEntropy(mnemonics);

        FocusScope.of(context).unfocus();
        if (widget.reprogramOnly) {
          FadeNavigator(context).navigateTo(
            DownloadPage(
              entropy: entropy,
              isSoftware: false,
              isNew: false,
              reprogramOnly: true,
            ),
          );
        } else {
          FadeNavigator(
            context,
          ).navigateTo(HardwareSoftware(isNew: false, entropy: entropy));
        }
      },
    );
  }
}
