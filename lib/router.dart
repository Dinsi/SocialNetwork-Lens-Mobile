import 'package:aperture/blocs/change_email_bloc.dart';
import 'package:aperture/view_models/change_password_bloc.dart';
import 'package:aperture/view_models/collection_list_bloc.dart';
import 'package:aperture/view_models/collection_posts_bloc.dart';
import 'package:aperture/view_models/feed_bloc.dart';
import 'package:aperture/view_models/new_collection_bloc.dart';
import 'package:aperture/view_models/providers/edit_profile_bloc_provider.dart';
import 'package:aperture/view_models/providers/feed_bloc_provider.dart';
import 'package:aperture/view_models/providers/post_details_bloc_provider.dart';
import 'package:aperture/view_models/providers/start_up_transition_bloc_provider.dart';
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
import 'package:aperture/ui/transition_widgets/start_up_transition_widget.dart';
import 'package:aperture/ui/transition_widgets/start_up_widget.dart';
import 'package:aperture/ui/upload_post_screen.dart';
import 'package:aperture/ui/user_info_screen.dart';
import 'package:aperture/ui/user_profile_screen.dart';
import 'package:aperture/view_models/topic_feed_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Router {
  static Route<dynamic> routes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute<Null>(builder: (context) => StartUpWidget());

      case '/login':
        return MaterialPageRoute<Null>(builder: (context) => LoginScreen());

      case '/userInfo':
        return MaterialPageRoute<Null>(builder: (context) => UserInfoScreen());

      case '/uploadPost':
        return MaterialPageRoute<int>(
          builder: (context) => UploadPostScreen(),
        );

      case '/recommendedTopics':
        return MaterialPageRoute<Null>(
          builder: (context) => RecommendedTopicsScreen(),
        );

      case '/feed':
        final bloc = FeedBloc();
        return MaterialPageRoute<Null>(
          builder: (context) => FeedBlocProvider(
                bloc,
                child: FeedScreen(),
              ),
        );

      case '/topicFeed':
        final bloc = TopicFeedBloc(settings.arguments as String);
        return MaterialPageRoute<Null>(
          builder: (context) => TopicFeedBlocProvider(
                bloc,
                child: TopicFeedScreen(),
              ),
        );

      case '/transitionWidget':
        final bloc = StartUpTransitionBloc();
        return MaterialPageRoute<Null>(
          builder: (context) => StartUpTransitionBlocProvider(
                bloc,
                child: StartUpTransitionWidget(),
              ),
        );

      case '/detailedPost':
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

      case '/editProfile':
        final bloc = EditProfileBloc();
        return MaterialPageRoute<int>(
          builder: (context) => EditProfileBlocProvider(
                bloc,
                child: EditProfileScreen(),
              ),
        );

      case '/userProfile':
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

      case '/search':
        return MaterialPageRoute<Null>(builder: (context) => SearchScreen());

      case '/topicList':
        return MaterialPageRoute<Null>(builder: (context) => TopicListScreen());

      case '/settings':
        return MaterialPageRoute<Null>(builder: (context) => SettingsScreen());

      case '/accountSettings':
        return MaterialPageRoute<Null>(
          builder: (context) => AccountSettingsScreen(),
        );

      case '/changeEmail':
        final bloc = ChangeEmailBloc();
        return MaterialPageRoute<int>(
          builder: (context) => ChangeEmailScreen(bloc: bloc),
        );

      case '/changePassword':
        final bloc = ChangePasswordBloc();
        return MaterialPageRoute<int>(
          builder: (context) => ChangePasswordScreen(bloc: bloc),
        );

      case '/collectionList':
        final args = settings.arguments as Map<String, dynamic>;
        final bloc = CollectionListBloc();
        return MaterialPageRoute<String>(
          builder: (context) => CollectionListScreen(
                bloc: bloc,
                addToCollection: args['addToCollection'],
                postId: args['postId'] ?? null,
              ),
        );

      case '/newCollection':
        final args = settings.arguments as Map<String, dynamic>;
        final bloc = NewCollectionBloc();
        return MaterialPageRoute<CompactCollection>(
          builder: (context) => NewCollectionScreen(
                bloc: bloc,
                addToCollection: args['addToCollection'],
                postId: args['postId'] ?? null,
              ),
        );

      case '/collectionPosts':
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
