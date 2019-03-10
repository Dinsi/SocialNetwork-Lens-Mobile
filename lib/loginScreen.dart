import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:proof_of_concept/api.dart';
import 'package:proof_of_concept/globals.dart';
import 'package:proof_of_concept/basicButton.dart';
import 'package:proof_of_concept/signUpScreen.dart';
import 'package:proof_of_concept/startTextField.dart';
import 'package:proof_of_concept/userInfoScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{
  String _username;
  String _password;
  String _message;

  void _updateUsername(String username) {
    setState(() {
      _username = username;
    });
  }

  void _updatePassword(String password) {
    setState(() {
      _password = password;
    });
  }

  Future<void> _login() async {
    final api = Api();

    http.Response response = await api.login(_username, _password);

    if (response.statusCode == 200) {
      var body = json.decode(response.body);

      var globals = Globals();
      globals.accessToken = body['access'];
      globals.refreshToken = body['refresh'];

      setState(() {
        _message = 'Access token: ${globals.accessToken}\n\n' +
            'Refresh token: ${globals.refreshToken}';
      });

      Navigator.of(context).push(MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.blue,
                title: Text('Aperture'),
              ),
              body: UserInfoScreen()
          );
        },
      ));

    } else {
      setState(() {
        _message = 'Error: Could not login';
      });
    }
  }

  void _signUp(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue,
            title: Text('Aperture'),
          ),
          body: SignUpScreen()
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          StartTextField(
            text: 'Username',
            onChanged: _updateUsername,
            obscured: false,
          ),
          StartTextField(
            text: 'Password',
            onChanged: _updatePassword,
            obscured: true,
          ),
          BasicButton(text: 'Login', onTap: _login),
          BasicButton(text: 'Sign Up', onTap: () => _signUp(context)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: Text(
                  _message == null ? '' : _message,
                  style: Theme.of(context).textTheme.headline
              ),
            ),
          ),
        ],
      ),
    );
  }
}