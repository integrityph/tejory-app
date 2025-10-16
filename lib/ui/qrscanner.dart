import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tejory/ui/tejory_page.dart';

void main() => runApp(MaterialApp(home: Tejory()));

class QRScanner extends StatefulWidget {
  QRScanner({Key? key}) : super(key: key);

  _QRViewExampleState createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRScanner> {
  Barcode? _barcode;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

final MobileScannerController controller = MobileScannerController(
  // cameraResolution: const Size(300,300),
  // detectionSpeed: detectionSpeed,
  // detectionTimeoutMs: detectionTimeout,
  // formats: selectedFormats,
  // returnImage: returnImage,
  torchEnabled: false,
  invertImage: false,
  autoZoom: false,
  facing: CameraFacing.back,
  initialZoom: 0.5,
);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                MobileScanner(
                  fit: BoxFit.cover,
                  onDetect: _handleBarcode,
                  controller: controller,
                  tapToFocus: true,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    height: 100,
                    color: const Color.fromRGBO(0, 0, 0, 0.4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Center(child: _barcodePreview(_barcode)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _qrDetails(),
        ],
      ),
    );
  }

  // Widget _buildQrView(BuildContext context) {
  //   var scanArea = (MediaQuery.of(context).size.width < 1000 ||
  //           MediaQuery.of(context).size.height < 1000)
  //       ? 300.0
  //       : 300.0;

  //   return QRView(
  //     key: qrKey,
  //     onQRViewCreated: _onQRViewCreated,
  //     overlay: QrScannerOverlayShape(
  //         borderColor: Colors.blue,
  //         borderRadius: 10,
  //         borderLength: 30,
  //         borderWidth: 10,
  //         overlayColor: Colors.black,
  //         cutOutSize: scanArea),
  //     onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
  //   );
  // }

  Widget _barcodePreview(Barcode? value) {
    if (value == null) {
      return const Text(
        'Scan something!',
        overflow: TextOverflow.fade,
        style: TextStyle(color: Colors.white),
      );
    }

    return Text(
      value.displayValue ?? 'No display value.',
      overflow: TextOverflow.fade,
      style: const TextStyle(color: Colors.white),
    );
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    if (mounted) {
      setState(() {
        _barcode = barcodes.barcodes.firstOrNull;
        if (_barcode != null &&
            _barcode!.rawValue != null &&
            _barcode!.rawValue!.length > 10) {
          if (!poped && context.mounted) {
            poped = true;
            Navigator.of(context).pop(_barcode!.rawValue!);
          }
        }
      });
    }
  }

  Widget _qrDetails() {
    return Expanded(
      flex: 1,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            if (_barcode != null)
              Text('${_barcode!.rawValue}')
            else
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text('Scan a QRcode', style: TextStyle(fontSize: 10)),
              ),
            SizedBox(height: 10),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: <Widget>[
            //     Container(
            //       margin: const EdgeInsets.all(10),
            //       child: ElevatedButton(
            //         onPressed: () async {
            //           await controller?.flipCamera();
            //           setState(() {});
            //         },
            //         child: FutureBuilder(
            //           future: controller?.(),
            //           builder: (context, snapshot) {
            //             if (snapshot.data != null) {
            //               return Text(
            //                 'Camera Facing ${(snapshot.data!.name)}',
            //                 style: TextStyle(),
            //               );
            //             } else {
            //               return Text('loading');
            //             }
            //           },
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
          ],
        ),
      ),
    );
  }

  var poped = false;

  // void _onQRViewCreated(QRViewController controller) {
  //   setState(() {
  //     this.controller = controller;
  //   });
  //   controller.scannedDataStream.listen((scanData) {
  //     if (scanData.code != null && scanData.code!.length > 10) {
  //       if (!poped && context.mounted) {
  //         poped = true;
  //         Navigator.of(context).pop(scanData.code!);
  //       }
  //     }
  //   });
  // }

  // void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
  //   log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
  //   if (!p) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('no Permission')));
  //   }
  // }

  @override
  void dispose() {
    
    super.dispose();
    controller.dispose();
  }
}
