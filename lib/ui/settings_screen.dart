import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../resources/globals.dart';

class SettingsScreen extends StatelessWidget {
  final Globals _globals = Globals.getInstance();

  Future<void> _editProfile(BuildContext context) async {
    int code = await Navigator.of(context).pushNamed('/editProfile') as int;
    if (code != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Edit Profile'),
            content: const Text('Profile has been edited successfully'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: BackButton(),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _buildListTile(
              context: context,
              title: 'Account',
              onTap: () {
                Navigator.of(context).pushNamed('/accountSettings');
              },
              iconData: FontAwesomeIcons.userCog,
            ),
            _buildListTile(
              context: context,
              title: 'Edit Profile',
              onTap: () {
                _editProfile(context);
              },
              iconData: FontAwesomeIcons.idBadge,
            ),
            _buildListTile(
              context: context,
              title: 'Subscriptions',
              onTap: () {
                Navigator.of(context).pushNamed('/topicList');
              },
              iconData: FontAwesomeIcons.thList,
            ),
            _buildListTile(
              context: context,
              title: 'Logout',
              onTap: () {
                _globals.clearCache();
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login', (Route<dynamic> route) => false);
              },
              iconData: FontAwesomeIcons.signOutAlt,
            ),
            _buildListTile(
              context: context,
              title: 'About',
              iconData: FontAwesomeIcons.info,
            ),
          ],
        ),
      ),
    );
  }

  ListTile _buildListTile(
          {@required BuildContext context,
          @required String title,
          @required IconData iconData,
          VoidCallback onTap}) =>
      ListTile(
        title: Text(
          title,
          style: Theme.of(context).textTheme.title,
        ),
        leading: Icon(iconData),
        onTap: onTap,
      );
}
