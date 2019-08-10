import 'package:aperture/models/post.dart';
import 'package:aperture/models/users/compact_user.dart';
import 'package:aperture/models/users/user.dart';
import 'package:aperture/ui/core/base_view.dart';
import 'package:aperture/ui/shared/image_container.dart';
import 'package:aperture/ui/shared/user_avatar.dart';
import 'package:aperture/utils/utils.dart';
import 'package:aperture/view_models/shared/basic_post.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

const double _iconSideSize = 35.0;
const double _defaultHeight = 55.0;

TextStyle _votesTextStyle([Color color]) {
  return TextStyle(
    fontSize: 17.0,
    fontWeight: FontWeight.bold,
    color: color ?? Colors.grey[600],
  );
}

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
            margin: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 10.0),
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

    /*// * If the post belongs to the user, fetches user
    // *     (provided by Stream Provider) from the widget tree

    // * Else, it uses the user info from the post itself

    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ImageContainer(
            imageUrl: model.post.image,
            imageHeight: model.post.height,
            imageWidth: model.post.width,
            onTap: !delegatingModel
                ? () => model.navigateToDetailedPost(context, false)
                : null, // TODO toFullImageScreen
            onDoubleTap: () => model.onUpvoteOrRemove(),
          ),
          _buildActionRow(context, model),
        ],
      ),
    );*/
  }

  Widget _buildActionRow(
      BuildContext context, BasicPostModel model, CompactUser user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                const SizedBox(
                  width: 8.0,
                ),
                Flexible(
                  child: GestureDetector(
                    onTap: () => model.navigateToUserProfile(context),
                    child: Text.rich(
                      TextSpan(text: user.name),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.blueGrey, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildVoteButton(model, true),
            SizedBox(
              width: 50.0,
              child: Center(
                child: Text(
                  nFormatter(model.post.votes.toDouble()),
                  style: _votesTextStyle(
                      model.state == BasicPostViewState.UpVote
                          ? Colors.blue
                          : null),
                ),
              ),
            ),
            _buildVoteButton(model, false),
          ],
        ),
      ],
    );

    /*return Container(
      height: _defaultHeight,
      padding: const EdgeInsets.only(left: 15.0),
      child: Theme(
        data: Theme.of(context).copyWith(
          iconTheme:
              Theme.of(context).iconTheme.copyWith(color: Colors.grey[600]),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            if (!delegatingModel)
              model.isSelf
                  ? Consumer<User>(
                      builder: (context, currentUser, __) => UserAvatar(
                        side: _iconSideSize,
                        user: currentUser,
                        onTap: () => model.navigateToUserProfile(context),
                      ),
                    )
                  : UserAvatar(
                      side: _iconSideSize,
                      user: model.post.user,
                      onTap: () => model.navigateToUserProfile(context),
                    ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Material(
                  child: InkWell(
                    onTap: () => model.onUpvoteOrRemove(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.arrowAltCircleUp,
                            color: model.state == BasicPostViewState.UpVote
                                ? Colors.blue
                                : Colors.grey[600],
                          ),
                          const SizedBox(
                            width: 8.0,
                          ),
                          Text(
                            nFormatter(model.post.votes.toDouble(), 0),
                            style: _votesTextStyle(
                                model.state == BasicPostViewState.UpVote
                                    ? Colors.blue
                                    : null),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Material(
                  child: InkWell(
                    onTap: () => model.onDownvoteOrRemove(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Icon(
                        FontAwesomeIcons.arrowAltCircleDown,
                        color: model.state == BasicPostViewState.DownVote
                            ? Colors.red
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                )
              ],
            ),
            Material(
              child: InkWell(
                onTap: !delegatingModel
                    ? () => model.navigateToDetailedPost(context, true)
                    : null,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 20.0,
                    end: 20.0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        FontAwesomeIcons.commentAlt,
                        size: 18.0,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8.0),
                      Center(
                        child: Text(
                          model.post.commentsLength.toString(),
                          style: _votesTextStyle(),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            PopupMenuButton<int>(
              onSelected: (value) => model.onSelected(context, value),
              itemBuilder: (_) => [
                PopupMenuItem<int>(
                  value: 1,
                  child: Row(
                    children: <Widget>[
                      Icon(FontAwesomeIcons.plusSquare),
                      const SizedBox(width: 15.0),
                      const Text('Add to collection'),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );*/
  }

  Widget _buildVoteButton(BasicPostModel model, bool isUpvote) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: isUpvote
            ? () => model.onUpvoteOrRemove()
            : () => model.onDownvoteOrRemove(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: isUpvote
              ? Icon(
                  FontAwesomeIcons.arrowAltCircleUp,
                  color: model.state == BasicPostViewState.UpVote
                      ? Colors.blue
                      : Colors.grey[600],
                )
              : Icon(
                  FontAwesomeIcons.arrowAltCircleDown,
                  color: model.state == BasicPostViewState.DownVote
                      ? Colors.red
                      : Colors.grey[600],
                ),
        ),
      ),
    );
  }
}
