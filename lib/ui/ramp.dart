import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RampPage extends StatefulWidget {
  final String initialToken;

  RampPage({super.key, required this.initialToken});

  @override
  _RampPage createState() => _RampPage();
}


class _RampPage extends State<RampPage> with ChangeNotifier {

  @override
  void initState() {
    super.initState();
  }

  urlOpen(String URL) {
    final Uri url = Uri.parse(URL);
    launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: Center(child: Column(
      children: [
        ElevatedButton(
            onPressed: (){
              urlOpen("https://exchange.mercuryo.io");
            },
            child: const Text("Mercuryo"),
          ),
      ],
    ),),);
  }
}