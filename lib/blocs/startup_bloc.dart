import 'dart:async';

import '../resources/globals.dart';
import '../resources/repository.dart';

class StartUpBloc {
  final Repository _repository = Repository();
  final Globals _globals = Globals.getInstance();
  StreamController<bool> _streamController = StreamController<bool>();

  void verifyToken() async {
    if (isUserLoggedIn) {
      bool result = await _repository.verifyToken();
      _streamController.sink.add(result);
    }
  }

  Stream<bool> get tokenStream => _streamController.stream;

  void dispose() {
    _streamController.close();
  }

  bool get isUserLoggedIn => _globals.isLoggedIn();
}

final startUpBloc = StartUpBloc();
