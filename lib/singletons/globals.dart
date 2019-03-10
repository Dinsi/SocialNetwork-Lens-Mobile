class Globals {
  static final Globals _singleton = new Globals._internal();
  String accessToken = '';
  String refreshToken = '';

  factory Globals() {
    return _singleton;
  }

  Globals._internal();
}
