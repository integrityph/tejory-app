import 'package:flutter/material.dart';
import 'package:tejory/ui/setup/download_block.dart';
import 'package:tejory/ui/setup/download_page.dart';
import 'package:tejory/ui/setup/page_animation.dart';

class AdvanceImport extends StatefulWidget {
  late final List<int> entropy;
  late final bool isNew;
  late final bool isSoftware;
  AdvanceImport({
    super.key,
    required bool this.isSoftware,
    required List<int> this.entropy,
    required this.isNew,
  });

  @override
  _AdvanceImport createState() => _AdvanceImport();
}

class _AdvanceImport extends State<AdvanceImport> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [_importType(), _basicImport(), _advanceImport()]),
    );
  }

  Widget _importType() {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Text(
        'Import Wallet Method',
        style: TextStyle(fontSize: 25),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _basicImport() {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Card(
        child: InkWell(
          onTap: () async {
            FadeNavigator(context).navigateTo(
              DownloadPage(
                entropy: widget.entropy,
                isSoftware: widget.isSoftware,
                isNew: widget.isNew,
                easyImport: true,
              ),
            );
          },
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.abc),
                title: Text(
                  'Basic Import',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('''• Very Fast
• Less Storage
• Less Bandwidth
• Uses RPC API (Less Privacy)'''),
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

  Widget _advanceImport() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Card(
        child: InkWell(
          onTap: () async {
            FadeNavigator(context).navigateTo(
              DownloadBlock(
                entropy: widget.entropy,
                isSoftware: widget.isSoftware,
              ),
            );
          },
          child: ListTile(
            leading: Icon(Icons.abc),
            title: Text(
              'Advanced Import',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.blue,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('''• Slow (Take Hours)
• More Bandwidth
• More Storage
• Uses P2p API (More Privacy))'''),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
