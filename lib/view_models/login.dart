import 'dart:async';

import 'package:aperture/locator.dart';
import 'package:aperture/models/users/user.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/router.dart';
import 'package:aperture/ui/utils/shortcuts.dart';
import 'package:aperture/utils/utils.dart';
import 'package:aperture/view_models/core/base_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

enum LoginField {
  SignInUsername,
  SignInPassword,
  SignUpUsername,
  SignUpFirstName,
  SignUpLastName,
  SignUpEmail,
  SignUpPassword,
  SignUpConfirmPassword,
}

class LoginModel extends BaseModel {
  final Repository _repository = locator<Repository>();

  ///////////////////////////////////////////////////////////

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final pageController = PageController();

  final Map<LoginField, TextEditingController> textControllers =
      Map.unmodifiable(
    Map.fromIterables(
      LoginField.values,
      List.generate(LoginField.values.length, (_) => TextEditingController()),
    ),
  );

  final Map<LoginField, FocusNode> focusNodes = Map.unmodifiable(
    Map.fromIterables(
      LoginField.values,
      List.generate(LoginField.values.length, (_) => FocusNode()),
    ),
  );

  final Map<LoginField, BehaviorSubject<bool>> _obscurityControllers =
      Map.unmodifiable({
    LoginField.SignInPassword: BehaviorSubject<bool>.seeded(true),
    LoginField.SignUpPassword: BehaviorSubject<bool>.seeded(true),
    LoginField.SignUpConfirmPassword: BehaviorSubject<bool>.seeded(true),
  });

  final _buttonsController = PublishSubject<bool>();

  ///////////////////////////////////////////////////////////
  // * Dispose
  @override
  void dispose() {
    pageController.dispose();

    textControllers.forEach((_, controller) => controller.dispose());
    focusNodes.forEach((_, node) => node.dispose());
    _obscurityControllers.forEach((_, controller) => controller.close());

    _buttonsController.close();
  }

  ///////////////////////////////////////////////////////////
  // * Public Functions
  void signInOrSignUp(BuildContext context) =>
      pageController.page == 0 ? _signIn(context) : _signUp(context);

  void toggleObscureText(LoginField field) =>
      _obscurityControllers[field].add(!_obscurityControllers[field].value);

  void togglePage() {
    pageController?.animateToPage(
      pageController.page.toInt() ^ 1,
      duration: Duration(milliseconds: 650),
      curve: Curves.easeInOut,
    );
  }

  ///////////////////////////////////////////////////////////
  // * Private Functions
  Future<void> _signIn(BuildContext context) async {
    _buttonsController.add(false);

    final username = textControllers[LoginField.SignInUsername].text.trim();
    final password = textControllers[LoginField.SignInPassword].text;

    if (username.isEmpty || password.isEmpty) {
      showInSnackBar(context, scaffoldKey, 'Username and password required');
      _buttonsController.add(true);
      return;
    }

    int code = await _repository.login(username, password);

    if (code == 0) {
      User user = await _repository.fetchUserInfo();
      if (user != null) {
        Navigator.of(context).pushReplacementNamed(!user.hasFinishedRegister
            ? RouteName.recommendedTopics
            : RouteName.userInfo);
        return;
      }

      showInSnackBar(
          context, scaffoldKey, 'Network error: could not fetch user info');
    } else {
      showInSnackBar(context, scaffoldKey,
          'No active account found with the given credentials');
    }

    _buttonsController.add(true);
  }

  Future<void> _signUp(BuildContext context) async {
    _buttonsController.add(false);

    final username = textControllers[LoginField.SignUpUsername].text.trim();
    final firstName = textControllers[LoginField.SignUpFirstName].text.trim();
    final lastName = textControllers[LoginField.SignUpLastName].text.trim();
    final email = textControllers[LoginField.SignUpEmail].text.trim();
    final password = textControllers[LoginField.SignUpPassword].text;
    final confirmedPassword =
        textControllers[LoginField.SignUpConfirmPassword].text;

    if (username.isEmpty ||
        firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      showInSnackBar(context, scaffoldKey, 'All sign up fields must be filled');
      _buttonsController.add(true);
      return;
    }

    if (RegExp(r'[^A-Za-z0-9@.+\-_]').hasMatch(username)) {
      showInSnackBar(context, scaffoldKey,
          'Invalid username (only letters/numbers/@/./+/-/_)');
      _buttonsController.add(true);
      return;
    }

    if (!isEmail(email)) {
      showInSnackBar(context, scaffoldKey, 'Invalid email address');
      _buttonsController.add(true);
      return;
    }

    if (password != confirmedPassword) {
      showInSnackBar(context, scaffoldKey, 'Passwords must match');
      _buttonsController.add(true);
      return;
    }

    if (password.length < 6 || password.length > 16) {
      showInSnackBar(context, scaffoldKey,
          'Password is too short or too long (min: 6 / max: 16)');
      _buttonsController.add(true);
      return;
    }

    final fields = {
      LoginField.SignUpUsername: username,
      LoginField.SignUpFirstName: firstName,
      LoginField.SignUpLastName: lastName,
      LoginField.SignUpEmail: email,
      LoginField.SignUpPassword: password
    };

    int result = await _repository.register(fields);

    if (result == 0) {
      result = await _repository.login(username, password);

      if (result == 0) {
        User user = await _repository.fetchUserInfo();
        if (user != null) {
          Navigator.of(context).pushReplacementNamed(!user.hasFinishedRegister
              ? RouteName.recommendedTopics
              : RouteName.userInfo);
          return;
        }

        showInSnackBar(
            context, scaffoldKey, 'Network error: could not fetch user info');
      } else {
        showInSnackBar(
            context, scaffoldKey, 'Account was created, but sign in failed');
      }
    } else {
      showInSnackBar(
          context, scaffoldKey, 'That username has already been taken');
    }

    _buttonsController.add(true);
  }

  ///////////////////////////////////////////////////////////
  // * Getters
  Stream<bool> getObscureStream(LoginField field) =>
      _obscurityControllers[field].stream;

  Stream<bool> get buttonsStream => _buttonsController.stream;
}
