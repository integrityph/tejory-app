import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tejory/coins/historic_price_service.dart';
import 'package:tejory/crypto-helper/other_helpers.dart';
import 'package:tejory/crypto-helper/se_helper.dart';
import 'package:tejory/singleton.dart';
import 'package:tejory/ui/asset_list.dart';
import 'package:tejory/ui/setup/page_animation.dart';
import 'package:tejory/ui/tejory_page.dart';
import 'package:boringssl_ffi/boringssl_ffi.dart' as bssl;
import 'package:secp256k1_ffi/secp256k1_ffi.dart';

class Login extends StatefulWidget {
  Login();

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login>  with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Future<bool> ready;
  
  @override
  void initState() {
    super.initState();

    sanityCheck();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    _controller = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _animation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.1),
        weight: 2.5,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.1, end: -0.1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ConstantTween(-0.1),
        weight: 0.5,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -0.1, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.0),
        weight: 0.5,
      ),
    ]).animate(_controller);

    HistoricPriceService.start();

    Singleton.assetList = AssetList(
      humanizeMoney: OtherHelpers.humanizeMoney,
    );

    () async {
      await Singleton.initNotifications();
      Singleton.loaded = Singleton.assetList.assetListState.loadAssets();
      while (true) {
        final ok = await SEHelper.unlock();
        if (!ok) {
          const snackBar = SnackBar(content: Padding(
            padding: EdgeInsets.symmetric(vertical:8.0),
            child: Text('Failed biometrics verification. Try again.'),
          ));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          continue;
        }

        if (!context.mounted) {
          return;
        }

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
        () async {
          await Singleton.loaded;
          await Future.wait(Singleton.assetList.assetListState.assets
            .where((asset) => asset.isolate != null)
            .map((asset) => asset.isolate!.ready()));
          Singleton.assetList.assetListState.assets.forEach((asset) {
            if (asset.coins.length == 0) {
              return;
            }
            asset.coins[0].setSeReady();
          });
        }();
        return;
      }
    }();
  }

  void sanityCheck() {
    if (bssl.sha1.hash([])==null) {
      throw Exception("boringSSLFFI didn't load");
    }
    if (secp256k1FFI.taggedSHA256.hash([],[])==null) {
      throw Exception("secp256k1FFI didn't load");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(child: FutureBuilder(future: Singleton.getVersion(), builder:(context, ver){
        return Text("${ver.data??""}${(secp256k1FFI.taggedSHA256.hash([],[])!=null)?"\nLibSecp256k1FFI: OK":""}${(bssl.sha1.hash([])!=null)?"\nBoringSSLFFI: OK":""}", style:TextStyle(fontFamily: "monospace", fontSize: 10));
      })),
      body: Container(
        child: Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right:20, left:20, bottom:100),
              child: Image.asset("assets/logo/tejoryname.png"),
            ),
            // ElevatedButton(
            //   style: ButtonStyle(
            //     elevation: WidgetStatePropertyAll(8),
            //     backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.primary),
            //     shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            //       RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(8.0),
            //       ))
            //   ),
            //   child: Padding(
            //     padding: const EdgeInsets.all(20.0),
            //     child: Column(
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         Icon(Icons.fingerprint, size: 50, color: Theme.of(context).colorScheme.surface),
            //         SizedBox(height: 5),
            //         Text("Login", style: TextStyle(fontSize:20, color: Theme.of(context).colorScheme.surface))
            //       ],
            //     ),
            //   ), onPressed: null,
            // ),
            _appLogo(),
          ],
        )),
      ),
    );
  }

    Widget _appLogo() {
    return Center(
      child: RotationTransition(
        turns: _animation,
        child: Image.asset('assets/logo/TEJORY_logo.png'),
      ),
    );
  }
}