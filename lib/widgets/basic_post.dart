import 'package:aperture/models/post.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:transparent_image/transparent_image.dart';

const double _iconSideSize = 45.0;
const double _defaultHeight = 55.0;

class BasicPost extends StatefulWidget {
  final Post post;

  const BasicPost({Key key, @required this.post}) : super(key: key);

  @override
  _BasicPostState createState() => _BasicPostState(this.post.votes);
}

class _BasicPostState extends State<BasicPost> {
  _BasicPostState(this._votes);

  int _votes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: Colors.grey[300],
            height: _calculatePlaceholderHeight(context),
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: widget.post.image,
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
                      ClipOval(
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
                      DefaultTextStyle(
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600]),
                        child: Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  IconButton(
                                    alignment: Alignment.centerRight,
                                    icon:
                                        Icon(FontAwesomeIcons.arrowAltCircleUp),
                                    onPressed: () {},
                                  ),
                                  SizedBox(
                                    width: 37.0,
                                    child: Center(
                                      child: Text(
                                        _votes != null
                                            ? nFormatter(_votes.toDouble(), 0)
                                            : "0",
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    alignment: Alignment.centerLeft,
                                    icon: Icon(
                                        FontAwesomeIcons.arrowAltCircleDown),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  IconButton(
                                    alignment: Alignment.centerRight,
                                    iconSize: 18.0,
                                    icon: Icon(FontAwesomeIcons.commentAlt),
                                    onPressed: () {},
                                  ),
                                  Text(
                                    "999", //TODO comments go here
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      /*SizedBox(
                        height: _defaultHeight,
                        width: _defaultHeight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: Icon(
                                Icons.menu,
                                size: 28.0,
                              )),
                        ),
                      ),*/
                      // This menu button widget updates a _selection field (of type WhyFarther,
// not shown here).
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
    return MediaQuery.of(context).size.width *
        widget.post.height /
        widget.post.width;
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
}
