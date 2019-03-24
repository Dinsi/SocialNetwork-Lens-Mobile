import 'package:flutter/material.dart';

class StartTextField extends StatelessWidget {
  final String text;
  final ValueChanged<String> onChanged;
  final bool obscured;

  const StartTextField(
      {@required this.text, @required this.onChanged, @required this.obscured})
      : assert(text != null),
        assert(onChanged != null),
        assert(obscured != null);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        style: Theme.of(context).textTheme.display1,
        decoration: InputDecoration(
          labelStyle: Theme.of(context).textTheme.display1,
          labelText: text,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(0.0),
          ),
        ),
        keyboardType: TextInputType.text,
        obscureText: obscured,
        enableInteractiveSelection: true,
        onChanged: onChanged,
      ),
    );
  }
}
