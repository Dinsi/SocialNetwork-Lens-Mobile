import 'dart:async' show Future;
import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:aperture/models/topic.dart';
import 'package:aperture/models/users/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppInfo {
  SharedPreferences _prefs;
  User _user;

  Future init() async {
    _prefs = await SharedPreferences.getInstance();
    _user = _prefs.getString('user') == null
        ? null
        : User.fromJson(jsonDecode(_prefs.getString('user')));
  }

  bool isLoggedIn() {
    return _prefs.getBool('loggedIn') != null;
  }

  Future clearCache() async {
    await _prefs.clear();
  }

  Future cacheLogin(String access, String refresh) async {
    final Future loggedInResult = setLoggedIn(true);
    final Future accessResult = setAccessToken(access);
    final Future refreshResult = setRefreshToken(refresh);
    await loggedInResult;
    await accessResult;
    await refreshResult;
  }

  Future<void> addTopicToUser(Topic topic) async {
    _user.topics.add(topic);
    await setUserFromUser(_user);
  }

  Future<void> removeTopicFromUser(String topicName) async {
    _user.topics.removeWhere((topic) => topic.name == topicName);
    await setUserFromUser(_user);
  }

  Future<void> bulkRemoveTopicsFromUser(List<Topic> topicList) async {
    for (Topic targetTopic in topicList) {
      _user.topics.removeWhere((topic) => topic.id == targetTopic.id);
    }
    await setUserFromUser(_user);
  }

  bool get loggedIn => _prefs.getBool('loggedIn');
  Future setLoggedIn(bool value) async =>
      await _prefs.setBool('loggedIn', value);

  String get accessToken => _prefs.getString('accessToken');
  Future setAccessToken(String value) async =>
      await _prefs.setString('accessToken', value);

  String get refreshToken => _prefs.getString('refreshToken');
  Future setRefreshToken(String value) async =>
      await _prefs.setString('refreshToken', value);

  User get user => _user;

  Future setUserFromMap(Map<String, dynamic> userMap) async {
    await _prefs.setString('user', jsonEncode(userMap));
    _user = User.fromJson(userMap);
  }

  Future setUserFromUser(User newUserData) async {
    await _prefs.setString('user', jsonEncode(newUserData.toJson()));
    _user = newUserData;
  }
}
