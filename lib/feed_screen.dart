import 'package:aperture/loading_list_view.dart';
import 'package:aperture/network/api.dart';
import 'package:aperture/models/post.dart';
import 'package:aperture/widgets/basic_post.dart';
import 'package:flutter/material.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key key}) : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingListView(
        pageRequest: Api.feed,
        widgetAdapter: (Post post) => BasicPost(post: post),
      ),
    );
  }
}
