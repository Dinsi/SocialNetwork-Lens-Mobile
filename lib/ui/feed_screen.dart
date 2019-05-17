import 'package:flutter/material.dart';

import '../blocs/feed_bloc.dart';
import '../blocs/providers/feed_bloc_provider.dart';
import 'sub_widgets/basic_post.dart';
import 'sub_widgets/loading_list_view.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key key}) : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  bool userIsConfirmed;
  FeedBloc bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc ??= FeedBlocProvider.of(context);
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LoadingListView postsList = LoadingListView(
      widgetAdapter: (dynamic post) => BasicPost(
            post: post,
            bloc: bloc,
          ),
      bloc: bloc,
    );

    return Scaffold(
      body: (bloc.userIsConfirmed
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
    );
  }
}
