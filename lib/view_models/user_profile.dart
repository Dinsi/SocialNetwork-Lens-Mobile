import 'dart:async';
import 'dart:collection';
import 'dart:core';

import 'package:aperture/locator.dart';
import 'package:aperture/models/post.dart';
import 'package:aperture/resources/app_info.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/view_models/core/base_model.dart';
import 'package:aperture/view_models/core/mixins/base_feed.dart';
import 'package:aperture/models/users/user.dart';
import 'package:url_launcher/url_launcher.dart';

const _backendListSize = 20;

enum UserProfileViewState { Loading, Done }

class UserProfileModel extends StateModel<UserProfileViewState>
    with BaseFeedMixin<Post> {
  final AppInfo _appInfo = locator<AppInfo>();
  final Repository _repository = locator<Repository>();

  User _user;
  bool clickableURL;

  UserProfileModel() : super(UserProfileViewState.Loading);

  void init(int userId) {
    fetchUser(userId);
  }

  @override
  Future<void> fetch(bool refresh) async {
    int fetchedListSize;
    UnmodifiableListView<Post> postList;

    if (refresh || !listSubject.hasValue) {
      final fetchedList =
          await _repository.fetchPostsByTopic(null, _user.username);

      fetchedListSize = fetchedList.length;

      postList = UnmodifiableListView<Post>(fetchedList);
    } else {
      final fetchedList = await _repository.fetchPostsByTopic(
          listSubject.value.last.id, _user.username);

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

  Future<void> fetchUser(int userId) async {
    if (_appInfo.currentUser.id == userId) {
      _user = appInfo.currentUser;
    } else {
      _user = await repository.fetchUserInfoById(userId);
    }

    if (_user.website != null && await canLaunch(_user.website)) {
      clickableURL = true;
    } else {
      clickableURL = false;
    }

    setState(UserProfileViewState.Done);
  }

  void launchURL() async {
    await launch(
      _user.website,
      enableJavaScript: true,
    );
  }

  User get user => _user;
  bool get isSelf => _appInfo.currentUser.id == _user.id;
}
