import 'package:aperture/locator.dart';
import 'package:aperture/models/users/user.dart';
import 'package:aperture/resources/app_info.dart';

class UserInfoScreenBloc {
  final AppInfo _appInfo = locator<AppInfo>();

  User get user => _appInfo.currentUser;

  void clearCache() {
    _appInfo.clearCache();
  }
}

final userInfoBloc = UserInfoScreenBloc();
