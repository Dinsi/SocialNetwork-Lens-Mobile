import 'dart:async';

import 'package:aperture/models/post.dart';
import 'package:flutter/material.dart';

typedef PageRequest = Future<List<Post>> Function(int lastPostId);
typedef WidgetAdapter = Widget Function(Post t);

class LoadingListView extends StatefulWidget {
  /// Abstraction for loading the data.
  /// This can be anything: An API-Call,
  /// loading data from a certain file or database,
  /// etc. It will deliver a list of objects (of type List<Post>)
  final PageRequest pageRequest;

  /// Used for building Widgets out of
  /// the fetched data
  final WidgetAdapter widgetAdapter;

  /// The number of "left over" elements in list which
  /// will trigger loading the next page
  final int pageThreshold;

  LoadingListView(
      {@required this.pageRequest,
      this.pageThreshold: 3,
      @required this.widgetAdapter});

  @override
  _LoadingListViewState createState() => _LoadingListViewState();
}

class _LoadingListViewState extends State<LoadingListView> {
  /// Contains all fetched elements ready to display!
  List<Post> posts = [];

  /// The size of list of the most recently fetched posts
  int currentPageSize;

  /// A Future returned by loadNext() if there
  /// is currently a request running
  /// or null, if no request is performed.
  Future request;

  @override
  Widget build(BuildContext context) {
    return posts.isNotEmpty
        ? RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView.builder(
              itemBuilder: itemBuilder,
              itemCount: posts.length,
            ),
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }

  @override
  void initState() {
    super.initState();
    lockedLoadNext();
  }

  Widget itemBuilder(BuildContext context, int index) {
    /// Once we are entering the threshold zone,
    /// the loadLockedNext() is triggered.
    if (currentPageSize == 20) {
      if (index + widget.pageThreshold - 1 == posts.length) {
        lockedLoadNext();
        return widget.widgetAdapter(posts[index]);
      }

      if (index == posts.length - 1) {
        return Column(
          children: <Widget>[
            widget.widgetAdapter(posts[index]),
            Container(
              margin: const EdgeInsets.only(top: 10.0, bottom: 30.0),
              child: CircularProgressIndicator(
                value: null,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
              ),
            ),
          ],
        );
      }
    }

    return widget.widgetAdapter(posts[index]);
  }

  Future loadNext() async {
    List<Post> fetched =
        await widget.pageRequest(posts.isEmpty ? null : posts.last.id);

    if (fetched.isNotEmpty && mounted) {
      setState(() {
        currentPageSize = fetched.length;
        posts.addAll(fetched);
      });
    }
  }

  void lockedLoadNext() {
    if (this.request == null) {
      this.request = loadNext().then((x) {
        this.request = null;
      });
    }
  }

  Future onRefresh() async {
    this.request?.timeout(const Duration());
    List<Post> fetched = await widget.pageRequest(null);
    setState(() {
      currentPageSize = fetched.length;
      this.posts = fetched;
    });

    return true;
  }
}
