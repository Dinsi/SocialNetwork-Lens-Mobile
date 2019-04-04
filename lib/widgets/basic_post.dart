import 'package:aperture/models/post.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class BasicPost extends StatefulWidget {
  final Post post;

  const BasicPost({Key key, @required this.post}) : super(key: key);

  @override
  _BasicPostState createState() =>
      _BasicPostState(this.post.ups, this.post.downs);
}

class _BasicPostState extends State<BasicPost> {
  _BasicPostState(this._ups, this._downs);

  int _ups;
  int _downs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Colors.grey[400],
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Row(
                  children: <Widget>[
                    Container(
                      color: Colors.white,
                      alignment: Alignment.centerLeft,
                      child: (widget.post.user.avatarUrl == null
                          ? Image.asset(
                              'assets/img/user_placeholder.png',
                              width: 55,
                              fit: BoxFit.fitHeight,
                            )
                          : Stack(
                              children: <Widget>[
                                Container(color: Colors.grey[600], width: 55.0),
                                FadeInImage.memoryNetwork(
                                  placeholder: kTransparentImage,
                                  image: widget.post.user.avatarUrl,
                                  width: 55.0,
                                  fit: BoxFit.fitHeight,
                                )
                              ],
                            )),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 7.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(widget.post.user.username),
                        ),
                      ),
                    ),
                  ],
                )),
                Expanded(
                  child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('(buttons here)'),
                ))
              ],
            ),
          ),
          Container(
            color: Colors.grey,
            alignment: Alignment.center,
            child: Image.network(
              widget.post.image,
              fit: BoxFit.fitWidth,
            ),
          ),
        ],
      ),
    );
  }
}
