import 'package:aperture/locator.dart';
import 'package:aperture/models/users/user.dart';
import 'package:aperture/resources/app_info.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/router.dart' show RouteNames;
import 'package:aperture/view_models/base_model.dart';

class StartUpModel extends BaseModel {
  final Repository _repository = locator<Repository>();
  final AppInfo _appInfo = locator<AppInfo>();

  Future<String> getStartRoute() async {
    bool validToken;
    if (_appInfo.isLoggedIn()) {
      validToken = await _repository.verifyToken();
    } else {
      validToken = false;
    }

    if (!validToken) {
      return RouteNames.login;
    }

    User user = await _repository.fetchUserInfo();
    if (!user.hasFinishedRegister) {
      return RouteNames.recommendedTopics;
    }

    return RouteNames.userInfo;
  }
}
