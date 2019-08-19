import 'package:aperture/models/comment.dart';
import 'package:aperture/models/users/compact_user.dart';
import 'package:aperture/models/users/user.dart';
import 'package:aperture/ui/shared/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const _iconSideSize = 30.0;
const _spaceBetweenImageAndName = 12.0;

class CommentTile extends StatelessWidget {
  final Comment comment;
  final void Function(BuildContext, [CompactUser]) onPressed;
  final bool isSelf;

  const CommentTile(
      {Key key,
      @required this.comment,
      @required this.onPressed,
      @required this.isSelf})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              isSelf
                  ? Consumer<User>(
                      builder: (_, currentUser, __) => UserAvatar(
                        isCircle: true,
                        side: _iconSideSize,
                        user: currentUser,
                        onTap: () => onPressed(context, comment.user),
                      ),
                    )
                  : UserAvatar(
                      isCircle: true,
                      side: _iconSideSize,
                      user: comment.user,
                      onTap: () => onPressed(context, comment.user),
                    ),
              const SizedBox(width: _spaceBetweenImageAndName),
              Flexible(
                child: GestureDetector(
                  onTap: () => onPressed(context, comment.user),
                  child: Text(
                    comment.user.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: _iconSideSize + _spaceBetweenImageAndName,
            ),
            child: Text(comment.text),
          ),
        ],
      ),

      /*Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          isSelf
              ? Consumer<User>(
                  builder: (_, currentUser, __) => UserAvatar(
                    side: _iconSideSize,
                    user: currentUser,
                    onTap: () => onPressed(context, comment.user),
                  ),
                )
              : UserAvatar(
                  side: _iconSideSize,
                  user: comment.user,
                  onTap: () => onPressed(context, comment.user),
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
                        text: '@${comment.user.name}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: ' ${comment.text}'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),*/
    );
  }
}
