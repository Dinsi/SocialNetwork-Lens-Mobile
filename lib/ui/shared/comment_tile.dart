import 'package:aperture/models/comment.dart';
import 'package:aperture/models/users/compact_user.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

const double _iconSideSize = 40.0;

class CommentTile extends StatefulWidget {
  final Comment comment;
  final void Function(BuildContext, [CompactUser]) onPressed;

  const CommentTile({Key key, @required this.comment, @required this.onPressed})
      : super(key: key);

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
              child: Stack(
                children: <Widget>[
                  widget.comment.user.avatar == null
                      ? Image.asset(
                          'assets/img/user_placeholder.png',
                        )
                      : FadeInImage.memoryNetwork(
                          placeholder: kTransparentImage,
                          image: widget.comment.user.avatar,
                        ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.white24,
                      onTap: () =>
                          widget.onPressed(context, widget.comment.user),
                    ),
                  ),
                ],
              ),
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
