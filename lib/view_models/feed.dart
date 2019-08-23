import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:aperture/locator.dart';
import 'package:aperture/resources/app_info.dart';
import 'package:aperture/router.dart';
import 'package:aperture/view_models/core/base_model.dart';
import 'package:aperture/view_models/core/mixins/base_feed.dart';
import 'package:aperture/models/post.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const _backendListSize = 20;

// TODO FIX THIS
class FeedModel extends BaseModel with BaseFeedMixin<Post> {
  // TODO cover empty list case
  final scaffoldKey = GlobalKey<ScaffoldState>();

  void signOut(BuildContext context) {
    locator<AppInfo>().clearCache();
    Navigator.of(context).pushReplacementNamed(RouteName.login);
  }

  void openDrawer() {
    scaffoldKey.currentState.openDrawer();
  }

  Future<void> uploadNewPost(BuildContext context) async {
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      navigateTo(context, RouteName.uploadPost, file);
    }
  }

  @override
  Future<void> fetch(bool refresh) async {
    int fetchedListSize;
    UnmodifiableListView<Post> postList;

    if (refresh || !listSubject.hasValue) {
      final fetchedList = await repository.fetchPosts(null);

      fetchedListSize = fetchedList.length;

      postList = UnmodifiableListView<Post>(fetchedList);
    } else {
      final fetchedList =
          await repository.fetchPosts(listSubject.value.last.id);

      fetchedListSize = fetchedList.length;

      postList = UnmodifiableListView<Post>(
          List<Post>.from(listSubject.value)..addAll(fetchedList));
    }

    if (fetchedListSize != _backendListSize) {
      existsNext = false;
    }

    if (!listSubject.isClosed) {
      listSubject.sink.add(postList);
    }
  }

  @override
  void afterInitialFetch(double circularIndicatorHeight) => null;

  void navigateTo(BuildContext context, String route, [Object arguments]) {
    Navigator.of(context).pushNamed(route, arguments: arguments);
  }

  bool get userIsConfirmed => appInfo.currentUser.isConfirmed;
}
