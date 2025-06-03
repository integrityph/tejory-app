import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:tejory/ui/tejory_page.dart';

void main() => runApp(MaterialApp(home: Tejory()));

class Qrscanner extends StatefulWidget {
  Qrscanner({Key? key}) : super(key: key);

  _QRViewExampleState createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<Qrscanner> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          _qrDetails()
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 1000 ||
            MediaQuery.of(context).size.height < 1000)
        ? 300.0
        : 300.0;

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.blue,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          overlayColor: Colors.black,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  Widget _qrDetails() {
    return Expanded(
      flex: 1,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            if (result != null)
              Text('${result!.code}')
            else
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Scan a QRcode',
                  style: TextStyle(fontSize: 10),
                ),
              ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(10),
                  child: ElevatedButton(
                      onPressed: () async {
                        await controller?.flipCamera();
                        setState(() {});
                      },
                      child: FutureBuilder(
                        future: controller?.getCameraInfo(),
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            return Text(
                              'Camera Facing ${(snapshot.data!.name)}',
                              style: TextStyle(),
                            );
                          } else {
                            return Text('loading');
                          }
                        },
                      )),
                )
              ],
            ),
            ElevatedButton(onPressed: (){
              Navigator.of(context).pop();
            }, child: Text("Cancel")),
            // if (result != null)
            //   ElevatedButton(
            //     onPressed: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => Sender(
            //             networkList: networkList,
            //             address: result!.code!,
            //           ),
            //         ),
            //       );
            //     },
            //     child: Text('Proceed to Send'),
            //   ),
          ],
        ),
      ),
    );
  }

  var poped = false;

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null && scanData.code!.length > 10) {
        if (!poped && context.mounted) {
          poped = true;
          Navigator.of(context).pop(scanData.code!);
        }
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
