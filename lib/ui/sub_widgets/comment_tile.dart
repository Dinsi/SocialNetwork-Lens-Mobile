import 'package:aperture/models/comment.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

const double _iconSideSize = 40.0;

class CommentTile extends StatefulWidget {
  final Comment comment;

  const CommentTile({Key key, @required this.comment}) : super(key: key);

  @override
  _CommentTileState createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              height: _iconSideSize,
              width: _iconSideSize,
              color: Colors.grey[300],
              child: (widget.comment.user.avatar == null
                  ? Image.asset(
                      'assets/img/user_placeholder.png',
                    )
                  : FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: widget.comment.user.avatar,
                    )),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.0,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                        text: '@${widget.comment.user.name}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: ' ${widget.comment.text}'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
