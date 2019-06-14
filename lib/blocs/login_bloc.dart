import 'dart:async';

import '../models/users/user.dart';
import '../resources/repository.dart';

class LoginBloc {
  final Repository _repository = Repository();

  Future<int> login(String username, String password) async {
    return await _repository.login(username, password);
  }

  Future<int> register(Map<String, String> fields) async {
    return await _repository.register(fields);
  }

  Future<User> fetchUserInfo() async {
    return await _repository.fetchUserInfo();
  }
}

final loginBloc = LoginBloc();
