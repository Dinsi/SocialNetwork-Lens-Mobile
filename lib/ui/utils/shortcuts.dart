import 'package:flutter/material.dart';

CircularProgressIndicator getWhiteCircularIndicator() =>
    CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
    );

void showInSnackBar(
    BuildContext context, GlobalKey<ScaffoldState> gKey, String value) {
  FocusScope.of(context).requestFocus(FocusNode());
  gKey.currentState?.removeCurrentSnackBar();
  gKey.currentState.showSnackBar(
    SnackBar(
      content: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontFamily: "WorkSansSemiBold"),
      ),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 3),
    ),
  );
}
