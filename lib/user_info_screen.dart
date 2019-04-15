import 'dart:async';
import 'dart:convert' show json;

import 'package:aperture/widgets/posts/upload_post.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aperture/feed_screen.dart';
import 'package:aperture/auth/ui/login_screen.dart';
import 'package:aperture/network/api.dart';
import 'package:aperture/globals.dart';
import 'package:aperture/widgets/user_info_line.dart';

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
    final Globals globals = Globals();
    if (globals.user == null) {
      http.Response response = await Api.getUserInfo();

      if (response.statusCode == 200) {
        dynamic body = json.decode(response.body);
        globals.cacheUser(body);
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Info'),
                content: Text('Error: ${response.body}'), //TODO
                actions: <Widget>[
                  FlatButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              );
            });
      }
    }

    setState(() {
      _name = globals.user.name;
      _username = globals.user.username;
      _email = globals.user.email;
    });
  }

  Future<void> _getPostDetails(BuildContext context) async {
    int result = await Navigator.of(context).push(
      MaterialPageRoute<int>(
        builder: (BuildContext context) => UploadPost(),
      ),
    );

    if (result == 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Uploaded post'),
            content: const Text('The post has been uploaded successfully.'),
            actions: <Widget>[
              FlatButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Uploaded post'),
            content: const Text('An error has occurred.'),
            actions: <Widget>[
              FlatButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        },
      );
    }
  }

  void _feed(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<Null>(
        builder: (BuildContext context) => FeedScreen()));
  }

  Future<void> _logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    Globals().clearCache();
    await prefs.clear();

    Navigator.of(context).pushReplacement(MaterialPageRoute<Null>(
        builder: (BuildContext context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            UserInfoLine(
              label: 'Name',
              info: _name == null ? '' : _name,
            ),
            UserInfoLine(
              label: 'Username',
              info: _username == null ? '' : _username,
            ),
            UserInfoLine(
              label: 'Email',
              info: _email == null ? '' : _email,
            ),
            const Divider(
              height: 10.0,
              color: Colors.transparent,
            ),
            SizedBox(
              height: 60.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: ButtonTheme(
                        buttonColor: Colors.blue[600],
                        splashColor: Colors.blueGrey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        child: RaisedButton(
                          elevation: 5.0,
                          onPressed: () => _getPostDetails(context),
                          child: Text(
                            'Upload Post',
                            style: Theme.of(context)
                                .textTheme
                                .headline
                                .copyWith(color: Colors.white, fontSize: 23.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: ButtonTheme(
                        buttonColor: Colors.blue[600],
                        splashColor: Colors.blueGrey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        child: RaisedButton(
                          elevation: 5.0,
                          onPressed: () => _feed(context),
                          child: Text(
                            'Feed',
                            style: Theme.of(context)
                                .textTheme
                                .headline
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 10.0,
              color: Colors.transparent,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: ButtonTheme(
                minWidth: double.infinity,
                height: 60.0,
                buttonColor: Colors.red[600],
                splashColor: Colors.red[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9.0),
                ),
                child: RaisedButton(
                  elevation: 5.0,
                  onPressed: () => _logout(context),
                  child: Text(
                    'Logout',
                    style: Theme.of(context)
                        .textTheme
                        .headline
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
