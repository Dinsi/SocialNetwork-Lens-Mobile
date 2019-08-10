import 'dart:async';

import 'package:aperture/router.dart';
import 'package:aperture/view_models/user_info_screen_bloc.dart';
import 'package:flutter/material.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key key}) : super(key: key);

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  Future<void> _uploadPost() async {
    int result = await Navigator.of(context).pushNamed(RouteName.uploadPost);

    switch (result) {
      case 0:
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Uploaded post'),
              content: const Text('The post has been uploaded successfully'),
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
              content: const Text('An error has occurred'),
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
    Navigator.of(context).pushNamed(RouteName.feed);
  }

  void _search() {
    Navigator.of(context).pushNamed(RouteName.search);
  }

  void _logout() {
    userInfoBloc.clearCache();
    Navigator.of(context).pushReplacementNamed(RouteName.login);
  }

  void _settings() {
    Navigator.of(context).pushNamed(RouteName.settings);
  }

  void _collections() {
    // TODO navigateToCollectionList
    Navigator.of(context).pushNamed(
      RouteName.collectionList,
      arguments: {
        'isAddToCollection': false,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ListTile(
                title: Text(
                  'Name: ${userInfoBloc.user.name}',
                  style: Theme.of(context).textTheme.headline,
                ),
              ),
              ListTile(
                title: Text(
                  'Username: ${userInfoBloc.user.username}',
                  style: Theme.of(context).textTheme.headline,
                ),
              ),
              ListTile(
                title: Text(
                  'Email: ${userInfoBloc.user.email}',
                  style: Theme.of(context).textTheme.headline,
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              _buildButton(
                title: 'Upload Post',
                onPressed: () => _uploadPost(),
              ),
              const SizedBox(
                height: 10.0,
              ),
              _buildButton(
                title: 'Feed',
                onPressed: _feed,
              ),
              const SizedBox(
                height: 10.0,
              ),
              _buildButton(
                title: 'Search',
                onPressed: _search,
              ),
              const SizedBox(
                height: 10.0,
              ),
              _buildButton(
                title: 'Settings',
                onPressed: _settings,
              ),
              const SizedBox(
                height: 10.0,
              ),
              _buildButton(
                title: 'Collections',
                onPressed: _collections,
              ),
              const SizedBox(
                height: 10.0,
              ),
              _buildButton(
                title: 'Logout',
                onPressed: _logout,
                dangerButton: true,
              ),
              const SizedBox(
                height: 10.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
      {@required String title,
      @required VoidCallback onPressed,
      bool dangerButton = false}) {
    return SizedBox(
      height: 60.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: ButtonTheme(
          buttonColor: dangerButton ? Colors.red[600] : Colors.blue[600],
          splashColor: dangerButton ? Colors.red[800] : Colors.blueGrey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9.0),
          ),
          child: RaisedButton(
            elevation: 5.0,
            onPressed: onPressed,
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .headline
                  .copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
