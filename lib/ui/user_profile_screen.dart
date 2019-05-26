import 'package:flutter/material.dart';

import '../models/user.dart';
import '../blocs/providers/user_profile_bloc_provider.dart';
import 'sub_widgets/basic_post.dart';
import 'sub_widgets/description_text_widget.dart';
import 'sub_widgets/loading_list_view.dart';

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
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    (bloc.isSelf
                        ? Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(vertical: 16.0),
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
                                        image: (userSnapshot.data.avatar == null
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
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                    Divider(
                      height: 20.0,
                      color: Colors.grey,
                    ),
                    DescriptionTextWidget(
                      text: userSnapshot.data.bio,
                      withHashtags: false,
                    ),
                    Divider(
                      height: 20.0,
                      color: Colors.grey,
                    ),
                    LoadingListView(
                      bloc: bloc,
                      widgetAdapter: (dynamic post) =>
                          BasicPost(post: post, bloc: bloc),
                      clamped: true,
                    ),
                  ],
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
