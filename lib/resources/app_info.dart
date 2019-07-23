import 'dart:async' show Future;
import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:aperture/models/topic.dart';
import 'package:aperture/models/users/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppInfo {
  SharedPreferences prefs;

  Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

  bool isLoggedIn() {
    return loggedIn != null;
  }

  Future clearCache() async {
    await prefs.clear();
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
    final user = User.fromJson(jsonDecode(prefs.getString('user')));
    user.topics.add(topic);
    await setUserFromUser(user);
  }

  Future<void> removeTopicFromUser(String topicName) async {
    final user = User.fromJson(jsonDecode(prefs.getString('user')));
    user.topics.removeWhere((topic) => topic.name == topicName);
    await setUserFromUser(user);
  }

  Future<void> bulkRemoveTopicsFromUser(List<Topic> topicList) async {
    final user = User.fromJson(jsonDecode(prefs.getString('user')));
    for (Topic targetTopic in topicList) {
      user.topics.removeWhere((topic) => topic.id == targetTopic.id);
    }
    await setUserFromUser(user);
  }

  bool get loggedIn => prefs.getBool('loggedIn');
  Future setLoggedIn(bool value) async =>
      await prefs.setBool('loggedIn', value);

  String get accessToken => prefs.getString('accessToken');
  Future setAccessToken(String value) async =>
      await prefs.setString('accessToken', value);

  String get refreshToken => prefs.getString('refreshToken');
  Future setRefreshToken(String value) async =>
      await prefs.setString('refreshToken', value);

  User get user => prefs.getString('user') == null
      ? null
      : User.fromJson(jsonDecode(prefs.getString('user')));

  Future setUserFromMap(Map<String, dynamic> value) async =>
      await prefs.setString('user', jsonEncode(value));

  Future setUserFromUser(User value) async =>
      await prefs.setString('user', jsonEncode(value.toJson()));
}
