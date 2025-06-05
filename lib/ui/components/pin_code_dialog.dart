import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tejory/keypad/keypad.dart';

class PINCodeDialog {
  _getPINContainer(String data) {
    print("_getPINContainer ${data}");
    return Container(
      child: Text(
        data,
        style: TextStyle(
          fontFamily: "monospace",
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
      ),
      padding: EdgeInsetsGeometry.only(top: 3, right: 15, left: 15, bottom: 9),
      decoration: BoxDecoration(
        border: BoxBorder.all(),
        borderRadius: BorderRadiusGeometry.all(Radius.circular(5)),
      ),
    );
  }

  Future<List<int>?> showPINModal(
    BuildContext context,
    String message, {
    String? baseClassUI,
  }) async {
    List<int> PIN = [];
    List<String> PINText = [" ", " ", " ", " "];
    TextEditingController pinController = TextEditingController();
    bool listening = false;
    Numpad numpad = Numpad(
          autoShow: true,
          keyboardController: pinController,
          onEditingCompleteKeyboard: (NumpadState numpadState) {
            numpadState.setVisible(false);
            Navigator.of(context).pop(PIN);
          },
        );
    Stopwatch watch = Stopwatch()..start();

    print("ready to show PIN dialog ${watch.elapsedMilliseconds}");
    var dialogFuture = showDialog<List<int>?>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (BuildContext context) {
        print("showDialog.builder ${watch.elapsedMilliseconds}");        
        return Dialog.fullscreen(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              print(
                "showDialog.builder.StatefulBuilder.builder ${watch.elapsedMilliseconds}",
              );
              if (!listening) {
                listening = true;
                pinController.addListener(() {
                  print("pinController.addListener ${pinController.text}");
                  // check the input is a number
                  if (pinController.text.length != 0) {
                    if (pinController.text.codeUnits.last < 48 ||
                        pinController.text.codeUnits.last > 57) {
                      pinController.text = pinController.text.substring(
                        0,
                        pinController.text.length - 1,
                      );
                      return;
                    }
                  }
                  if (pinController.text.length > 4) {
                    pinController.text = pinController.text.substring(
                      0,
                      pinController.text.length - 1,
                    );
                    return;
                  }

                  setState(() {
                    PINText = [" ", " ", " ", " "];
                    print("pinController.text ${pinController.text}");
                    PIN.clear();
                    pinController.text.codeUnits.forEachIndexed((index, digit) {
                      PIN.add(pinController.text.codeUnits[index] - 48);
                      PINText[index] = "●";
                    });
                  });
                });
              }
              return Stack(
                children: [
                  Column(
                    children: [
                      SizedBox(height: 30),
                      Text(message, style: TextStyle(fontSize: 24)),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 20,
                          children: [
                            _getPINContainer(PINText[0]),
                            _getPINContainer(PINText[1]),
                            _getPINContainer(PINText[2]),
                            _getPINContainer(PINText[3]),
                          ],
                        ),
                      ),
                    ],
                  ),
                  numpad,
                ],
              );
            },
          ),
        );
      },
    );
    return dialogFuture;
  }
}
