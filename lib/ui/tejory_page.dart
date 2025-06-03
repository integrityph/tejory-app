import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tejory/custom_icons_icons.dart';
import 'package:tejory/singleton.dart';
import 'package:tejory/ui/ramp.dart';
import 'package:tejory/ui/swap.dart';
import 'package:tejory/ui/tejory_homepage.dart';
import 'settings.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

enum accountSetting {
  network,
  walletStatus,
  ImportWallet,
  KeyDerivation,
  ImportWalletXprv,
  login,
  setupWallet,
}

class Tejory extends StatefulWidget {
  Tejory({super.key});

  @override
  _TejoryState createState() => _TejoryState();
}

class _TejoryState extends State<Tejory> with RouteAware {
  accountSetting? selectedMenu;
  int _currentIndex = 0;

  // biometric_storage
  // final String baseName = 'default';
  // BiometricStorageFile? _authStorage;
  // BiometricStorageFile? _storage;
  // BiometricStorageFile? _customPrompt;

  List<Widget> _pages =
      (kDebugMode)
          ? [
            HomePage(),
            SwapPage(initialToken: ''),
            RampPage(initialToken: ''),
            SettingsPage(),
          ]
          : [HomePage(), SwapPage(initialToken: ''), SettingsPage()];

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    initNotifications();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  // Future<CanAuthenticateResponse> _checkAuthenticate() async {
  //   final response = await BiometricStorage().canAuthenticate();
  //   print('checked if authentication was possible: $response');
  //   return response;
  // }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.only(top: 60.0),
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items:
            (kDebugMode)
                ? <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(CustomIcons.tejory1),
                    label: 'Wallet',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.swap_horiz),
                    label: 'Swap',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.attach_money_outlined),
                    label: 'Buy/Sell',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ]
                : <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(CustomIcons.tejory1),
                    label: 'Wallet',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.swap_horiz),
                    label: 'Swap',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
        selectedLabelStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Future<void> initNotifications() async {
    Singleton.notificationsEnabled =
        await Singleton.flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission() ?? false;

    // initialize the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('launcher_icon');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: null,
          linux: null,
        );
    await Singleton.flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      print('notification payload: $payload');
    }
    // await Navigator.push(
    //   context,
    //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
    // );
  }
}
