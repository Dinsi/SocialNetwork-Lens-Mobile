library aperture.globals;

import 'package:aperture/models/user.dart';


class Globals {
  static final Globals _singleton = new Globals._internal();

  String accessToken = '';
  String refreshToken = '';
  User user;

  factory Globals() {
    return _singleton;
  }

  Globals._internal();

  void cacheUser(Map<String, dynamic> body) {
    user = User.fromJson(body, false);
  }

  void cacheTokens(String access, String refresh) {
    accessToken = access;
    refreshToken = refresh;
  }

  void removeTokens() {
    accessToken = '';
    refreshToken = '';
  }

  void clearCache() {
    removeTokens();
    user = null;
  }
}
