import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tejory/crypto-helper/other_helpers.dart';
import 'package:tejory/singleton.dart';
import 'package:tejory/main.dart';
import 'package:tejory/ui/send.dart';
import 'network.dart';
import 'receive.dart';
import 'asset.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with RouteAware, TickerProviderStateMixin {
  late AnimationController controller;
  // late Future<Data> futureData;
  List<Asset> filteredAssets = [];
  TextEditingController searchController = TextEditingController();
  String balance = '0.00';

  String selectedToken = '';

  _HomePageState() {
    // Singleton.assetList = AssetList(
    //   humanizeMoney: OtherHelpers.humanizeMoney,
    //   searchController: searchController,
    // );
    Singleton.assetList.searchController = searchController;

    balance = OtherHelpers.humanizeMoney(
      0.0,
      isFiat: true,
      addFiatSymbol: false,
    );
  }

  Future<void> _refreshData() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      // balance;
      // _refreshBalance();
      // HomePage();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    try {
      routeObserver.unsubscribe(this);
      searchController.dispose();
    } catch (e) {
      //
    }

    super.dispose();
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // layoutComplete();
    });
    controller = BottomSheet.createAnimationController(this);
    controller.duration = Duration(seconds: 1);
    controller.reverseDuration = Duration(seconds: 1);
    controller.drive(CurveTween(curve: Curves.linear));
  }

  Future<void> _refreshBalance() async {
    if (Singleton.assetList.assetListState.assets.isEmpty) {
      return;
    }

    // for (int i = 0; i < Singleton.assetList.assetListState.assets.length; i++) {
    //   Singleton.assetList.assetListState.setAmount(
    //       Singleton.assetList.assetListState.assets[i]
    //           .getBalance(notify: false)
    //           .toInt(),
    //       i);
    // }

    balance = OtherHelpers.humanizeMoney(
      Singleton.assetList.assetListState.getTotalBalance(),
      isFiat: true,
      addFiatSymbol: false,
    );

    return;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Column(
        children: <Widget>[
          Center(
            child: GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _totalBalance(),
                  _balance(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25, top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[_sendBtn(), _receiveBtn()],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 15),
                    child: _searchBar(),
                  ),
                ],
              ),
            ),
          ),
          // _filter(),
          _tokenList(),
        ],
      ),
    );
  }

  Widget _totalBalance() {
    return Text(
      "Total Value",
      style: TextStyle(
        fontSize: 16,
        // fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _balance() {
    return ListenableBuilder(
      listenable: Singleton.assetList.assetListState,
      builder: (context, child) {
        return FutureBuilder(
          future: _refreshBalance(),
          builder: (context, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (Singleton.currentCurrency.symbolBeforeNumber)
                Text(
                  "${Singleton.currentCurrency.symbol} ",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Courier monospace",
                  ),
                ),

                Text(
                  (Singleton.assetList.assetListState.privacy) ? "****": balance,
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Courier monospace",
                  ),
                ),

                if (!Singleton.currentCurrency.symbolBeforeNumber)
                Text(
                  "${Singleton.currentCurrency.symbol} ",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Courier monospace",
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _sendBtn() {
    return SizedBox(
      width: 130,
      child: ElevatedButton(
        child: Text('Send', style: TextStyle(fontSize: 18)),
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();
          showModalBottomSheet(
            context: context,
            transitionAnimationController: controller,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return SingleChildScrollView(
                child: SizedBox(
                  height: 700,
                  child: Sender(networkList: networkList, address: ''),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _receiveBtn() {
    return SizedBox(
      width: 130,
      child: ElevatedButton(
        child: Text('Receive', style: TextStyle(fontSize: 18)),
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();
          showModalBottomSheet(
            context: context,
            transitionAnimationController: controller,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return SingleChildScrollView(
                child: SizedBox(
                  height: 700,
                  child: Receiver(
                    initialNetwork: '',
                    networkList: networkList,
                    address: '',
                    initialToken: '',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _searchBar() {
    return TextField(
      enableIMEPersonalizedLearning: false,
      controller: searchController,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary),
      decoration: InputDecoration(
        labelText: 'Search',
        prefixIcon: Icon(
          Icons.search,
          color: Theme.of(context).inputDecorationTheme.prefixIconColor,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        suffixIcon: _filter(),
      ),
    );
  }

  Widget _filter() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          PopupMenuButton<Asset>(
            icon: Icon(Icons.arrow_drop_down),
            onSelected: (Asset value) {
              setState(() {
                value.active = !value.active; // Set the selected token directly
                Singleton.assetList.assetListState.filterAssets();
              });
            },
            itemBuilder: (BuildContext context) {
              return [
                // PopupMenuItem<String>(
                //   value: "",
                //   child: Row(
                //     children: [
                //       Checkbox(
                //         value:
                //             selectedToken
                //                 .isEmpty, // Check if no token is selected
                //         onChanged: (bool? checked) {
                //           setState(() {
                //             if (checked != null && checked) {
                //               selectedToken = ""; // Clear selected token
                //             }
                //           });
                //         },
                //       ),
                //       Text(
                //         "",
                //         style: TextStyle(
                //           fontSize: 15,
                //           fontWeight: FontWeight.w900,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                ...Singleton.assetList.assetListState.assets
                    .map<PopupMenuItem<Asset>>((Asset asset) {
                      return PopupMenuItem<Asset>(
                        value: asset,
                        child: Text(
                          "${asset.symbol} (${asset.name})",
                          style: TextStyle(color: asset.active? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.tertiary)
                        ),
                      );
                    }),
              ];
            },
          ),
        ],
      ),
    );
  }

  Widget _tokenList() {
    // return ListenableBuilder(
    //   listenable: Singleton.assetList.assetListState,
    //   builder: (context, child) {
    //     return Expanded(child: Container(child: Singleton.assetList));
    //   },
    // );
    return Expanded(child: Container(child: Singleton.assetList));
  }
}
