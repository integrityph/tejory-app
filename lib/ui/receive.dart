// ignore_for_file: must_be_immutable
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tejory/crypto-helper/other_helpers.dart';
import 'package:tejory/singleton.dart';
import 'package:tejory/keypad/keypad.dart';
import 'package:tejory/ui/asset.dart';
import 'network.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Receiver extends StatefulWidget {
  String initialNetwork;
  final Map<String, Set<Network>> networkList;
  final String initialToken;
  final String address;
  Asset? asset;

  Receiver({
    required this.initialNetwork,
    required this.networkList,
    required this.initialToken,
    required this.address,
    this.asset,
  });

  @override
  _ReceiverState createState() => _ReceiverState();
}

class _ReceiverState extends State<Receiver> {
  String receivingAddress = '';
  late Network? selectedNetwork;
  late String selectedNetworkString;
  late String selectedToken;
  Asset? asset;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController amountFiatController = TextEditingController();
  Numpad numpad = Numpad();

  @override
  void initState() {
    super.initState();
    selectedNetworkString = widget.initialNetwork;
    selectedNetwork = Network(asset?.id ?? "", selectedNetworkString);
    selectedToken = widget.initialToken;
    asset = widget.asset;
    amountController.addListener(updateCryptoAmount);
    amountFiatController.addListener(updateFiatAmount);
  }

  void updateCryptoAmount() {
    if (asset?.priceUsd == null) {
      return;
    }
    var amountDouble = double.tryParse(amountController.text);
    if (amountDouble == null) {
      setFiatAmount("");
      return;
    }
    var fiatAmountDouble = asset!.priceUsd * amountDouble;
    setFiatAmount(OtherHelpers.humanizeMoney(fiatAmountDouble,
        isFiat: true, addFiatSymbol: false));
  }

  void updateFiatAmount() {
    if (asset?.priceUsd == null) {
      return;
    }
    var amountFiatDouble =
        double.tryParse(amountFiatController.text.replaceAll(',', ''));
    if (amountFiatDouble == null) {
      setCryptoAmount("");
      return;
    }
    var amountDouble = amountFiatDouble /
        asset!.priceUsd /
        Singleton.currentCurrency.usdMultiplier;
    setCryptoAmount(asset!.getDecimalAmountFromDouble(amountDouble));
  }

  void setCryptoAmount(String v) {
    amountController.removeListener(updateCryptoAmount);
    amountController.text = v;
    amountController.addListener(updateCryptoAmount);
  }

  void setFiatAmount(String v) {
    amountFiatController.removeListener(updateFiatAmount);
    amountFiatController.text = v;
    amountFiatController.addListener(updateFiatAmount);
  }

  void copyText(BuildContext context) {
    Clipboard.setData(ClipboardData(text: receivingAddress));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Address copied to clipboard!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool showQRCode = receivingAddress.isNotEmpty;
    return Stack(
      children: [
        Column(
          children: [
            _indicator(),
            _receiveToken(),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10),
              child: Column(
                children: [
                  _dropdownToken(),
                  _dropdownNetwork(),
                  if (selectedNetwork?.requiresAmount ?? false) _enterAmount(),
                  if (selectedNetwork?.requiresAmount ?? false)
                    _enterAmountFiat(),
                  if (showQRCode) ...[_qrCode(), _copy()],
                ],
              ),
            )
          ],
        ),
        numpad,
      ],
    );
  }

  Widget _indicator() {
    return Container(
        width: 200, height: 5, decoration: BoxDecoration(color: Colors.blue));
  }

  Widget _receiveToken() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            'Receive Crypto',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
          ),
        ),
      ],
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
              onEditingComplete: setReceivingAddress,
              onTapOutside: (Platform.operatingSystem == "ios")
                  ? null
                  : setReceivingAddress,
              enableIMEPersonalizedLearning: false,
              onTap: (Platform.operatingSystem == "ios")
                  ? () {
                      numpad.state.openKeyboard(amountController,
                          onEditingComplete: setReceivingAddress);
                    }
                  : null,
              keyboardType: (Platform.operatingSystem == "ios")
                  ? TextInputType.none
                  : TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^[0-9\]+[\.0-9]*')),
              ],
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                labelText: 'Enter Amount',
                labelStyle:
                    TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          SizedBox(
            width: 55,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Text(
                ' ${asset?.symbol ?? ""}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
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
              onEditingComplete: setReceivingAddress,
              onTapOutside: (Platform.operatingSystem == "ios")
                  ? null
                  : setReceivingAddress,
              enableIMEPersonalizedLearning: false,
              onTap: (Platform.operatingSystem == "ios")
                  ? () {
                      numpad.state.openKeyboard(amountFiatController,
                          onEditingComplete: setReceivingAddress);
                    }
                  : null,
              keyboardType: (Platform.operatingSystem == "ios")
                  ? TextInputType.none
                  : TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^[0-9\]+[\.0-9]*')),
              ],
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                labelText: 'Enter Amount',
                labelStyle:
                    TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Text(
                ' ${Singleton.currentCurrency.isoName}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void setReceivingAddress([dynamic val = null]) async {
    if ((selectedNetwork?.requiresAmount ?? false) &&
        amountController.text == "") {
      receivingAddress = "";
      return;
    }
    if (selectedToken.isEmpty || selectedNetworkString.isEmpty) {
      receivingAddress = "";
      return;
    }

    var amountDouble = double.tryParse(amountController.text);
    var tempAddress = await asset?.getReceivingAddress(
            network: selectedNetworkString,
            amount: asset?.getBaseAmount(amountDouble ?? 0)) ??
        '';
    setState(() {
      receivingAddress = tempAddress;
    });
    FocusManager.instance.primaryFocus?.unfocus();
    numpad.state.setVisible(false);
  }

  Widget _dropdownToken() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Center(
        child: SizedBox(
          child: DropdownButton<String>(
            value: selectedToken,
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down),
            underline: Container(
              height: 0.5,
            ),
            onChanged: (String? value) {
              setState(() {
                if (value == null || value == "") {
                  selectedToken = "";
                  asset = null;
                  return;
                }
                selectedToken = value;
                asset =
                    Singleton.assetList.assetListState.findAsset(selectedToken);

                // TODO: this is not correct. A network should have the asset id to check
                if (selectedNetwork?.networkName != asset?.id) {
                  selectedNetwork = Network("", "");
                  selectedNetworkString = "";
                }
                setReceivingAddress("");
              });
            },
            items: () {
              List<DropdownMenuItem<String>> x = Singleton
                  .assetList.assetListState.filteredAssets
                  .map<DropdownMenuItem<String>>((Asset _asset) {
                return DropdownMenuItem<String>(
                    value: _asset.id,
                    child: Text("${_asset.symbol} (${_asset.name})"));
              }).toList();
              x.insert(
                  0,
                  DropdownMenuItem<String>(
                      value: "",
                      child: Text(
                        "Select Token",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w900),
                      )));
              return x;
            }(),
          ),
        ),
      ),
    );
  }

  Widget _dropdownNetwork() {
    return Center(
      child: SizedBox(
        child: DropdownButton<Network>(
          value: selectedNetwork,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down),
          underline: Container(
            height: 0.5,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black54,
          ),
          onChanged: (Network? value) {
            setState(() {
              selectedNetwork = value ?? Network(asset?.symbol ?? "", "");
              selectedNetworkString = selectedNetwork?.networkSymbol ?? "";
              setReceivingAddress("");
            });
          },
          items: () {
            List<DropdownMenuItem<Network>> x = widget
                .networkList[asset?.symbol ?? ""]!
                .map<DropdownMenuItem<Network>>((Network network) {
              return DropdownMenuItem<Network>(
                value: network,
                child: Text("${network.networkName}"),
              );
            }).toList();
            x.insert(
                0,
                DropdownMenuItem<Network>(
                    value: Network("", ""),
                    child: Text("Select Network",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w900))));
            return x;
          }(),
        ),
      ),
    );
  }

  Widget _qrCode() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        child: QrImageView(
          backgroundColor: Theme.of(context).colorScheme.surface,
          eyeStyle: QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Theme.of(context).colorScheme.primary),
          dataModuleStyle: QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Theme.of(context).colorScheme.primary),
          data: receivingAddress,
          version: QrVersions.auto,
          size: 250,
          gapless: false,
        ),
      ),
    );
  }

  Widget _copy() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('     '),
        Expanded(
          child: Text(
            receivingAddress,
            style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 10.0),
          child: IconButton(
            icon: Icon(Icons.copy),
            onPressed: () => copyText(context),
            tooltip: 'Copy to clipboard',
          ),
        ),
      ],
    );
  }
}
