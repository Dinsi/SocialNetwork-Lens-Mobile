import 'dart:io';

import 'package:aperture/ui/account_settings_screen.dart';
import 'package:aperture/ui/change_email_screen.dart';
import 'package:aperture/ui/change_password_screen.dart';
import 'package:aperture/ui/collection_list_screen.dart';
import 'package:aperture/ui/collection_post_grid_screen.dart';
import 'package:aperture/ui/detailed_post_screen.dart';
import 'package:aperture/ui/edit_profile_screen.dart';
import 'package:aperture/ui/feed_screen.dart';
import 'package:aperture/ui/login_screen.dart';
import 'package:aperture/ui/recommended_topics_screen.dart';
import 'package:aperture/ui/search_screen.dart';
import 'package:aperture/ui/settings_screen.dart';
import 'package:aperture/ui/topic_feed_screen.dart';
import 'package:aperture/ui/topic_list_screen.dart';
import 'package:aperture/ui/tournament_screen.dart';
import 'package:aperture/ui/upload_post_screen.dart';
import 'package:aperture/ui/user_info_screen.dart';
import 'package:aperture/ui/user_profile_screen.dart';
import 'package:aperture/view_models/shared/basic_post.dart';
import 'package:flutter/material.dart';

abstract class RouteName {
  static const String login = 'login';
  static const String userInfo = 'userInfo';
  static const String uploadPost = 'uploadPost';
  static const String recommendedTopics = 'recommendedTopics';
  static const String feed = 'feed';
  static const String topicFeed = 'topicFeed';
  static const String detailedPost = 'detailedPost';
  static const String editProfile = 'editProfile';
  static const String userProfile = 'userProfile';
  static const String search = 'search';
  static const String topicList = 'topicList';
  static const String settings = 'settings';
  static const String accountSettings = 'accountSettings';
  static const String changeEmail = 'changeEmail';
  static const String changePassword = 'changePassword';
  static const String collectionList = 'collectionList';
  static const String collectionPosts = 'collectionPosts';
  static const String tournament = 'tournament';
}

abstract class Router {
  static Route<dynamic> routes(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.login:
        return MaterialPageRoute<Null>(builder: (_) => LoginScreen());

      case RouteName.recommendedTopics:
        return MaterialPageRoute<Null>(
            builder: (_) => RecommendedTopicsScreen());

      case RouteName.userInfo:
        return MaterialPageRoute<Null>(builder: (_) => UserInfoScreen());

      case RouteName.uploadPost:
        return MaterialPageRoute<int>(
          builder: (_) => UploadPostScreen(file: settings.arguments as File),
        );

      case RouteName.feed:
        return MaterialPageRoute<Null>(builder: (_) => FeedScreen());

      case RouteName.detailedPost:
        return MaterialPageRoute<Null>(
          builder: (_) {
            return DetailedPostScreen(
              basicPostModel: settings.arguments as BasicPostModel,
            );
          },
        );

      case RouteName.topicFeed:
        return MaterialPageRoute<Null>(
          builder: (_) => TopicFeedScreen(topic: settings.arguments as String),
        );

      case RouteName.editProfile:
        return MaterialPageRoute<int>(builder: (_) => EditProfileScreen());

      case RouteName.userProfile:
        return MaterialPageRoute<Null>(
          builder: (_) => UserProfileScreen(userId: settings.arguments as int),
        );

      case RouteName.search:
        return MaterialPageRoute<Null>(builder: (_) => SearchScreen());

      case RouteName.topicList:
        return MaterialPageRoute<Null>(builder: (_) => TopicListScreen());

      case RouteName.settings:
        return MaterialPageRoute<Null>(builder: (_) => SettingsScreen());

      case RouteName.accountSettings:
        return MaterialPageRoute<Null>(builder: (_) => AccountSettingsScreen());

      case RouteName.changeEmail:
        return MaterialPageRoute<int>(builder: (_) => ChangeEmailScreen());

      case RouteName.changePassword:
        return MaterialPageRoute<int>(builder: (_) => ChangePasswordScreen());

      case RouteName.collectionList:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute<String>(
          builder: (_) => CollectionListScreen(
            isAddToCollection: args['isAddToCollection'],
            postId: args['postId'] ?? null,
          ),
        );

      case RouteName.collectionPosts:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute<Null>(
          builder: (_) => CollectionPostGridScreen(
            collectionId: args['collId'],
            collectionName: args['collName'],
          ),
        );

      case RouteName.tournament:
        return MaterialPageRoute<Null>(builder: (_) => TournamentScreen());

      default:
        throw FlutterError('Route "${settings.name}" does not exist');
    }
  }
}
