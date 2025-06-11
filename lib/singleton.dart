import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:isar/isar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tejory/collections/balance.dart';
import 'package:tejory/collections/block.dart';
import 'package:tejory/collections/coin.dart';
import 'package:tejory/collections/data_version.dart';
import 'package:tejory/collections/key.dart';
import 'package:tejory/collections/lp.dart';
import 'package:tejory/collections/next_key.dart';
import 'package:tejory/collections/tx.dart';
import 'package:tejory/collections/wallet_db.dart';
import 'package:tejory/objectbox/objectbox.dart';
import 'package:tejory/swap/swap.dart';
import 'package:tejory/ui/asset_list.dart';
import 'package:tejory/ui/currency.dart';

class Singleton {
  static Isar? isar;
  static ObjectBox? objectbox;
  static AssetList assetList = AssetList.newBlank();
  static String? QRAddress = null;
  static Future<bool>? loaded;
  static bool initialSetup = false;
  static Map<String, dynamic> settings = {
    "WalletViewMode": "aggregated", // "aggregated", "separated"
    "DefaultWalletId": "1",
    "AggregatePaymentFromMultipleWallets":
        "0", // It's not possible sometimes to make a transaction from multiple wallet like in ETH
    "LocalCurrency": "USD",
    "HideBalance": "false",
  };
  static bool DEBUG = true;
  static Currency currentCurrency = Currency(
    "United State Dollar",
    "USD",
    "\$",
    true,
  );
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static Swap swap = new Swap();
  static bool notificationsEnabled = false;

  Singleton() {}

  static ThemeData getBrightTheme() {
    TextTheme textTheme = TextTheme(
      bodyLarge: TextStyle(),
      bodyMedium: TextStyle(),
      bodySmall: TextStyle(),
      displayLarge: TextStyle(),
      displayMedium: TextStyle(),
      displaySmall: TextStyle(),
      titleLarge: TextStyle(),
      titleMedium: TextStyle(),
      titleSmall: TextStyle(),
      labelLarge: TextStyle(),
      labelMedium: TextStyle(),
      labelSmall: TextStyle(),
    );

    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Color.fromARGB(255, 65, 65, 65),
        secondary: Color.fromARGB(255, 241, 241, 241),
        tertiary: Color.fromARGB(255, 209, 209, 209),
        surface: Color(0xfff7f7f7),
      ),
      appBarTheme: AppBarTheme(
        // backgroundColor: Color(0xfff7f7f7),
        scrolledUnderElevation: 0.0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: Colors.black),
        prefixIconColor: Color(0xff111111),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        // backgroundColor: Color(0xfff7f7f7),
        selectedItemColor: Color(0xff111111),
        unselectedItemColor: Color.fromARGB(255, 172, 166, 166),
      ),
      cardTheme: CardThemeData(color: Color.fromARGB(255, 241, 241, 241)),
      textTheme: textTheme.apply(bodyColor: Color(0xff4f4f4f)),
      primaryTextTheme: textTheme.apply(bodyColor: Color(0xff4f4f4f)),
    );
  }

  static ThemeData getDarkTheme() {
    TextTheme textTheme = TextTheme(
      bodyLarge: TextStyle(),
      bodyMedium: TextStyle(),
      bodySmall: TextStyle(),
      displayLarge: TextStyle(),
      displayMedium: TextStyle(),
      displaySmall: TextStyle(),
      titleLarge: TextStyle(),
      titleMedium: TextStyle(),
      titleSmall: TextStyle(),
      labelLarge: TextStyle(),
      labelMedium: TextStyle(),
      labelSmall: TextStyle(),
    );

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Color.fromARGB(255, 235, 235, 235),
        secondary: Color.fromARGB(255, 28, 28, 28),
        tertiary: Color.fromARGB(255, 46, 46, 46),
        surface: Color.fromARGB(255, 8, 8, 8),
      ),
      scaffoldBackgroundColor: Color.fromARGB(255, 8, 8, 8),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color?>(
            Color.fromARGB(255, 28, 28, 28),
          ),
          foregroundColor: WidgetStateProperty.all<Color?>(
            Color.fromARGB(255, 247, 247, 247),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        // backgroundColor: Color.fromARGB(255, 8, 8, 8),
        scrolledUnderElevation: 0.0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: Colors.white),
        prefixIconColor: Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        // backgroundColor: Color.fromARGB(255, 8, 8, 8),
        selectedItemColor: Colors.white,
        unselectedItemColor: Color.fromARGB(255, 100, 100, 100),
      ),
      cardTheme: CardThemeData(color: Color.fromARGB(255, 28, 28, 28)),
      textTheme: textTheme.apply(bodyColor: Color.fromARGB(255, 255, 255, 255)),
      primaryTextTheme: textTheme.apply(bodyColor: Color(0xff4f4f4f)),
    );
  }

  static Future<void> initDB({bool showInspector = false}) async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [
        KeySchema,
        TxDBSchema,
        CoinSchema,
        WalletDBSchema,
        BalanceSchema,
        NextKeySchema,
        BlockSchema,
        DataVersionSchema,
        LPSchema,
      ],
      inspector: showInspector,
      directory: dir.path,
    );
  }

  static Isar getDB() {
    return isar!;
  }

  static Future<void> initObjectBoxDB() async {
    objectbox = await ObjectBox.create();
  }

  static ObjectBox getObjectBoxDB() {
    return objectbox!;
  }

  static void printMsg(dynamic val) {
    if (DEBUG) {
      print(val);
    }
  }

  static int notificationId = 0;

  static Future<void> sendNotification(
    String title,
    String body, {
    String? payload,
    String? groupKey,
  }) async {
    if (!notificationsEnabled) {
      return;
    }

    groupKey = groupKey ?? 'tejory';
    await sendGroupSummary(groupKey);
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'tejory',
          'Tejory',
          largeIcon:  DrawableResourceAndroidBitmap(groupKey.toLowerCase()),
          channelDescription: 'Tejory Notifications',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker',
          groupKey: groupKey,
          setAsGroupSummary: false,
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: title,
            summaryText: groupKey,
            htmlFormatContent: true,
            htmlFormatBigText: true,
            htmlFormatSummaryText: true,
            htmlFormatTitle: true,
            htmlFormatContentTitle: true,
          ),
        );
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    notificationId++;
    await flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static Future<void> sendGroupSummary(String groupKey) async {
    if (!Platform.isAndroid) {
      return;
    }
    if (!(await needsGroupSummary(groupKey))) {
      print("No need for group summary");
      return;
    }
    print("Needs new group summary");
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'tejory',
          'Tejory',
          channelDescription: 'Tejory Notifications',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker',
          groupKey: groupKey,
          setAsGroupSummary: true,
          styleInformation: BigTextStyleInformation(
            "",
            htmlFormatContent: true,
            htmlFormatBigText: true,
            htmlFormatSummaryText: true,
          ),
        );
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    notificationId++;
    await flutterLocalNotificationsPlugin.show(
      notificationId,
      groupKey,
      groupKey,
      notificationDetails,
      payload: groupKey,
    );
  }

  static Future<bool> needsGroupSummary(String groupKey) async {
    var list = await flutterLocalNotificationsPlugin.getActiveNotifications();
    if (list.length == 0) {
      return true;
    }
    var firstInstance = list.firstWhereOrNull(
      (notification) => notification.groupKey == groupKey,
    );
    return firstInstance == null;
  }

  static Future<String> getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    // String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    return "$appName $version ($buildNumber)";
  }

  static Future<void> initNotifications() async {
    Singleton.notificationsEnabled =
        await Singleton.flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission() ??
        false;

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

  static void onDidReceiveNotificationResponse(
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
