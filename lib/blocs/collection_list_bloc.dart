import 'package:aperture/blocs/append_to_collection_bloc.dart';
import 'package:aperture/models/collections/collection.dart';
import 'package:aperture/models/collections/compact_collection.dart';
import 'package:aperture/resources/globals.dart';

class CollectionListBloc extends AppendToCollectionBloc {
  List<CompactCollection> collections =
      List.from(Globals.getInstance().user.collections);

  @override
  Future<Collection> updateCollection(int index, int postId) async {
    Collection result = await super.updateCollection(index, postId);

    if (result != null) {
      if (collections[index].length++ == 0) {
        collections[index].cover = result.cover;
      }
      collections[index].posts.add(postId);
    }

    return result;
  }

  void addToCollections(CompactCollection newCollection) {
    collections.add(newCollection);
  }

  bool existsInCollection(int index, int postId) {
    return collections[index].posts.contains(postId);
  }
}
