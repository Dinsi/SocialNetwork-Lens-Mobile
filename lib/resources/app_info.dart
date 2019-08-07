import 'dart:async' show Future;
import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:aperture/models/topic.dart';
import 'package:aperture/models/users/user.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppInfo {
  final SharedPreferences _prefs;
  BehaviorSubject<User> _userController = BehaviorSubject();

  AppInfo(this._prefs) {
    String userJson = _prefs.getString('user');

    if (userJson != null) {
      User user = User.fromJson(jsonDecode(userJson));
      addUser(user);
    }
  }

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

  Future<void> addTopicToUser(Topic topic) async {
    User newUser = User.from(currentUser);
    newUser.topics.add(topic);
    await updateUser(newUser);
  }

  Future<void> removeTopicFromUser(String topicName) async {
    User newUser = User.from(currentUser);
    newUser.topics.removeWhere((topic) => topic.name == topicName);
    await updateUser(newUser);
  }

  Future<void> bulkRemoveTopicsFromUser(List<Topic> topicList) async {
    User newUser = User.from(currentUser);
    topicList.forEach(
      (topicElem) => newUser.topics.removeWhere(
        (topic) => topic.id == topicElem.id,
      ),
    );

    await updateUser(newUser);
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

  Function(User) get addUser => _userController.sink.add;
  Stream<User> get userStream => _userController.stream;
  User get currentUser => _userController.value ?? User.initial();

  Future<void> setUserFromMap(Map<String, dynamic> userMap) async {
    await _prefs.setString('user', jsonEncode(userMap));
    addUser(User.fromJson(userMap));
  }

  Future<void> updateUser(User newUserData) async {
    await _prefs.setString('user', jsonEncode(newUserData.toJson()));
    addUser(newUserData);
  }
}
