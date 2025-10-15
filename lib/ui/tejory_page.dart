import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tejory/custom_icons_icons.dart';
import 'package:tejory/singleton.dart';
import 'package:tejory/coins/network.dart';
import 'package:tejory/ui/ramp.dart';
import 'package:tejory/ui/send.dart';
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
  TejoryState createState() => TejoryState();
}

class TejoryState extends State<Tejory> with RouteAware {
  accountSetting? selectedMenu;
  int _currentIndex = 0;

  void changeTab(int index) {
    // Add a check to ensure the index is valid
    if (index >= 0 && index < _pages.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  List<Widget> _pages = (kDebugMode)
      ? [
          HomePage(),
          SwapPage(initialToken: ''),
          RampPage(initialToken: ''),
          SettingsPage(),
        ]
      : [
          HomePage(),
          SwapPage(initialToken: ''),
          RampPage(initialToken: ''),
          SettingsPage(),
        ];

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    Singleton.initNotifications();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

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
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _currentIndex,
      //   items:
      //       (kDebugMode)
      //           ? <BottomNavigationBarItem>[
      //             BottomNavigationBarItem(
      //               icon: Icon(CustomIcons.tejory1),
      //               label: 'Wallet',
      //             ),
      //             BottomNavigationBarItem(
      //               icon: Icon(Icons.swap_horiz),
      //               label: 'Swap',
      //             ),
      //             BottomNavigationBarItem(
      //               icon: Icon(Icons.attach_money_outlined),
      //               label: 'Buy/Sell',
      //             ),
      //             BottomNavigationBarItem(
      //               icon: Icon(Icons.settings),
      //               label: 'Settings',
      //             ),
      //           ]
      //           : <BottomNavigationBarItem>[
      //             BottomNavigationBarItem(
      //               icon: Icon(CustomIcons.tejory1),
      //               label: 'Wallet',
      //             ),
      //             BottomNavigationBarItem(
      //               icon: Icon(Icons.swap_horiz),
      //               label: 'Swap',
      //             ),
      //             BottomNavigationBarItem(
      //               icon: Icon(Icons.settings),
      //               label: 'Settings',
      //             ),
      //           ],
      //   selectedLabelStyle: TextStyle(
      //     fontSize: 18,
      //     fontWeight: FontWeight.bold,
      //   ),
      //   unselectedLabelStyle: TextStyle(
      //     fontSize: 14,
      //     fontWeight: FontWeight.bold,
      //   ),
      //   onTap: (index) {
      //     setState(() {
      //       _currentIndex = index;
      //     });
      //   },
      // ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // Left side icons
            IconButton(
              tooltip: 'Wallet',
              icon: Icon(CustomIcons.tejory1),
              onPressed: () => setState(() => _currentIndex = 0),
            ),
            IconButton(
              tooltip: 'Swap',
              icon: Icon(Icons.swap_horiz),
              onPressed: () => setState(() => _currentIndex = 1),
            ),

            // The empty space for the Floating Action Button
            SizedBox(width: 48),

            IconButton(
              tooltip: 'Buy/Sell',
              icon: Icon(Icons.attach_money_outlined),
              onPressed: () => setState(() => _currentIndex = 2),
            ),

            // Right side icon
            IconButton(
              tooltip: 'Settings',
              icon: Icon(Icons.settings),
              onPressed: () => setState(() => _currentIndex = 3),
            ),

            // Add an invisible spacer to balance the layout
            // This makes the right side take up the same space as the two icons on the left
            SizedBox.shrink(),
          ],
        ),
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 18),
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          child: Icon(
            Icons.qr_code_scanner,
            color: Color.fromARGB(255, 219, 14, 14),
            size: 30,
          ),
          shape: CircleBorder(),
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            showModalBottomSheet(
              context: context,
              // transitionAnimationController: controller,
              isScrollControlled: true,
              builder: (BuildContext context) {
                return SingleChildScrollView(
                  child: SizedBox(
                    height: 700,
                    child: Sender(address: '', startInQR: true),
                  ),
                );
              },
            );
          },
        ),
      ),

      // 2. Set the location to center docked
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
