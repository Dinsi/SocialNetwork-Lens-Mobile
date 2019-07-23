import 'dart:async';
import 'dart:io' show File;

import 'package:aperture/locator.dart';
import 'package:aperture/resources/repository.dart';

class UploadPostBloc {
  final Repository _repository = locator<Repository>();
  StreamController<String> _buttonController;
  StreamController<String> _imageController;

  Future<int> uploadPost(File image, String title, String description) async {
    return _repository.uploadPost(image, title, description);
  }

  void init() {
    _buttonController = StreamController.broadcast();
    _imageController = StreamController.broadcast();
  }

  void dispose() {
    _buttonController.close();
    _imageController.close();
  }

  void changeButton(String type) {
    if (_buttonController.isClosed) {
      _buttonController = StreamController.broadcast();
    }

    _buttonController.add(type);
  }

  void changeImage(String type) {
    if (_imageController.isClosed) {
      _imageController = StreamController.broadcast();
    }

    _imageController.add(type);
  }

  Stream<String> get buttonWidget => _buttonController.stream;
  Stream<String> get image => _imageController.stream;
}

final uploadPostBloc = UploadPostBloc();
