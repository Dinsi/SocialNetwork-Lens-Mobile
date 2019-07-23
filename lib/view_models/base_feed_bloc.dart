import 'dart:async';

import 'package:aperture/locator.dart';
import 'package:aperture/models/post.dart';
import 'package:aperture/resources/app_info.dart';
import 'package:aperture/resources/repository.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart' show protected;

const double loadingOffset = 100.0;

abstract class BaseFeedBloc {
  @protected
  final Repository repository = locator<Repository>();

  @protected
  final AppInfo appInfo = locator<AppInfo>();

  @protected
  Future request;

  final List<Post> postsList = List<Post>();

  bool existsNext = true;
  bool isLoading = false;

  @protected
  StreamController<List<Post>> postsFetcher =
      StreamController<List<Post>>.broadcast();

  void dispose() {
    postsFetcher.close();
  }

  Future<int> removeVote(int postId) async {
    return await repository.changeVote(postId, "removevote");
  }

  Future<int> downVote(int postId) async {
    return await repository.changeVote(postId, "downvote");
  }

  Future<int> upVote(int postId) async {
    return await repository.changeVote(postId, "upvote");
  }

  void clear() {
    postsList.clear();
    existsNext = true;
  }

  Future<void> lockedLoadNext() {
    if (request == null) {
      request = fetch().then((_) {
        isLoading = false;
        request = null;
      }).catchError((_) {
        isLoading = false;
        request = null;
      });
      return request;
    }

    return null;
  }

  bool onNotification(ScrollNotification notification) {
    if (existsNext) {
      if ((notification is OverscrollNotification &&
              notification.overscroll > 0) ||
          (notification is ScrollUpdateNotification &&
              notification.metrics.maxScrollExtent >
                  notification.metrics.pixels &&
              notification.metrics.maxScrollExtent -
                      notification.metrics.pixels <=
                  loadingOffset)) {
        if (!isLoading) {
          isLoading = true;
          lockedLoadNext();
        }

        return true;
      }
    }

    return false;
  }

  Future<void> onRefresh() {
    request?.timeout(const Duration());

    clear();

    return lockedLoadNext();
  }

  Future<void> fetch();

  Stream<List<Post>> get posts => postsFetcher.stream;
  int get listLength => postsList.length;
}
