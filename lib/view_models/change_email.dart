import 'dart:async';

import 'package:aperture/locator.dart';
import 'package:aperture/models/users/user.dart';
import 'package:aperture/resources/app_info.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/ui/utils/shortcuts.dart';
import 'package:aperture/utils/utils.dart';
import 'package:aperture/view_models/core/base_model.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

enum ChangeEmailViewState { Idle, Updating }

class ChangeEmailModel extends StateModel<ChangeEmailViewState> {
  final Repository _repository = locator<Repository>();
  final AppInfo _appInfo = locator<AppInfo>();

  PublishSubject<bool> _obscureTextController = PublishSubject();

  /////////////////////////////////////////////////////////////////////////

  final scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  FocusNode _emailFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();

  /////////////////////////////////////////////////////////////////////////

  ChangeEmailModel() : super(ChangeEmailViewState.Idle);

  /////////////////////////////////////////////////////////////////////////

  // * Dispose
  void dispose() {
    super.dispose();
    _obscureTextController.close();

    _emailController?.dispose();
    _passwordController?.dispose();
    _emailFocusNode?.dispose();
    _passwordFocusNode?.dispose();
  }

  /////////////////////////////////////////////////////////////////////////

  void toggleObscureText(bool newValue) {
    _obscureTextController.sink.add(newValue);
  }

  /////////////////////////////////////////////////////////////////////////

  Future<void> updateUserEmail(BuildContext context) async {
    setState(ChangeEmailViewState.Updating);

    String newEmail = _emailController.text.trim();
    String password = _passwordController.text;

    // Validations
    if (newEmail.isEmpty || password.isEmpty) {
      setState(ChangeEmailViewState.Idle);
      showInSnackBar(context, scaffoldKey, 'All fields must be filled');
      return;
    }

    if (!isEmail(newEmail)) {
      setState(ChangeEmailViewState.Idle);
      showInSnackBar(context, scaffoldKey, 'Invalid email address');
      return;
    }

    User user = User.from(_appInfo.currentUser);

    if (newEmail == user.email) {
      setState(ChangeEmailViewState.Idle);
      showInSnackBar(context, scaffoldKey,
          'New email cannot be the same as the current email');
      return;
    }

    // Post to server
    int result = await _repository.updateUserEmail(newEmail, password);
    if (result == 0) {
      user.email = newEmail;
      await _appInfo.updateUser(user);
      Navigator.of(context).pop(result);
    } else {
      setState(ChangeEmailViewState.Idle);
      showInSnackBar(context, scaffoldKey,
          'The provided password does not match the current password');
    }
  }

  /////////////////////////////////////////////////////////////////////////

  Stream<bool> get obscureText => _obscureTextController.stream;
  String get email => _appInfo.currentUser.email;

  /////////////////////////////////////////////////////////////////////////

  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  FocusNode get emailFocusNode => _emailFocusNode;
  FocusNode get passwordFocusNode => _passwordFocusNode;
}
