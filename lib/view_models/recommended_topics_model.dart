import 'dart:async';

import 'package:aperture/locator.dart';
import 'package:aperture/models/topic.dart';
import 'package:aperture/resources/app_info.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/view_models/base_model.dart';

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

  Future<bool> sendTopics() async {
    setState(RecTopViewState.Busy);

    List<int> selectedTopicIds = _recommendedTopics.keys
        .where((topic) => _recommendedTopics[topic])
        .map((topic) => topic.id)
        .toList();

    int code = await _repository.finishRegister(selectedTopicIds);
    if (code == 0) {
      return true;
    }

    setState(RecTopViewState.Idle);
    return false;
  }

  void toggleTopic(Topic topic) {
    _recommendedTopics[topic] = !_recommendedTopics[topic];
    notifyListeners();
  }

  Map<Topic, bool> get recommendedTopics => _recommendedTopics;
  List<Topic> get topicList => _recommendedTopics.keys.toList();
  String get userUsername => _appInfo.user.username;
  bool get emptyTopics => _recommendedTopics.isEmpty;
}
