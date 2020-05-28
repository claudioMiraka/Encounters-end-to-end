import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import '../../GlobalVariables.dart' as global;

class CustomSnackbar {
  String message;
  BuildContext context;
  int duration;

  CustomSnackbar(
      {@required this.message, @required this.context, this.duration});

  show() {
    Flushbar(
      messageText: Text(
        this.message,
        style: global.styleText.copyWith(color: Colors.white, fontSize: 15),
      ),
      backgroundGradient: LinearGradient(
        colors: [global.primaryThemeColor, global.secondThemeColor],
      ),
      backgroundColor: Colors.red,
      flushbarStyle: FlushbarStyle.FLOATING,
      duration: Duration(seconds: duration == null ? 3 : duration),
      boxShadows: [
        BoxShadow(
          color: Colors.blue[800],
          offset: Offset(0.0, 2.0),
          blurRadius: 3.0,
        )
      ],
    ).show(context);
  }
}
