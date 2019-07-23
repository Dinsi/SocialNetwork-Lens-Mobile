import 'dart:async';

import 'package:aperture/locator.dart';
import 'package:aperture/resources/repository.dart';

class ChangePasswordBloc {
  final Repository _repository = locator<Repository>();

  StreamController<bool> _saveButtonController = StreamController();
  StreamController<bool> _oldPwdController = StreamController();
  StreamController<bool> _newPwdController = StreamController();
  StreamController<bool> _confirmedPwdController = StreamController();
  bool _willPop = true;

  void dispose() {
    _saveButtonController.close();
    _oldPwdController.close();
    _newPwdController.close();
    _confirmedPwdController.close();
  }

  void shiftObscureText(String type, bool newValue) {
    switch (type) {
      case 'old':
        _oldPwdController.sink.add(newValue);
        break;
      case 'new':
        _newPwdController.sink.add(newValue);
        break;
      case 'confirmed':
        _confirmedPwdController.sink.add(newValue);
    }
  }

  Future<int> changeUserPassword(Map<String, String> fields) async {
    _willPop = false;
    _saveButtonController.sink.add(false);

    if (fields['password'].isEmpty ||
        fields['new_password'].isEmpty ||
        fields['new_password_confirm'].isEmpty) {
      _willPop = true;
      _saveButtonController.sink.add(true);
      return -1;
    }

    if (fields['new_password'] != fields['new_password_confirm']) {
      _willPop = true;
      _saveButtonController.sink.add(true);
      return -2;
    }

    final Map<String, String> requestFields = fields
      ..remove('new_password_confirm');

    int result = await _repository.changeUserPassword(requestFields);
    if (result != 0) {
      _willPop = true;
      _saveButtonController.sink.add(true);
    }

    return result;
  }

  Stream<bool> get saveButton => _saveButtonController.stream;
  Stream<bool> get oldPwdObscureText => _oldPwdController.stream;
  Stream<bool> get newPwdObscureText => _newPwdController.stream;
  Stream<bool> get confirmedPwdObscureText => _confirmedPwdController.stream;
  bool get willPop => _willPop;
}
