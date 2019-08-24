import 'package:flutter/material.dart';

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
