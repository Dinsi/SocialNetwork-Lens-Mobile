import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'network/api.dart';
import 'singletons/globals.dart';
import 'widgets/basicButton.dart';
import 'signUpScreen.dart';
import 'widgets/startTextField.dart';
import 'userInfoScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
    http.Response response = await Api.login(_username, _password);

    if (response.statusCode == 200) {
      var body = json.decode(response.body);

      var globals = Globals();
      globals.accessToken = body['access'];
      globals.refreshToken = body['refresh'];

      Navigator.of(context).pushReplacement(
          MaterialPageRoute<Null>(builder: (context) => UserInfoScreen()));
    } else {
      setState(() {
        _message = 'Error: Could not login';
      });
    }
  }

  void _signUp(BuildContext context) async {
    final result = await Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) {
        return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue,
              title: Text('Aperture'),
            ),
            body: SignUpScreen());
      },
    ));

    if (result != null) {
      setState(() {
        _message = 'You can now log in!';
      });
    }
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
              child: Text(_message == null ? '' : _message,
                  style: Theme.of(context).textTheme.headline),
            ),
          ),
        ],
      ),
    );
  }
}
