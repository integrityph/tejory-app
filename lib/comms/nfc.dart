import 'package:flutter/material.dart';
import 'package:tejory/ui/components/pin_code_dialog.dart';

import 'medium.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NFC implements Medium {
  bool stopNfcOperation = false;

  @override
  MediumType type = MediumType.NFC;

  NFC();

  Future<bool> isAvailable() async {
    return await NfcManager.instance.isAvailable();
  }

  Future<dynamic> showNFCModal(
    BuildContext context,
    String message, {
    String? baseClassUI,
  }) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Builder(
          builder: (context) {
            return AlertDialog(
              content: SizedBox(
                height: 400,
                child: Center(
                  child: Column(
                    children: [
                      Text(message),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Image.asset("assets/icons/scann.png"),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    stopNfcOperation = true;
                    disconnect();
                    if (baseClassUI != null) {
                      Navigator.popUntil(
                        context,
                        ModalRoute.withName(baseClassUI),
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  disconnect() {
    NfcManager.instance.stopSession();
  }

  @override
  Future<bool> startSession(
    BuildContext? context,
    NFCSessionCallbackFunction callback, {
    String? baseClassUI,
    List<int>? PIN,
    List<int>? newPIN,
    bool isNewPIN = false,
    bool changePIN = false,
    String enterPINMessage = "Enter your PIN",
    String enterPIN2Message = "Please confirm your PIN again",
  }) async {
    bool? successful;
    List<int>? pinCodeNew = newPIN;
    if (context != null && PIN == null) {
      PINCodeDialog pinDialog = PINCodeDialog();
      List<int>? PIN1 = await pinDialog.showPINModal(
        context,
        enterPINMessage,
        baseClassUI: baseClassUI,
      );
      if (PIN1 == null || PIN1.length != 4) {
        return false;
      }
      if (isNewPIN || changePIN) {
        List<int>? PIN2 = await pinDialog.showPINModal(
          context,
          enterPIN2Message,
          baseClassUI: baseClassUI,
        );
        if (PIN2 == null || PIN2.length != 4 || PIN1.join("") != PIN2.join("")) {
          return false;
        }
        if (changePIN) {
          pinCodeNew = PIN2;
        }
      }
      PIN = PIN1;
    }
    stopNfcOperation = false;
    if (context != null) {
      showNFCModal(
        context,
        "Tap your card until this message disappears",
        baseClassUI: baseClassUI,
      );
    }
    await NfcManager.instance.startSession(
      onDiscovered: await (NfcTag tag) async {
        print("found tag");
        successful = await callback(tag, pinCode:PIN, pinCodeNew:pinCodeNew);
        if (successful != null && successful!) {
          NfcManager.instance.stopSession();
        }
      },
      // invalidateAfterFirstRead: true,
      invalidateAfterFirstReadIos: true,
      pollingOptions: <NfcPollingOption>{NfcPollingOption.iso14443},
      onSessionErrorIos: await (error) async {
        NfcManager.instance.stopSession();
        print("onSessionErrorIos ${error}");
        successful = false;
      },
    );


    while (successful == null) {
      if (stopNfcOperation) {
        try {
          NfcManager.instance.stopSession();
        } catch (e) {}
        successful = false;
      } else {
        print("XXXXXXXXXXXXXXXXXXXXXXXXXXx");
        await Future.delayed(Duration(milliseconds: 300));
      }
    }

    if (context != null) {
      if (baseClassUI != null) {
        Navigator.popUntil(context, ModalRoute.withName(baseClassUI));
      } else {
        Navigator.pop(context);
      }
    }

    return successful!;
  }
}
