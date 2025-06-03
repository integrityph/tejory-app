// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'dart:io';

// class TokenListItem_ {
//   Widget getListToken(String name, String symbol, String image, double amount,
//       double fiatAmount, String fiatSymbol) {
//     return Card(
//         semanticContainer: false,
//         child: ListTile(
//           leading: Image(image: AssetImage(image)),
//           title:
//               Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//             Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
//             Text(amount.toString(),
//                 textAlign: TextAlign.right,
//                 style: const TextStyle(fontWeight: FontWeight.bold))
//           ]),
//           subtitle: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(symbol),
//                 Text('~ $fiatSymbol$fiatAmount', textAlign: TextAlign.right)
//               ]),
//         ));
//   }
// }

// String Filepath = "lib/ui/json.json";
// JsonDecoder decoder = JsonDecoder();

// class DATA {
//   String? symbol;
//   String? name;
//   String? priceUsd;
//   String? changePercent24Hr;

//   //{ } - implies named arguments
//   DATA({this.symbol, this.name, this.priceUsd, this.changePercent24Hr});

//   @override
//   String toString() {
//     return "{symbol:$symbol,name:$name,priceUsd:$priceUsd,changePercent24Hr:$changePercent24Hr}";
//   }
// }

// void main() {
//   List<DATA>? coin;
//   //synchronously read file contents
//   var jsonString = File(Filepath).readAsStringSync();
//   //pass the read string to JsonDecoder class to convert into corresponding Objects
//   final Map<String, dynamic> jsonmap = decoder.convert(jsonString);

//   //DataModel - key = "data", value = "ARRAY of Objects"
//   var value = jsonmap["data"];
//   if (value != null) {
//     coin = <DATA>[];
//     //Each item in value is of type::: _InternalLinkedHashMap<String, dynamic>
//     value.forEach((item) => coin?.add(new DATA(
//         symbol: item["symbol"],
//         name: item["name"],
//         priceUsd: item["priceUsd"],
//         changePercent24Hr: item["changePercent24Hr"])));
//   }
//   coin?.forEach((element) => print(element));
// }
