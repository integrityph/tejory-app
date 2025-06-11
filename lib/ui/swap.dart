import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tejory/coins/crypto_coin.dart';
import 'package:tejory/coins/psbt.dart';
import 'package:tejory/coins/pst.dart';
import 'package:tejory/coins/tx.dart';
import 'package:tejory/collections/wallet_db.dart';
import 'package:tejory/comms/nfc.dart';
import 'package:tejory/crypto-helper/other_helpers.dart';
import 'package:tejory/singleton.dart';
import 'package:tejory/keypad/keypad.dart';
import 'package:tejory/ui/asset.dart';
import 'package:tejory/ui/network.dart';

class SwapPage extends StatefulWidget {
  final String initialToken;

  SwapPage({super.key, required this.initialToken});

  @override
  _SwapPage createState() => _SwapPage();
}

class _SwapPage extends State<SwapPage> with ChangeNotifier {
  String selectedToken0 = '';
  String selectedToken1 = '';
  Network? selectedNetworkObj = null;
  Asset? asset0;
  Asset? asset1;
  Future<BigInt>? oneUnitRate;
  TextEditingController controller0 = TextEditingController();
  TextEditingController controller1 = TextEditingController();
  double amountIn = 0.0;
  double amountOut = 0.0;
  bool ready = false;
  NFC nfc = NFC();
  Numpad numpad = Numpad();

  void setReady(bool value) {
    ready = value;
    notifyListeners();
  }

  @override
  void initState() {
    super.initState();
    selectedNetworkObj = null; // TODO: find the selected network
    controller0.addListener(() {
      setReady(false);
    });
    controller1.addListener(() {
      setReady(false);
    });
  }

  handleToken0Change(String? value) {
    setState(() {
      setReady(false);
      controller0.text = "0";
      controller1.text = "0";
      selectedToken0 = value!;
      selectedToken1 = "";
      // set asset
      asset0 = Singleton.assetList.assetListState.findAsset(selectedToken0);
      asset1 = null;
    });
  }

  handleToken1Change(String? value) {
    setState(() {
      setReady(false);
      controller0.text = "0";
      controller1.text = "0";
      oneUnitRate = Future.value(BigInt.zero);
      selectedToken1 = value!;
      // set asset
      asset1 = Singleton.assetList.assetListState.findAsset(selectedToken1);
      if (asset1 != null) {
        oneUnitRate = Singleton.swap
            .swapRate(asset0!.coins[0], asset1!.coins[0], doubleAmountIn: 1.0);
      }
    });
  }

  Future<bool> getRate0() async {
    if (asset1 != null) {
      FocusManager.instance.primaryFocus?.unfocus();
      controller1.text = "";
      var rate = await Singleton.swap.swapRate(
          asset0!.coins[0], asset1!.coins[0],
          doubleAmountIn: double.parse(controller0.text));
      if (rate == BigInt.zero) {
        return false;
      }
      setState(() {
        controller1.text = asset1!.getDecimalAmount(rate);
        amountIn = double.parse(controller0.text);
        amountOut = double.parse(controller1.text);
      });
      return true;
    }
    return false;
  }

  Future<bool> getRate1() async {
    if (asset0 != null) {
      FocusManager.instance.primaryFocus?.unfocus();
      controller0.text = "";
      var rate = await Singleton.swap.swapRate(
          asset1!.coins[0], asset0!.coins[0],
          doubleAmountIn: double.parse(controller1.text));
      if (rate == BigInt.zero) {
        return false;
      }
      setState(() {
        controller0.text = asset0!.getDecimalAmount(rate);
        amountIn = double.parse(controller0.text);
        amountOut = double.parse(controller1.text);
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Singleton.loaded,
        builder: (context, v) {
          return Scaffold(
            body: Container(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Text(
                        "Swap Token",
                        style: TextStyle(fontSize: 22),
                      ),
                      Container(
                        height: 275,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 10, left: 10, right: 10),
                            child: Stack(
                                alignment: AlignmentDirectional.center,
                                fit: StackFit.expand,
                                children: [
                                  _sell(),
                                  Positioned(top: 95, child: _swapButton()),
                                ]),
                          ),
                        ),
                      ),
                      _conversion(),
                      Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: ListenableBuilder(
                            listenable: this,
                            builder: (context, v) {
                              if (ready == false) {
                                return Container(
                                    child: Center(
                                        child: Text("Enter your swap values")));
                              }
                              return _confirm();
                            }),
                      )
                    ],
                  ),
                  numpad,
                ],
              ),
            ),
          );
        });
  }

  Widget _sell() {
    return Column(
      children: [
        Container(
          // height: 120,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              border: Border.all(width: 1, color: Theme.of(context).colorScheme.primary),
              borderRadius: BorderRadius.all(Radius.elliptical(5, 5)),
              color: Theme.of(context).colorScheme.surface,
              ),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Sell",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(" - balance: "),
                        Text(
                          (asset0 == null)
                              ? ""
                              : OtherHelpers.humanizeMoney(asset0!
                                  .getDecimalAmountInDouble(
                                      asset0!.getBalance())),
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 150,
                      child: TextField(
                        onTap: (Platform.operatingSystem == "ios")
                            ? () {
                                numpad.state.openKeyboard(controller0,
                                    onEditingComplete: (NumpadState numpadState) async {
                                  setReady(await getRate0());
                                });
                              }
                            : null,
                        keyboardType: (Platform.operatingSystem == "ios")
                            ? TextInputType.none
                            : TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^[0-9\]+[\.0-9]*')),
                        ],
                        textInputAction: TextInputAction.done,
                        controller: controller0,
                        onEditingComplete: () async {
                          setReady(await getRate0());
                        },
                        style: TextStyle(fontSize: 30),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "0",
                        ),
                      ),
                    ),
                    Text(
                      "${(asset0 == null) ? "" : OtherHelpers.humanizeMoney(amountIn * asset0!.priceUsd, isFiat: true, addFiatSymbol: true)}",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Container(
                  width: 140,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                      border: Border.all(width: 0.5, color: Theme.of(context).colorScheme.primary),
                      borderRadius:
                          BorderRadius.all(Radius.elliptical(10, 10))),
                  child: _dropdownSelectToken0())
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: _buy(),
        )
      ],
    );
  }

  Widget _buy() {
    return Column(
      children: [
        Container(
          // height: 120,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              border: Border.all(width: 1, color: Theme.of(context).colorScheme.primary),
              borderRadius: BorderRadius.all(Radius.elliptical(5, 5)),
              color: Theme.of(context).colorScheme.surface,
              ),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Buy",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(" - balance: "),
                        Text(
                          (asset1 == null)
                              ? ""
                              : OtherHelpers.humanizeMoney(asset1!
                                  .getDecimalAmountInDouble(
                                      asset1!.getBalance())),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 220,
                      child: TextField(
                        onTap: (Platform.operatingSystem == "ios")
                            ? () {
                                numpad.state.openKeyboard(controller1,
                                    onEditingComplete: (NumpadState numpadState) async {
                                  setReady(await getRate1());
                                });
                              }
                            : null,
                        keyboardType: (Platform.operatingSystem == "ios")
                            ? TextInputType.none
                            : TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^[0-9\]+[\.0-9]*')),
                        ],
                        textInputAction: TextInputAction.done,
                        controller: controller1,
                        onEditingComplete: () async {
                          setReady(await getRate1());
                        },
                        style: TextStyle(fontSize: 30),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "0",
                        ),
                      ),
                    ),
                    Text(
                      "${(asset1 == null) ? "" : OtherHelpers.humanizeMoney(amountOut * asset1!.priceUsd, isFiat: true, addFiatSymbol: true)}",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Container(
                  width: 140,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                      border: Border.all(width: 0.5, color: Theme.of(context).colorScheme.primary),
                      borderRadius:
                          BorderRadius.all(Radius.elliptical(10, 10))),
                  child: _dropdownSelectToken1())
            ],
          ),
        ),
      ],
    );
  }

  Widget _swapButton() {
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            border: Border.all(width: 1, color: Theme.of(context).colorScheme.primary),
            borderRadius: BorderRadius.all(Radius.elliptical(5, 5))),
        child: IconButton(
            onPressed: () {
              setState(() {
                var tempAsset = asset0;
                asset0 = asset1;
                asset1 = tempAsset;
                var tempToken = selectedToken0;
                selectedToken0 = selectedToken1;
                selectedToken1 = tempToken;
                var tempText = controller0.text;
                controller0.text = controller1.text;
                controller1.text = tempText;
              });
              handleToken1Change(selectedToken1);
            },
            icon: Icon(Icons.swap_vert_rounded)));
  }

  Widget _dropdownSelectToken0() {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: DropdownButton<String>(
        value: selectedToken0,
        isExpanded: true,
        icon: Icon(Icons.arrow_drop_down),
        underline: Container(
          height: 0,
        ),
        dropdownColor: Theme.of(context).colorScheme.tertiary,
        onChanged: (selectedNetworkObj?.requiresAmount ?? false)
            ? null
            : handleToken0Change,
        items: () {
          List<DropdownMenuItem<String>> x = Singleton.swap
              .getFullSwapList()
              .map<DropdownMenuItem<String>>((CryptoCoin _asset) {
            return DropdownMenuItem<String>(
                value: _asset.name(),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/${_asset.symbol().toLowerCase()}.png',
                      height: 25,
                      width: 25,
                    ),
                    Text(
                      "  ${_asset.symbol()}",
                    ),
                  ],
                ));
          }).toList();
          x.insert(
              0,
              DropdownMenuItem<String>(
                  value: "",
                  child: Text(
                    "-",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                  )));
          return x;
        }(),
      ),
    );
  }

  Widget _dropdownSelectToken1() {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: DropdownButton<String>(
        value: selectedToken1,
        isExpanded: true,
        icon: Icon(Icons.arrow_drop_down),
        underline: Container(
          height: 0,
        ),
        dropdownColor: Theme.of(context).colorScheme.tertiary,
        onChanged: (selectedNetworkObj?.requiresAmount ?? false)
            ? null
            : handleToken1Change,
        items: () {
          List<DropdownMenuItem<String>> x = (asset0 == null)
              ? []
              : Singleton.swap
                  .getSwapList(asset0!.coins[0])
                  .map<DropdownMenuItem<String>>((CryptoCoin _asset) {
                  return DropdownMenuItem<String>(
                      value: _asset.name(),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/${_asset.symbol().toLowerCase()}.png',
                            height: 25,
                            width: 25,
                          ),
                          Text(
                            "  ${_asset.symbol()}",
                          ),
                        ],
                      ));
                }).toList();
          x.insert(
              0,
              DropdownMenuItem<String>(
                  value: "",
                  child: Text(
                    "-",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                  )));
          return x;
        }(),
      ),
    );
  }

  Widget _conversion() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        children: [
          Expanded(
            child: (asset0 == null || asset1 == null)
                ? Container()
                : Container(
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    decoration: BoxDecoration(
                        border: Border.all(width: 1),
                        borderRadius:
                            BorderRadius.all(Radius.elliptical(5, 5))),
                    child: FutureBuilder(
                        future: oneUnitRate,
                        builder: (context, rate) {
                          return Text(
                            "1 ${asset0?.symbol ?? ""} = ${(rate.data != null) ? OtherHelpers.humanizeMoney(asset1!.getDecimalAmountInDouble(rate.data!)) : "?"} ${asset1?.symbol ?? ""}",
                            style: TextStyle(fontSize: 24),
                            textAlign: TextAlign.center,
                          );
                        }),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _confirm() {
    return ElevatedButton(
        style: ButtonStyle(
          padding: WidgetStateProperty.all<EdgeInsets>(
              EdgeInsets.only(left: 18.0, right: 18, top: 12, bottom: 12)),
        ),
        onPressed: () async {
          var unlocked = await Singleton.swap
              .checkToken(asset0!.coins[0], asset1!.coins[0]);
          if (unlocked == null) {
            _errorDialogBuilder(context,
                'Unable to check if tokens are available for swap. Check your Internet connectivity and try again.');
            return;
          }
          if (!unlocked) {
            var txList = await Singleton.swap
                .unlockToken(asset0!.coins[0], asset1!.coins[0]);
            if (txList == null) {
              _errorDialogBuilder(context,
                  'Unable to unlock tokens for swap. Check your Internet connectivity and try again.');
              return;
            }
            await _msgDialogBuilder(context,
                "The selected token pair is not unlocked for swaps. We will have to unlock them first. You will have to sign ${txList.length} transaction(s) to unlock the tokens for swap");
            for (final tx in txList) {
              Uint8List? signedBytes;
              if ((await asset0!.getWallet()).type == WalletType.phone) {
                signedBytes = await signTxPhone(PSBT(), tx);
              } else if ((await asset0!.getWallet()).type == WalletType.tejoryCard) {
                signedBytes = await signTxNFC(PSBT(), tx);
              } else {
                _errorDialogBuilder(context,
                    'Unable to unlock tokens for swap. Unknown wallet type');
                return;
              }
              if (signedBytes == null) {
                _errorDialogBuilder(context,
                    'Unable to sign token unlock transaction. Try again');
                return;
              }
              // int eIndex;
              // var rawTx = tx.getRawTX();
              // print("UNLOCK TOKEN");
              // for (int i=0; i<signedBytes.length; i+=32){
              //   eIndex = (i+32 > signedBytes.length) ? signedBytes.length : i+32;
              //   print("$i: ${hex.encode(signedBytes.sublist(i,eIndex))}");
              // }
              asset0!.transmitTxBytes(signedBytes);
            }
            _msgDialogBuilder(context,
                "Tokens unlocked for swaps successfully. Please wait a few minutes before swapping any tokens.");
            return;
          }
          var tx = await Singleton.swap.swap(
              asset0!.coins[0],
              asset1!.coins[0],
              asset0!.getBaseAmount(double.parse(controller0.text)),
              asset1!.getBaseAmount(double.parse(controller1.text)));
          if (tx == null) {
            _errorDialogBuilder(context, 'Swap failed. Try again');
            return;
          }
          Uint8List? signedBytes;
          if ((await asset0!.getWallet()).type == WalletType.phone) {
            signedBytes = await signTxPhone(PSBT(), tx);
          } else if ((await asset0!.getWallet()).type == WalletType.tejoryCard) {
            signedBytes = await signTxNFC(PSBT(), tx);
          }
          if (signedBytes == null) {
            _errorDialogBuilder(
                context, 'Signing swap transaction failed. Try again');
            return;
          }
          var asset0BalanceOld = asset0!.getBalance();
          // var asset1BalanceOld = asset1!.getBalance();
          var objFuture = asset0!.transmitTxBytes(signedBytes);

          // int eIndex;
          // print("SIGNED TX");
          // for (int i=0; i<signedBytes.length; i+=32){
          //   eIndex = (i+32 > signedBytes.length) ? signedBytes.length : i+32;
          //   print("$i: ${hex.encode(signedBytes.sublist(i,eIndex))}");
          // }
          // _successDialogBuilder(context);

          showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                // icon: Icon(
                //   Icons.check_circle_outline,
                //   size: 100,
                //   color: Colors.green,
                // ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        FutureBuilder(
                            future: objFuture,
                            builder: (context, v) {
                              if (v.data == null) {
                                return Icon(Icons.pending);
                              }
                              if (!v.data!.containsKey("result")) {
                                return Icon(Icons.error_outline_rounded,
                                    color: Colors.red);
                              }
                              return Icon(Icons.check_circle_outline,
                                  color: Colors.green);
                            }),
                        Text("Transaction sent")
                      ],
                    ),
                    ListenableBuilder(
                        listenable: asset0!,
                        builder: (context, v) {
                          var newBalance = asset0!.getBalance();
                          if (asset0BalanceOld == newBalance) {
                            return Row(
                              children: [
                                Icon(Icons.pending),
                                Text("Transaction processing")
                              ],
                            );
                          }
                          var delta0 = asset0!.getBalance() - asset0BalanceOld;
                          // var delta1 = asset1!.getBalance() - asset1BalanceOld;
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.check_circle_outline,
                                      color: Colors.green),
                                  Text("Transaction successful")
                                ],
                              ),
                              Text(
                                'Transaction Done\n'
                                '${OtherHelpers.humanizeMoney(asset0!.getDecimalAmountInDouble(delta0))} ${asset0!.symbol} = ${OtherHelpers.humanizeMoney(double.parse(controller1.text))} ${asset1!.symbol}\n'
                                '------------------------------------------------------',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        }),
                  ],
                ),
                actionsAlignment: MainAxisAlignment.center,
                actions: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                        textStyle: Theme.of(context).textTheme.labelLarge),
                    child: const Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Text("Swap", style: TextStyle(fontSize: 20)));
  }

  // Future<void> _successDialogBuilder(BuildContext context) {
  //   return showDialog<void>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         icon: Icon(
  //           Icons.check_circle_outline,
  //           size: 100,
  //           color: Colors.green,
  //         ),
  //         content: Text(
  //           'Transaction Done\n'
  //           '${OtherHelpers.humanizeMoney(double.parse(controller0.text))} ${asset0!.symbol} = ${OtherHelpers.humanizeMoney(double.parse(controller1.text))} ${asset1!.symbol}\n'
  //           '------------------------------------------------------',
  //           textAlign: TextAlign.center,
  //         ),
  //         actionsAlignment: MainAxisAlignment.center,
  //         actions: <Widget>[
  //           TextButton(
  //             style: TextButton.styleFrom(
  //                 textStyle: Theme.of(context).textTheme.labelLarge),
  //             child: const Text('Close'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Future<void> _errorDialogBuilder(BuildContext context, String errMsg) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(
            Icons.error_outline,
            size: 100,
            color: Colors.red,
          ),
          content: Text(
            'Transaction Failed\n'
            'Error Details\n'
            '${errMsg}\n'
            '------------------------------------------------------',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge),
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> _msgDialogBuilder(BuildContext context, String errMsg) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(
            Icons.info_outline,
            size: 100,
            color: Colors.lightBlue,
          ),
          content: Text(
            '${errMsg}\n'
            '------------------------------------------------------',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge),
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<Uint8List?> signTxPhone(PST pst, Tx tx) async {
    var signedPST = asset0!.coins[0].signPST(pst, tx, context);

    return signedPST;
  }

  Future<Uint8List?> signTxNFC(PST pst, Tx tx) async {
    var pstBytes = pst.getRawBytes();
    print("pstBytes: ${pstBytes.length}");
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
      return null;
    }

    Uint8List? signedBytes = await asset0!.signTx(pst, tx, context);

    return signedBytes;
  }
}
