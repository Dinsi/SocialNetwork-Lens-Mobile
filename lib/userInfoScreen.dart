import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:proof_of_concept/api.dart';
import 'package:proof_of_concept/uploadImageScreen.dart';


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
    http.Response response = await Api().getUserInfo();

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: ListView(
        shrinkWrap: true,
          children: <Widget>[
            UserInfoLine(label: 'Name', info: _name == null ? '' : _name),
            UserInfoLine(
              label: 'Username',
              info: _username == null ? '' : _username
            ),
            UserInfoLine(label: 'Email', info: _email == null ? '' : _email),
            UploadImageButton()
          ],
      ),
    );
  }


}

class UserInfoLine extends StatelessWidget {
  final String label;
  final String info;

  const UserInfoLine({
    @required this.label,
    @required this.info
  }) : assert(label != null),
       assert(info != null);


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Text(
          label + ': ' + info,
          style: Theme.of(context).textTheme.headline,
        ),
      ),
    );
  }

}