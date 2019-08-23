import 'package:aperture/models/post.dart';
import 'package:aperture/models/users/compact_user.dart';
import 'package:aperture/models/users/user.dart';
import 'package:aperture/ui/core/base_view.dart';
import 'package:aperture/ui/shared/image_container.dart';
import 'package:aperture/ui/shared/user_avatar.dart';
import 'package:aperture/ui/shared/vote_buttons.dart';
import 'package:aperture/view_models/shared/basic_post.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const _iconSideSize = 35.0;
const _defaultHeight = 50.0;

class BasicPost extends StatelessWidget {
  final Post post;

  const BasicPost({Key key, this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierBaseView<BasicPostModel>(
      onModelReady: (model) => model.init(post),
      builder: _buildBasicPost,
    );
  }

  Widget _buildBasicPost(
      BuildContext context, BasicPostModel model, Widget __) {
    final cardTheme = CardTheme.of(context);

    return Card(
      child: Column(
        children: <Widget>[
          ImageContainer(
            paddingDiff: cardTheme.margin.horizontal,
            imageUrl: model.post.image,
            imageHeight: model.post.height,
            imageWidth: model.post.width,
            onTap: () => model.navigateToDetailedPost(context, false),
            onDoubleTap: () => model.onUpvoteOrRemove(),
          ),
          Container(
            height: _defaultHeight,
            margin: const EdgeInsets.only(left: 8.0),
            child: model.isSelf
                ? Consumer<User>(
                    builder: (context, currentUser, __) =>
                        _buildActionRow(context, model, currentUser),
                  )
                : _buildActionRow(context, model, model.post.user),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(
      BuildContext context, BasicPostModel model, CompactUser user) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Row(
            children: <Widget>[
              UserAvatar(
                side: _iconSideSize,
                user: user,
                onTap: () => model.navigateToUserProfile(context),
              ),
              const SizedBox(width: 8.0),
              Flexible(
                child: GestureDetector(
                  onTap: () => model.navigateToUserProfile(context),
                  child: Text(
                    user.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        VoteButtons(),
      ],
    );
  }
}
