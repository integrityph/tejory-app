import 'dart:io';
import 'dart:math';
import 'package:blockchain_utils/hex/hex.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tejory/coins/tx.dart';
import 'package:tejory/collections/tx.dart';
import 'package:tejory/collections/walletDB.dart';
import 'package:tejory/comms/nfc.dart';
import 'package:tejory/crypto-helper/other_helpers.dart';
import 'package:tejory/singleton.dart';
import 'package:tejory/keypad/keypad.dart';
import 'package:tejory/ui/asset.dart';
import 'package:tejory/ui/qrscanner.dart';
import 'package:tejory/coins/pst.dart';
import 'package:url_launcher/url_launcher.dart';
import 'network.dart';

class Sender extends StatefulWidget {
  final String? network;
  final Map<String, Set<Network>> networkList;
  final Asset? asset;
  final String address;
  final bool sendMax = false;

  Sender({
    required this.networkList,
    required this.address,
    this.network,
    this.asset = null,
  });

  @override
  _SenderState createState() => _SenderState();
}

class _SenderState extends State<Sender> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController amountFiatController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String selectedToken = '';
  String selectedNetwork = '';
  Network? selectedNetworkObj = null;
  String feeAmountDouble = '';
  String feeAmountFiatDouble = '';
  String amountDouble = '';
  BigInt balance = BigInt.zero;
  String balanceStr = '';
  String balanceFiatStr = '';
  String symbol = '';
  String totalAmountDouble = '';
  BigInt sendAmount = BigInt.zero;
  BigInt sendFee = BigInt.zero;
  String sendDialogMessage = "";
  final String msgSigning =
      "NFC Signing Transaction. Put your phone on the hardware wallet";
  final String msgSending = "Sending Transaction to the network";
  Asset? asset;
  String address = "";
  bool _isMax = false;
  NFC nfc = NFC();
  Numpad numpad = Numpad();

  @override
  void initState() {
    super.initState();
    amountController.addListener(updateAmounts);
    amountFiatController.addListener(updateFiatAmounts);
    addressController.text = address;
    asset = widget.asset;
    selectedToken = asset?.id ?? "";
    selectedNetwork = widget.network ?? "";
    selectedNetworkObj = null; // TODO: find the selected network
    balance = asset?.getBalance() ?? BigInt.zero;
    balanceStr = asset?.getDecimalAmount(balance) ?? "0.00000000";
    balanceFiatStr = OtherHelpers.humanizeMoney(
      (asset?.getDecimalAmountInDouble(balance) ?? 0.0) *
          (asset?.priceUsd ?? 0.0),
      isFiat: true,
      addFiatSymbol: false,
    );
    amountDouble = OtherHelpers.humanizeMoney(0.0);
    feeAmountDouble = OtherHelpers.humanizeMoney(0.0);
    feeAmountFiatDouble = OtherHelpers.humanizeMoney(0.0, isFiat: true);
    totalAmountDouble = OtherHelpers.humanizeMoney(0.0);
  }

  void processAddress() {
    if (!addressController.text.startsWith("lnbc")) {
      if (selectedNetwork == "BTC_LIGHTNING") {
        setState(() {
          selectedToken = "";
          asset = null;
          selectedNetworkObj = null;
          selectedNetwork = "";

          balance = BigInt.zero;
          balanceStr = "";
          balanceFiatStr = "";
          symbol = "";

          amountController.text = "";
          amountFiatController.text = "";

          amountDouble = OtherHelpers.humanizeMoney(0.0);
          feeAmountDouble = OtherHelpers.humanizeMoney(0.0);
          feeAmountFiatDouble = OtherHelpers.humanizeMoney(0.0, isFiat: true);
          totalAmountDouble = OtherHelpers.humanizeMoney(0.0);
        });
      }
      return;
    }
    var BTCLN = Singleton.assetList.assetListState.findAsset("BTCLN");
    var amount = BTCLN!.getAmountFromAddress(addressController.text);
    if (amount == null) {
      if (selectedNetwork == "BTC_LIGHTNING") {
        setState(() {
          selectedToken = "";
          asset = null;
          selectedNetworkObj = null;
          selectedNetwork = "";

          balance = BigInt.zero;
          balanceStr = "";
          balanceFiatStr = "";
          symbol = "";

          amountController.text = "";
          amountFiatController.text = "";

          amountDouble = OtherHelpers.humanizeMoney(0.0);
          feeAmountDouble = OtherHelpers.humanizeMoney(0.0);
          feeAmountFiatDouble = OtherHelpers.humanizeMoney(0.0, isFiat: true);
          totalAmountDouble = OtherHelpers.humanizeMoney(0.0);
        });
      }
      return;
    }

    setState(() {
      selectedToken = BTCLN.id;
      asset = BTCLN;
      selectedNetworkObj = networkList["BTCLN"]!.firstWhere((net) {
        return net.networkSymbol == "BTC_LIGHTNING";
      });
      selectedNetwork = selectedNetworkObj!.networkSymbol;

      balance = asset!.getBalance();
      balanceStr = asset?.getDecimalAmount(balance) ?? "0.00000000";
      balanceFiatStr = OtherHelpers.humanizeMoney(
        (asset?.getDecimalAmountInDouble(balance) ?? 0.0) *
            (asset?.priceUsd ?? 0.0),
        isFiat: true,
        addFiatSymbol: false,
      );
      symbol = asset!.symbol;
      var cryptoAmount = asset!.getDecimalAmount(amount);
      amountController.text = cryptoAmount;
      FocusManager.instance.primaryFocus?.unfocus();

      () async {
        var fee = await asset!.calculateFee(addressController.text, amount);
        var feeDouble = asset!.getDecimalAmountInDouble(fee);
        var amountDouble = asset!.getDecimalAmountInDouble(amount);

        setState(() {
          feeAmountDouble = OtherHelpers.humanizeMoney(feeDouble);
          feeAmountFiatDouble = OtherHelpers.humanizeMoney(
            feeDouble * asset!.priceUsd,
            isFiat: true,
          );
          totalAmountDouble = OtherHelpers.humanizeMoney(
            amountDouble + feeDouble,
          );
        });
      }();
    });
  }

  void updateFiatAmounts() {
    double amount = 0.0;
    try {
      amount = double.parse(amountFiatController.text.replaceAll(",", ""));
      amount /= asset!.priceUsd * Singleton.currentCurrency.usdMultiplier;
      amountController.removeListener(updateAmounts);
      amountController.text = asset!.getDecimalAmount(
        asset!.getBaseAmount(amount),
      );
      amountController.addListener(updateAmounts);
    } catch (e) {
      // TODO; show some error
      sendAmount = asset?.getBaseAmount(amount) ?? BigInt.zero;
      amountDouble = asset?.getDecimalAmount(sendAmount) ?? "0.00000000";
      sendFee = BigInt.zero;
      feeAmountDouble = "0.00000000";
      feeAmountFiatDouble = "0.00000000";
      BigInt total = sendFee + sendAmount;
      totalAmountDouble = asset?.getDecimalAmount(total) ?? "0.00000000";
    }
    updateAmounts(updateFiat: false);
  }

  void updateAmounts({bool updateFiat = true}) async {
    var amountStr = amountController.text;
    double amount = 0.0;
    print("selectedToken: $selectedToken");
    asset = Singleton.assetList.assetListState.findAsset(selectedToken);
    if (asset == null) {
      return;
    }
    String feeSymbol = asset!.getFeeSymbol();
    Asset? feeAsset = Singleton.assetList.assetListState.findAsset(feeSymbol);
    try {
      amount = double.parse(amountStr);
      sendAmount = asset!.getBaseAmount(amount);
      sendFee = await asset!.calculateFee(
        addressController.text,
        sendAmount,
        noChange: _isMax,
      );
      amountDouble = asset!.getDecimalAmount(sendAmount);
      feeAmountDouble = feeAsset!.getDecimalAmount(sendFee);
      feeAmountFiatDouble = OtherHelpers.humanizeMoney(
        feeAsset.getDecimalAmountInDouble(sendFee) * feeAsset.priceUsd,
        isFiat: true,
      );

      BigInt total = sendAmount;
      if (feeSymbol == asset!.symbol) {
        total += sendFee;
      }
      print(
        "sendFee: $sendFee,  sendAmount: $sendAmount, total: $total,  balance: $balance, _isMax: $_isMax",
      );
      if (total > balance) {
        _isMax = true;
        amountStr = balanceStr;
        amount = double.parse(amountStr);
        sendAmount = asset!.getBaseAmount(amount);
        sendFee = await asset!.calculateFee(
          addressController.text,
          sendAmount,
          noChange: _isMax,
        );
        if (feeSymbol == asset!.symbol) {
          sendAmount -= sendFee;
        }
        amountDouble = asset!.getDecimalAmount(sendAmount);
        feeAmountDouble = feeAsset.getDecimalAmount(sendFee);
        feeAmountFiatDouble = OtherHelpers.humanizeMoney(
          feeAsset.getDecimalAmountInDouble(sendFee) * feeAsset.priceUsd,
          isFiat: true,
        );
        total = sendAmount;
        if (feeSymbol == asset!.symbol) {
          total += sendFee;
        }
        amountController.removeListener(updateAmounts);
        amountController.text = amountDouble;
        amountController.addListener(updateAmounts);
      } else if (total < balance) {
        _isMax = false;
      }
      if (updateFiat) {
        amountFiatController.removeListener(updateFiatAmounts);
        amountFiatController.text = OtherHelpers.humanizeMoney(
          amount * asset!.priceUsd,
          isFiat: true,
          addFiatSymbol: false,
        );
        amountFiatController.addListener(updateFiatAmounts);
      } else {
        if (_isMax) {
          amountFiatController.removeListener(updateFiatAmounts);
          amountFiatController.text = OtherHelpers.humanizeMoney(
            amount * asset!.priceUsd,
            isFiat: true,
            addFiatSymbol: false,
          );
          amountFiatController.addListener(updateFiatAmounts);
        }
      }
      totalAmountDouble = asset!.getDecimalAmount(total);

      setState(() {
        amountDouble = amountDouble;
        feeAmountDouble = feeAmountDouble;
        feeAmountFiatDouble = feeAmountFiatDouble;
        totalAmountDouble = totalAmountDouble;
      });
    } catch (e) {
      // TODO; show some error
      setState(() {
        sendAmount = asset?.getBaseAmount(amount) ?? BigInt.zero;
        amountDouble = asset?.getDecimalAmount(sendAmount) ?? "0.00000000";
        sendFee = BigInt.zero;
        feeAmountDouble = feeAsset?.getDecimalAmount(sendFee) ?? "0.00000000";
        feeAmountFiatDouble = OtherHelpers.humanizeMoney(
          (feeAsset?.getDecimalAmountInDouble(sendFee) ?? 0.0) *
              (feeAsset?.priceUsd ?? 0.0),
          isFiat: true,
        );
        BigInt total = sendFee + sendAmount;
        totalAmountDouble = asset?.getDecimalAmount(total) ?? "0.00000000";
      });
    }
  }

  handleTokenChange(String? value) {
    setState(() {
      selectedNetwork = "";
      selectedNetworkObj = null;
      selectedToken = value!;
      // set asset
      asset = Singleton.assetList.assetListState.findAsset(selectedToken);
      print("asset: ${asset?.symbol ?? "UNKNOWN"}");

      balance = asset!.getBalance();
      balanceStr = asset?.getDecimalAmount(balance) ?? "0.00000000";
      balanceFiatStr = OtherHelpers.humanizeMoney(
        (asset?.getDecimalAmountInDouble(balance) ?? 0.0) *
            (asset?.priceUsd ?? 0.0),
        isFiat: true,
        addFiatSymbol: false,
      );
      symbol = asset!.symbol;

      amountDouble = OtherHelpers.humanizeMoney(0.0);
      feeAmountDouble = OtherHelpers.humanizeMoney(0.0);
      feeAmountFiatDouble = OtherHelpers.humanizeMoney(0.0, isFiat: true);
      totalAmountDouble = OtherHelpers.humanizeMoney(0.0);
      amountController.removeListener(updateAmounts);
      amountController.text = "";
      amountController.addListener(updateAmounts);
      amountFiatController.removeListener(updateFiatAmounts);
      amountFiatController.text = "";
      amountFiatController.addListener(updateFiatAmounts);
    });
  }

  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            numpad.state.setVisible(false);
          },
          child: Column(
            children: [
              _dropIndicator(),
              _sendToken(),
              Padding(
                padding: const EdgeInsets.only(top: 5.0, left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _address(),
                    _dropdownSelectToken(),
                    _selectNetwork(),
                    _enterAmount(),
                    _availableBalance(),
                    _enterAmountFiat(),
                    _availableBalanceFiat(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: _estimatedFee(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [_cancelButton(), _sendButton()],
                ),
              ),
            ],
          ),
        ),
        numpad,
      ],
    );
  }

  Widget _dropIndicator() {
    return Container(
      width: 200,
      height: 5,
      decoration: BoxDecoration(color: Colors.blue),
    );
  }

  Widget _sendToken() {
    return Padding(
      padding: EdgeInsets.only(top: 10.0, bottom: 0),
      child: Text(
        'Send Crypto',
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _dropdownSelectToken() {
    return DropdownButton<String>(
      value: selectedToken,
      isExpanded: true,
      icon: Icon(Icons.arrow_drop_down),
      underline: Container(
        height: 0.5,
        color:
            Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black54,
      ),
      onChanged:
          (selectedNetworkObj?.requiresAmount ?? false)
              ? null
              : handleTokenChange,
      items: () {
        List<DropdownMenuItem<String>> x =
            Singleton.assetList.assetListState.filteredAssets
                .map<DropdownMenuItem<String>>((Asset _asset) {
                  return DropdownMenuItem<String>(
                    value: _asset.id,
                    child: Text("${_asset.symbol} (${_asset.name})"),
                  );
                })
                .toList();
        x.insert(
          0,
          DropdownMenuItem<String>(
            value: "",
            child: Text(
              "Select Token",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
          ),
        );
        return x;
      }(),
    );
  }

  Widget _enterAmount() {
    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: amountController,
              enabled: !(selectedNetworkObj?.requiresAmount ?? false),
              enableIMEPersonalizedLearning: false,
              enableInteractiveSelection: false,
              onTap:
                  (Platform.operatingSystem == "ios")
                      ? () {
                        numpad.state.openKeyboard(amountController);
                      }
                      : null,
              keyboardType:
                  (Platform.operatingSystem == "ios")
                      ? TextInputType.none
                      : TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^[0-9\]+[\.0-9]*')),
              ],
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                labelText: 'Enter Amount',
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Text(
                ' ${asset?.symbol ?? ""}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          SizedBox(width: 10),
          SizedBox(
            width: 48,
            child: TextButton(
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: EdgeInsets.all(7),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed:
                  (selectedNetworkObj?.requiresAmount ?? false)
                      ? null
                      : () {
                        amountController.removeListener(updateAmounts);
                        amountController.text = balanceStr;
                        amountController.addListener(updateAmounts);
                        _isMax = true;
                        updateAmounts();
                      },
              child: Text(
                "Max",
                style: TextStyle(
                  color:
                      !(selectedNetworkObj?.requiresAmount ?? false)
                          ? Colors.blueAccent
                          : Colors.grey,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _enterAmountFiat() {
    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: amountFiatController,
              enabled: !(selectedNetworkObj?.requiresAmount ?? false),
              enableIMEPersonalizedLearning: false,
              enableInteractiveSelection: false,
              onTap:
                  (Platform.operatingSystem == "ios")
                      ? () {
                        numpad.state.openKeyboard(amountFiatController);
                      }
                      : null,
              keyboardType:
                  (Platform.operatingSystem == "ios")
                      ? TextInputType.none
                      : TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^[0-9\]+[\.0-9]*')),
              ],
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                labelText: 'Enter Amount',
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Text(
                ' ${Singleton.currentCurrency.isoName}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          SizedBox(width: 10),
          SizedBox(
            width: 48,
            child: TextButton(
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: EdgeInsets.all(7),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed:
                  (selectedNetworkObj?.requiresAmount ?? false)
                      ? null
                      : () {
                        amountFiatController.removeListener(updateFiatAmounts);
                        amountFiatController.text = balanceFiatStr;
                        amountFiatController.addListener(updateFiatAmounts);
                        _isMax = true;
                        updateFiatAmounts();
                      },
              child: Text(
                "Max",
                style: TextStyle(
                  color:
                      !(selectedNetworkObj?.requiresAmount ?? false)
                          ? Colors.blueAccent
                          : Colors.grey,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _availableBalance() {
    return Padding(
      padding: EdgeInsets.only(right: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text("Available Balance: "),
          Text(balanceStr, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(' ${asset?.symbol ?? ""}'),
        ],
      ),
    );
  }

  Widget _availableBalanceFiat() {
    return Padding(
      padding: EdgeInsets.only(right: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text("Available Balance: "),
          Text(balanceFiatStr, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(' ${Singleton.currentCurrency.isoName}'),
        ],
      ),
    );
  }

  Widget _selectNetwork() {
    return DropdownButton<String>(
      value: selectedNetwork,
      isExpanded: true,
      icon: Icon(Icons.arrow_drop_down),
      underline: Container(
        height: 0.5,
        color:
            Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black54,
      ),
      onChanged:
          (selectedNetworkObj?.requiresAmount ?? false)
              ? null
              : (String? value) {
                setState(() {
                  selectedNetwork = value ?? "";
                  selectedNetworkObj = networkList[selectedToken]?.firstWhere((
                    net,
                  ) {
                    return net.networkSymbol == selectedNetwork;
                  });
                });
              },
      items: () {
        List<DropdownMenuItem<String>> x =
            widget.networkList[asset?.symbol ?? ""]!
                .map<DropdownMenuItem<String>>((Network network) {
                  return DropdownMenuItem<String>(
                    value: network.networkSymbol,
                    child: Text(network.networkName),
                  );
                })
                .toList();
        x.insert(
          0,
          DropdownMenuItem<String>(
            value: "",
            child: Text(
              "Select Network",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
            ),
          ),
        );
        return x;
      }(),
    );
  }

  Widget _address() {
    return Center(
      child: SizedBox(
        child: TextField(
          enableIMEPersonalizedLearning: false,
          controller: addressController,
          textInputAction: TextInputAction.done,
          onEditingComplete: processAddress,
          minLines: 1,
          maxLines: 9,
          style: TextStyle(fontSize: 12),
          decoration: InputDecoration(
            labelText: 'Address',
            labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            suffixIcon: IconButton(
              icon: Icon(Icons.center_focus_weak),
              onPressed: () {
                var result = Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => Qrscanner()));

                result.then((val) {
                  if (val == null) {
                    return;
                  }
                  if (val is String) {
                    addressController.text = val;
                    processAddress();
                  }
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _estimatedFee() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.transparent,
          style: BorderStyle.solid,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 10.0, right: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Estimated Fee:'),
                Text('${feeAmountDouble} ${asset?.getFeeSymbol() ?? ""}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Estimated Fee (${Singleton.currentCurrency.isoName}):'),
                Text(feeAmountFiatDouble),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('Estimated time: '), Text('10 - 60 minutes')],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Amount:'),
                Text('$totalAmountDouble ${asset?.symbol ?? ""}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cancelButton() {
    return ElevatedButton(
      child: Text('Cancel', style: TextStyle(color: Colors.red)),
      onPressed: () => Navigator.pop(context),
    );
  }

  void copyText(BuildContext _context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text('Tx Hash copied to clipboard!'),
    //   ),
    // );
  }

  urlOpen(String URL) {
    final Uri url = Uri.parse(URL);
    launchUrl(url);
  }

  Widget _sendButton() {
    return ElevatedButton(
      child: Text('Send', style: TextStyle(color: Colors.blue)),
      onPressed: () async {
        asset = Singleton.assetList.assetListState.findAsset(selectedToken);
        if (asset == null) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(content: Text('Select a Token'));
            },
          );
          return null;
        }

        if (amountController.text == "0" || amountController.text == "") {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(content: Text('Input a number'));
            },
          );
          return;
        }

        if (!asset!.isValidAddress(addressController.text)) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(content: Text('Input a valid address'));
            },
          );
          return;
        }

        String address = addressController.text;
        // Uint8List addressBytes = asset!.getAddressBytes(address);
        var amountStr = amountController.text;
        var amount = double.parse(amountStr);
        Tx? tx = await asset!.makeTransaction(
          address,
          asset!.getBaseAmount(amount),
          noChange: _isMax,
        );
        if (tx == null) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text('Unable to generate transaction'),
              );
            },
          );
          return;
        }
        print('RawTX: ${hex.encode(tx.getRawTX())}');

        Uint8List? signedBytes;
        PST pst = asset!.makePST(tx);
        String? ErrorMsg;
        try {
          if (asset!.getWalletType() == WalletType.tejoryCard) {
            signedBytes = await signTxNFC(pst, tx);
          } else {
            signedBytes = await signTxPhone(pst, tx);
          }
        } catch (e) {
          ErrorMsg = e.toString().replaceFirst("Exception: ", "");
        }

        if (signedBytes == null) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                icon: Icon(Icons.error_outline, color: Colors.red, size: 36),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 5,
                  children: [
                    Text(
                      "Transaction Failed",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${ErrorMsg == null ? "Unknown error in signing transaction" : ErrorMsg}',
                    ),
                  ],
                ),
              );
            },
          );
          return;
        }

        print('Signed TX: ${hex.encode(signedBytes)}');

        // asset = Singleton.assetList.assetListState.findAsset(selectedToken);
        // asset!.transmitTxBytes(signedBytes);

        Tx signedTx = tx.fromTxBytes(signedBytes);
        var txHash = signedTx.getHashHex();
        // asset!.storeTransaction(tx, pst:pst, verfied: false, confirmed: false);

        Navigator.of(context).pop();

        var URL = asset!.getTrackingURL(txHash);

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        'Transaction Sent Successfully',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 46,
                      ),
                    ),
                  ),
                  Text(
                    "Recipient:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    addressController.text,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                    // overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Amount:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${amountController.text} ${asset!.symbol}",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  Text(
                    "${amountFiatController.text} ${Singleton.currentCurrency.isoName}",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Tx Hash:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    txHash,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                    // overflow: TextOverflow.ellipsis,
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: IconButton(
                        icon: Icon(Icons.copy),
                        onPressed: () => copyText(context, txHash),
                        tooltip: 'Copy to clipboard',
                      ),
                    ),
                  ),
                  (URL != "")
                      ? Center(
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              Colors.blue,
                            ),
                          ),
                          onPressed: () {
                            urlOpen(URL);
                          },
                          child: Text(
                            "Track Transaction",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                      : Container(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<Uint8List?> signTxPhone(PST pst, Tx tx) async {
    var signedPST = asset!.coins[0].signPST(pst, tx, context);

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
              'NFC is disabled. Please enable it to sign the transaction',
            ),
          );
        },
      );
      return null;
    }

    Uint8List? signedBytes = await asset!.signTx(pst, tx, context);

    return signedBytes;
  }
}
