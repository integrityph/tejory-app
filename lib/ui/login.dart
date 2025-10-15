import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:tejory/coins/historic_price_service.dart';
import 'package:tejory/crypto-helper/other_helpers.dart';
import 'package:tejory/libsecp256k1ffi/libsecp256k1ffi.dart';
import 'package:tejory/singleton.dart';
import 'package:tejory/ui/asset_list.dart';
import 'package:tejory/ui/setup/page_animation.dart';
import 'package:tejory/ui/tejory_page.dart';
import 'package:boringssl_ffi/boringssl_ffi.dart' as bsll;

class Login extends StatefulWidget {
  Login();

  @override
  _LoginState createState() => _LoginState();
}

// local_auth
enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class _LoginState extends State<Login> {
  // local_auth
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  late Future<bool> ready;
  
  @override
  void initState() {
    super.initState();
    Singleton.initNotifications();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    ready = auth.isDeviceSupported().then(
      (bool isSupported) {
        setState(() => _supportState = isSupported
          ? _SupportState.supported
          : _SupportState.unsupported);
        return true;
      }
    );
    Singleton.assetList = AssetList(
      humanizeMoney: OtherHelpers.humanizeMoney,
    );
    Singleton.loaded = Singleton.assetList.assetListState.loadAssets();
    HistoricPriceService.start();
  }

  Future<bool> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason:
            'Login to Tejory Wallet',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      print("authenticated: $authenticated");
    } on PlatformException catch (e) {
      print('authException: ${e}');
      return authenticated;
    }
    if (!mounted) {
      return authenticated;
    }

    return authenticated;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(child: FutureBuilder(future: Singleton.getVersion(), builder:(context, ver){
        return Text("${ver.data??""}${LibSecp256k1FFI.loaded()?"\nLibSecp256k1FFI: OK":""}${(bsll.sha1.hash([])!=null)?"\nBoringSSLFFI: OK":""}", style:TextStyle(fontFamily: "monospace", fontSize: 10));
      })),
      body: Container(
        child: Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right:20, left:20, bottom:200),
              child: Image.asset("assets/logo/tejoryname.png"),
            ),
            ElevatedButton(
              style: ButtonStyle(
                elevation: WidgetStatePropertyAll(8),
                backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.primary),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ))
              ),
              child:Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fingerprint, size: 50, color: Theme.of(context).colorScheme.surface),
                  SizedBox(height: 5),
                  Text("Login", style: TextStyle(fontSize:20, color: Theme.of(context).colorScheme.surface))
                ],
              ),
            ), onPressed: (){
              () async {
                bool auth = false;
                if (_supportState == _SupportState.supported) {
                  auth = await _authenticateWithBiometrics();
                } else {
                  const snackBar = SnackBar(content: Padding(
                    padding: EdgeInsets.symmetric(vertical:8.0),
                    child: Text('Please enable a PIN code or Biometrics to open the app'),
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  await Future.delayed(Duration(seconds: 5));
                }
                if (auth) {
                  if (Singleton.objectbox == null) {
                    const snackBar = SnackBar(content: Padding(
                      padding: EdgeInsets.symmetric(vertical:8.0),
                      child: Text('Unable to open your database. Please reinstall the add and import your wallet again'),
                    ));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    await Future.delayed(Duration(seconds: 5));

                    SystemNavigator.pop();
                    return;
                  }
                  FadeNavigator(context).navigateToReplace(Tejory(key: Singleton.tejoryScaffoldKey), customName: Navigator.defaultRouteName);
                } else {
                  SystemNavigator.pop();
                }
              }();
            }),
          ],
        )),
      ),
    );
  }
}