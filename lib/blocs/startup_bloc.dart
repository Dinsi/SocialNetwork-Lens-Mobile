import 'dart:async';

import 'package:aperture/locator.dart';
import 'package:aperture/resources/app_info.dart';
import 'package:aperture/resources/repository.dart';

class StartUpBloc {
  final Repository _repository = Repository();
 final AppInfo _appInfo = locator<AppInfo>();
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

  bool get isUserLoggedIn => _appInfo.isLoggedIn();
}

final startUpBloc = StartUpBloc();
