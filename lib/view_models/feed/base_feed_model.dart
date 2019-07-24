import 'dart:async';

import 'package:aperture/locator.dart';
import 'package:aperture/models/post.dart';
import 'package:aperture/resources/app_info.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/view_models/base_model.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart' show protected;
import 'package:rxdart/rxdart.dart';

const double loadingOffset = 100.0;

abstract class BaseFeedModel extends BaseModel {
  @protected
  final Repository repository = locator<Repository>();

  @protected
  final AppInfo appInfo = locator<AppInfo>();

  @protected
  Future request;

  bool existsNext = true;
  bool isLoading = false;

  @protected
  BehaviorSubject<List<Post>> postsFetcher = BehaviorSubject<List<Post>>();

  @override
  void dispose() {
    postsFetcher.close();
  }

  Future<void> lockedLoadNext(bool refresh) {
    if (request == null) {
      request = fetch(refresh).then((_) {
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
          lockedLoadNext(false);
        }

        return true;
      }
    }

    return false;
  }

  Future<void> onRefresh() {
    request?.timeout(const Duration());
    existsNext = true;
    return lockedLoadNext(true);
  }

  Future<void> fetch(bool refresh);

  Stream<List<Post>> get posts => postsFetcher.stream;
  int get listLength => postsFetcher.value.length;
}
