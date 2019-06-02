import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AccountSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
        leading: BackButton(),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            ListTile(
              leading: Icon(FontAwesomeIcons.envelope),
              title: Text(
                'Change email',
                style: Theme.of(context).textTheme.title,
              ),
              onTap: () async {
                int result = await Navigator.of(context)
                    .pushNamed('/changeEmail') as int;
                if (result != null) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Change email'),
                        content: const Text(
                            'Your email has been changed successfully'),
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
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.key),
              title: Text(
                'Change password',
                style: Theme.of(context).textTheme.title,
              ),
              onTap: () async {
                int result =
                    await Navigator.of(context).pushNamed('/changePassword') as int;
                if (result != null) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Change password'),
                        content: const Text(
                            'Your password has been changed successfully'),
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
            ),
          ],
        ),
      ),
    );
  }
}
