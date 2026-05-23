import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tejory/coins/visual_tx.dart';
import 'package:tejory/crypto-helper/other_helpers.dart';
import 'package:tejory/box_models.g.dart';
import 'package:tejory/objectbox.g.dart';
import 'package:tejory/singleton.dart';
import 'package:tejory/ui/receive.dart';
import 'package:tejory/ui/send.dart';
import 'package:url_launcher/url_launcher.dart';
import 'asset.dart';
import 'package:tejory/coindesk/api.dart' as coindesk;

class TokenDetails extends StatefulWidget {
  final Asset asset;

  TokenDetails({required this.asset});

  @override
  _TokenDetails createState() => _TokenDetails();
}

class _TokenDetails extends State<TokenDetails> with TickerProviderStateMixin {
  late Asset asset = widget.asset;
  List<Map<String, dynamic>>? chartData;
  int assetIndex = 0;
  late AnimationController controller;
  bool dismissCustodialMessage = Singleton.dismissCustodialMessage;

  @override
  void initState() {
    super.initState();

    controller = BottomSheet.createAnimationController(this);
    controller.duration = Duration(seconds: 1);
    controller.reverseDuration = Duration(seconds: 1);
    controller.drive(CurveTween(curve: Curves.linear));
  }

  Future<List<VisualTx>> getTxDbList() async {
    var txDBList = await Models.txDB.find(q: TxDB_.coin.equals(asset.coinId!));

    if (txDBList == null) {
      return [];
    }

    List<VisualTx> vTxList = asset.getVisualTxList(txDBList);

    vTxList.sort((a, b) {
      int val = a.time!.isAfter(b.time!) ? -1 : 1;
      return val;
    });

    return vTxList;
  }

  Widget getTxItem(VisualTx tx) {
    final rawText = (tx.outAddress != "") ? tx.outAddress : tx.inAddress;
    
    final parts = rawText.split('\n');
    final address = parts[0];
    final memo = parts.length > 1 ? parts[1] : null;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          tx.isDeposit
                              ? Icons.arrow_circle_down
                              : Icons.arrow_circle_up,
                          color: tx.isDeposit ? Colors.green : Colors.red,
                        ),
                        SizedBox(width: 2),
                        Text(
                          '${tx.isDeposit ? "Received" : "Sent"}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          DateFormat("hh:mm a").format(tx.time!),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),

                    // Text(
                    //   "${tx.getFiatRate(asset)}",
                    //   style: TextStyle(
                    //     fontSize: 12,
                    //     fontWeight: FontWeight.normal,
                    //   ),
                    // ),
                    // Text(
                    //   "${tx.time!.year.toString()}-${tx.time!.month.toString().padLeft(2, '0')}-${tx.time!.day.toString().padLeft(2, '0')} ${tx.time!.hour.toString().padLeft(2, '0')}:${tx.time!.minute.toString().padLeft(2, '0')}",
                    //   style: TextStyle(
                    //     fontSize: 12,
                    //     fontWeight: FontWeight.normal,
                    //   ),
                    // ),
                    Row(
                      children: [
                        SizedBox(width: 27),
                        Text(
                          DateFormat("MMM d, yyyy").format(tx.time!),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(width: 27),
                        Text(
                          "Fee: ${(asset.getDecimalAmountInDouble(BigInt.from(tx.fee))).toStringAsFixed(8)}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${tx.isDeposit ? "+" : "-"}${(asset.getDecimalAmountInDouble(BigInt.from((tx.amount > 0 ? tx.amount : -tx.amount)))).toStringAsFixed(8)}",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: "monospace",
                        color: tx.isDeposit ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      "${tx.getFiatValue(asset)}",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: "monospace",
                        color: tx.isDeposit ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (tx.outAddress != "" || tx.inAddress != "")
              FittedBox(
                fit: BoxFit.contain, // This tells it to scale down to fit
                child: Text(
                  "$address",
                  style: TextStyle(
                    fontFamily: 'monospace',
                  ), // No need for a font size!
                  maxLines: 1,
                ),
              ),
              if (memo != null) FittedBox(
                fit: BoxFit.contain, // This tells it to scale down to fit
                child: Text(
                  "$memo",
                  style: TextStyle(
                    fontFamily: 'monospace',
                  ), // No need for a font size!
                  maxLines: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }

  urlOpen(String URL) {
    final Uri url = Uri.parse(URL);
    launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data:
          Theme.of(context).brightness == Brightness.dark
              ? Singleton.getDarkTheme()
              : Singleton.getBrightTheme(),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              SizedBox(height: 24, child: asset.getIcon()),
              SizedBox(width: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${asset.name}', style: TextStyle(fontSize: 20)),
                  Text(
                    ' ${asset.symbol}',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: "monospace",
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: CustomScrollView(
          slivers: [
            ListenableBuilder(
              listenable: Singleton.assetList.assetListState.assets[assetIndex],
              builder: (context, w) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "${(asset.lastChange >= 0) ? "▲" : "▼"}${OtherHelpers.humanizeMoney(asset.priceUsd, isFiat: true, addFiatSymbol: true)}",
                              style: TextStyle(
                                fontSize: 24,
                                color:
                                    (asset.lastChange >= 0)
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        if (asset.coins[0].isCustodial() &&
                            !dismissCustodialMessage)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "🏦",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      Expanded(
                                        child: Text(
                                          asset.coins[0].custodialMessage()!,
                                          style: TextStyle(fontSize: 14),
                                          maxLines: 3,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    spacing: 8,
                                    children: [
                                      if (asset.coins[0]
                                              .custodialMessageLink() !=
                                          null)
                                        ElevatedButton(
                                          child: Text(
                                            "Learn More",
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          onPressed: () {
                                            urlOpen(
                                              asset.coins[0]
                                                  .custodialMessageLink()!,
                                            );
                                          },
                                        ),
                                      ElevatedButton(
                                        child: Text(
                                          "Dismiss",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        onPressed: () {
                                          Singleton.setDismissCustodialMessage(
                                            true,
                                          );
                                          setState(() {
                                            dismissCustodialMessage = true;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            FutureBuilder(
              future: coindesk.getChartData(asset.yahooFinance),
              builder: (context, data) {
                if (data.data != null) {
                  return () {
                    if (data.data!.length == 0) {
                      return SliverToBoxAdapter(
                        child: Text("Error loading chart data"),
                      );
                    }
                    chartData = data.data;
                    double minY = chartData![0]["close"];
                    double maxY = chartData![0]["close"];
                    for (final (_, v) in chartData!.indexed) {
                      if (v["close"] == null) {
                        continue;
                      }
                      minY = (v["close"]! < minY) ? v["close"] : minY;
                      maxY = (v["close"]! > maxY) ? v["close"] : maxY;
                    }
                    minY *= Singleton.currentCurrency.usdMultiplier;
                    maxY *= Singleton.currentCurrency.usdMultiplier;
                    minY -= minY * 0.05;
                    maxY += maxY * 0.05;

                    return SliverToBoxAdapter(
                      child: SizedBox(
                        height: 200,
                        child: SfCartesianChart(
                          primaryXAxis: DateTimeAxis(
                            dateFormat: DateFormat.MMMd(),
                            intervalType: DateTimeIntervalType.days,
                            maximumLabels: 5,
                          ),
                          primaryYAxis: NumericAxis(
                            maximum: maxY,
                            minimum: minY,
                            numberFormat: NumberFormat.compactCurrency(
                              symbol: Singleton.currentCurrency.symbol,
                            ),
                          ),
                          series: <CartesianSeries>[
                            // Renders line chart
                            LineSeries<Map<String, dynamic>, DateTime>(
                              color:
                                  (chartData!.first["close"] <=
                                          chartData!.last["close"])
                                      ? Colors.green
                                      : Colors.red,
                              dataSource: data.data,
                              xValueMapper:
                                  (Map<String, dynamic> point, _) =>
                                      point["date"],
                              yValueMapper:
                                  (Map<String, dynamic> point, _) =>
                                      point["close"] *
                                      Singleton.currentCurrency.usdMultiplier,
                            ),
                          ],
                        ),
                      ),
                    );
                  }();
                }
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              },
            ),
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 5.0, left: 5.0),
                    child: ElevatedButton(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 8.0,
                          bottom: 8.0,
                          right: 8.0,
                          left: 8.0,
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.arrow_upward, size: 25),
                            Text("Send"),
                          ],
                        ),
                      ),
                      onPressed: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        showModalBottomSheet(
                          context: context,
                          transitionAnimationController: controller,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return SingleChildScrollView(
                              child: SizedBox(
                                height: 735,
                                child: Sender(
                                  address: '',
                                  asset: asset,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 5.0, left: 5.0),
                    child: ElevatedButton(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Column(
                          children: [
                            Icon(Icons.arrow_downward, size: 25),
                            Text("Receive"),
                          ],
                        ),
                      ),
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
                                  address: '',
                                  initialToken: asset.id,
                                  asset: asset,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 5.0, left: 5.0),
                    child: ElevatedButton(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 8.0,
                          bottom: 8.0,
                          right: 8.0,
                          left: 8.0,
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.swap_horiz, size: 25),
                            Text("Swap"),
                          ],
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Singleton.tejoryScaffoldKey.currentState?.changeTab(1);
                      },
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text('Transaction History'),
                ),
              ),
            ),
            FutureBuilder(
              future: getTxDbList(),
              builder: (context, txDBList) {
                if (txDBList.connectionState == ConnectionState.waiting) {
                  // Loading state: return a sliver
                  return SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (txDBList.hasError) {
                  // Error state: return a sliver
                  return SliverToBoxAdapter(
                    child: Center(child: Text("Error: ${txDBList.error}")),
                  );
                }
                if (!txDBList.hasData ||
                    txDBList.data == null ||
                    txDBList.data!.isEmpty) {
                  // Empty state: return a sliver
                  return SliverToBoxAdapter(
                    child: Center(child: Text("No data found.")),
                  );
                }
                return SliverPadding(
                  padding: EdgeInsetsGeometry.only(right: 8, left: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((
                      BuildContext context,
                      int index,
                    ) {
                      return getTxItem(txDBList.data![index]);
                    }, childCount: txDBList.data!.length),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
