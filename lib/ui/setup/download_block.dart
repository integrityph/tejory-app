import 'package:flutter/material.dart';
import 'package:tejory/ui/setup/download_page.dart';
import 'package:tejory/ui/setup/page_animation.dart';

class DownloadBlock extends StatefulWidget {
  late final List<int> entropy;
  late final bool isSoftware;
  late final bool isNew;
  DownloadBlock({
    super.key,
    required bool this.isSoftware,
    required List<int> this.entropy,
  });
  @override
  _DownloadBlock createState() => _DownloadBlock();
}

class _DownloadBlock extends State<DownloadBlock> {
  bool optionBool = true;
  late int dropdownValue = yearList.first;
  List<int> yearList = List<int>.generate(
          DateTime.now().year - 2009 + 1, (int index) => index + 2009,
          growable: true)
      .reversed
      .toList();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          'Advanced Input Options',
          style: TextStyle(fontSize: 24, color: Colors.blue),
        )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [_question(), _yes(), _no(), _proceedButton()],
        ),
      ),
    );
  }

  Widget _question() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        'Do you remember when you created this wallet?',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _yes() {
    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: Checkbox(
              value: optionBool,
              onChanged: (bool? newValue) {
                setState(() {
                  optionBool = newValue!;
                });
              },
            ),
            title: Text(
              'Yes',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        Visibility(
          visible: optionBool,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            margin: EdgeInsets.zero,
            child: Center(
              child: SizedBox(
                width: 300,
                child: DropdownButton<int>(
                  value: dropdownValue,
                  icon: Icon(Icons.arrow_drop_down),
                  iconSize: 18,
                  style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black54,
                      fontSize: 16),
                  underline: Container(
                    height: 0.5,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black54,
                  ),
                  onChanged: (int? value) {
                    setState(() {
                      dropdownValue = value!;
                    });
                  },
                  items: yearList.map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: SizedBox(width: 280, child: Text('$value')),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _no() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: Checkbox(
              value: !optionBool,
              onChanged: (bool? newValue) {
                setState(() {
                  optionBool = !newValue!;
                });
              },
            ),
            title: Text(
              'No',
              style: TextStyle(fontSize: 16),
            ),
          ),
          Visibility(
            visible: !optionBool,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.orange, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.warning, color: Colors.orange, size: 40),
                        SizedBox(height: 10),
                        Text(
                          'WARNING',
                          style: TextStyle(
                              color: Colors.orange,
                              fontSize: 20,
                              fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'The app will download the complete blockchain. This process will take a very long time which might take a day to several days.',
                          style: TextStyle(color: Colors.orange, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _proceedButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Center(
          child: ElevatedButton(
              onPressed: () {
                FadeNavigator(context).navigateTo(DownloadPage(
                  isNew: false,
                  entropy: widget.entropy,
                  isSoftware: widget.isSoftware,
                  easyImport: false,
                  startYear: dropdownValue,
                ));
              },
              child: Text('Proceed'))),
    );
  }
}
