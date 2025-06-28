import 'package:flutter/material.dart';

class Numpad extends StatefulWidget {
  final bool autoShow;
  final TextEditingController? keyboardController;
  final void Function(NumpadState numpadState)? onEditingCompleteKeyboard;
  Numpad({this.autoShow=false, this.keyboardController=null, this.onEditingCompleteKeyboard=null});

  final NumpadState state = NumpadState();

  @override
  NumpadState createState() => state;
}

class NumpadState extends State<Numpad> {
  bool visibleKeyboard = false;
  TextEditingController? keyboardController;
  void Function(NumpadState numpadState)? onEditingCompleteKeyboard;

  NumpadState();

  @override
  void initState() {
    super.initState();
    keyboardController = widget.keyboardController;
    onEditingCompleteKeyboard = widget.onEditingCompleteKeyboard;
    visibleKeyboard = widget.autoShow;
  }

  void openKeyboard(TextEditingController controller,
      {void Function(NumpadState numpadState)? onEditingComplete}) {
    setState(() {
      visibleKeyboard = true;
    });
    keyboardController = controller;
    onEditingCompleteKeyboard = onEditingComplete;
  }

  void setVisible(bool val) {
    setState(() {
      visibleKeyboard = val;
    });
  }

  Widget build(BuildContext context) {
    return Positioned(
        left: 0,
        bottom: 0,
        child: Visibility(
          visible: visibleKeyboard,
          child: Container(
            decoration: BoxDecoration(color: Color.fromARGB(255, 50, 50, 50)),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  SizedBox(height: 1),
                  Row(
                    spacing: 5,
                    children: [
                      _getButton("1"),
                      _getButton("2"),
                      _getButton("3"),
                      _getButton("C"),
                    ],
                  ),
                  Row(
                    spacing: 5,
                    children: [
                      _getButton("4"),
                      _getButton("5"),
                      _getButton("6"),
                      _getButton("<"),
                    ],
                  ),
                  Row(
                    spacing: 5,
                    children: [
                      _getButton("7"),
                      _getButton("8"),
                      _getButton("9"),
                      _getButton("OK", color: Colors.green),
                    ],
                  ),
                  Row(
                    spacing: 5,
                    children: [
                      // _getButton("", spacer: true),
                      _getButton("0",
                          width: (MediaQuery.of(context).size.width - 5) / 2),
                      _getButton("."),
                    ],
                  ),
                  SizedBox(height: 25)
                ]),
          ),
        ));
  }

  Widget _getButton(String text,
      {void Function()? action,
      double? width,
      bool spacer = false,
      Color color = const Color.fromARGB(255, 114, 114, 114)}) {
    double fullWidth = MediaQuery.of(context).size.width - 15;
    if (spacer) {
      return Container(
        width: width ?? fullWidth / 4,
        height: fullWidth / 6,
      );
    }
    return TextButton(
        onPressed: action ??
            () {
              if (keyboardController == null) {
                return;
              }
              if (text == "C") {
                keyboardController!.text = "0";
                keyboardController!.text = "";
                return;
              }
              if (text == "<") {
                if (keyboardController!.text != "") {
                  keyboardController!.text = keyboardController!.text
                      .substring(0, keyboardController!.text.length - 1);
                }
                return;
              }
              if (text == "OK") {
                setState(() {
                  visibleKeyboard = false;
                });
                FocusManager.instance.primaryFocus?.unfocus();
                if (onEditingCompleteKeyboard != null) {
                  onEditingCompleteKeyboard!(this);
                }
                return;
              }
              keyboardController!.text += text;
            },
        style: ButtonStyle(
          backgroundColor:
              WidgetStateProperty.all(color),
          shape: WidgetStateProperty.all(ContinuousRectangleBorder()),
          fixedSize: WidgetStateProperty.all(
              Size(width ?? fullWidth / 4, fullWidth / 6)),
        ),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ));
  }
}
