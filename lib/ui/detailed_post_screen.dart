import 'package:aperture/locator.dart';
import 'package:aperture/models/comment.dart';
import 'package:aperture/models/users/compact_user.dart';
import 'package:aperture/models/users/user.dart';
import 'package:aperture/resources/app_info.dart';
import 'package:aperture/ui/core/base_view.dart';
import 'package:aperture/ui/shared/comment_tile.dart';
import 'package:aperture/ui/shared/description_text.dart';
import 'package:aperture/ui/shared/image_container.dart';
import 'package:aperture/ui/shared/loading_lists/no_scroll_loading_list_view.dart';
import 'package:aperture/ui/shared/user_avatar.dart';
import 'package:aperture/ui/shared/vote_buttons.dart';
import 'package:aperture/view_models/detailed_post.dart';
import 'package:aperture/view_models/shared/basic_post.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

const _iconSideSize = 40.0;
const _newCommentIconSideSize = 30.0;

class DetailedPostScreen extends StatelessWidget {
  final BasicPostModel basicPostModel;

  const DetailedPostScreen({@required this.basicPostModel});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ChangeNotifierBaseView<DetailedPostModel>(
          onModelReady: (model) {
            model.init(basicPostModel);
          },
          builder: (context, model, _) {
            return RefreshIndicator(
              onRefresh: model.onRefresh,
              child: NotificationListener<ScrollNotification>(
                onNotification: model.onNotification,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView(
                        controller: model.scrollController,
                        key: model.listViewKey,
                        children: _buildWidgetList(context, model),
                      ),
                    ),
                    _buildNewCommentSection(context, model),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildWidgetList(BuildContext context, DetailedPostModel model) {
    return [
      Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 12.0, right: 12.0),
        child: basicPostModel.isSelf
            ? Consumer<User>(
                builder: (context, currentUser, __) =>
                    _buildUserRow(context, model, currentUser),
              )
            : _buildUserRow(context, model, model.post.user),
      ),
      const SizedBox(height: 16.0),
      DescriptionText(
        text: model.post.description,
        withHashtags: true,
      ),
      const SizedBox(height: 16.0),
      _buildImageAndVoteSection(context, model),
      const SizedBox(height: 16.0),
      Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Text(
          model.post.commentsLength == 1
              ? '1 comment'
              : '${model.post.commentsLength} comments',
          style: Theme.of(context).textTheme.subhead.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
        ),
      ),
      const SizedBox(height: 8.0),
      if (model.post.commentsLength != 0) _buildCommentSection(model)
    ];
  }

  Widget _buildUserRow(
      BuildContext context, DetailedPostModel model, CompactUser user) {
    return Flexible(
      child: Row(
        children: <Widget>[
          UserAvatar(
            isCircle: true,
            side: _iconSideSize,
            user: user,
            onTap: () => model.navigateToUserProfile(context),
          ),
          const SizedBox(width: 12.0),
          Flexible(
            child: GestureDetector(
              onTap: () => model.navigateToUserProfile(context),
              child: Text(
                user.name,
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageAndVoteSection(
      BuildContext context, DetailedPostModel model) {
    final iconTheme = IconTheme.of(context);

    return Column(
      children: <Widget>[
        ImageContainer(
          imageUrl: model.post.image,
          imageHeight: model.post.height,
          imageWidth: model.post.width,
          onTap: null,
          onDoubleTap: () => model.onUpvoteOrRemove(),
        ),
        Container(
          color: Colors.grey[100],
          height: 50.0,
          child: Material(
            type: MaterialType.transparency,
            child: IconTheme(
              data: iconTheme.copyWith(color: Colors.grey[600]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: SizedBox(
                      width: 50.0,
                      height: double.infinity,
                      child: InkWell(
                        onTap: null,
                        child: Icon(FontAwesomeIcons.camera),
                      ),
                    ),
                  ),
                  ChangeNotifierProvider<BasicPostModel>.value(
                    value: basicPostModel,
                    child: VoteButtons(),
                  ),
                  PopupMenuButton<DetailedPostOptions>(
                    onSelected: (result) =>
                        model.onMoreSelected(context, result),
                    itemBuilder: (context) =>
                        <PopupMenuEntry<DetailedPostOptions>>[
                      const PopupMenuItem<DetailedPostOptions>(
                        value: DetailedPostOptions.CollectionAdd,
                        height: 52.0,
                        child: ListTile(
                          title: Text('Add to collection'),
                          leading: Icon(FontAwesomeIcons.bookmark),
                        ),
                      ),
                      PopupMenuItem<DetailedPostOptions>(
                        value: DetailedPostOptions.SubmitPost,
                        height: 52.0,
                        enabled: model.postBelongsToUser,
                        child: ListTile(
                          title: const Text('Submit post'),
                          leading: const Icon(FontAwesomeIcons.random),
                          enabled: model.postBelongsToUser,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentSection(DetailedPostModel model) {
    return NoScrollLoadingListView<Comment>(
      model: model,
      widgetAdapter: (ObjectKey key, Comment comment) {
        final isSelf = comment.user.id == locator<AppInfo>().currentUser.id;
        return CommentTile(
          key: key,
          comment: comment,
          onPressed: model.navigateToUserProfile,
          isSelf: isSelf,
        );
      },
    );
  }

  Widget _buildNewCommentSection(
      BuildContext context, DetailedPostModel model) {
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(primaryColor: Colors.red),
      child: Column(
        children: <Widget>[
          Divider(height: 15.0, color: Colors.black45),
          SizedBox(
            height: _newCommentIconSideSize + 10.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const SizedBox(width: 8.0),
                    Consumer<User>(
                      builder: (_, currentUser, __) => UserAvatar(
                        isCircle: true,
                        side: _newCommentIconSideSize,
                        user: currentUser,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: TextField(
                        controller: model.commentTextController,
                        focusNode: model.commentFocusNode,
                        style: TextStyle(fontSize: 16.0),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1024),
                        ],
                        decoration: InputDecoration(
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: "Add a comment...",
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 5.0,
                            horizontal: 2.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    GestureDetector(
                      onTap: () => model.onCommentPublish(context),
                      child: SizedBox(
                        height: _newCommentIconSideSize,
                        width: _newCommentIconSideSize + 10.0,
                        child: Icon(
                          FontAwesomeIcons.solidPaperPlane,
                          size: _newCommentIconSideSize - 5.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12.0),
        ],
      ),
    );
  }
}
