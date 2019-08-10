import 'package:flutter/material.dart';

CircularProgressIndicator getWhiteCircularIndicator() =>
    CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
    );

void showInSnackBar(
    BuildContext context, GlobalKey<ScaffoldState> gKey, String value) {
  FocusScope.of(context).requestFocus(FocusNode());
  gKey.currentState.hideCurrentSnackBar();
  gKey.currentState.showSnackBar(
    SnackBar(
      content: Text(
        value,
        textAlign: TextAlign.center,
      ),
    ),
  );
}
