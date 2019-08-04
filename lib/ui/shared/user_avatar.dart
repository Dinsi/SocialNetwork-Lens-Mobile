import 'package:aperture/models/users/compact_user.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final double side;
  final CompactUser user;
  final VoidCallback onTap;

  const UserAvatar({this.side, this.user, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        height: side,
        width: side,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          image: DecorationImage(
            image: user.avatar == null
                ? AssetImage(
                    'assets/img/user_placeholder.png',
                  )
                : NetworkImage(
                    user.avatar,
                  ),
            fit: BoxFit.cover,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.white24,
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
