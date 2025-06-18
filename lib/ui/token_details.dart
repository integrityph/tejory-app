import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tejory/coins/visual_tx.dart';
import 'package:tejory/crypto-helper/other_helpers.dart';
import 'package:tejory/box_models.g.dart';
import 'package:tejory/objectbox.g.dart';
import 'package:tejory/singleton.dart';
import 'package:tejory/ui/network.dart';
import 'package:tejory/ui/receive.dart';
import 'package:tejory/ui/send.dart';
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

  @override
  void initState() {
    super.initState();

    controller = BottomSheet.createAnimationController(this);
    controller.duration = Duration(seconds: 1);
    controller.reverseDuration = Duration(seconds: 1);
    controller.drive(CurveTween(curve: Curves.linear));
  }

  Future<List<VisualTx>> getTxDbList() async {
    // var txDBList =
    //     await Singleton.getDB().txDBs
    //         .filter()
    //         .coinEqualTo(asset.coinId)
    //         .findAll();
    var txDBList = await Models.txDB.find(q:
      TxDB_.coin.equals(asset.coinId!),
    );

    if (txDBList==null) {
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
    return Container(
      padding: EdgeInsets.only(top: 8, bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.0,
          ),
        ),
      ),
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
                  Text(
                    'Transfer - ${tx.isDeposit ? "Incoming" : "Outgoing"}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "1${asset.symbol} = ${OtherHelpers.humanizeMoney(tx.usdAmount, isFiat: true)}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    "Fee: ${(asset.getDecimalAmountInDouble(BigInt.from(tx.fee))).toStringAsFixed(8)}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    "${tx.time!.year.toString()}-${tx.time!.month.toString().padLeft(2, '0')}-${tx.time!.day.toString().padLeft(2, '0')} ${tx.time!.hour.toString().padLeft(2, '0')}:${tx.time!.minute.toString().padLeft(2, '0')}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${tx.isDeposit ? "+" : "-"} ${(asset.getDecimalAmountInDouble(BigInt.from((tx.amount > 0 ? tx.amount : -tx.amount)))).toStringAsFixed(8)}",
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: "monospace",
                      color: tx.isDeposit ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 9),
                  Text(
                    "${OtherHelpers.humanizeMoney(asset.getDecimalAmountInDouble(BigInt.from((tx.amount > 0 ? tx.amount : -tx.amount))) * tx.usdAmount, isFiat: true)}",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "monospace",
                      color: tx.isDeposit ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            "${(tx.outAddress != "") ? tx.outAddress : tx.inAddress}",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
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
              SizedBox(
                height: 24,
                child: Image.asset("assets/${asset.symbol.toLowerCase()}.png"),
              ),
              SizedBox(width: 10),
              Text(
                '${asset.name} (${asset.symbol})',
                style: TextStyle(fontSize: 20),
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
                    padding: const EdgeInsets.only(left:8.0),
                    child: Row(
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
                          primaryXAxis: DateTimeAxis(dateFormat: DateFormat.MMMd(), intervalType: DateTimeIntervalType.days, maximumLabels:5),
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
                                  networkList: networkList,
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
                                  networkList: networkList,
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
                      onPressed: () {},
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
                if (!txDBList.hasData || txDBList.data == null || txDBList.data!.isEmpty) {
                  // Empty state: return a sliver
                  return SliverToBoxAdapter(
                    child: Center(child: Text("No data found.")),
                  );
                }
                return SliverPadding(
                  padding: EdgeInsetsGeometry.only(right: 8, left:8),
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
