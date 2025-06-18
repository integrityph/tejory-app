import 'dart:convert';
import 'package:tejory/coindesk/api.dart' as coinsdesk;

BlockchainApi blockchainApiFromJson(String str) =>
    BlockchainApi.fromJson(json.decode(str));

String blockchainApiToJson(BlockchainApi data) => json.encode(data.toJson());

class BlockchainApi {
  String status;
  String name;
  String unit;
  String period;
  String description;
  List<Value> values;

  BlockchainApi({
    required this.status,
    required this.name,
    required this.unit,
    required this.period,
    required this.description,
    required this.values,
  });

  factory BlockchainApi.fromJson(Map<String, dynamic> json) => BlockchainApi(
        status: json["status"],
        name: json["name"],
        unit: json["unit"],
        period: json["period"],
        description: json["description"],
        values: List<Value>.from(json["values"].map((x) => Value.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "name": name,
        "unit": unit,
        "period": period,
        "description": description,
        "values": List<dynamic>.from(values.map((x) => x.toJson())),
      };
}

class Value {
  int x;
  double y;

  Value({
    required this.x,
    required this.y,
  });

  factory Value.fromJson(Map<String, dynamic> json) => Value(
        x: json["x"],
        y: json["y"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "x": x,
        "y": y,
      };
}

Future<double?> getBlockchainAPIHistoricPrice(
    String symbol, DateTime date, {int errorCount = 0}) async {
  // Map<String, int> startingDate = {
  //   "BTC-USD": 1257033600,
  //   "ETH-USD": 1510185600,
  // };
  if (errorCount == 5) {
    return null;
  }
  Map<String, int> startingDate = {
    "BTC-USD": 1410912000,
    "ETH-USD": 1510185600,
    "USDT-USD": 1510185600,
  };
  int epochDate = date.millisecondsSinceEpoch ~/ 1000;
  if (epochDate < (startingDate[symbol]?? 0.0)) {
    epochDate = startingDate[symbol]?? epochDate;
  }

  List<Map<String, dynamic>>? prices = await coinsdesk.getChartData(symbol, count:1, endDate: date);

  if (prices == null || prices.isEmpty) {
    return null;
  }

  return prices[0]["close"];

  // var epoch1 = date.subtract(Duration(days: 3)).millisecondsSinceEpoch ~/ 1000;
  // var epoch2 = date.millisecondsSinceEpoch ~/ 1000;
  // var URL = Uri.parse("https://query1.finance.yahoo.com/v8/finance/chart/${symbol}?period1=${epoch1}&period2=${epoch2}&interval=1d&lang=en-US&region=US");
  // try {
  //   final response = await http.get(URL);
  //   YahooFinance yfObj = yahooFinanceFromJson(response.body);
  //   return yfObj.chart.result[0].indicators.adjclose[0].adjclose[0];
  // } catch(e) {
  //   return getBlockchainAPIHistoricPrice(symbol, date, errorCount:errorCount+1);
  //   // return 0;
  // }
}
