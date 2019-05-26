import 'dart:async';
import 'dart:core';

import '../models/post.dart';
import '../models/user.dart';
import 'base_feed_bloc.dart';

class UserProfileBloc extends BaseFeedBloc {
  final userId;
  final String userName;
  final String userUsername;
  StreamController<User> _userController;

  UserProfileBloc(this.userId, this.userName, this.userUsername)
      : _userController = StreamController<User>();

  @override
  Future<void> fetch() async {
    List<Post> fetchedList = await repository.fetchPostsByUser(
        postsList.isNotEmpty ? postsList.last.id : null, userUsername);

    postsList.addAll(fetchedList);
    if (!postsFetcher.isClosed) {
      postsFetcher.sink.add(postsList);
    }
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

  @override
  void dispose() {
    super.dispose();
    _userController.close();
  }

  bool get isSelf => globals.user.id == userId;
  Stream<User> get userInfo => _userController.stream;
}
