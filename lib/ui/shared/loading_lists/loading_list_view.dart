import 'dart:async';

import 'package:aperture/models/post.dart';
import 'package:aperture/ui/shared/loading_lists/scroll_loading_list_view.dart';
import 'package:aperture/view_models/feed/base_feed_model.dart';
import 'package:flutter/material.dart';

typedef WidgetAdapter = Widget Function(Post t);
typedef FetchRequester = Future Function(int lastId);

abstract class LoadingListView extends StatefulWidget {
  /// Used for building Widgets out of
  /// the fetched data
  final WidgetAdapter widgetAdapter;

  final BaseFeedModel model;

  /// The number of "left over" elements in list which
  /// will trigger loading the next page

  LoadingListView({@required this.widgetAdapter, @required this.model});
}

abstract class LoadingListViewState<T extends LoadingListView>
    extends State<T> {
  @override
  void initState() {
    super.initState();
    widget.model.fetch(false);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Post>>(
      stream: widget.model.posts,
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
        if (widget.model.existsNext && index == posts.length - 1) {
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
