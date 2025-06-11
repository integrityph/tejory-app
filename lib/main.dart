import 'package:flutter/material.dart';
import 'package:tejory/api_keys/api_keys.dart';
import 'package:tejory/benchmark.dart';
import 'package:tejory/libsecp256k1ffi/libsecp256k1ffi.dart';
import 'package:tejory/singleton.dart';
import 'package:tejory/ui/login.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LibSecp256k1FFI.init();
  const APP_MODE = String.fromEnvironment('APP_MODE', defaultValue: '');
  if (APP_MODE == "benchmark") {
    await runBenchmarks();
    return;
  }
  // initialize API keys
  APIKeys.init();
  await openIsar();
  await openObjectBox();

  runApp(const MyApp());
}

Future<Null> openIsar() async {
  for (int i = 0; i < 10; i++) {
    try {
      await Singleton.initDB(showInspector: true);
      break;
    } catch (e) {
      print(e);
      await Future.delayed(Duration(milliseconds: 400));
    }
  }
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
      home: Login(),
      navigatorObservers: [routeObserver],
    );
  }
}
