import 'package:flutter/material.dart';
import 'package:tejory/ui/setup/createwallet.dart';
import 'package:tejory/ui/setup/importwallet.dart';
import 'package:tejory/ui/setup/page_animation.dart';

class StartSetup extends StatefulWidget {
  StartSetup({super.key});

  @override
  State<StartSetup> createState() => _StartSetup();
}

class _StartSetup extends State<StartSetup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [_appName(), _appLogo(), _createOrImport(), _compLogo()],
      ),
    );
  }

  Widget _appName() {
    return Padding(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
      child: Center(child: Image.asset('assets/logo/tejoryname.png')),
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

  Widget _createOrImport() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          SizedBox(
            width: 300,
            child: ElevatedButton(
              onPressed: () {
                FadeNavigator(context).navigateTo(CreateWallet());
              },
              child: Text('Create a New Wallet'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SizedBox(
              width: 300,
              child: ElevatedButton(
                onPressed: () {
                  FadeNavigator(context).navigateTo(ImportWallet());
                },
                child: Text('Import an Existing Wallet'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _compLogo() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 100,
            child: Image.asset('assets/integritynet-logo-red.png'),
          ),
        ],
      ),
    );
  }
}
