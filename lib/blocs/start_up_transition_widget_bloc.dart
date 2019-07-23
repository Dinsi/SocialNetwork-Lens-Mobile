import 'dart:async';

import 'package:aperture/locator.dart';
import 'package:aperture/models/users/user.dart';
import 'package:aperture/resources/repository.dart';

class StartUpTransitionBloc {
  final Repository _repository = locator<Repository>();
  StreamController<User> _streamController = StreamController<User>.broadcast();

  Future fetchUserInfo() async {
    User user = await _repository.fetchUserInfo();
    _streamController.sink.add(user);
  }

  void dispose() {
    _streamController.close();
  }

  Stream<User> get stream => _streamController.stream;
}
