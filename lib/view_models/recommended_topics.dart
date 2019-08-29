import 'dart:async';

import 'package:aperture/locator.dart';
import 'package:aperture/models/topic.dart';
import 'package:aperture/resources/app_info.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/router.dart';
import 'package:aperture/view_models/core/base_model.dart';
import 'package:flutter/material.dart' show BuildContext, Navigator, debugPrint;

enum RecTopViewState { Loading, Idle, Busy }

class RecommendedTopicsModel extends StateModel<RecTopViewState> {
  RecommendedTopicsModel() : super(RecTopViewState.Loading);

  final AppInfo _appInfo = locator<AppInfo>();
  final Repository _repository = locator<Repository>();
  final Map<Topic, bool> _recommendedTopics = Map<Topic, bool>();

  Future<void> getRecommendedTopics() async {
    List<Topic> topics = await _repository.recommendedTopics();
    for (final topic in topics) {
      _recommendedTopics[topic] = false;
    }

    setState(RecTopViewState.Idle);
  }

  Future<void> sendTopics(BuildContext context) async {
    setState(RecTopViewState.Busy);

    List<int> selectedTopicIds = _recommendedTopics.keys
        .where((topic) => _recommendedTopics[topic])
        .map((topic) => topic.id)
        .toList();

    int code = await _repository.finishRegister(selectedTopicIds);
    if (code == 0) {
      Navigator.of(context).pushReplacementNamed(RouteName.userInfo);
      return;
    }

    setState(RecTopViewState.Idle);
  }

  void toggleTopic(Topic topic) {
    _recommendedTopics[topic] = !_recommendedTopics[topic];
    debugPrint(_recommendedTopics.toString());
    notifyListeners();
  }

  Map<Topic, bool> get recommendedTopics => _recommendedTopics;
  List<Topic> get topicList => _recommendedTopics.keys.toList();
  String get userUsername => _appInfo.currentUser.username;
  bool get emptyTopics => _recommendedTopics.isEmpty;
}
