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

const double _iconSideSize = 35.0;
const double _defaultHeight = 60.0;

class BasicPost extends StatelessWidget {
  final bool delegatingModel;
  final Post post;

  const BasicPost({Key key, this.delegatingModel = false, this.post})
      : assert((delegatingModel == true && post == null) ||
            (delegatingModel == false && post != null)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return delegatingModel
        ? Consumer<BasicPostModel>(
            builder: _buildBasicPost,
          )
        : ChangeNotifierBaseView<BasicPostModel>(
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
            onTap: !delegatingModel
                ? () => model.navigateToDetailedPost(context, false)
                : null, // TODO toFullImageScreen
            onDoubleTap: () => model.onUpvoteOrRemove(),
          ),
          Container(
            height: _defaultHeight,
            margin: const EdgeInsets.only(left: 12.0),
            child: model.isSelf && !delegatingModel
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
        if (!delegatingModel)
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
        VoteButtons(model: model),
      ],
    );
  }
}
