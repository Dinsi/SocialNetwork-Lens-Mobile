import 'dart:async';
import 'dart:convert' show json;

import 'package:proof_of_concept/globals.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proof_of_concept/api.dart';
import 'package:http/http.dart' as http;


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: Scaffold(
        appBar: AppBar(backgroundColor: Colors.blue,
        title: Text('App'),),
        body: Material(
          child: ListView(
            children: <Widget>[
              UploadApp(),
              Container(
                height: 3.0,
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                color: Colors.black54,
              ),
              LoginApp()
            ],
          ),
        )
        //UploadApp()
        //LoginApp(),
      ),
    );
  }
}

class UploadApp extends StatelessWidget {

  const UploadApp({Key key}) : super(key: key);

  Future<void> _getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    Api().upload(image);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Material(
        color: Colors.red,
        child: Container(
          height: 100.0,
          child: InkWell(
            highlightColor: Colors.green,
            splashColor: Colors.green,
            onTap: _getImage,
            child: Center(
              child: Text(
                'Upload Image',
                style: Theme.of(context).textTheme.title.copyWith(
                  color: Colors.white
                ),
              )
            ),
          )
        ),
      ),
    );
  }
}

class LoginApp extends StatefulWidget {
  const LoginApp({Key key}) : super(key: key);

  _LoginAppState createState() => _LoginAppState();
}

class _LoginAppState extends State<LoginApp>{
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // This is the widget that accepts text input. In this case, it
          // accepts numbers and calls the onChanged property on update.
          // You can read more about it here: https://flutter.io/text-input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: Theme.of(context).textTheme.display1,
              decoration: InputDecoration(
                labelStyle: Theme.of(context).textTheme.display1,
                labelText: 'Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0.0),
                ),
              ),
              // Since we only want numerical input, we use a number keyboard. There
              // are also other keyboards for dates, emails, phone numbers, etc.
              keyboardType: TextInputType.text,
              onChanged: _updateUsername,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: Theme.of(context).textTheme.display1,
              decoration: InputDecoration(
                labelStyle: Theme.of(context).textTheme.display1,
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0.0),
                ),
              ),
              // Since we only want numerical input, we use a number keyboard. There
              // are also other keyboards for dates, emails, phone numbers, etc.
              keyboardType: TextInputType.text,
              obscureText: true,
              onChanged: _updatePassword,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              color: Colors.deepPurple,
              child: Container(
                height: 100.0,
                child: InkWell(
                  onTap: _login,
                  highlightColor: Colors.pink,
                  splashColor: Colors.pink,
                  child: Center(
                    child: Text(
                      'Login',
                      style: Theme.of(context).textTheme.display1.copyWith(
                        color: Colors.white
                      )
                    )
                  ),
                )
              ),
            ),
          ),
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

  Future<void> _login() async {
    final api = Api();

    http.Response response = await api.login(_username, _password);

    if (response.statusCode == 200) {
      var body = json.decode(response.body);
      var globals = Globals();
      globals.accessToken = body['access'];
      globals.refreshToken = body['refresh'];

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      setState(() {
        _message = 'Access token: ${globals.accessToken}\n\n' +
                   'Refresh token: ${globals.refreshToken}';
      });

    } else {
      print('Error: ${response.body}');

      setState(() {
        _message = 'Error: Could not login';
      });
    }
  }
}
