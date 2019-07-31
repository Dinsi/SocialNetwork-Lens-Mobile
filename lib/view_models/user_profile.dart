import 'dart:async';
import 'dart:collection';
import 'dart:core';

import 'package:aperture/locator.dart';
import 'package:aperture/models/post.dart';
import 'package:aperture/resources/app_info.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/router.dart';
import 'package:aperture/view_models/core/base_model.dart';
import 'package:aperture/view_models/core/mixins/base_feed.dart';
import 'package:aperture/models/users/user.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
    UnmodifiableListView<Post> fetchedList;
    if (refresh || !listSubject.hasValue) {
      fetchedList = UnmodifiableListView<Post>(
          await _repository.fetchPostsByTopic(null, _user.username));
    } else {
      fetchedList = UnmodifiableListView<Post>(
          List<Post>.from(listSubject.value)
            ..addAll(await _repository.fetchPostsByTopic(
                listSubject.value.last.id, _user.username)));
    }

    if (fetchedList.length != 20) {
      existsNext = false;
    }

    if (!listSubject.isClosed) {
      listSubject.sink.add(fetchedList);
    }
  }

  @override
  void afterInitialFetch(double circularIndicatorHeight) => null;

  Future<void> fetchUser(int userId) async {
    if (_appInfo.user.id == userId) {
      _user = appInfo.user;
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
      forceWebView: true,
      enableJavaScript: true,
    );
  }

  Future<void> navigateToEditProfile(BuildContext context) async {
    int result = await Navigator.of(context).pushNamed(RouteName.editProfile);

    if (result != null) {
      setState(UserProfileViewState.Loading);

      fetchUser(_user.id);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Edit Profile'),
            content: const Text('Profile has been edited successfully'),
            actions: <Widget>[
              FlatButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        },
      );
    }
  }

  User get user => _user;
  bool get isSelf => _appInfo.user.id == _user.id;
}
