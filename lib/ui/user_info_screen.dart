import 'dart:async';

import 'package:flutter/material.dart';

import '../blocs/user_info_screen_bloc.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key key}) : super(key: key);

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _uploadPost() async {
    int result = await Navigator.of(context).pushNamed('/uploadPost') as int;

    switch (result) {
      case 0:
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
        break;

      case -1: //TODO not implemented
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

  void _feed() {
    Navigator.of(context).pushNamed('/feed');
  }

  void _logout() {
    userInfoBloc.clearCache();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              title: Text(
                'Name: ${(userInfoBloc.user.name)}',
                style: Theme.of(context).textTheme.headline,
              ),
            ),
            ListTile(
              title: Text(
                'Username: ${(userInfoBloc.user.username)}',
                style: Theme.of(context).textTheme.headline,
              ),
            ),
            ListTile(
              title: Text(
                'Email: ${(userInfoBloc.user.email)}',
                style: Theme.of(context).textTheme.headline,
              ),
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
                          onPressed: () => _uploadPost(),
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
                          onPressed: () => _feed(),
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
                  onPressed: () => _logout(),
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
