import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show DeviceOrientation, SystemChrome, SystemUiOverlayStyle;

import 'blocs/edit_profile_bloc.dart';
import 'blocs/feed_bloc.dart';
import 'blocs/post_details_bloc.dart';
import 'blocs/providers/edit_profile_bloc_provider.dart';
import 'blocs/providers/feed_bloc_provider.dart';
import 'blocs/providers/post_details_bloc_provider.dart';
import 'blocs/providers/topic_feed_bloc_provider.dart';
import 'blocs/providers/transition_widget_bloc_provider.dart';
import 'blocs/topic_feed_bloc.dart';
import 'models/post.dart';
import 'resources/globals.dart';
import 'ui/detailed_post_screen.dart';
import 'ui/edit_profile_screen.dart';
import 'ui/feed_screen.dart';
import 'ui/recommended_topics_screen.dart';
import 'ui/startup_widget.dart';
import 'ui/login_screen.dart';
import 'ui/sub_widgets/transition_widget.dart';
import 'ui/topic_feed_screen.dart';
import 'ui/upload_post_screen.dart';
import 'ui/user_info_screen.dart';

Future<void> main() async {
  //TODO remove for full view pictures
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.red, // Note RED here
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
          final bloc = TopicFeedBloc(ModalRoute.of(context).settings.arguments);
          return TopicFeedBlocProvider(
            bloc,
            child: TopicFeedScreen(),
          );
        },
        '/transitionWidget': (context) {
          final bloc = TransitionWidgetBloc();
          return TransitionWidgetBlocProvider(
            bloc,
            child: TransitionWidget(),
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
        '/editUser': (context) {
          final bloc = EditProfileBloc();
          return EditProfileBlocProvider(
            bloc,
            child: EditProfileScreen(),
          );
        },
      },
    );
  }
}
