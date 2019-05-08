import '../models/user.dart';
import '../resources/globals.dart';

class UserInfoScreenBloc {
  final Globals _globals = Globals.getInstance();

  User get user => _globals.user;

  void clearCache() {
    _globals.clearCache();
  }
}

final userInfoBloc = UserInfoScreenBloc();
