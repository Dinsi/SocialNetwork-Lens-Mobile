import 'dart:async';
import 'dart:collection';

import 'package:aperture/view_models/core/base_model.dart';
import 'package:aperture/view_models/core/enums/checkbox_state.dart';
import 'package:aperture/locator.dart';
import 'package:aperture/models/topic.dart';
import 'package:aperture/resources/app_info.dart';
import 'package:aperture/resources/repository.dart';
import 'package:flutter/material.dart' show Navigator, BuildContext;
import 'package:rxdart/rxdart.dart';

enum TopicListViewState { Idle, Updating }

class TopicListModel extends StateModel<TopicListViewState> {
  final Repository _repository = locator<Repository>();
  final AppInfo _appInfo = locator<AppInfo>();

  UnmodifiableListView<Topic> _initialTopics;
  final List<Topic> _changedTopics = List<Topic>();

  List<PublishSubject<CheckBoxState>> _checkBoxControllerList;

  /////////////////////////////////////////////////////////////

  TopicListModel() : super(TopicListViewState.Idle) {
    _initialTopics = UnmodifiableListView(
      _appInfo.currentUser.topics
        ..sort((Topic a, Topic b) => a.name.compareTo(b.name)),
    );

    _checkBoxControllerList = List<PublishSubject<CheckBoxState>>.generate(
      _initialTopics.length,
      (_) => PublishSubject<CheckBoxState>(),
    );
  }

  /////////////////////////////////////////////////////////////
  // * Dispose
  void dispose() {
    super.dispose();
    _checkBoxControllerList.forEach((controller) => controller.close());
  }

  /////////////////////////////////////////////////////////////
  // * Public functions
  Future<void> saveUserTopics(BuildContext context) async {
    if (_changedTopics.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    setState(TopicListViewState.Updating);

    for (int i = 0; i < _checkBoxControllerList.length; i++) {
      _checkBoxControllerList[i].sink.add(
          _changedTopics.contains(_initialTopics[i])
              ? CheckBoxState.UncheckedDisabled
              : CheckBoxState.CheckedDisabled);
    }

    int result = await _repository.bulkUpdateTopics(_changedTopics);

    if (result == 0) {
      await _appInfo.bulkRemoveTopicsFromUser(_changedTopics);
    }

    Navigator.of(context).pop();
  }

  void toggleTopic(bool newValue, int index) {
    // ignore: close_sinks
    final controller = _checkBoxControllerList[index];
    CheckBoxState newState;

    if (newValue == false) {
      _changedTopics.add(_initialTopics[index]);
      newState = CheckBoxState.Unchecked;
    } else {
      _changedTopics.remove(_initialTopics[index]);
      newState = CheckBoxState.Checked;
    }

    if (!controller.isClosed) {
      controller.sink.add(newState);
    }
  }

  /////////////////////////////////////////////////////////////
  // * Getters

  Stream<CheckBoxState> getStreamByIndex(int index) {
    return _checkBoxControllerList[index].stream;
  }

  UnmodifiableListView<Topic> get topics => _initialTopics;
}
