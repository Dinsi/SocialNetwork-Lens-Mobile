import 'dart:async';

import '../models/topic.dart';
import '../resources/repository.dart';
import '../resources/globals.dart';
import 'enums/checkbox_state.dart';

class TopicListBloc {
  final Repository _repository;
  final Globals _globals;

  final List<Topic> _initialTopics;
  List<Topic> _changedTopics;

  List<StreamController<CheckBoxState>> _subscribeButtonControllerList;
  final StreamController<bool> _saveButtonController;

  bool willPop = true;

  TopicListBloc()
      : _repository = Repository(),
        _globals = Globals.getInstance(),
        _initialTopics = Globals.getInstance().user.topics
          ..sort(
            (Topic a, Topic b) => a.name.compareTo(b.name),
          ),
        _changedTopics = List<Topic>(),
        _saveButtonController = StreamController<bool>() {
    _subscribeButtonControllerList =
        List<StreamController<CheckBoxState>>(_initialTopics.length);

    for (var i = 0; i < _subscribeButtonControllerList.length; i++) {
      _subscribeButtonControllerList[i] = StreamController<CheckBoxState>();
    }
  }

  void dispose() {
    for (StreamController<CheckBoxState> controller
        in _subscribeButtonControllerList) {
      controller.close();
    }
    _saveButtonController.close();
  }

  Future<void> saveUserTopics() async {
    if (_changedTopics.isEmpty) {
      return;
    }

    willPop = false;
    _saveButtonController.sink.add(false);
    for (var i = 0; i < _subscribeButtonControllerList.length; i++) {
      _subscribeButtonControllerList[i].sink.add(
          _changedTopics.contains(_initialTopics[i])
              ? CheckBoxState.UncheckedDisabled
              : CheckBoxState.CheckedDisabled);
    }

    int result = await _repository.bulkUpdateTopics(_changedTopics);

    if (result == 0) {
      await _globals.bulkRemoveTopicsFromUser(_changedTopics);
    }
  }

  void shiftTopic(bool newValue, int index) {
    if (newValue == false) {
      _changedTopics.add(_initialTopics[index]);
      if (!_subscribeButtonControllerList[index].isClosed) {
        _subscribeButtonControllerList[index].sink.add(CheckBoxState.Unchecked);
      }
    } else {
      _changedTopics.remove(_initialTopics[index]);
      if (!_subscribeButtonControllerList[index].isClosed) {
        _subscribeButtonControllerList[index].sink.add(CheckBoxState.Checked);
      }
    }
  }

  Stream<CheckBoxState> getStream(int index) {
    return _subscribeButtonControllerList[index].stream;
  }

  Stream<bool> get saveButton => _saveButtonController.stream;
  List<Topic> get topics => _initialTopics;
}
