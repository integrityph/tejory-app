import 'package:flutter/material.dart';
import 'package:tejory/ui/setup/advance_import.dart';
import 'package:tejory/ui/setup/download_page.dart';
import 'package:tejory/ui/setup/page_animation.dart';

class HardwareSoftware extends StatefulWidget {
  final List<int> entropy;
  final bool isNew;
  HardwareSoftware(
      {super.key, required List<int> this.entropy, required this.isNew});

  @override
  _HardwareSoftware createState() => _HardwareSoftware();
}

class _HardwareSoftware extends State<HardwareSoftware> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  // String sendDialogMessage = "";
  // final String msgSigning =
  //     "NFC Signing Transaction. Put your phone on the hardware wallet";
  String selectedToken = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Wallet',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blue),
        ),
      ),
      body: Column(
        children: [
          _walletType(),
          //  _softwareWallet(),
          _hardwareWallet()
        ],
      ),
    );
  }

  Widget _walletType() {
    return Padding(
      padding: EdgeInsets.only(top: 10, right: 20, left: 40),
      child: Text(
        'Choose Type of Wallet You Have',
        style: TextStyle(fontSize: 25),
        textAlign: TextAlign.center,
      ),
    );
  }

//   Widget _softwareWallet() {
//     return Padding(
//       padding: const EdgeInsets.only(top: 30),
//       child: Card(
//         child: InkWell(
//           onTap: () {
//             if (widget.isNew) {
//               FadeNavigator(context).navigateTo(DownloadPage(
//                   entropy: widget.entropy,
//                   isSoftware: true,
//                   isNew: widget.isNew));
//             } else {
//               FadeNavigator(context).navigateTo(AdvanceImport(
//                   isNew: false, entropy: widget.entropy, isSoftware: true));
//             }
//           },
//           child: ListTile(
//             leading: Icon(Icons.abc),
//             title: Text(
//               'Software Wallet',
//               style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.blue),
//             ),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Most Convenient (BASIC)',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 8.0),
//                   child: Text('''• Better for Quick Transactions
// • Good for Small Amounts of Crypto
// • Hot Wallet (Connected to the Internet)
// • Self-Custody (You have your own private keys)'''),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

  Widget _hardwareWallet() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Card(
        child: InkWell(
          onTap: () async {
            if (widget.isNew) {
              FadeNavigator(context).navigateTo(DownloadPage(
                  entropy: widget.entropy,
                  isSoftware: false,
                  isNew: widget.isNew));
            } else {
              FadeNavigator(context).navigateTo(AdvanceImport(
                  isNew: widget.isNew,
                  entropy: widget.entropy,
                  isSoftware: false));
            }
          },
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.abc),
                title: Text('Hardware Wallet',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Highest Security (PRO)',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('''• Better for Long Term Storage
• Good for Large Amounts of Crypto
• Cold Wallet (Not connected to the Internet)
• Self-Custody (You have your own private keys)
    
Supported Hardware Wallets:
• Tejory Card Wallet'''),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}