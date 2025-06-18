import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tejory/api_keys/api_keys.dart';
import 'package:tejory/ui/asset.dart';
import 'package:tejory/singleton.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

Future<Map<String, dynamic>?> makeCall(String path, {int depth = 0}) async {
  final API_KEY = APIKeys.getAPIKey("coindesk");
  if (API_KEY == null) {
    return null;
  }
  if (depth >= 5) {
    return null;
  }
  // /spot/v1/latest/tick?market=coinbase&instruments=BTC-USD,ETH-USD&apply_mapping=true&groups=VALUE
  var URL = Uri.parse('https://data-api.coindesk.com/${path}');

  Map<String, String> headers = <String, String>{
      "Content-Type": "application/json",
      "x-api-key": API_KEY,
    };

    http.Response response;
    Map<String, dynamic> jObj;

    try {
      print('https://data-api.coindesk.com/${path}');
      response = await http
          .get(URL, headers: headers)
          .timeout(Duration(seconds: 5));
    } catch (e) {
      return makeCall(path, depth: depth + 1);
    }

    try {
      jObj = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return makeCall(path, depth: depth + 1);
    }

    return jObj;
}

Future<AssetsData?> getPrices() async {
  if (Singleton.assetList.assetListState.assets.length == 0) {
    return null;
  }
  // BTC-USD,ETH-USD
  Set<String> symbolList = {};
  for (final asset in Singleton.assetList.assetListState.assets) {
    symbolList.add(asset.yahooFinance);
  }
  String path = "spot/v1/latest/tick?market=coinbase&instruments=${symbolList.join(",")}&apply_mapping=true&groups=VALUE,CURRENT_DAY";
  var obj = await makeCall(path);

  if (obj == null) {
    return null;
  }

  List<Asset> assetlList = [];
  Map<String, dynamic> assetMap;
  Map<String, dynamic>? valueMap;
  Map<String, dynamic> data = obj["Data"];
  for (final key in data.keys) {
    valueMap = data[key];
    if (valueMap == null) {
      continue;
    }
    if (!valueMap.containsKey("PRICE")) {
      continue;
    }
    assetMap = {
      "id": key,
      "name":key,
      "symbol":key,
      "priceUsd":valueMap["PRICE"].toString(),
      "changePercent24Hr":valueMap["CURRENT_DAY_CHANGE_PERCENTAGE"].toString(),
    };
    assetlList.add(Asset.fromJson(assetMap));
  }

  return AssetsData(assets: assetlList, version: 0);
}

Map<String, List<Map<String, dynamic>>> chartDataCache = {};
Future<List<Map<String, dynamic>>?> getChartData(String symbol, {String interval = "d1", int count=30, DateTime? endDate}) async {
  String intervalName;
  if (interval.startsWith("d")) {
    intervalName = "days";
  } else if (interval.startsWith("h")) {
    intervalName = "hours";
  } else if (interval.startsWith("m")) {
    intervalName = "minutes";
  } else {
    // fallback to days
    intervalName = "days";
  }
  int? aggregate = int.tryParse(interval.substring(1)); 
  if (aggregate == null) {
    aggregate = 1;
  }

  if (chartDataCache.containsKey("$symbol-$interval-$count-${endDate?.toIso8601String()}") && chartDataCache["$symbol-$interval-$count-${endDate?.toIso8601String()}"]!.length != 0) {
    return chartDataCache["$symbol-$interval-$count-${endDate?.toIso8601String()}"];
  }

  String path = "index/cc/v1/historical/${intervalName}?market=cadli&instrument=${symbol}&limit=${count}&aggregate=${aggregate}&fill=true&apply_mapping=false&response_format=JSON&groups=OHLC";
  if (endDate != null) {
    path += "&to_ts=${endDate.millisecondsSinceEpoch~/1000}";
  }
  var obj = await makeCall(path);

  if (obj == null) {
    return null;
  }

  if (!obj.containsKey("Data")) {
    return null;
  }
  List<dynamic>? data = obj["Data"];
  if (data == null) {
    return null;
  }
  List<Map<String, dynamic>> result = [];
  DateTime? date;
  double? closePrice;
  for (final Map<String, dynamic>? record in data) {
    if (record == null) {
      continue;
    }
    if (!record.containsKey("TIMESTAMP")) {
      continue;
    }
    if (!record.containsKey("CLOSE")) {
      continue;
    }
    try {
      date = DateTime.fromMillisecondsSinceEpoch(record["TIMESTAMP"] * 1000, isUtc: true);
      closePrice = record["CLOSE"];
      if (closePrice == null) {
        continue;
      }
    }catch(e){
      continue;
    }
    
    result.add(
      {'date': date, 'close': closePrice}
    );
  }

  chartDataCache["$symbol-$interval-$count-${endDate?.toIso8601String()}"] = result;
  return result;
}

typedef StreamPriceCallback = void Function(String symbol, double price);

Future<void> streamPrices(List<String> symbolList, StreamPriceCallback callback) async {
  final API_KEY = APIKeys.getAPIKey("coindesk");
  if (API_KEY == null) {
    return null;
  }
// build asset list for the API
    var URL = Uri.parse(
      // "wss://data-streamer.cryptocompare.com/?api_key=${API_KEY}",
      "wss://data-streamer.cryptocompare.com/",
    );

    final channel = WebSocketChannel.connect(URL);
    channel.ready
        .then((val) {
          channel.stream.listen(
            (msg) {
              Map<String, dynamic> obj = {};
              try {
                obj = jsonDecode(msg);
              } catch (e) {
                return;
              }
              if (!obj.containsKey("TYPE")) {
                return;
              }
              if (obj["TYPE"] == "4000") {
                // subscribe
                Map<String, dynamic> sendObj = {
                  "action": "SUBSCRIBE",
                  "type": "index_cc_v1_latest_tick",
                  "groups": ["VALUE"],
                  "market": "cadli",
                  "instruments": symbolList.toList(),
                };
                String sendMsg = json.encode(sendObj);
                channel.sink.add(sendMsg);
                return;
              }
              if (obj["TYPE"] != "1101") {
                return;
              }
              if (!obj.containsKey("INSTRUMENT")) {
                return;
              }
              if (!obj.containsKey("VALUE")) {
                return;
              }
              double? newPrice = obj["VALUE"];
              String symbol = obj["INSTRUMENT"];

              if (newPrice != null) {
                callback(symbol, newPrice);
              }
            },
            onError: (v) {
              try {
                channel.sink.close(status.goingAway);
              } catch (e) {}
              // retry again after 5 seconds
              Future.delayed(Duration(seconds: 5)).then((v) {
                streamPrices(symbolList, callback);
              });
            },
            onDone: () {
              try {
                channel.sink.close(status.goingAway);
              } catch (e) {}
              // retry again after 5 seconds
              Future.delayed(Duration(seconds: 5)).then((v) {
                streamPrices(symbolList, callback);
              });
            },
          );
        })
        .onError((e, s) {
          // retry again after 5 seconds
          Future.delayed(Duration(seconds: 5)).then((v) {
            streamPrices(symbolList, callback);
          });
        });
}