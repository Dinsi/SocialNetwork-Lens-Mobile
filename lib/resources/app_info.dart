import 'dart:async' show Future;
import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:aperture/models/collections/collection.dart';
import 'package:aperture/models/collections/compact_collection.dart';
import 'package:aperture/models/topic.dart';
import 'package:aperture/models/users/user.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef UserChangeCallback = User Function(User);

class AppInfo {
  final SharedPreferences _prefs;
  BehaviorSubject<User> _userController = BehaviorSubject();

  AppInfo(this._prefs) {
    String userJson = _prefs.getString('user');

    if (userJson != null) {
      User user = User.fromJson(jsonDecode(userJson));
      _addUser(user);
    }
  }

  ///////////////////////////////////////////////////////

  // * Dispose
  void dispose() {
    _userController.close();
  }

  ///////////////////////////////////////////////////////
  // * Public functions
  bool isLoggedIn() {
    return _prefs.getBool('loggedIn') != null;
  }

  Future<void> clearCache() async {
    await _prefs.clear();
  }

  Future<void> cacheLogin(String access, String refresh) async {
    await Future.wait<void>([
      _setLoggedIn(true),
      setAccessToken(access),
      _setRefreshToken(refresh)
    ]);
  }

  // User modifiers
  Future<void> updateUserEmail(String newEmail) =>
      _updateUser((user) => user..email = newEmail);

  Future<void> addTopicToUser(Topic topic) =>
      _updateUser((user) => user..topics.add(topic));

  Future<void> removeTopicFromUser(String topicName) =>
      _updateUser((user) => user
        ..topics.removeWhere(
          (topic) => topic.name == topicName,
        ));

  Future<void> bulkRemoveTopicsFromUser(List<Topic> topicList) =>
      _updateUser((user) {
        topicList.forEach(
          (topicElem) => user.topics.removeWhere(
            (topic) => topic.id == topicElem.id,
          ),
        );

        return user;
      });

  Future<void> addCollectionToUser(CompactCollection collection) =>
      _updateUser((user) => user..collections.add(collection));

  Future<void> addPostToUserCollection(
          int index, CompactCollection collection) =>
      _updateUser((user) => user..collections.add(collection));

  Future<void> updateUserCollection(
          int index, int postId, Collection newCollectionData) =>
      _updateUser(((user) {
        if (user.collections[index].length++ == 0) {
          user.collections[index].cover = newCollectionData.cover;
        }

        user.collections[index].posts.add(postId);

        return user;
      }));

  ///////////////////////////////////////////////////////
  // * Private Functions
  Future<void> _updateUser(UserChangeCallback onUserChange) async {
    User newUserData = User.from(currentUser);
    newUserData = onUserChange(newUserData);
    await _prefs.setString('user', jsonEncode(newUserData.toJson()));
    _addUser(newUserData);
  }

  ///////////////////////////////////////////////////////
  // * Getters and private/public setters
  bool get loggedIn => _prefs.getBool('loggedIn');
  Future<void> _setLoggedIn(bool value) async =>
      await _prefs.setBool('loggedIn', value);

  String get accessToken => _prefs.getString('accessToken');
  Future<void> setAccessToken(String value) async =>
      await _prefs.setString('accessToken', value);

  String get refreshToken => _prefs.getString('refreshToken');
  Future<void> _setRefreshToken(String value) async =>
      await _prefs.setString('refreshToken', value);

  ////////////////////////////

  Function(User) get _addUser => _userController.sink.add;
  Stream<User> get userStream => _userController.stream;
  User get currentUser => _userController.value ?? User.initial();

  Future<void> setUserFromMap(Map<String, dynamic> userMap) async {
    await _prefs.setString('user', jsonEncode(userMap));
    _addUser(User.fromJson(userMap));
  }
}
