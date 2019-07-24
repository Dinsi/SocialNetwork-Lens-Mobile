import 'package:flutter/foundation.dart';

enum ViewState { Idle, Busy }

abstract class BaseModel {
  void dispose() {}
}

abstract class StateModel extends BaseModel with ChangeNotifier {
  ViewState _state = ViewState.Idle;

  ViewState get state => _state;

  void setState(ViewState state) {
    _state = state;
    notifyListeners();
  }
}
