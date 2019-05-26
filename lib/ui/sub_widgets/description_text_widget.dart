import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../utils/post_shared_functions.dart';

class DescriptionTextWidget extends StatefulWidget {
  final String text;
  final bool withHashtags;

  DescriptionTextWidget({@required this.text, @required this.withHashtags});

  @override
  _DescriptionTextWidgetState createState() => _DescriptionTextWidgetState();
}

class _DescriptionTextWidgetState extends State<DescriptionTextWidget>
    with SingleTickerProviderStateMixin<DescriptionTextWidget> {
  List<String> _textSplits;
  bool showAll = false;

  @override
  void initState() {
    super.initState();
    if (widget.withHashtags) {
      _textSplits = detectHashtags(widget.text);
    } else {
      _textSplits = List<String>();
      if (widget.text.length > 100) {
        _textSplits.add(widget.text.substring(0, 100));
        _textSplits.add(widget.text.substring(100, widget.text.length));
      } else {
        _textSplits.add(widget.text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.withHashtags) {
      return _buildTextSpans();
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: (_textSplits.length == 1
          ? Text(
              _textSplits.first,
              style: TextStyle(fontSize: 16.0),
            )
          : Column(
              children: (showAll
                  ? <Widget>[
                      Text(
                        _textSplits.first,
                        style: TextStyle(fontSize: 16.0),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FlatButton(
                          child: Text(
                            'show more',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          onPressed: () => setState(() {
                                showAll = true;
                              }),
                        ),
                      )
                    ]
                  : <Widget>[
                      Text(
                        _textSplits.join(),
                        style: TextStyle(fontSize: 16.0),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FlatButton(
                          child: Text(
                            'show less',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          onPressed: () => setState(() {
                                showAll = false;
                              }),
                        ),
                      )
                    ]))),
    );
  }

  Widget _buildTextSpans() {
    TextSpan descriptionTextSpan = TextSpan(
      children: <TextSpan>[],
      style: TextStyle(fontSize: 16.0, color: Colors.black),
    );

    _textSplits.forEach((textSplit) {
      if (textSplit.startsWith('#')) {
        descriptionTextSpan.children.add(
          TextSpan(
            text: textSplit,
            style: TextStyle(color: Colors.blue),
            recognizer: TapGestureRecognizer()
              ..onTap = () => Navigator.of(context).pushNamed(
                    '/topicFeed',
                    arguments: textSplit.replaceFirst('#', ''),
                  ),
          ),
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
