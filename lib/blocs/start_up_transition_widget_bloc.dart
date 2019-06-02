import 'dart:async';

import '../models/user.dart';
import '../resources/repository.dart';

class StartUpTransitionBloc {
  final Repository _repository = Repository();
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
