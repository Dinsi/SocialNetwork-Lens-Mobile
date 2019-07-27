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
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

  setupLocator();
  final AppInfo appInfo = locator<AppInfo>();
  await appInfo.init();

  // * Gets the initial route the app starts with
  String initialRoute = await _getInitialRoute(appInfo);
  runApp(MyApp(initialRoute: initialRoute));
  //TODO insert splash screen
}

Future<String> _getInitialRoute(AppInfo appInfo) async {
  final Repository repository = locator<Repository>();

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

  const MyApp({Key key, @required this.initialRoute}) : super(key: key);

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
      initialRoute: initialRoute,
      onGenerateRoute: Router.routes,
    );
  }
}
