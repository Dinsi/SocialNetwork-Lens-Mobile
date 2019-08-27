import 'package:aperture/models/post.dart';
import 'package:aperture/models/users/user.dart';
import 'package:aperture/router.dart';
import 'package:aperture/ui/core/base_view.dart';
import 'package:aperture/ui/shared/basic_post.dart';
import 'package:aperture/ui/shared/loading_lists/scroll_loading_list_view.dart';
import 'package:aperture/ui/shared/user_avatar.dart';
import 'package:aperture/view_models/feed.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SimpleBaseView<FeedModel>(
        builder: (_, model, __) {
          /*NestedScrollView(
    controller: _scrollViewController,
    headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
      return <Widget>[
        new SliverAppBar(
          title: new Text(widget.title),
          pinned: true,
          floating: true,
          forceElevated: innerBoxIsScrolled,
          bottom: new TabBar(
            tabs: <Tab>[
              new Tab(text: "STATISTICS"),
              new Tab(text: "HISTORY"),
            ],
            controller: _tabController,
          ),
        ),
      ];*/
          return Scaffold(
            key: model.scaffoldKey,
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Consumer<User>(
                    builder: (context, currentUser, _) => ListTile(
                      leading: UserAvatar(
                        isCircle: true,
                        side: 40.0,
                        user: currentUser,
                      ),
                      title: Text(
                        '${currentUser.name}',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () => model.navigateTo(
                        context,
                        RouteName.userProfile,
                        currentUser.id,
                      ),
                    ),
                  ),
                  _buildListTile(
                    icon: Icons.book,
                    title: 'Collections',
                    onTap: () => model.navigateTo(
                      context,
                      RouteName.collectionList,
                      {'isAddToCollection': false},
                    ),
                  ),
                  _buildListTile(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () => model.navigateTo(context, RouteName.settings),
                  ),
                  _buildListTile(
                    icon: FontAwesomeIcons.trophy,
                    title: 'Tournament',
                    onTap: () =>
                        model.navigateTo(context, RouteName.tournament),
                  ),
                  _buildListTile(
                    icon: FontAwesomeIcons.signOutAlt,
                    title: 'Logout',
                    onTap: () => model.signOut(context),
                  ),
                ],
              ),
            ),
            body: RefreshIndicator(
              onRefresh: model.onRefresh,
              child: NotificationListener<ScrollNotification>(
                onNotification: model.onNotification,
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverAppBar(
                      title: Text('Home'),
                      pinned: false,
                      floating: true,
                      actions: <Widget>[
                        IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () =>
                              model.navigateTo(context, RouteName.search),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () => model.uploadNewPost(context),
                        ),
                      ],
                      bottom: !model.userIsConfirmed
                          ? PreferredSize(
                              preferredSize: Size(double.infinity, 50.0),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                ),
                                child: Center(
                                  child: Text(
                                    "Please confirm your email address",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : null,
                    ),
                    ScrollLoadingListView<Post>(
                      sliver: true,
                      model: model,
                      widgetAdapter: (ObjectKey key, Post post) => BasicPost(
                        key: key,
                        post: post,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListTile(
      {@required IconData icon,
      @required String title,
      @required VoidCallback onTap,
      Map<String, dynamic> arguments}) {
    return ListTile(
      leading: Icon(icon, size: 28.0),
      title: Text(title, style: TextStyle(fontSize: 15.0)),
      onTap: onTap,
    );
  }
}
