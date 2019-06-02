import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show DeviceOrientation, SystemChrome, SystemUiOverlayStyle;

import 'blocs/change_email_bloc.dart';
import 'blocs/change_password_bloc.dart';
import 'blocs/edit_profile_bloc.dart';
import 'blocs/feed_bloc.dart';
import 'blocs/post_details_bloc.dart';
import 'blocs/providers/edit_profile_bloc_provider.dart';
import 'blocs/providers/feed_bloc_provider.dart';
import 'blocs/providers/post_details_bloc_provider.dart';
import 'blocs/providers/topic_feed_bloc_provider.dart';
import 'blocs/providers/start_up_transition_bloc_provider.dart';
import 'blocs/providers/user_profile_bloc_provider.dart';
import 'blocs/topic_feed_bloc.dart';
import 'models/post.dart';
import 'resources/globals.dart';
import 'ui/settings_screen.dart';
import 'ui/detailed_post_screen.dart';
import 'ui/account_settings_screen.dart';
import 'ui/change_email_screen.dart';
import 'ui/change_password_screen.dart';
import 'ui/edit_profile_screen.dart';
import 'ui/feed_screen.dart';
import 'ui/recommended_topics_screen.dart';
import 'ui/search_screen.dart';
import 'ui/transition_widgets/start_up_widget.dart';
import 'ui/login_screen.dart';
import 'ui/transition_widgets/start_up_transition_widget.dart';
import 'ui/topic_feed_screen.dart';
import 'ui/topic_list_screen.dart';
import 'ui/upload_post_screen.dart';
import 'ui/user_info_screen.dart';
import 'ui/user_profile_screen.dart';

Future<void> main() async {
  //TODO remove for full view pictures
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.blue,
    ),
  );

  await Globals.getInstance().init();
  //TODO insert splash screen so you can use verifyToken there and delete TransitionWidget
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aperture',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "SourceSansPro",
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        appBarTheme: AppBarTheme(
          color: Colors.white,
          textTheme: Theme.of(context).textTheme.merge(
                TextTheme(
                  title: TextStyle(color: Colors.black),
                ),
              ),
          iconTheme: Theme.of(context).iconTheme.merge(
                IconThemeData(
                  color: Colors.black,
                ),
              ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => StartUpWidget(),
        '/login': (context) => LoginScreen(),
        '/userInfo': (context) => UserInfoScreen(),
        '/uploadPost': (context) => UploadPostScreen(),
        '/recommendedTopics': (context) => RecommendedTopicsScreen(),
        '/feed': (context) {
          final bloc = FeedBloc();
          return FeedBlocProvider(
            bloc,
            child: FeedScreen(),
          );
        },
        '/topicFeed': (context) {
          final bloc = TopicFeedBloc(
              ModalRoute.of(context).settings.arguments as String);
          return TopicFeedBlocProvider(
            bloc,
            child: TopicFeedScreen(),
          );
        },
        '/transitionWidget': (context) {
          final bloc = StartUpTransitionBloc();
          return StartUpTransitionBlocProvider(
            bloc,
            child: StartUpTransitionWidget(),
          );
        },
        '/detailedPost': (context) {
          Map<String, dynamic> arguments =
              ModalRoute.of(context).settings.arguments as Map<String, dynamic>;

          final bloc = PostDetailsBloc(arguments['postId'] as int);

          return PostDetailsBlocProvider(
            bloc,
            child: DetailedPostScreen(
              post: arguments['post'] as Post,
              toComments: arguments['toComments'] as bool,
            ),
          );
        },
        '/editProfile': (context) {
          final bloc = EditProfileBloc();
          return EditProfileBlocProvider(
            bloc,
            child: EditProfileScreen(),
          );
        },
        '/userProfile': (context) {
          Map<String, dynamic> arguments =
              ModalRoute.of(context).settings.arguments as Map<String, dynamic>;

          final bloc = UserProfileBloc(
            arguments['id'] as int,
            arguments['username'] as String,
          );
          return UserProfileBlocProvider(
            bloc,
            child: UserProfileScreen(),
          );
        },
        '/search': (context) => SearchScreen(),
        '/topicList': (context) => TopicListScreen(),
        '/settings': (context) => SettingsScreen(),
        '/accountSettings': (context) => AccountSettingsScreen(),
        '/changeEmail': (context) {
          final bloc = ChangeEmailBloc();
          return ChangeEmailScreen(bloc: bloc);
        },
        '/changePassword': (context) {
          final bloc = ChangePasswordBloc();
          return ChangePasswordScreen(bloc: bloc);
        },
      },
    );
  }
}
