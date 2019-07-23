import 'package:aperture/view_models/change_email_bloc.dart';
import 'package:aperture/view_models/change_password_bloc.dart';
import 'package:aperture/view_models/collection_list_bloc.dart';
import 'package:aperture/view_models/collection_posts_bloc.dart';
import 'package:aperture/view_models/feed_bloc.dart';
import 'package:aperture/view_models/new_collection_bloc.dart';
import 'package:aperture/view_models/providers/edit_profile_bloc_provider.dart';
import 'package:aperture/view_models/providers/feed_bloc_provider.dart';
import 'package:aperture/view_models/providers/post_details_bloc_provider.dart';
import 'package:aperture/view_models/providers/topic_feed_bloc_provider.dart';
import 'package:aperture/view_models/providers/user_profile_bloc_provider.dart';
import 'package:aperture/models/collections/compact_collection.dart';
import 'package:aperture/models/post.dart';
import 'package:aperture/ui/account_settings_screen.dart';
import 'package:aperture/ui/change_email_screen.dart';
import 'package:aperture/ui/change_password_screen.dart';
import 'package:aperture/ui/collection_list_screen.dart';
import 'package:aperture/ui/collection_posts_screen.dart';
import 'package:aperture/ui/detailed_post_screen.dart';
import 'package:aperture/ui/edit_profile_screen.dart';
import 'package:aperture/ui/feed_screen.dart';
import 'package:aperture/ui/login_screen.dart';
import 'package:aperture/ui/new_collection_screen.dart';
import 'package:aperture/ui/recommended_topics_screen.dart';
import 'package:aperture/ui/search_screen.dart';
import 'package:aperture/ui/settings_screen.dart';
import 'package:aperture/ui/topic_feed_screen.dart';
import 'package:aperture/ui/topic_list_screen.dart';
import 'package:aperture/ui/startup_screen.dart';
import 'package:aperture/ui/upload_post_screen.dart';
import 'package:aperture/ui/user_info_screen.dart';
import 'package:aperture/ui/user_profile_screen.dart';
import 'package:aperture/view_models/topic_feed_bloc.dart';
import 'package:flutter/material.dart';

abstract class RouteNames {
  static const String home = '/';
  static const String login = '/login';
  static const String userInfo = '/userInfo';
  static const String uploadPost = '/uploadPost';
  static const String recommendedTopics = '/recommendedTopics';
  static const String feed = '/feed';
  static const String topicFeed = '/topicFeed';
  static const String detailedPost = '/detailedPost';
  static const String editProfile = '/editProfile';
  static const String userProfile = '/userProfile';
  static const String search = '/search';
  static const String topicList = '/topicList';
  static const String settings = '/settings';
  static const String accountSettings = '/accountSettings';
  static const String changeEmail = '/changeEmail';
  static const String changePassword = '/changePassword';
  static const String collectionList = '/collectionList';
  static const String newCollection = '/newCollection';
  static const String collectionPosts = '/collectionPosts';
}

abstract class Router {
  static Route<dynamic> routes(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.home:
        return MaterialPageRoute<Null>(
            builder: (context) => const StartUpWidget());

      case RouteNames.login:
        return MaterialPageRoute<Null>(builder: (context) => LoginScreen());

      case RouteNames.userInfo:
        return MaterialPageRoute<Null>(builder: (context) => UserInfoScreen());

      case RouteNames.uploadPost:
        return MaterialPageRoute<int>(
          builder: (context) => UploadPostScreen(),
        );

      case RouteNames.recommendedTopics:
        return MaterialPageRoute<Null>(
          builder: (context) => RecommendedTopicsScreen(),
        );

      case RouteNames.feed:
        final bloc = FeedBloc();
        return MaterialPageRoute<Null>(
          builder: (context) => FeedBlocProvider(
            bloc,
            child: FeedScreen(),
          ),
        );

      case RouteNames.topicFeed:
        final bloc = TopicFeedBloc(settings.arguments as String);
        return MaterialPageRoute<Null>(
          builder: (context) => TopicFeedBlocProvider(
            bloc,
            child: TopicFeedScreen(),
          ),
        );

      case RouteNames.detailedPost:
        Map<String, dynamic> arguments =
            settings.arguments as Map<String, dynamic>;

        final bloc = PostDetailsBloc(arguments['postId'] as int);
        return MaterialPageRoute<Map<String, dynamic>>(
          builder: (context) => PostDetailsBlocProvider(
            bloc,
            child: DetailedPostScreen(
              post: arguments['post'] as Post,
              toComments: arguments['toComments'] as bool,
            ),
          ),
        );

      case RouteNames.editProfile:
        final bloc = EditProfileBloc();
        return MaterialPageRoute<int>(
          builder: (context) => EditProfileBlocProvider(
            bloc,
            child: EditProfileScreen(),
          ),
        );

      case RouteNames.userProfile:
        Map<String, dynamic> arguments =
            settings.arguments as Map<String, dynamic>;

        final bloc = UserProfileBloc(
          arguments['id'] as int,
          arguments['username'] as String,
        );
        return MaterialPageRoute<Null>(
          builder: (context) => UserProfileBlocProvider(
            bloc,
            child: UserProfileScreen(),
          ),
        );

      case RouteNames.search:
        return MaterialPageRoute<Null>(builder: (context) => SearchScreen());

      case RouteNames.topicList:
        return MaterialPageRoute<Null>(builder: (context) => TopicListScreen());

      case RouteNames.settings:
        return MaterialPageRoute<Null>(builder: (context) => SettingsScreen());

      case RouteNames.accountSettings:
        return MaterialPageRoute<Null>(
          builder: (context) => AccountSettingsScreen(),
        );

      case RouteNames.changeEmail:
        final bloc = ChangeEmailBloc();
        return MaterialPageRoute<int>(
          builder: (context) => ChangeEmailScreen(bloc: bloc),
        );

      case RouteNames.changePassword:
        final bloc = ChangePasswordBloc();
        return MaterialPageRoute<int>(
          builder: (context) => ChangePasswordScreen(bloc: bloc),
        );

      case RouteNames.collectionList:
        final args = settings.arguments as Map<String, dynamic>;
        final bloc = CollectionListBloc();
        return MaterialPageRoute<String>(
          builder: (context) => CollectionListScreen(
            bloc: bloc,
            addToCollection: args['addToCollection'],
            postId: args['postId'] ?? null,
          ),
        );

      case RouteNames.newCollection:
        final args = settings.arguments as Map<String, dynamic>;
        final bloc = NewCollectionBloc();
        return MaterialPageRoute<CompactCollection>(
          builder: (context) => NewCollectionScreen(
            bloc: bloc,
            addToCollection: args['addToCollection'],
            postId: args['postId'] ?? null,
          ),
        );

      case RouteNames.collectionPosts:
        final args = settings.arguments as Map<String, dynamic>;
        final bloc = CollectionPostsBloc(args['collId']);
        return MaterialPageRoute<Null>(
          builder: (context) => CollectionPostsScreen(
            bloc: bloc,
            collName: args['collName'],
          ),
        );

      default:
        throw FlutterError('Route "${settings.name}" does not exist');
    }
  }
}
