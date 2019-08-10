import 'package:aperture/locator.dart';
import 'package:aperture/models/collections/collection.dart';
import 'package:aperture/models/users/user.dart';
import 'package:aperture/resources/app_info.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/view_models/core/base_model.dart';
import 'package:meta/meta.dart';

abstract class AppendToCollectionModel extends BaseModel {
  @protected
  final repository = locator<Repository>();

  @protected
  final AppInfo appInfo = locator<AppInfo>();

  @protected
  int protPostId;

  Future<Collection> updateCollection(int index) async {
    User user = appInfo.currentUser;

    Collection result = await repository.appendPostToCollection(
        user.collections[index].id, protPostId);

    if (result != null) {
      if (user.collections[index].length++ == 0) {
        user.collections[index].cover = result.cover;
      }
      user.collections[index].posts.add(protPostId);
      await appInfo.updateUser(user);
    }

    return result;
  }
}
