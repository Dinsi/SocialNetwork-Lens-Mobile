import 'dart:async';

import 'package:aperture/view_models/append_to_collection_bloc.dart';
import 'package:aperture/models/collections/collection.dart';
import 'package:aperture/models/collections/compact_collection.dart';

class NewCollectionBloc extends AppendToCollectionBloc {
  StreamController<bool> _saveController = StreamController();

  void dispose() {
    _saveController.close();
  }

  Future postNewCollection(String collectionName, int postId) async {
    if (collectionName.trim().isEmpty) {
      return -1;
    }

    _saveController.sink.add(false);

    Collection result =
        await repository.postNewCollection(collectionName.trim());
    if (result != null) {
      final newCollection = CompactCollection.fromJson(result.toJson());
      user.collections.add(newCollection);
      await appInfo.setUserFromUser(user);
      Collection result2 =
          await super.updateCollection(user.collections.length - 1, postId);
      return result2 != null ? newCollection : 2;
    }

    _saveController.sink.add(true);
    return 1;
  }

  Stream<bool> get saveButton => _saveController.stream;
}
