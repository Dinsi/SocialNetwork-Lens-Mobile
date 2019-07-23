import 'package:aperture/resources/app_info.dart';
import 'package:aperture/resources/collection_api_provider.dart';
import 'package:aperture/resources/comment_api_provider.dart';
import 'package:aperture/resources/post_api_provider.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/resources/token_api_provider.dart';
import 'package:aperture/resources/topic_api_provider.dart';
import 'package:aperture/resources/user_api_provider.dart';
import 'package:aperture/view_models/startup_model.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt();

void setupLocator() {
  locator.registerLazySingleton(() => AppInfo());

  locator.registerLazySingleton(() => CollectionApiProvider());
  locator.registerLazySingleton(() => CommentApiProvider());
  locator.registerLazySingleton(() => PostApiProvider());
  locator.registerLazySingleton(() => TokenApiProvider());
  locator.registerLazySingleton(() => TopicApiProvider());
  locator.registerLazySingleton(() => UserApiProvider());

  locator.registerLazySingleton(() => Repository());

  locator.registerFactory(() => StartUpModel());
}
