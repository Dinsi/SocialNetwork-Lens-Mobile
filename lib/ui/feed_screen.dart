import 'package:aperture/ui/shared/basic_post.dart';
import 'package:aperture/ui/shared/loading_lists/scroll_loading_list_view.dart';
import 'package:aperture/view_models/feed_bloc.dart';
import 'package:aperture/view_models/providers/feed_bloc_provider.dart';
import 'package:flutter/material.dart';

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
    Widget postsList = RefreshIndicator(
      onRefresh: bloc.onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: bloc.onNotification,
        child: ScrollLoadingListView(
          widgetAdapter: (dynamic post) => BasicPost(
                post: post,
                bloc: bloc,
              ),
          bloc: bloc,
        ),
      ),
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
