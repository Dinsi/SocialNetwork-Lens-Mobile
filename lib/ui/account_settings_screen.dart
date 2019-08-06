import 'package:aperture/router.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AccountSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Account'),
          leading: BackButton(),
        ),
        body: Column(
          children: <Widget>[
            _buildListTile(context,
                destRoute: RouteName.changeEmail,
                icon: FontAwesomeIcons.envelope,
                title: 'Change email',
                content: 'Your email has been changed successfully'),
            _buildListTile(context,
                destRoute: RouteName.changePassword,
                icon: FontAwesomeIcons.key,
                title: 'Change password',
                content: 'Your password has been changed successfully')
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    @required String destRoute,
    @required IconData icon,
    @required String title,
    @required String content,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: Theme.of(context).textTheme.title,
      ),
      onTap: () async {
        int result = await Navigator.of(context).pushNamed(destRoute);
        if (result != null) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(title),
                content: Text(content),
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
      },
    );
  }
}
