import 'dart:async';

import 'package:aperture/locator.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/ui/utils/shortcuts.dart';
import 'package:aperture/view_models/core/base_model.dart';
import 'package:flutter/material.dart';

enum PasswordField { Old, New, Confirmed }

enum ChangePasswordViewState { Idle, Updating }

class ChangePasswordModel extends StateModel<ChangePasswordViewState> {
  final Repository _repository = locator<Repository>();

  StreamController<bool> _oldPwdController = StreamController();
  StreamController<bool> _newPwdController = StreamController();
  StreamController<bool> _confirmedPwdController = StreamController();

  /////////////////////////////////////////////////////////////////////////

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final Map<PasswordField, TextEditingController> _textControllers = {
    PasswordField.Old: TextEditingController(),
    PasswordField.New: TextEditingController(),
    PasswordField.Confirmed: TextEditingController(),
  };

  final Map<PasswordField, FocusNode> _focusNodes = {
    PasswordField.Old: FocusNode(),
    PasswordField.New: FocusNode(),
    PasswordField.Confirmed: FocusNode(),
  };

  /////////////////////////////////////////////////////////////////////////

  ChangePasswordModel() : super(ChangePasswordViewState.Idle);

  /////////////////////////////////////////////////////////////////////////

  // * Dispose
  void dispose() {
    super.dispose();
    _oldPwdController.close();
    _newPwdController.close();
    _confirmedPwdController.close();

    _textControllers.forEach((_, controller) => controller?.dispose());
    _focusNodes.forEach((_, controller) => controller?.dispose());
  }

  /////////////////////////////////////////////////////////////////////////F

  // * Public Functions
  void toggleObscureText(PasswordField field, bool newValue) {
    switch (field) {
      case PasswordField.Old:
        _oldPwdController.sink.add(newValue);
        break;
      case PasswordField.New:
        _newPwdController.sink.add(newValue);
        break;
      case PasswordField.Confirmed:
        _confirmedPwdController.sink.add(newValue);
    }
  }

  Future<void> updateUserPassword(BuildContext context) async {
    setState(ChangePasswordViewState.Updating);

    String oldPassword = textControllers[PasswordField.Old].text.trim();
    String newPassword = textControllers[PasswordField.New].text.trim();
    String confirmationPassword =
        textControllers[PasswordField.Confirmed].text.trim();

    // Validations
    if (oldPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmationPassword.isEmpty) {
      setState(ChangePasswordViewState.Idle);
      showInSnackBar(context, scaffoldKey, 'All fields must be filled');
      return;
    }

    if (newPassword != confirmationPassword) {
      setState(ChangePasswordViewState.Idle);
      showInSnackBar(context, scaffoldKey, 'Passwords don\'t match');
      return;
    }

    int result = await _repository.changeUserPassword(
        oldPassword, newPassword, confirmationPassword);
    if (result != 0) {
      setState(ChangePasswordViewState.Idle);
      showInSnackBar(
          context, scaffoldKey, 'The old password provided is invalid');
      return;
    }

    Navigator.of(context).pop(result);
  }

  /////////////////////////////////////////////////////////////////////////

  Stream<bool> get oldPwdObscureText => _oldPwdController.stream;
  Stream<bool> get newPwdObscureText => _newPwdController.stream;
  Stream<bool> get confirmedPwdObscureText => _confirmedPwdController.stream;

  /////////////////////////////////////////////////////////////////////////

  Map<PasswordField, TextEditingController> get textControllers =>
      _textControllers;
  Map<PasswordField, FocusNode> get focusNodes => _focusNodes;
}
