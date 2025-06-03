// To parse this JSON data, do
//
//     final yahooFinance = yahooFinanceFromJson(jsonString);

import 'dart:convert';
import 'package:http/http.dart' as http;

YahooFinance yahooFinanceFromJson(String str) =>
    YahooFinance.fromJson(json.decode(str));

String yahooFinanceToJson(YahooFinance data) => json.encode(data.toJson());

class YahooFinance {
  Chart chart;

  YahooFinance({
    required this.chart,
  });

  factory YahooFinance.fromJson(Map<String, dynamic> json) => YahooFinance(
        chart: Chart.fromJson(json["chart"]),
      );

  Map<String, dynamic> toJson() => {
        "chart": chart.toJson(),
      };
}

class Chart {
  List<Result> result;
  dynamic error;

  Chart({
    required this.result,
    required this.error,
  });

  factory Chart.fromJson(Map<String, dynamic> json) => Chart(
        result:
            List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "result": List<dynamic>.from(result.map((x) => x.toJson())),
        "error": error,
      };
}

class Result {
  List<int> timestamp;
  Indicators indicators;

  Result({
    required this.timestamp,
    required this.indicators,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        timestamp: List<int>.from(json["timestamp"].map((x) => x)),
        indicators: Indicators.fromJson(json["indicators"]),
      );

  Map<String, dynamic> toJson() => {
        "timestamp": List<dynamic>.from(timestamp.map((x) => x)),
        "indicators": indicators.toJson(),
      };
}

class Indicators {
  List<Adjclose> adjclose;

  Indicators({
    required this.adjclose,
  });

  factory Indicators.fromJson(Map<String, dynamic> json) => Indicators(
        adjclose: List<Adjclose>.from(
            json["adjclose"].map((x) => Adjclose.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "adjclose": List<dynamic>.from(adjclose.map((x) => x.toJson())),
      };
}

class Adjclose {
  List<double> adjclose;

  Adjclose({
    required this.adjclose,
  });

  factory Adjclose.fromJson(Map<String, dynamic> json) => Adjclose(
        adjclose: List<double>.from(json["adjclose"].map((x) => x?.toDouble())),
      );

  Map<String, dynamic> toJson() => {
        "adjclose": List<dynamic>.from(adjclose.map((x) => x)),
      };
}

Future<double?> getYahooFinanceHistoricPrice(
    String symbol, DateTime date) async {
  Map<String, int> startingDate = {
    "BTC-USD": 1413763200,
  };
  int epochDate = date.millisecondsSinceEpoch ~/ 1000;
  if (epochDate < startingDate[symbol]!) {
    epochDate = startingDate[symbol]!;
  }
  String URLStr =
      "https://query2.finance.yahoo.com/v8/finance/chart/${symbol}?period1=$epochDate&period2=$epochDate&interval=1d&includePrePost=false&events=&lang=en-US&region=US";
  var URL = Uri.parse(URLStr);
  final response = await http.get(URL);
  var yf = yahooFinanceFromJson(response.body);

  if (yf.chart.result.isEmpty) {
    return null;
  }

  if (yf.chart.result[0].indicators.adjclose.isEmpty) {
    return null;
  }

  if (yf.chart.result[0].indicators.adjclose[0].adjclose.isEmpty) {
    return null;
  }

  return yf.chart.result[0].indicators.adjclose[0].adjclose[0];
}
