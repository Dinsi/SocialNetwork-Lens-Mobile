import 'package:aperture/locator.dart';
import 'package:aperture/models/collections/collection.dart';
import 'package:aperture/models/users/user.dart';
import 'package:aperture/resources/app_info.dart';
import 'package:aperture/resources/repository.dart';
import 'package:meta/meta.dart';

abstract class AppendToCollectionBloc {
  @protected
  final repository = locator<Repository>();

  @protected
  final AppInfo appInfo = locator<AppInfo>();

  Future<Collection> updateCollection(int index, int postId) async {
    User user = appInfo.user;

    Collection result = await repository.appendPostToCollection(
        user.collections[index].id, postId);

    if (result != null) {
      if (user.collections[index].length++ == 0) {
        user.collections[index].cover = result.cover;
      }
      user.collections[index].posts.add(postId);
      await appInfo.updateUser();
    }

    return result;
  }
}
