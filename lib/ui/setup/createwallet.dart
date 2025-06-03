import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:tejory/ui/setup/hardware_software.dart';

class CreateWallet extends StatefulWidget {
  @override
  State<CreateWallet> createState() => _CreateWalletState();
}

class _CreateWalletState extends State<CreateWallet> {
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  Duration sensorInterval = Duration(milliseconds: 150);
  final THRESHOLD = 0.7;
  double progress = 0.0;
  final int numberOfValues = 32;
  List<int> entropy = [];
  DateTime lastEvent = DateTime.now();

  @override
  void initState() {
    super.initState();
    _streamSubscriptions.add(
        userAccelerometerEventStream(samplingPeriod: sensorInterval).listen(
      (UserAccelerometerEvent event) {
        if (DateTime.now().isBefore(lastEvent.add(sensorInterval))) {
          return;
        }
        lastEvent = DateTime.now();
        // skip if there is not enough acceleration
        if (event.x < THRESHOLD && event.y < THRESHOLD && event.z < THRESHOLD) {
          return;
        }

        // add a value to entropy
        var byteData = ByteData(8 * 3);
        byteData.setFloat64(8 * 0, event.x);
        byteData.setFloat64(8 * 1, event.y);
        byteData.setFloat64(8 * 2, event.z);
        entropy.add(md5.convert(byteData.buffer.asUint8List()).bytes[0]);
        setState(() {
          progress = entropy.length.toDouble() / numberOfValues.toDouble();
        });

        if (progress >= 1.0) {
          _streamSubscriptions[0].cancel();
          var random = Random.secure();
          for (int i = 0; i < entropy.length; i++) {
            entropy[i] = random.nextInt(256) ^ entropy[i];
          }
          Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(
                  builder: (BuildContext context) => HardwareSoftware(
                        isNew: true,
                        entropy: entropy,
                      )));
        }
      },
      onError: (e) {},
      cancelOnError: true,
    ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 50),
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage('assets/background/shake.png'),
            fit: BoxFit.contain,
          )),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_shake(), _progress()],
          ),
        ),
      ),
    );
  }

  Widget _shake() {
    return Padding(
      padding: const EdgeInsets.only(top: 90),
      child: Text(
        'Please Shake your Phone',
        style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _progress() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: LinearProgressIndicator(
            value: progress,
            semanticsLabel: 'Linear progress indicator',
          ),
        ),
        ElevatedButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            }),
      ],
    );
  }
}
