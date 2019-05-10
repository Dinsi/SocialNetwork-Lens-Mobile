import 'dart:async';

import 'package:flutter/material.dart';
import '../../models/post.dart';
import '../../blocs/base_feed_bloc.dart';

typedef WidgetAdapter = Widget Function(Post t);
typedef FetchRequester = Future Function(int lastId);

class LoadingListView extends StatefulWidget {
  /// Used for building Widgets out of
  /// the fetched data
  final WidgetAdapter widgetAdapter;

  final BaseFeedBloc bloc;

  /// The number of "left over" elements in list which
  /// will trigger loading the next page
  final int pageThreshold;

  LoadingListView(
      {this.pageThreshold: 3,
      @required this.widgetAdapter,
      @required this.bloc});

  @override
  _LoadingListViewState createState() => _LoadingListViewState();
}

class _LoadingListViewState extends State<LoadingListView> {
  /// A Future returned by loadNext() if there
  /// is currently a request running
  /// or null, if no request is performed.
  Future request;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: StreamBuilder<List<Post>>(
        stream: widget.bloc.posts,
        builder: (BuildContext context, AsyncSnapshot<List<Post>> snapshot) {
          if (snapshot.hasData) {
            return _buildList(snapshot.data);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    lockedLoadNext();
  }

  Widget _buildList(List<Post> posts) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (BuildContext context, int index) {
        if (widget.bloc.listLength == 20) {
          if (index + widget.pageThreshold - 1 == posts.length) {
            lockedLoadNext();
            return widget.widgetAdapter(posts[index]);
          }

          if (index == posts.length - 1) {
            return Column(
              children: <Widget>[
                widget.widgetAdapter(posts[index]),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blueGrey),
                    ),
                  ),
                ),
              ],
            );
          }
        }

        return widget.widgetAdapter(posts[index]);
      },
    );
  }

  void lockedLoadNext() {
    if (this.request == null) {
      this.request = widget.bloc.fetch().then((_) {
        this.request = null;
      }).catchError((error) => this.request = null);
    }
  }

  Future onRefresh() async {
    this.request?.timeout(const Duration());

    widget.bloc.clear();

    this.request = widget.bloc.fetch();
    await this.request;
    this.request = null;

    return true;
  }
}
