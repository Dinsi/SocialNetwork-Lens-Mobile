import 'package:flutter/material.dart';

import '../blocs/feed_bloc.dart';
import 'sub_widgets/basic_post.dart';
import 'loading_list_view.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key key}) : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  bool userIsConfirmed;

  @override
  void initState() {
    super.initState();
    userIsConfirmed = feedBloc.userIsConfirmed;
  }

  @override
  void dispose() {
    feedBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LoadingListView postsList = LoadingListView(
      widgetAdapter: (dynamic post) => BasicPost(post: post),
      bloc: feedBloc,
    );

    return SafeArea(
      child: Scaffold(
        body: (userIsConfirmed
            ? postsList
            : Column(
                children: <Widget>[
                  Container(
                    height: 50.0,
                    color: Colors.blue,
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
                  Expanded(
                    child: postsList,
                  ),
                ],
              )),
      ),
    );
  }
}
