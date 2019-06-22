import 'package:aperture/models/collections/collection.dart';
import 'package:aperture/models/users/user.dart';
import 'package:aperture/resources/globals.dart';
import 'package:aperture/resources/repository.dart';
import 'package:meta/meta.dart';

abstract class AppendToCollectionBloc {
  @protected
  final repository = Repository();

  @protected
  final globals = Globals.getInstance();

  @protected
  User user = Globals.getInstance().user;

  Future<Collection> updateCollection(int index, int postId) async {
    Collection result = await repository.appendPostToCollection(
        user.collections[index].id, postId);

    if (result != null) {
      if (user.collections[index].length++ == 0) {
        user.collections[index].cover = result.cover;
      }
      user.collections[index].posts.add(postId);
      await globals.setUserFromUser(user);
    }

    return result;
  }
}
