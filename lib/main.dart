import 'dart:async';

import 'package:aperture/locator.dart';
import 'package:aperture/models/users/user.dart';
import 'package:aperture/resources/app_info.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show DeviceOrientation, SystemChrome, SystemUiOverlayStyle;

Future<void> main() async {
  // * Setup
  // TODO remove for full view pictures
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      systemNavigationBarColor: Colors.grey[50],
      statusBarColor: Colors.grey[50],
      systemNavigationBarIconBrightness: Brightness.dark));

  setupLocator();

  // * Gets the initial route the app starts with
  String initialRoute = await _getInitialRoute();
  runApp(MyApp(initialRoute: initialRoute));
  //TODO insert splash screen
}

Future<String> _getInitialRoute() async {
  final Repository repository = locator<Repository>();
  final AppInfo appInfo = locator<AppInfo>();

  //
  await appInfo.init();

  bool validToken;
  if (appInfo.isLoggedIn()) {
    validToken = await repository.verifyToken();
  } else {
    validToken = false;
  }

  if (!validToken) {
    return RouteName.login;
  } else {
    User user = await repository.fetchUserInfo();
    if (!user.hasFinishedRegister) {
      return RouteName.recommendedTopics;
    } else {
      return RouteName.userInfo;
    }
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({@required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aperture',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "SourceSansPro",
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
      initialRoute: initialRoute,
      onGenerateRoute: Router.routes,
    );
  }
}
