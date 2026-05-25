import 'dart:convert';
import 'dart:math';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tejory/coins/bitcoin.dart';
import 'package:tejory/coins/btkn.dart';
import 'package:tejory/coins/spark_btc.dart';
import 'package:tejory/singleton.dart';
import 'package:tejory/ui/components/pin_code_dialog.dart';
import 'package:tejory/ui/currency.dart';
import 'package:tejory/ui/disgnostics.dart';
import 'package:tejory/ui/qrscanner.dart';
import 'package:tejory/ui/setup/page_animation.dart';
import 'package:tejory/ui/setup/seed_dropdown.dart';
import 'package:tejory/ui/setup/seedphrase.dart';
import 'package:tejory/wallets/iwallet.dart';
import 'package:tejory/wallets/wallet_type.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with ChangeNotifier {
  // General settings
  String _localCurrency = 'USD';
  bool _showNotifications = true;

  // Fee settings
  double _customFee = 0.0003;

  // Privacy settings
  bool _hideBalance = false;

  String _password = '';

  // Security settings
  bool _twoFactorAuthentication = false;
  String _walletPin = '';

  // Account settings
  String _selectedAccount = 'Show All';
  List<Widget> _wallets = [];
  List<Widget> _currencies = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('localCurrency', _localCurrency);
    await prefs.setDouble('customFee', _customFee);
    await prefs.setBool('hideBalance', _hideBalance);
    await prefs.setBool('showNotifications', _showNotifications);
    await prefs.setString('password', _password);
    await prefs.setBool('twoFactorAuthentication', _twoFactorAuthentication);
    await prefs.setString('walletPin', _walletPin);
    await prefs.setString('selectedAccount', _selectedAccount);
    await prefs.setBool(
      'hideCustodialMessage',
      Singleton.dismissCustodialMessage,
    );

    Singleton.assetList.assetListState.setCurrency(
      Singleton.assetList.assetListState.currencyList.firstWhere((
        Currency currency,
      ) {
        return currency.isoName == _localCurrency;
      }),
    );

    Singleton.assetList.assetListState.setPrivacy(_hideBalance);
    Singleton.notificationsEnabled = _showNotifications;
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    await Singleton.loaded;
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _localCurrency = prefs.getString('localCurrency') ?? 'USD';
      _customFee = prefs.getDouble('customFee') ?? 0.0003;
      _hideBalance = prefs.getBool('hideBalance') ?? false;
      _showNotifications = prefs.getBool('showNotifications') ?? false;
      _password = prefs.getString('password') ?? '';
      _twoFactorAuthentication =
          prefs.getBool('twoFactorAuthentication') ?? false;
      _walletPin = prefs.getString('walletPin') ?? '';
      _selectedAccount = prefs.getString('selectedAccount') ?? 'Show All';
      Singleton.dismissCustodialMessage =
          prefs.getBool('hideCustodialMessage') ?? false;
    });

    Singleton.assetList.assetListState.currencyList.addAll([
      Currency("United State Dollar", "USD", "\$", true),
      Currency("Euro", "EUR", "€", true),
      Currency("Argentine Peso", "ARS", "AG\$", true),
      Currency("Australian Dollar", "AUD", "AU\$", true),
      Currency("Brazilian Real", "BRL", "R\$", true),
      Currency("British Pound", "GBP", "£", true),
      Currency("Bulgarian Lev", "BGN", "лв", false),
      Currency("Canadian Dollar", "CAD", "CA\$", true),
      Currency("Chilean Peso", "CLP", "CLP\$", true),
      Currency("Chinese Yuan", "CNH", "CN¥", true),
      Currency("Colombian Peso", "COP", "COL\$", true),
      Currency("Costa Rican Colon", "CRC", "₡", true),
      Currency("Croatian Kuna", "HRK", "kn", false),
      Currency("Czech Koruna", "CZK", "Kč", false),
      Currency("Danish Krone", "DKK", "kr", false),
      Currency("Dominican Peso", "DOP", "RD\$", true),
      Currency("Egyptian Pound", "EGP", " EGP", false),
      Currency("Ghanaian Cedi", "GHS", " GH₵", true),
      Currency("Hong Kong Dollar", "HKD", "HK\$", true),
      Currency("Hungarian Forint", "HUF", "Ft", true),
      Currency("Indian Rupee", "INR", "₹", true),
      Currency("Indonesian Rupiah", "IDR", "Rp", true),
      Currency("Israeli new Shekel", "ILS", "₪", true),
      Currency("Japanese Yen", "JPY", "JP¥", true),
      Currency("Kazakhstani Tenge", "KZT", "₸", false),
      Currency("Kenyan Shilling", "KES", "KSh", true),
      Currency("Malaysian Ringgit", "MYR", "RM", true),
      Currency("Mexican Peso", "MXN", "MX\$", true),
      Currency("Moroccan Dirham", "MAD", "MD", false),
      Currency("Myanmar Kyat", "MMK", "K", true),
      Currency("New Taiwan Dollar", "TWD", "NT\$", true),
      Currency("New Zealand Dollar", "NZD", "NZ\$", true),
      Currency("Norwegian Krone", "NOK", "kr", false),
      Currency("Peruvian Sol", "PEN", "S/", true),
      Currency("Philippine Peso", "PHP", "₱", true),
      Currency("Polish Zloty", "PLN", "zł", false),
      Currency("Qatari Riyal", "QAR", "QR", false),
      Currency("Romanian Leu", "RON", "lei", false),
      Currency("Russian Ruble", "RUB", "₽", false),
      Currency("Saudi Riyal", "SAR", "SAR", false),
      Currency("Singapore Dollar", "SGD", "S\$", true),
      Currency("South African Rand", "ZAR", "R", true),
      Currency("South Korean Won", "KRW", "₩", true),
      Currency("Swedish Krona", "SEK", " kr", false),
      Currency("Swiss Franc", "CHF", "CHF", true),
      Currency("Thai Baht", "THB", "฿", true),
      Currency("Turkish Lira", "TRY", "₺", true),
      Currency("Ugandan Shilling", "UGX", "USh", true),
      Currency("Ukrainian Hryvnia", "UAH", "₴", false),
      Currency("Uruguayan Peso", "UYU", "\$U", true),
      Currency("United Arab Emirates Dirham", "AED", "AED", false),
      Currency("Vietnamese Dong", "VND", "₫", false),
    ]);

    Singleton.assetList.assetListState.setCurrency(
      Singleton.assetList.assetListState.currencyList.firstWhere((
        Currency currency,
      ) {
        return currency.isoName == _localCurrency;
      }),
    );

    Singleton.assetList.assetListState.setPrivacy(_hideBalance);
    Singleton.notificationsEnabled = _showNotifications;

    setState(() {
      Singleton.loaded!.then((val) {
        List<Widget> walletList = [
          ListTile(
            key: Key("Show All"),
            leading: Icon(Icons.all_inbox),
            titleAlignment: ListTileTitleAlignment.center,
            minTileHeight: 8,
            minVerticalPadding: 0,
            title: Text("Show All"),
          ),
        ];
        for (final wallet in Singleton.assetList.assetListState.walletList) {
          walletList.add(
            ListTile(
              key: Key("${wallet.id}"),
              leading: wallet.type == WalletType.phone
                  ? Icon(Icons.phone_android)
                  : Icon(Icons.picture_in_picture_alt_rounded),
              minTileHeight: 8,
              minVerticalPadding: 0,
              title: Text(wallet.name!),
            ),
          );
        }
        _wallets.addAll(walletList);

        for (final currency
            in Singleton.assetList.assetListState.currencyList) {
          _currencies.add(
            ListTile(
              key: Key(currency.isoName),
              trailing: Text(currency.symbol),
              minTileHeight: 8,
              minVerticalPadding: 0,
              title: Text(currency.name),
            ),
          );
        }

        notifyListeners();
      });
    });
  }

  @override
  void addListener(VoidCallback listener) {
    Singleton.assetList.assetListState.addListener(listener);
    super.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          // _buildSectionTitle('Account Settings'),
          // _buildCard(
          //   child: _buildWalletDropdown(
          //     title: 'Select Wallet',
          //     value: _selectedAccount,
          //     onChanged: (value) {
          //       setState(() {
          //         _selectedAccount = value!;
          //       });
          //       _saveSettings();
          //     },
          //   ),
          // ),
          // SizedBox(height: 20),
          _buildSectionTitle('General Settings'),
          _buildCard(
            child: Column(
              spacing: 10,
              children: [
                _buildCurrencyDropdown(
                  title: 'Local Currency',
                  value: _localCurrency,
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _localCurrency = value;
                    });
                    _saveSettings();
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Enable Notifications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Switch(
                      value: _showNotifications,
                      onChanged: (value) {
                        setState(() {
                          _showNotifications = value;
                        });
                        _saveSettings();
                        if (_showNotifications == true) {
                          Singleton.initNotifications();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // SizedBox(height: 20),
          // _buildSectionTitle('Fee Settings'),
          // _buildCard(
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Text('Fees', style: TextStyle(fontWeight: FontWeight.bold)),
          //       SizedBox(height: 10),
          //       Text('Maximum Fee'),
          //       SizedBox(height: 10),
          //       TextFormField(
          //         keyboardType: TextInputType.number,
          //         decoration: InputDecoration(
          //           labelText: 'Custom Fee',
          //           border: OutlineInputBorder(),
          //         ),
          //         initialValue: _customFee.toString(),
          //         onChanged: (value) {
          //           setState(() {
          //             _customFee = double.parse(value);
          //           });
          //           _saveSettings();
          //         },
          //       ),
          //     ],
          //   ),
          // ),
          SizedBox(height: 20),
          _buildSectionTitle('Privacy Settings'),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hide Balance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Switch(
                      value: _hideBalance,
                      onChanged: (value) {
                        setState(() {
                          _hideBalance = value;
                        });
                        _saveSettings();
                      },
                    ),
                  ],
                ),
                // SizedBox(height: 10),
              ],
            ),
          ),
          SizedBox(height: 20),
          // _buildSectionTitle('Security Settings'),
          // _buildCard(
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Text('Enable Biometrics'),
          //           Switch(
          //             value: _twoFactorAuthentication,
          //             onChanged: (value) {
          //               setState(() {
          //                 _twoFactorAuthentication = value;
          //               });
          //               _saveSettings();
          //             },
          //           ),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),
          // SizedBox(height: 30),
          _buildSectionTitle('Terminals'),
          _buildCard(
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // _linkTerminalWithQRCode(context),
                _linkTerminalWithToken(context),
                _linkTejoryBusiness(context),
              ],
            ),
          ),
          SizedBox(height: 30),
          _buildSectionTitle('Hardware Wallet'),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      const Color.fromARGB(255, 14, 154, 219),
                    ),
                    padding: WidgetStateProperty.all(
                      EdgeInsets.only(top: 15, bottom: 15),
                    ),
                  ),
                  onPressed: () async {
                    var ErrorMsg = await _changePIN();
                    if (ErrorMsg != null) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            icon: Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 36,
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 5,
                              children: [
                                Text(
                                  "Unable to change PIN Code",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('${ErrorMsg}'),
                              ],
                            ),
                          );
                        },
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            icon: Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                              size: 36,
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 5,
                              children: [
                                Text(
                                  "PIN code changed successfully",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                  child: Center(
                    child: Text(
                      "Change Card PIN Code",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      const Color.fromARGB(255, 14, 154, 219),
                    ),
                    padding: WidgetStateProperty.all(
                      EdgeInsets.only(top: 15, bottom: 15),
                    ),
                  ),
                  onPressed: () async {
                    var ErrorMsg = await _resetPIN();
                    if (ErrorMsg != null) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            icon: Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 36,
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 5,
                              children: [
                                Text(
                                  "Unable to reset PIN Code",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('${ErrorMsg}'),
                              ],
                            ),
                          );
                        },
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            icon: Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                              size: 36,
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 5,
                              children: [
                                Text(
                                  "PIN code reset successfully",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                  child: Center(
                    child: Text(
                      "Reset Card PIN Code",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      const Color.fromARGB(255, 248, 140, 17),
                    ),
                    padding: WidgetStateProperty.all(
                      EdgeInsets.only(top: 15, bottom: 15),
                    ),
                  ),
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          icon: Icon(
                            Icons.warning,
                            size: 100,
                            color: const Color.fromARGB(255, 255, 209, 7),
                          ),
                          content: Text(
                            'This action will reset you private key in the hardware wallet. Make sure you have your Mnemonic Phrase (12 to 24 words) before you start',
                            textAlign: TextAlign.center,
                          ),
                          actionsAlignment: MainAxisAlignment.spaceEvenly,
                          actions: <Widget>[
                            TextButton(
                              style: ButtonStyle(
                                side: WidgetStateProperty.all(
                                  BorderSide(width: 0.5),
                                ),
                              ),
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();
                                FadeNavigator(context).navigateTo(
                                  SeedPhrase(
                                    seedList: seedList,
                                    initialPhraseLength: 24,
                                    entropy: [],
                                    reprogramOnly: true,
                                  ),
                                );
                              },
                            ),
                            TextButton(
                              style: ButtonStyle(
                                side: WidgetStateProperty.all(
                                  BorderSide(width: 0.5),
                                ),
                              ),
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Center(
                    child: Text(
                      "Initialize Card",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          _buildSectionTitle('Diagnostics'),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      Theme.of(
                        context,
                      ).colorScheme.errorContainer.withAlpha(150),
                    ),
                    padding: WidgetStateProperty.all(
                      EdgeInsets.only(top: 15, bottom: 15),
                    ),
                  ),
                  onPressed: () async {
                    FadeNavigator(context).navigateTo(Diagnostics());
                  },
                  child: Center(
                    child: Text(
                      "Get Diagnostics Data",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      Theme.of(
                        context,
                      ).colorScheme.errorContainer.withAlpha(150),
                    ),
                    padding: WidgetStateProperty.all(
                      EdgeInsets.only(top: 15, bottom: 15),
                    ),
                  ),
                  onPressed: () async {
                    final btc = Singleton.assetList.assetListState.findAsset(
                      "btc",
                    );
                    (btc!.coins[0] as Bitcoin).resyncWalletFromRPC();
                    const snackBar = SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 50,
                            color: const Color.fromARGB(255, 87, 206, 51),
                          ),
                          Text("BTC is re-downloading your wallet"),
                        ],
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  child: Center(
                    child: Text(
                      "Resynch Wallet From RPC",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(padding: const EdgeInsets.all(16.0), child: child),
    );
  }

  // Widget _buildDropdown({
  //   required String title,
  //   required String value,
  //   required List<Widget> items,
  //   required ValueChanged<String?> onChanged,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         title,
  //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  //       ),
  //       SizedBox(height: 8),
  //       ListenableBuilder(
  //         listenable: this,
  //         builder: (context, child) {
  //           return DropdownButtonFormField<String>(
  //             value: value,
  //             decoration: InputDecoration(
  //               border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //             ),
  //             onChanged: onChanged,
  //             items: items.map((item) {
  //               String? value = (item.key != null)?((item.key as ValueKey).value) : null;
  //               if (value == null) {
  //                 value = item is Text ? item.data : null;
  //               }
  //               if (value == null) {
  //                 throw Exception(
  //                     "You forgot to add a key for one of your menu items");
  //               }
  //               return DropdownMenuItem<String>(
  //                 value: value,
  //                 child: SizedBox(child: item, width: 270),
  //               );
  //             }).toList(),
  //           );
  //         }
  //       ),
  //     ],
  //   );
  // }

  Widget _buildCurrencyDropdown({
    required String title,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        ListenableBuilder(
          listenable: this,
          builder: (context, child) {
            return DropdownButtonFormField<String>(
              initialValue: value,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: onChanged,
              items: _currencies.map((item) {
                String? value = (item.key != null)
                    ? ((item.key as ValueKey).value)
                    : null;
                if (value == null) {
                  value = item is Text ? item.data : null;
                }
                if (value == null) {
                  throw Exception(
                    "You forgot to add a key for one of your menu items",
                  );
                }
                return DropdownMenuItem<String>(
                  value: value,
                  child: SizedBox(child: item, width: 260),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // Widget _buildWalletDropdown({
  //   required String title,
  //   required String value,
  //   required ValueChanged<String?> onChanged,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         title,
  //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  //       ),
  //       SizedBox(height: 8),
  //       ListenableBuilder(
  //         listenable: this,
  //         builder: (context, child) {
  //           return DropdownButtonFormField<String>(
  //             value: value,
  //             decoration: InputDecoration(
  //               border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //             ),
  //             onChanged: onChanged,
  //             items: _wallets.map((item) {
  //               String? value = (item.key != null)?((item.key as ValueKey).value) : null;
  //               if (value == null) {
  //                 value = item is Text ? item.data : null;
  //               }
  //               if (value == null) {
  //                 throw Exception(
  //                     "You forgot to add a key for one of your menu items");
  //               }
  //               return DropdownMenuItem<String>(
  //                 value: value,
  //                 child: SizedBox(child: item, width: 270),
  //               );
  //             }).toList(),
  //           );
  //         }
  //       ),
  //     ],
  //   );
  // }

  dynamic msgDialog(
    Widget? content,
    BuildContext _context, {
    List<Widget>? actions,
    Widget? icon,
  }) {
    return showDialog<dynamic>(
      context: _context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: icon,
          content: content,
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: actions,
        );
      },
    );
  }

  Future<String?> _changePIN() async {
    String? errorMsg;
    List<int>? pin = await PINCodeDialog().showPINModal(
      context,
      "Enter current PIN code",
    );
    if (pin == null || pin.length != 4) {
      errorMsg = "4 digit PIN code was not entered";
      return errorMsg;
    }
    List<int>? pinNew1 = await PINCodeDialog().showPINModal(
      context,
      "Enter new PIN code",
    );
    if (pinNew1 == null || pinNew1.length != 4) {
      errorMsg = "4 digit PIN code was not entered";
      return errorMsg;
    }
    List<int>? pinNew2 = await PINCodeDialog().showPINModal(
      context,
      "Confirm new PIN code",
    );
    if (pinNew2 == null || pinNew2.length != 4) {
      errorMsg = "4 digit PIN code was not entered";
      return errorMsg;
    }
    if (String.fromCharCodes(pinNew1) != String.fromCharCodes(pinNew2)) {
      errorMsg =
          "The new PIN code didn't match. Make sure you enter the same PIN code twice";
      return errorMsg;
    }
    var wallet =
        (await Singleton.assetList.assetListState.assets[0].getWallet())
            .signingWallet!;
    var success = await wallet.startSession(
      context,
      await (
        dynamic session, {
        List<int>? pinCode,
        List<int>? pinCodeNew,
      }) async {
        wallet.setMediumSession(session);
        if (pinCode == null) {
          errorMsg = "PIN code was not entered";
          return false;
        }
        if (pinCodeNew == null) {
          errorMsg = "New PIN code was not entered";
          return false;
        }

        VerifyPINResult? result = await wallet.changePINCode(
          CodeType.PIN,
          String.fromCharCodes(pinCode),
          CodeType.PIN,
          String.fromCharCodes(pinCodeNew),
        );

        if (result == VerifyPINResult.InvalidPIN) {
          errorMsg = "Invalid PIN code";
        } else if (result == VerifyPINResult.LockedPIN) {
          errorMsg = "PIN code is locked";
        } else if (result == null) {
          errorMsg = "Unknown error";
        }

        if (errorMsg != null) {
          return false;
        }

        return true;
      },
      PIN: pin,
      newPIN: pinNew1,
    );

    if (!success) {
      return errorMsg ?? "Unknown error";
    }
    return null;
  }

  Future<String?> _resetPIN() async {
    String? errorMsg;
    List<int>? pin = await PINCodeDialog().showPINModal(
      context,
      "Enter current PUK code",
    );
    if (pin == null || pin.length != 4) {
      errorMsg = "4 digit PUK code was not entered";
      return errorMsg;
    }
    List<int>? pinNew1 = await PINCodeDialog().showPINModal(
      context,
      "Enter new PIN code",
    );
    if (pinNew1 == null || pinNew1.length != 4) {
      errorMsg = "4 digit PIN code was not entered";
      return errorMsg;
    }
    List<int>? pinNew2 = await PINCodeDialog().showPINModal(
      context,
      "Confirm new PIN code",
    );
    if (pinNew2 == null || pinNew2.length != 4) {
      errorMsg = "4 digit PIN code was not entered";
      return errorMsg;
    }
    if (String.fromCharCodes(pinNew1) != String.fromCharCodes(pinNew2)) {
      errorMsg =
          "The new PIN code didn't match. Make sure you enter the same PIN code twice";
      return errorMsg;
    }
    var wallet =
        (await Singleton.assetList.assetListState.assets[0].getWallet())
            .signingWallet!;
    var success = await wallet.startSession(
      context,
      await (
        dynamic session, {
        List<int>? pinCode,
        List<int>? pinCodeNew,
      }) async {
        wallet.setMediumSession(session);
        if (pinCode == null) {
          errorMsg = "PIN code was not entered";
          return false;
        }
        if (pinCodeNew == null) {
          errorMsg = "New PIN code was not entered";
          return false;
        }

        VerifyPINResult? result = await wallet.changePINCode(
          CodeType.PUK,
          String.fromCharCodes(pinCode),
          CodeType.PIN,
          String.fromCharCodes(pinCodeNew),
        );

        if (result == VerifyPINResult.InvalidPIN) {
          errorMsg = "Invalid PUK code";
        } else if (result == VerifyPINResult.LockedPIN) {
          errorMsg =
              "PUK code is locked. Your card is completely locked and needs to be reinitialized";
        } else if (result == null) {
          errorMsg = "Unknown error";
        }

        if (errorMsg != null) {
          return false;
        }

        return true;
      },
      PIN: pin,
      newPIN: pinNew1,
    );

    if (!success) {
      return errorMsg ?? "Unknown error";
    }
    return null;
  }

  Widget _linkTerminalWithQRCode(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return TextButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              const Color.fromARGB(255, 14, 154, 219),
            ),
            padding: WidgetStateProperty.all(
              EdgeInsets.only(top: 15, bottom: 15),
            ),
          ),
          onPressed: () async {
            final terminalNameController = TextEditingController();
            final terminalName = await showDialog<String>(
              context: context,
              builder: (dialogContext) {
                // --- THIS IS THE CORRECT PATTERN ---
                // ONE StatefulBuilder that builds the ENTIRE dialog.
                return StatefulBuilder(
                  builder: (builderContext, setState) {
                    void listener() => setState(() {});
                    terminalNameController.addListener(listener);

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!ModalRoute.of(builderContext)!.isCurrent) {
                        terminalNameController.removeListener(listener);
                      }
                    });

                    return AlertDialog(
                      title: const Text('Link New Terminal'),
                      content: TextField(
                        controller: terminalNameController,
                        decoration: const InputDecoration(
                          labelText: 'Terminal Name',
                        ),
                        autofocus: true,
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                        TextButton(
                          child: const Text('OK'),
                          onPressed: terminalNameController.text.trim().isEmpty
                              ? null
                              : () {
                                  Navigator.of(
                                    dialogContext,
                                  ).pop(terminalNameController.text);
                                },
                        ),
                      ],
                    );
                  },
                );
              },
            );

            if (terminalName == null || terminalName.trim().isEmpty) {
              const snackBar = SnackBar(
                content: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 50,
                      color: const Color.fromARGB(255, 206, 51, 51),
                    ),
                    Text("Failed to link terminal. Try again"),
                  ],
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              return;
            }

            // Get the token from QR code
            var terminalToken = await Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => QRScanner()));

            print("${terminalName} ${terminalToken}");

            // terminalInfo is not used in this context, but the code stores it in a variable
            // for other implementations that needs this patterns with terminal info
            final terminalInfo = await _createTerminal(
              context,
              terminalName,
              terminalToken,
            );

            if (terminalInfo == null) {
              const snackBar = SnackBar(
                content: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 50,
                      color: const Color.fromARGB(255, 206, 51, 51),
                    ),
                    Text("Failed to link terminal. Try again"),
                  ],
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              return;
            }

            const snackBar = SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 50,
                    color: const Color.fromARGB(255, 87, 206, 51),
                  ),
                  Text("Terminal linked successfully"),
                ],
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
          child: Center(
            child: Text(
              "Link Local Terminal",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ),
        );
      },
    );
  }

  Widget _linkTerminalWithToken(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return TextButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              const Color.fromARGB(255, 14, 154, 219),
            ),
            padding: WidgetStateProperty.all(
              EdgeInsets.only(top: 15, bottom: 15),
            ),
          ),
          onPressed: () async {
            final terminalNameController = TextEditingController();
            final terminalName = await showDialog<String>(
              context: context,
              builder: (dialogContext) {
                return StatefulBuilder(
                  builder: (builderContext, setState) {
                    void listener() => setState(() {});
                    terminalNameController.addListener(listener);

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!ModalRoute.of(builderContext)!.isCurrent) {
                        terminalNameController.removeListener(listener);
                      }
                    });

                    return AlertDialog(
                      title: const Text('Link New Terminal'),
                      content: TextField(
                        controller: terminalNameController,
                        decoration: const InputDecoration(
                          labelText: 'Terminal Name',
                        ),
                        autofocus: true,
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                        TextButton(
                          child: const Text('OK'),
                          onPressed: terminalNameController.text.trim().isEmpty
                              ? null
                              : () {
                                  Navigator.of(
                                    dialogContext,
                                  ).pop(terminalNameController.text);
                                },
                        ),
                      ],
                    );
                  },
                );
              },
            );

            if (terminalName == null || terminalName.trim().isEmpty) {
              const snackBar = SnackBar(
                content: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 50,
                      color: const Color.fromARGB(255, 206, 51, 51),
                    ),
                    Text("Failed to link terminal. Try again"),
                  ],
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              return;
            }

            // // Generate a pseudo random 33 bytes that starts with ff to emulate an uninitialized terminal
            // final terminalToken =
            //     "ff" +
            //     hex.encode(
            //       List<int>.generate(32, (i) => Random.secure().nextInt(256)),
            //     );

            // print("${terminalName} ${terminalToken}");

            // final terminalInfo = await _createTerminal(
            //   context,
            //   terminalName,
            //   terminalToken, // Assuming this is passed to your function
            // );

            // // --- This error handling part remains the same ---
            // if (terminalInfo == null) {
            //   // Check if the widget is still mounted before showing UI
            //   if (!context.mounted) return;
            //   const snackBar = SnackBar(
            //     content: Row(
            //       children: [
            //         Icon(
            //           Icons.error_outline,
            //           size: 50,
            //           color: Color.fromARGB(255, 206, 51, 51),
            //         ),
            //         SizedBox(width: 8),
            //         Text("Failed to link terminal. Try again"),
            //       ],
            //     ),
            //   );
            //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
            //   return;
            // }

            // // --- This is the new success dialog ---
            // // Check if the widget is still mounted before showing UI
            // if (!context.mounted) return;

            // final pubkey = terminalInfo["pubkey"];
            // final token = terminalInfo["token"];
            // final initCode = "$pubkey:$token:$terminalName";

            final sparkCoin = Singleton.assetList.assetListState.findAsset("USDB")!.coins[0] as BTKN;
            final sparkInvoice = await sparkCoin.getTerminalLinkAddress(terminalName);
            final initCode = "$sparkInvoice:$terminalName";

            await showDialog(
              context: context,
              builder: (dialogContext) {
                return AlertDialog(
                  title: const Text('Terminal Link Code'),
                  // Use SelectableText to make the code easy to copy manually
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Copy this code and past it in Tejory Terminal to link it:',
                      ),
                      const SizedBox(height: 16),
                      SelectableText(
                        initCode,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace', // Ideal for codes
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Copy'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: initCode));

                        // Optional: Show a confirmation SnackBar
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(content: Text('Copied to clipboard!')),
                        );
                      },
                    ),
                    ElevatedButton(
                      child: const Text('Done'),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Center(
            child: Text(
              "Link Remote Terminal",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ),
        );
      },
    );
  }

  Widget _linkTejoryBusiness(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return TextButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              const Color.fromARGB(255, 14, 154, 219),
            ),
            padding: WidgetStateProperty.all(
              EdgeInsets.only(top: 15, bottom: 15),
            ),
          ),
          onPressed: () async {
            final terminalName =
                "bb" +
                hex.encode(
                  List<int>.generate(32, (i) => Random.secure().nextInt(256)),
                );

            // Generate a pseudo random 33 bytes that starts with ff to emulate an uninitialized terminal
            final terminalToken =
                "ff" +
                hex.encode(
                  List<int>.generate(32, (i) => Random.secure().nextInt(256)),
                );

            print("${terminalName} ${terminalToken}");

            final terminalInfo = await _createTerminal(
              context,
              terminalName,
              terminalToken,
              role: "BUSINESS_APP",
            );

            // --- This error handling part remains the same ---
            if (terminalInfo == null) {
              // Check if the widget is still mounted before showing UI
              if (!context.mounted) return;
              const snackBar = SnackBar(
                content: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 50,
                      color: Color.fromARGB(255, 206, 51, 51),
                    ),
                    SizedBox(width: 8),
                    Text("Failed to link terminal. Try again"),
                  ],
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              return;
            }

            // --- This is the new success dialog ---
            // Check if the widget is still mounted before showing UI
            if (!context.mounted) return;

            final pubkey = terminalInfo["pubkey"];
            final token = terminalInfo["token"];
            final initCode = "$pubkey:$token";

            await showDialog(
              context: context,
              builder: (dialogContext) {
                return AlertDialog(
                  title: const Text('Tejory Business Initialization Code'),
                  // Use SelectableText to make the code easy to copy manually
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Copy this code and paste it in Tejory Business app',
                      ),
                      const SizedBox(height: 16),
                      SelectableText(
                        initCode,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace', // Ideal for codes
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Copy'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: initCode));

                        // Optional: Show a confirmation SnackBar
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(content: Text('Copied to clipboard!')),
                        );
                      },
                    ),
                    ElevatedButton(
                      child: const Text('Done'),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Center(
            child: Text(
              "Link Tejory Business",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _createTerminal(
    BuildContext context,
    String terminalName,
    String? terminalToken, {
    String? role,
  }) async {
    return null;
    // if (terminalToken == null) {
    //   return null;
    // }

    // if (terminalToken.trim().isEmpty) {
    //   return null;
    // }

    // var URL = Uri.parse("https://ln.tejory.io/createterminal");
    // var btcln =
    //     Singleton.assetList.assetListState.findAsset("btcln")!.coins[0]
    //         as BTCLN;
    // Map<String, String> headers = <String, String>{
    //   "pubkey": await btcln.getClientPubkey(),
    //   "token": await btcln.getClientToken(),
    // };
    // Map<String, dynamic> body = {
    //   "terminal_name": terminalName,
    //   "terminal_token": terminalToken,
    // };
    // if (role != null) {
    //   body["terminal_role"] = role;
    // }
    // http.Response response;
    // try {
    //   response = await http.post(
    //     URL,
    //     headers: headers,
    //     body: json.encode(body),
    //   );
    // } catch (e) {
    //   return null;
    // }

    // Map<String, dynamic> jObj =
    //     jsonDecode(response.body) as Map<String, dynamic>;

    // if (!jObj.containsKey("status")) {
    //   return null;
    // }
    // if (jObj["status"] is! String) {
    //   return null;
    // }
    // if (jObj["status"] != "ok") {
    //   return null;
    // }

    // return jObj;
  }
}
