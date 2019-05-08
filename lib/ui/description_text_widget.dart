import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'utils/post_shared_functions.dart';


class DescriptionTextWidget extends StatefulWidget {
  final String text;

  DescriptionTextWidget({@required this.text});

  @override
  _DescriptionTextWidgetState createState() => _DescriptionTextWidgetState();
}

class _DescriptionTextWidgetState extends State<DescriptionTextWidget>
    with SingleTickerProviderStateMixin<DescriptionTextWidget> {
  List<String> _textSplits;
  TapGestureRecognizer _tapGestureRecognizer;
  bool flag = true;

  @override
  void initState() {
    super.initState();
    _textSplits = detectHashtags(widget.text);
    _tapGestureRecognizer = TapGestureRecognizer()..onTap = () => print('k');
    /*if (widget.text.length > 100) {
      firstHalf = widget.text.substring(0, 100);
      secondHalf = widget.text.substring(100, widget.text.length);
    } else {
      firstHalf = widget.text;
      secondHalf = "";
    }*/
  }

  @override
  Widget build(BuildContext context) {
    TextSpan descriptionTextSpan = TextSpan(
      children: <TextSpan>[],
      style: TextStyle(
        fontSize: 16.0,
        color: Colors.black
      ),
    );

    _textSplits.forEach((textSplit) {
      if (textSplit.startsWith('#')) {
        descriptionTextSpan.children.add(
          TextSpan(
              text: textSplit,
              style: TextStyle(color: Colors.blue),
              recognizer: _tapGestureRecognizer),
        );
      } else {
        descriptionTextSpan.children.add(
          TextSpan(
            text: textSplit,
          ),
        );
      }
    });

    return Container(
        padding: const EdgeInsets.all(16.0),
        child: RichText(
          text: descriptionTextSpan,
        ));
  }
}
