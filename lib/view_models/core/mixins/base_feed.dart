import 'dart:async';
import 'dart:collection';

import 'package:aperture/locator.dart';
import 'package:aperture/resources/app_info.dart';
import 'package:aperture/resources/repository.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart' show protected;
import 'package:rxdart/rxdart.dart';

const double loadingOffset = 50.0;

mixin BaseFeedMixin<T> {
  @protected
  final Repository repository = locator<Repository>();

  @protected
  final AppInfo appInfo = locator<AppInfo>();

  @protected
  Future request;

  bool existsNext = true;

  @protected
  BehaviorSubject<UnmodifiableListView<T>> listSubject =
      BehaviorSubject<UnmodifiableListView<T>>();

  @mustCallSuper
  void dispose() {
    listSubject.close();
  }

  Future<void> lockedLoadNext(bool refresh) {
    if (request == null) {
      request = fetch(refresh).whenComplete(() {
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
        lockedLoadNext(false);
        return true;
      }
    }

    return false;
  }

  Future<void> onRefresh() {
    request?.timeout(const Duration());
    request = null;
    existsNext = true;
    return lockedLoadNext(true);
  }

  void insertEmptyList() {
    existsNext = false;
    listSubject.add(UnmodifiableListView(List(0)));
  }

  Future<void> fetch(bool refresh);

  Observable<UnmodifiableListView<T>> get listStream => listSubject.stream;
  int get listLength => listSubject.value.length;
}
