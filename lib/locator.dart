import 'package:aperture/resources/app_info.dart';
import 'package:aperture/resources/collection_api_provider.dart';
import 'package:aperture/resources/comment_api_provider.dart';
import 'package:aperture/resources/post_api_provider.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/resources/token_api_provider.dart';
import 'package:aperture/resources/topic_api_provider.dart';
import 'package:aperture/resources/user_api_provider.dart';
import 'package:aperture/view_models/change_email.dart';
import 'package:aperture/view_models/change_password.dart';
import 'package:aperture/view_models/collection_list.dart';
import 'package:aperture/view_models/collection_post_grid.dart';
import 'package:aperture/view_models/detailed_post.dart';
import 'package:aperture/view_models/edit_profile.dart';
import 'package:aperture/view_models/login.dart';
import 'package:aperture/view_models/search.dart';
import 'package:aperture/view_models/shared/basic_post.dart';
import 'package:aperture/view_models/feed.dart';
import 'package:aperture/view_models/recommended_topics.dart';
import 'package:aperture/view_models/shared/subscription_app_bar.dart';
import 'package:aperture/view_models/topic_feed.dart';
import 'package:aperture/view_models/topic_list.dart';
import 'package:aperture/view_models/upload_post.dart';
import 'package:aperture/view_models/user_profile.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final locator = GetIt();

void setupLocator(SharedPreferences prefs) {
  locator.registerLazySingleton(() => AppInfo(prefs));

  locator.registerLazySingleton(() => CollectionApiProvider());
  locator.registerLazySingleton(() => CommentApiProvider());
  locator.registerLazySingleton(() => PostApiProvider());
  locator.registerLazySingleton(() => TokenApiProvider());
  locator.registerLazySingleton(() => TopicApiProvider());
  locator.registerLazySingleton(() => UserApiProvider());

  locator.registerLazySingleton(() => Repository());

  //TODO turn to LazySingleton for production
  locator.registerFactory(() => FeedModel());

  locator.registerFactory(() => LoginModel());
  locator.registerFactory(() => RecommendedTopicsModel());
  locator.registerFactory(() => BasicPostModel());
  locator.registerFactory(() => DetailedPostModel());
  locator.registerFactory(() => SubscriptionAppBarModel());
  locator.registerFactory(() => TopicFeedModel());
  locator.registerFactory(() => UserProfileModel());
  locator.registerFactory(() => EditProfileModel());
  locator.registerFactory(() => ChangeEmailModel());
  locator.registerFactory(() => ChangePasswordModel());
  locator.registerFactory(() => TopicListModel());
  locator.registerFactory(() => CollectionListModel());
  locator.registerFactory(() => CollectionPostGridModel());
  locator.registerFactory(() => SearchModel());
  locator.registerFactory(() => UploadPostModel());
}
