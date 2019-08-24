import 'package:aperture/router.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsScreen extends StatelessWidget {
  Future<void> _editProfile(BuildContext context) async {
    int code = await Navigator.of(context).pushNamed(RouteName.editProfile);
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
          leading: BackButton(),
        ),
        body: Column(
          children: <Widget>[
            _buildListTile(
              context: context,
              title: 'Account',
              onTap: () {
                Navigator.of(context).pushNamed(RouteName.accountSettings);
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
                Navigator.of(context).pushNamed(RouteName.topicList);
              },
              iconData: FontAwesomeIcons.thList,
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
        title: Text(title),
        leading: Icon(iconData),
        onTap: onTap,
      );
}
