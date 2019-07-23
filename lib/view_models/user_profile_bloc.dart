import 'dart:async';
import 'dart:core';

import 'package:aperture/view_models/single_subscription_bloc.dart';
import 'package:aperture/models/users/user.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfileBloc extends SingleSubscriptionBloc {
  final userId;
  StreamController<User> _userController;

  bool clickableURL;

  UserProfileBloc(this.userId, String userUsername)
      : _userController = StreamController<User>(),
        super(userUsername);

  @override
  void dispose() {
    _userController.close();
    super.dispose();
  }

  Future<void> fetchUser() async {
    User targetUser;
    if (isSelf) {
      targetUser = appInfo.user;
    } else {
      targetUser = await repository.fetchUserInfoById(userId);
    }

    if (targetUser.website != null && await canLaunch(targetUser.website)) {
      clickableURL = true;
    } else {
      clickableURL = false;
    }

    if (!_userController.isClosed) {
      _userController.sink.add(targetUser);
    }
  }

  void launchURL(String url) async {
    await launch(url);
  }

  bool get isSelf => appInfo.user.id == userId;
  Stream<User> get userInfo => _userController.stream;
}
