import 'dart:async';

import 'package:aperture/locator.dart';
import 'package:aperture/models/users/user.dart';
import 'package:aperture/resources/app_info.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/utils/utils.dart';

class ChangeEmailBloc {
  final Repository _repository = locator<Repository>();
  final AppInfo _appInfo = locator<AppInfo>();

  bool _willPop = true;
  StreamController<bool> _saveButtonController = StreamController();
  StreamController<bool> _obscureTextController = StreamController();

  void dispose() {
    _obscureTextController.close();
    _saveButtonController.close();
  }

  void shiftObscureText(bool newValue) {
    _obscureTextController.sink.add(newValue);
  }

  Future<int> changeUserEmail(Map<String, String> fields) async {
    User user = _appInfo.currentUser;

    _willPop = false;
    _saveButtonController.sink.add(false);

    final Map<String, String> requestFields = fields;
    requestFields['email'] = requestFields['email'].trimRight();

    if (requestFields['email'].isEmpty || requestFields['password'].isEmpty) {
      _willPop = true;
      _saveButtonController.sink.add(true);
      return -1;
    }

    if (!isEmail(requestFields['email'])) {
      _willPop = true;
      _saveButtonController.sink.add(true);
      return -2;
    }

    if (requestFields['email'] == user.email) {
      _willPop = true;
      _saveButtonController.sink.add(true);
      return -3;
    }

    int result = await _repository.changeUserEmail(requestFields);
    if (result == 0) {
      user.email = requestFields['email'];
      await _appInfo.updateUser(user);
    }

    _willPop = true;
    _saveButtonController.sink.add(true);
    return result;
  }

  Stream<bool> get saveButton => _saveButtonController.stream;
  Stream<bool> get obscureText => _obscureTextController.stream;
  String get email => _appInfo.currentUser.email;
  bool get willPop => _willPop;
}
