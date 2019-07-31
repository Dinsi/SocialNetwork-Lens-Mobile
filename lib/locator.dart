import 'package:aperture/resources/app_info.dart';
import 'package:aperture/resources/collection_api_provider.dart';
import 'package:aperture/resources/comment_api_provider.dart';
import 'package:aperture/resources/post_api_provider.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/resources/token_api_provider.dart';
import 'package:aperture/resources/topic_api_provider.dart';
import 'package:aperture/resources/user_api_provider.dart';
import 'package:aperture/view_models/detailed_post.dart';
import 'package:aperture/view_models/shared/basic_post.dart';
import 'package:aperture/view_models/feed.dart';
import 'package:aperture/view_models/recommended_topics.dart';
import 'package:aperture/view_models/shared/subscription_app_bar.dart';
import 'package:aperture/view_models/topic_feed.dart';
import 'package:aperture/view_models/user_profile.dart';
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

  locator.registerFactory(() => RecommendedTopicsModel());
  locator.registerFactory(
      () => FeedModel()); //TODO turn to LazySingleton for production
  locator.registerFactory(() => BasicPostModel());
  locator.registerFactory(() => DetailedPostModel());
  locator.registerFactory(() => SubscriptionAppBarModel());
  locator.registerFactory(() => TopicFeedModel());
  locator.registerFactory(() => UserProfileModel());
}
