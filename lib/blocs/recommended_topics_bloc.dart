import 'dart:async';

import '../resources/globals.dart';
import '../models/topic.dart';
import '../resources/repository.dart';

class RecommendedTopicsBloc {
  final Globals _globals  = Globals.getInstance();
  final Repository _repository = Repository();

  Future<List<Topic>> recommendedTopics() async {
    return await _repository.recommendedTopics();
  }

  Future<int> finishRegister(List<int> topicIds) async {
    return await _repository.finishRegister(topicIds);
  }

  String get userUsername => _globals.user.username;
}

final recommendedTopicsBloc = RecommendedTopicsBloc();
