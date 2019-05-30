import 'package:flutter/material.dart';

import '../models/user.dart';
import '../blocs/enums/subscribe_button.dart';
import '../blocs/providers/user_profile_bloc_provider.dart';
import 'shared/basic_post.dart';
import 'shared/description_text_widget.dart';
import 'shared/loading_lists/no_scroll_loading_list_view.dart';

class UserProfileScreen extends StatefulWidget {
  UserProfileScreen({Key key}) : super(key: key);

  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  UserProfileBloc bloc;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      bloc = UserProfileBlocProvider.of(context);
      bloc.fetchUser();
      _isInit = true;
    }
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream: bloc.userInfo,
      builder: (BuildContext context, AsyncSnapshot<User> userSnapshot) {
        if (userSnapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue,
              leading: BackButton(
                color: Colors.white,
              ),
              title: Text(
                userSnapshot.data.name,
                style: Theme.of(context)
                    .textTheme
                    .title
                    .copyWith(color: Colors.white),
              ),
              actions: <Widget>[
                if (!bloc.isSelf)
                  StreamBuilder<SubscribeButton>(
                    stream: bloc.subscriptionButton,
                    initialData: bloc.initSubscribeButton(),
                    builder: (BuildContext context,
                        AsyncSnapshot<SubscribeButton> snapshot) {
                      if (snapshot.hasData) {
                        switch (snapshot.data) {
                          case SubscribeButton.subscribe:
                            return MaterialButton(
                              child: Text(
                                'SUBSCRIBE',
                                style: Theme.of(context).textTheme.button.merge(
                                      TextStyle(color: Colors.white),
                                    ),
                              ),
                              onPressed: () =>
                                  bloc.toggleSubscribe('subscribe'),
                            );

                          case SubscribeButton.subscribeInactive:
                            return MaterialButton(
                              child: Text(
                                'SUBSCRIBE',
                                style: Theme.of(context).textTheme.button.merge(
                                      TextStyle(color: Colors.grey[400]),
                                    ),
                              ),
                              onPressed: null,
                            );

                          case SubscribeButton.unsubscribe:
                            return FlatButton.icon(
                              icon: Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                              label: Text(
                                'SUBSCRIBED',
                                style: Theme.of(context).textTheme.button.merge(
                                      TextStyle(color: Colors.white),
                                    ),
                              ),
                              onPressed: () =>
                                  bloc.toggleSubscribe('unsubscribe'),
                            );

                          case SubscribeButton.unsubscribeInactive:
                            return FlatButton.icon(
                              icon: Icon(
                                Icons.check,
                                color: Colors.grey[400],
                              ),
                              label: Text(
                                'SUBSCRIBED',
                                style: Theme.of(context).textTheme.button.merge(
                                      TextStyle(color: Colors.grey[400]),
                                    ),
                              ),
                              onPressed: null,
                            );
                        }
                      } else {
                        return Container();
                      }
                    },
                  ),
              ],
            ),
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: bloc.onRefresh,
                child: NotificationListener<ScrollNotification>(
                  onNotification: bloc.onNotification,
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        (bloc.isSelf
                            ? Container(
                                width: double.infinity,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    ClipOval(
                                      child: Container(
                                        height: 125.0,
                                        width: 125.0,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          image: DecorationImage(
                                            image: (userSnapshot.data.avatar ==
                                                    null
                                                ? AssetImage(
                                                    'assets/img/user_placeholder.png')
                                                : NetworkImage(
                                                    userSnapshot.data.avatar)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      height: 125.0,
                                      right: 15.0,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        alignment: Alignment.center,
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pushNamed('/editProfile')
                                              .then((_) {
                                            if (bloc.isSelf) {
                                              bloc.fetchUser();
                                            }
                                          });
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                child: ClipOval(
                                  child: Container(
                                    height: 125.0,
                                    width: 125.0,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      image: DecorationImage(
                                        image: (userSnapshot.data.avatar == null
                                            ? AssetImage(
                                                'assets/img/user_placeholder.png')
                                            : NetworkImage(
                                                userSnapshot.data.avatar)),
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                        if (userSnapshot.data.headline != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(
                              userSnapshot.data.headline,
                              style: Theme.of(context).textTheme.headline,
                            ),
                          ),
                        Text(userSnapshot.data.name,
                            style: Theme.of(context).textTheme.subhead),
                        if (userSnapshot.data.location != null)
                          Text(userSnapshot.data.location),
                        if (userSnapshot.data.website != null)
                          Text(userSnapshot.data.website),
                        if (userSnapshot.data.bio != null) ...[
                          Divider(
                            height: 20.0,
                            color: Colors.grey,
                          ),
                          DescriptionTextWidget(
                            text: userSnapshot.data.bio,
                            withHashtags: false,
                          ),
                        ],
                        Divider(
                          height: 20.0,
                          color: Colors.grey,
                        ),
                        NoScrollLoadingListView(
                          bloc: bloc,
                          widgetAdapter: (dynamic post) =>
                              BasicPost(post: post, bloc: bloc),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue,
            leading: BackButton(
              color: Colors.white,
            ),
          ),
          body: const Center(
            child: const CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
