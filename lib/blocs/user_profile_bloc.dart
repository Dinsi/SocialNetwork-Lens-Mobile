import 'dart:async';
import 'dart:core';

import '../blocs/subscription_bloc.dart';

import '../models/user.dart';

class UserProfileBloc extends SubscriptionBloc {
  final userId;
  StreamController<User> _userController;

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
      targetUser = globals.user;
    } else {
      targetUser = await repository.fetchUserInfoById(userId);
    }

    if (!_userController.isClosed) {
      _userController.sink.add(targetUser);
    }
  }

  bool get isSelf => globals.user.id == userId;
  Stream<User> get userInfo => _userController.stream;
}
