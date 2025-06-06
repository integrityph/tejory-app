import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tejory/keypad/keypad.dart';

class PINCodeDialog {
  _getPINContainer(String data, BuildContext context) {
    return Container(
      child: Text(
        data,
        style: TextStyle(
          fontFamily: "monospace",
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
      ),
      padding: EdgeInsetsGeometry.only(top: 8, right: 15, left: 15, bottom: 0),
      decoration: BoxDecoration(
        border: BoxBorder.all(color: Theme.of(context).colorScheme.primary),
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
    var dialogFuture = showDialog<List<int>?>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return Dialog.fullscreen(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              if (!listening) {
                listening = true;
                pinController.addListener(() {
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
                    PIN.clear();
                    pinController.text.codeUnits.forEachIndexed((index, digit) {
                      PIN.add(pinController.text.codeUnits[index] - 48);
                      PINText[index] = "*";
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
                            _getPINContainer(PINText[0], context),
                            _getPINContainer(PINText[1], context),
                            _getPINContainer(PINText[2], context),
                            _getPINContainer(PINText[3], context),
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
