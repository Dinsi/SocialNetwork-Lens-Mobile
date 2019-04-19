library aperture.globals;

import 'dart:async' show Future;
import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:aperture/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Globals {
  static Globals _singleton;
  SharedPreferences prefs;

  Globals._internal();

  factory Globals.getInstance() {
    if (_singleton == null) {
      _singleton = new Globals._internal();
    }
    return _singleton;
  }

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

  bool get loggedIn => prefs.getBool('loggedIn');
  Future setLoggedIn(bool value) async => await prefs.setBool('loggedIn', value);

  String get accessToken => prefs.getString('accessToken');
  Future setAccessToken(String value) async => await prefs.setString('accessToken', value);

  String get refreshToken => prefs.getString('refreshToken');
  Future setRefreshToken(String value) async => await prefs.setString('refreshToken', value);

  User get user => prefs.getString('user') == null ? null : User.fromJson(jsonDecode(prefs.getString('user')));
  Future setUser(Map<String, dynamic> value) async => await prefs.setString('user', jsonEncode(value));
}
