import 'dart:async';
import 'dart:io' show File;

import '../resources/repository.dart';

class UploadPostBloc {
  final Repository _repository = Repository();

  Future<int> uploadPost(
      File image, String title, String description) async {
    return await _repository.uploadPost(image, title, description);
  }
}

final uploadPostBloc = UploadPostBloc();
