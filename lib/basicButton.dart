import 'package:flutter/material.dart';

final _borderRadius = BorderRadius.circular(16.0);

class BasicButton extends StatelessWidget {
  final String text;
  final GestureTapCallback onTap;

  const BasicButton({
      Key key,
      @required this.text,
      @required this.onTap
  }) : assert(text != null),
       assert(text != ''),
       assert(onTap != null),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
      child: Material(
        color: Colors.deepPurple,
        borderRadius: _borderRadius,
        child: Container(
          height: 60.0,
          child: InkWell(
            onTap: onTap,
            borderRadius: _borderRadius,
            highlightColor: Colors.pink,
            splashColor: Colors.pink,
            child: Center(
              child: Text(
                text,
                style: Theme.of(context).textTheme.display1.copyWith(
                  color: Colors.white
                )
              )
            ),
          )
        ),
      ),
    );
  }
}