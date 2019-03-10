import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'loginScreen.dart';
import 'network/api.dart';
import 'singletons/globals.dart';
import 'widgets/userInfoLine.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key key}) : super(key: key);

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  String _name;
  String _username;
  String _email;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    http.Response response = await Api.getUserInfo();

    if (response.statusCode == 200) {
      var body = json.decode(response.body);

      setState(() {
        _name = body['name'];
        _username = body['username'];
        _email = body['email'];
      });
    } else {
      print('Error: ${response.body}');
    }
  }

  Future<void> _getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        Api.upload(image);
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Info'),
                content: Text('Image uploaded'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              );
            });
      } on Exception {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Info'),
                content: Text('An error occurred'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              );
            });
      }
    }
  }

  void _logout(BuildContext context) {
    var globals = Globals();
    globals.accessToken = null;
    globals.refreshToken = null;

    Navigator.of(context).pushReplacement(
        MaterialPageRoute<Null>(builder: (BuildContext context) {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue,
            title: Text('Aperture'),
          ),
          body: LoginScreen());
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Aperture'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            UserInfoLine(label: 'Name', info: _name == null ? '' : _name),
            UserInfoLine(
                label: 'Username', info: _username == null ? '' : _username),
            UserInfoLine(label: 'Email', info: _email == null ? '' : _email),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () => _getImage(),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 15.0, horizontal: 6.0),
                      child: Container(
                          alignment: Alignment.center,
                          height: 60.0,
                          decoration: BoxDecoration(
                              color: Colors.blue[800],
                              borderRadius: BorderRadius.circular(9.0)),
                          child: Text(
                            'Upload Image',
                            style: Theme.of(context)
                                .textTheme
                                .title
                                .copyWith(color: Colors.white),
                          )),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _logout(context),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 15.0, horizontal: 6.0),
                      child: Container(
                          alignment: Alignment.center,
                          height: 60.0,
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(9.0)),
                          child: Text(
                            'Log Out',
                            style: Theme.of(context)
                                .textTheme
                                .title
                                .copyWith(color: Colors.white),
                          )),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
