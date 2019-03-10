import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:proof_of_concept/api.dart';
import 'package:proof_of_concept/basicButton.dart';
import 'package:proof_of_concept/loginScreen.dart';
import 'package:proof_of_concept/startTextField.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key key}) : super(key: key);

  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String _username;
  String _firstName;
  String _lastName;
  String _email;
  String _password;
  String _message;

  void _updateUsername(String value) {
    setState(() {
      _username = value;
    });
  }

  void _updateEmail(String value) {
    setState(() {
      _email = value;
    });
  }

  void _updateFirstName(String value) {
    setState(() {
      _firstName = value;
    });
  }

  void _updateLastName(String value) {
    setState(() {
      _lastName = value;
    });
  }

  void _updatePassword(String value) {
    setState(() {
      _password = value;
    });
  }

  Future<void> _register() async {
    if (_username.isEmpty || _firstName.isEmpty ||
        _lastName.isEmpty || _email.isEmpty || _password.isEmpty) {
      setState(() {
        _message = 'Error: Could not register';
      });
    }

    final api = Api();
    Map<String, String> fields = {
      'username': _username,
      'first_name': _firstName,
      'last_name': _lastName,
      'email': _email,
      'password': _password
    };

    http.Response response = await api.register(fields);

    if (response.statusCode == 201) {
      Navigator.of(context).push(MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.blue,
                title: Text('Aperture'),
              ),
              body: LoginScreen()
          );
        },
      ));

    } else {
      setState(() {
        _message = 'Error: Could not register';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        StartTextField(
          text: 'Username',
          onChanged: _updateUsername,
          obscured: false,
        ),
        StartTextField(
          text: 'First Name',
          onChanged: _updateFirstName,
          obscured: false,
        ),
        StartTextField(
          text: 'Last Name',
          onChanged: _updateLastName,
          obscured: false,
        ),
        StartTextField(
            text: 'Email',
          onChanged: _updateEmail,
          obscured: false,
        ),
        StartTextField
          (text: 'Password',
          onChanged: _updatePassword,
          obscured: true,
        ),
        BasicButton(text: 'Register', onTap: _register,),
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
    );
  }
}