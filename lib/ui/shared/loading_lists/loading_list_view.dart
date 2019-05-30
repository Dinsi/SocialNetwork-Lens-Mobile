import 'dart:async';

import 'package:flutter/material.dart';

import '../../../models/post.dart';
import '../../../blocs/base_feed_bloc.dart';
import 'scroll_loading_list_view.dart';

export '../../../blocs/base_feed_bloc.dart';

typedef WidgetAdapter = Widget Function(Post t);
typedef FetchRequester = Future Function(int lastId);

abstract class LoadingListView extends StatefulWidget {
  /// Used for building Widgets out of
  /// the fetched data
  final WidgetAdapter widgetAdapter;

  final BaseFeedBloc bloc;

  /// The number of "left over" elements in list which
  /// will trigger loading the next page

  LoadingListView({@required this.widgetAdapter, @required this.bloc});
}

abstract class LoadingListViewState<T extends LoadingListView>
    extends State<T> {
  @override
  void initState() {
    super.initState();
    widget.bloc.fetch();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Post>>(
      stream: widget.bloc.posts,
      builder: (BuildContext context, AsyncSnapshot<List<Post>> snapshot) {
        if (snapshot.hasData) {
          return _buildList(snapshot.data);
        } else {
          return const Center(
            child: const SizedBox(
              height: 70.0,
              child: const Center(
                child: const CircularProgressIndicator(),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildList(List<Post> posts) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (BuildContext context, int index) {
        if (widget.bloc.existsNext && index == posts.length - 1) {
          return Column(
            children: <Widget>[
              widget.widgetAdapter(posts[index]),
              const Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
                child: const Center(
                  child: const CircularProgressIndicator(
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.blueGrey),
                  ),
                ),
              ),
            ],
          );
        }

        return widget.widgetAdapter(posts[index]);
      },
      physics: (widget is ScrollLoadingListView
          ? const AlwaysScrollableScrollPhysics()
          : null),
      primary: widget is ScrollLoadingListView,
      shrinkWrap: !(widget is ScrollLoadingListView),
    );
  }
}
