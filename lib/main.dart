import 'dart:async';

import 'package:aperture/network/api.dart';
import 'package:aperture/utils/transition_widget.dart';
import 'package:flutter/material.dart';
import 'package:aperture/screens/login_screen.dart';
import 'package:flutter/services.dart' show SystemChrome, DeviceOrientation;
import 'package:aperture/globals.dart';

Future<void> main() async {
  //TODO remove for full view pictures
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final Globals globalVariables = Globals.getInstance();
  await globalVariables.init();

  if (globalVariables.isLoggedIn() && await Api.verifyToken()) {
    runApp(MyApp(isLoggedIn: true, globals: globalVariables));
    return;
  }

  globalVariables.clearCache();
  runApp(MyApp(isLoggedIn: false));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final Globals globals;

  const MyApp({@required this.isLoggedIn, this.globals});

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
      home: !isLoggedIn ? LoginScreen() : TransitionWidget(),
    );
  }
}
/*if (widget.isLoggedIn) {
      if (widget.globals.user.hasFinishedRegister) {
        _home = UserInfoScreen();
        
      } else {
        _home = RecommendedTopicsScreen();
      }
    } else {
      _home = LoginScreen();
    }*/
