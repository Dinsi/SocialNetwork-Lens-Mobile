import 'dart:async';

import 'package:aperture/models/post.dart';
import 'package:aperture/network/api.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:synchronized/synchronized.dart';
import 'package:transparent_image/transparent_image.dart';

const double _iconSideSize = 45.0;
const double _defaultHeight = 55.0;

TextStyle _getTextStyle([Color color]) {
  return TextStyle(
    fontSize: 17.0,
    fontWeight: FontWeight.bold,
    color: color ?? Colors.grey[600],
  );
}

String nFormatter(double num, int digits) {
  final List<Map<dynamic, dynamic>> si = const [
    {"value": 1, "symbol": ""},
    {"value": 1E3, "symbol": "k"},
    {"value": 1E6, "symbol": "M"},
    {"value": 1E9, "symbol": "G"},
    {"value": 1E12, "symbol": "T"},
    {"value": 1E15, "symbol": "P"},
    {"value": 1E18, "symbol": "E"}
  ];
  final rx = RegExp(r"\.0+$|(\.[0-9]*[1-9]*)0+$");
  var i;
  for (i = si.length - 1; i > 0; i--) {
    if (num >= si[i]["value"]) {
      break;
    }
  }

  return (num / si[i]["value"]).toStringAsFixed(digits).replaceAllMapped(rx,
          (match) {
        return match.group(1) ?? "";
      }) +
      si[i]["symbol"];
}

class BasicPost extends StatefulWidget {
  final Post post;

  const BasicPost({Key key, @required this.post}) : super(key: key);

  @override
  _BasicPostState createState() => _BasicPostState(this.post.votes);
}

class _BasicPostState extends State<BasicPost> {
  _BasicPostState(this._votes);

  int _votes;
  int _currentVote;
  bool _downIconColor;
  bool _upIconColor;
  final Lock _lock = new Lock();

  void initState() {
    super.initState();
    switch (widget.post.userVote) {
      case 0:
        _downIconColor = false;
        _upIconColor = false;
        break;
      case 1:
        _downIconColor = false;
        _upIconColor = true;
        break;
      case -1:
        _downIconColor = true;
        _upIconColor = false;
        break;
      default:
    }
    _currentVote = widget.post.userVote;
  }

  @override
  Widget build(BuildContext context) {
    final double imageHeight = _calculatePlaceholderHeight(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: imageHeight,
            color: Colors.grey[300],
            child: Stack(
              children: <Widget>[
                Center(
                  child: FadeInImage.memoryNetwork(
                    fit: BoxFit.fitWidth,
                    placeholder: kTransparentImage,
                    image: widget.post.image,
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.white24,
                    onTap: () {
                      print('tap => $imageHeight');
                    }, //TODO postscreen
                    onDoubleTap: () {
                      print('double');
                    }, //TODO upvote
                  ),
                ),
              ],
            ),
          ),
          Material(
            elevation: 5.0,
            child: Container(
              height: _defaultHeight,
              child: Theme(
                data: Theme.of(context).copyWith(
                  iconTheme: Theme.of(context).iconTheme.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Container(
                          height: _iconSideSize,
                          width: _iconSideSize,
                          color: Colors.grey[300],
                          child: (widget.post.user.avatar == null
                              ? Image.asset(
                                  'assets/img/user_placeholder.png',
                                )
                              : FadeInImage.memoryNetwork(
                                  placeholder: kTransparentImage,
                                  image: widget.post.user.avatar,
                                )),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Material(
                            child: InkWell(
                              onTap: () => _upvoteOrRemove(),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      FontAwesomeIcons.arrowAltCircleUp,
                                      color: _upIconColor
                                          ? Colors.blue
                                          : Colors.grey[600],
                                    ),
                                    SizedBox(
                                      width: 8.0,
                                    ),
                                    Text(
                                      _votes != null
                                          ? nFormatter(_votes.toDouble(), 0)
                                          : "0",
                                      style: _getTextStyle(
                                          _upIconColor ? Colors.blue : null),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Material(
                            child: InkWell(
                              onTap: () => _downvoteOrRemove(),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: Icon(
                                  FontAwesomeIcons.arrowAltCircleDown,
                                  color: _downIconColor
                                      ? Colors.red
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          FlatButton.icon(
                            color: Colors.transparent,
                            icon: Icon(
                              FontAwesomeIcons.commentAlt,
                              size: 18.0,
                              color: Colors.grey[600],
                            ),
                            label: Text(
                              "999", //TODO comments go here
                              style: _getTextStyle(),
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      PopupMenuButton<int>(
                        onSelected: (int result) {},
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<int>>[
                              const PopupMenuItem<int>(
                                value: 1,
                                child: Text("1"),
                              ),
                              const PopupMenuItem<int>(
                                value: 2,
                                child: Text("2"),
                              ),
                              const PopupMenuItem<int>(
                                value: 3,
                                child: Text("3"),
                              ),
                              const PopupMenuItem<int>(
                                value: 4,
                                child: Text("4"),
                              ),
                            ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculatePlaceholderHeight(BuildContext context) {
    if (MediaQuery.of(context).size.width >= widget.post.width) {
      return widget.post.height.toDouble();
    }

    return MediaQuery.of(context).size.width *
        widget.post.height /
        widget.post.width;
  }

  Future _downvoteOrRemove() async {
    await _lock.synchronized(() async {
      if (_currentVote == -1) {
        setState(() {
          _downIconColor = false;
          _votes++;
        });

        int result = await Api.removeVote(widget.post.id);
        if (result == 0) {
          setState(() {
            _currentVote = 0;
          });
        } else {
          setState(() {
            _downIconColor = true;
            _votes--;
          });
          /*TODO place dialog here*/
        }
        return;
      }

      setState(() {
        _upIconColor = false;
        _downIconColor = true;
        _currentVote == 1 ? _votes -= 2 : _votes--;
      });

      int result = await Api.downVote(widget.post.id);
      if (result == 0) {
        setState(() {
          _currentVote = -1;
        });
      } else {
        setState(() {
          _upIconColor = true;
          _downIconColor = false;
          _currentVote == 1 ? _votes += 2 : _votes++;
        }); /*TODO place dialog here*/
      }
    });
  }

  Future _upvoteOrRemove() async {
    await _lock.synchronized(() async {
      if (_currentVote == 1) {
      setState(() {
        _upIconColor = false;
        _votes--;
      });

      int result = await Api.removeVote(widget.post.id);
      if (result == 0) {
        setState(() {
          _currentVote = 0;
        });
      } else {
        setState(() {
          _upIconColor = true;
          _votes++;
        });
        /*TODO place dialog here*/
      }
      return;
    }

    setState(() {
      _upIconColor = true;
      _downIconColor = false;
      _currentVote == -1 ? _votes += 2 : _votes++;
    });

    int result = await Api.upVote(widget.post.id);
    if (result == 0) {
      setState(() {
        _currentVote = 1;
      });
    } else {
      setState(() {
        _upIconColor = false;
        _downIconColor = true;
        _currentVote == -1 ? _votes -= 2 : _votes--;
      });
      /*TODO place dialog here*/
    }
    });
  }
  //TODO disable buttons/
}
