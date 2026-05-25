import 'package:flutter/material.dart';
import 'package:tejory/api_keys/api_keys.dart';
import 'package:tejory/singleton.dart';
import 'package:tejory/updates/update_ui.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialize API keys
  APIKeys.init();
  // await openIsar();
  await openObjectBox();

  runApp(const MyApp());
}

Future<Null> openObjectBox() async {
  await Singleton.initObjectBoxDB();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tejory Wallet',
      theme: Singleton.getBrightTheme(),
      darkTheme: Singleton.getDarkTheme(),
      themeMode: ThemeMode.system,
      home: UpdateUI(),
      navigatorObservers: [routeObserver],
    );
  }
}
