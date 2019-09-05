import 'package:aperture/models/post.dart';
import 'package:aperture/models/users/compact_user.dart';
import 'package:aperture/ui/core/base_view.dart';
import 'package:aperture/ui/shared/basic_post.dart';
import 'package:aperture/ui/shared/description_text.dart';
import 'package:aperture/ui/shared/loading_lists/no_scroll_loading_list_view.dart';
import 'package:aperture/ui/shared/app_bars/subscription_app_bar.dart';
import 'package:aperture/ui/shared/user_avatar.dart';
import 'package:aperture/ui/utils/shortcuts.dart';
import 'package:aperture/view_models/user_profile.dart';
import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  final int userId;

  UserProfileScreen({Key key, @required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierBaseView<UserProfileModel>(
      onModelReady: (model) => model.init(userId),
      builder: (_, model, __) {
        return SafeArea(
          child: model.state == UserProfileViewState.Loading
              ? _buildLoadingScaffold()
              : Scaffold(
                  appBar: SubscriptionAppBar(
                    topicOrUser: model.user.username,
                    title: Text(model.isSelf ? 'My profile' : 'Profile'),
                  ),
                  body: RefreshIndicator(
                    onRefresh: model.onRefresh,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: model.onNotification,
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: _buildUserAvatar(model.user),
                            ),
                            if (model.user.headline != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Text(
                                  model.user.headline,
                                  style: Theme.of(context).textTheme.headline,
                                ),
                              ),
                            Text(
                              model.user.name,
                              style: Theme.of(context).textTheme.subhead,
                            ),
                            if (model.user.location != null)
                              Text(model.user.location),
                            if (model.user.publicEmail != null)
                              Text(model.user.publicEmail),
                            if (model.user.website != null)
                              model.clickableURL
                                  ? GestureDetector(
                                      onTap: () {
                                        model.launchURL();
                                      },
                                      child: Text(
                                        model.user.website,
                                        style: TextStyle(
                                          color: Colors.blue,
                                        ),
                                      ),
                                    )
                                  : Text(model.user.website),
                            if (model.user.bio != null) ...[
                              Divider(
                                height: 20.0,
                                color: Colors.grey,
                              ),
                              DescriptionText(
                                text: model.user.bio,
                                withHashtags: false,
                              ),
                            ],
                            Divider(
                              height: 20.0,
                              color: Colors.grey,
                            ),
                            NoScrollLoadingListView(
                              model: model,
                              widgetAdapter: (ObjectKey key, Post post) =>
                                  BasicPost(
                                key: key,
                                post: post,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildLoadingScaffold() {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: defaultCircularIndicator(),
      ),
    );
  }

  Widget _buildUserAvatar(CompactUser user) {
    return UserAvatar(isCircle: true, side: 130.0, user: user);
  }
}
