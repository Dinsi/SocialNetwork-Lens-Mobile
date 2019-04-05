import 'package:aperture/models/post.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:transparent_image/transparent_image.dart';

const double _sideIcon = 45.0;

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
            color: Colors.white,
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ClipOval(
                  child: Container(
                      height: _sideIcon,
                      width: _sideIcon,
                      color: Colors.grey[300],
                      child: (widget.post.user.avatarUrl == null
                          ? Image.asset(
                              'assets/img/user_placeholder.png',
                            )
                          : FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,
                              image: widget.post.user.avatarUrl,
                            ))),
                ),
                /*child: Container(
                    width: _sideIcon,
                    height: _sideIcon,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: (widget.post.user.avatarUrl == null
                            ? AssetImage(
                                'assets/img/user_placeholder.png',
                              )
                            : FadeInImage.memoryNetwork(
                                placeholder: kTransparentImage,
                                image: widget.post.user.avatarUrl,
                              ).image),
                      )),
                  ),*/
                /*Container(
                      width: 190.0,
                      height: 190.0,
                      decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: new NetworkImage(
                                 "https://i.imgur.com/BoN9kdC.png")
                                 )
                )),
                ),*/
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(widget.post.title,
                      style: Theme.of(context).textTheme.title),
                ),
                Expanded(
                    child: Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: _sideIcon,
                    width: _sideIcon,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: Icon(
                            Icons.menu,
                            size: 28.0,
                          )),
                    ),
                  ),
                ))
              ],
            ),
          ),
          Container(
            color: Colors.grey[300],
            height: _calculatePlaceholderHeight(context),
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: widget.post.image,
            ),
          ),
          Material(
            elevation: 1.0,
            child: Container(
              height: 50.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(FontAwesomeIcons.arrowAltCircleUp),
                    onPressed: () {},
                  ),
                  Text(
                    _votes != null ? nFormatter(_votes.toDouble(), 1) : "0",
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    padding: const EdgeInsets.only(
                        top: 8.0, bottom: 8.0, left: 11.0, right: 30.0),
                    icon: Icon(FontAwesomeIcons.arrowAltCircleDown),
                    onPressed: () {},
                  ),
                  IconButton(
                    iconSize: 20.0,
                    padding: const EdgeInsets.only(
                        top: 8.0, bottom: 8.0, left: 30.0, right: 8.0),
                    icon: Icon(FontAwesomeIcons.commentAlt),
                    onPressed: () {},
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      "999", //TODO comments go here
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
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
