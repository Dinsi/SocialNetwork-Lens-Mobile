import 'package:aperture/view_models/append_to_collection_bloc.dart';
import 'package:aperture/locator.dart';
import 'package:aperture/models/collections/collection.dart';
import 'package:aperture/models/collections/compact_collection.dart';
import 'package:aperture/resources/app_info.dart';

class CollectionListBloc extends AppendToCollectionBloc {
  List<CompactCollection> collections =
      List.from(locator<AppInfo>().currentUser.collections);

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
