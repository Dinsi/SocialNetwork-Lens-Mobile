import 'package:aperture/globals.dart';
import 'package:aperture/widgets/loading_list_view.dart';
import 'package:aperture/network/api.dart';
import 'package:aperture/models/post.dart';
import 'package:aperture/widgets/posts/basic_post.dart';
import 'package:flutter/material.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key key}) : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  Globals globalsInstance;

  @override
  void initState() {
    super.initState();
    globalsInstance = Globals.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    LoadingListView postsList = LoadingListView(
      pageRequest: Api.feed,
      widgetAdapter: (Post post) => BasicPost(post: post),
    );

    return SafeArea(
      child: Scaffold(
        body: (globalsInstance.user.isConfirmed
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
