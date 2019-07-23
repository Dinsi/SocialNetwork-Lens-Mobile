import 'dart:async';

import 'package:aperture/locator.dart';
import 'package:aperture/models/topic.dart';
import 'package:aperture/resources/app_info.dart';
import 'package:aperture/resources/repository.dart';

class RecommendedTopicsBloc {
  final AppInfo _appInfo = locator<AppInfo>();
  final Repository _repository = Repository();

  Future<List<Topic>> recommendedTopics() async {
    return await _repository.recommendedTopics();
  }

  Future<int> finishRegister(List<int> topicIds) async {
    return await _repository.finishRegister(topicIds);
  }

  String get userUsername => _appInfo.user.username;
}

final recommendedTopicsBloc = RecommendedTopicsBloc();
