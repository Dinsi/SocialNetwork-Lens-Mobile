import 'package:aperture/models/users/compact_user.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final backgroundColor = const Color(0xFFE0E0E0); // Colors.grey[300]
  final double side;
  final CompactUser user;
  final VoidCallback onTap;
  final bool isCircle;

  const UserAvatar(
      {@required this.side,
      @required this.user,
      this.onTap,
      this.isCircle = false});

  @override
  Widget build(BuildContext context) {
    final imageProvider = user.avatar == null
        ? AssetImage('assets/img/user_placeholder.png')
        : NetworkImage(user.avatar);

    return isCircle
        ? CircleAvatar(
            backgroundColor: backgroundColor,
            radius: side / 2,
            backgroundImage: imageProvider,
            child: onTap != null
                ? Material(
                    color: Colors.transparent,
                    child: InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.white24,
                      onTap: this.onTap,
                    ),
                  )
                : null,
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              height: side,
              width: side,
              decoration: BoxDecoration(
                color: backgroundColor,
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
              child: onTap != null
                  ? Material(
                      color: Colors.transparent,
                      child: InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.white24,
                        onTap: this.onTap,
                      ),
                    )
                  : null,
            ),
          );
  }
}
