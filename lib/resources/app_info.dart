import 'dart:async' show Future;
import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:aperture/models/topic.dart';
import 'package:aperture/models/users/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppInfo {
  SharedPreferences _prefs;
  User _user;

  ///////////////////////////////////////////////////////
  // * Init
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _user = _prefs.getString('user') == null
        ? null
        : User.fromJson(jsonDecode(_prefs.getString('user')));
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
    _user.topics.add(topic);
    await updateUser();
  }

  Future<void> removeTopicFromUser(String topicName) async {
    _user.topics.removeWhere((topic) => topic.name == topicName);
    await updateUser();
  }

  Future<void> bulkRemoveTopicsFromUser(List<Topic> topicList) async {
    for (Topic targetTopic in topicList) {
      _user.topics.removeWhere((topic) => topic.id == targetTopic.id);
    }
    await updateUser();
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

  User get user => _user;

  Future<void> setUserFromMap(Map<String, dynamic> userMap) async {
    await _prefs.setString('user', jsonEncode(userMap));
    _user = User.fromJson(userMap);
  }

  Future<void> updateUser() async {
    await _prefs.setString('user', jsonEncode(_user.toJson()));
  }
}
