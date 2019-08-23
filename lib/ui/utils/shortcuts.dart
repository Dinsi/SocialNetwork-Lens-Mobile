import 'package:flutter/material.dart';

const textFieldtextStyle = TextStyle(fontSize: 18.0);

CircularProgressIndicator defaultCircularIndicator() =>
    const CircularProgressIndicator(
      valueColor: const AlwaysStoppedAnimation<Color>(
        Colors.blueGrey,
      ),
    );

void showInSnackBar(
    BuildContext context, GlobalKey<ScaffoldState> gKey, String value) {
  FocusScope.of(context).unfocus();
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
