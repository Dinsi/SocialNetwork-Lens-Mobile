import 'package:flutter/foundation.dart';

abstract class BaseModel {
  void dispose() {}
}

abstract class StateModel<T> extends BaseModel with ChangeNotifier {
  StateModel(T initialState) : _state = initialState;

  T _state;

  T get state => _state;

  void setState(T state) {
    _state = state;
    notifyListeners();
  }
}
