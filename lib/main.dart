import 'dart:async';

import 'package:aperture/locator.dart';
import 'package:aperture/models/users/user.dart';
import 'package:aperture/resources/app_info.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/router.dart';
import 'package:aperture/ui/utils/shortcuts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show DeviceOrientation, SystemChrome, SystemUiOverlayStyle;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// TODO Place animatedLists on feeds

Future<void> main() async {
  // * Setup
  // TODO change for full view pictures
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
        systemNavigationBarColor: Colors.grey[50],
        statusBarColor: Colors.grey[50],
        systemNavigationBarIconBrightness: Brightness.dark),
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  setupLocator(prefs);

  // * Gets the initial route the app starts with
  String initialRoute = await _getInitialRoute();
  runApp(MyApp(initialRoute: initialRoute));
  //TODO insert splash screen
}

Future<String> _getInitialRoute() async {
  final repository = locator<Repository>();
  final appInfo = locator<AppInfo>();

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

class MyApp extends StatefulWidget {
  final String initialRoute;

  const MyApp({@required this.initialRoute});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    locator<AppInfo>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>(
      initialData: User.initial(),
      builder: (_) => locator<AppInfo>().userStream,
      child: MaterialApp(
        title: 'Aperture',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          cursorColor: Colors.red,
          primarySwatch: Colors.red,
          primaryColor: Colors.white,
          textTheme: TextTheme(
            subhead: textFieldtextStyle,
          ),
          primaryTextTheme: TextTheme(
            title: TextStyle(
              color: Colors.black,
            ),
          ),
          appBarTheme: AppBarTheme(
            brightness: Brightness.light,
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
          ),
          brightness: Brightness.light,
          fontFamily: "SourceSansPro",
          iconTheme: IconThemeData(color: Colors.black),
          cardTheme: CardTheme(
            margin: const EdgeInsets.all(8.0),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            contentPadding: const EdgeInsets.all(12.0),
            labelStyle: textFieldtextStyle.copyWith(color: Colors.black45),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2.0),
            ),
          ),
          buttonTheme: ButtonThemeData(buttonColor: Colors.white),
        ),
        initialRoute: this.widget.initialRoute,
        onGenerateRoute: Router.routes,
      ),
    );
  }
}
