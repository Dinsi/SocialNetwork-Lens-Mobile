import 'package:flutter/material.dart';

class UserInfoLine extends StatelessWidget {
  final String label;
  final String info;

  const UserInfoLine({@required this.label, @required this.info})
      : assert(label != null),
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
