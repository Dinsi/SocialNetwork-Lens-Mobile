import 'dart:async';

import 'package:aperture/network/api.dart';
import 'package:aperture/screens/user_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:aperture/screens/login_screen.dart';
import 'package:flutter/services.dart'
    show SystemChrome, DeviceOrientation, SystemUiOverlayStyle;
import 'package:aperture/globals.dart';

Future<void> main() async {
  //TODO remove for full view pictures
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.blue,
    statusBarColor: Colors.pink,
  ));

  final Globals globalVariables = Globals.getInstance();
  await globalVariables.init();

  if (globalVariables.isLoggedIn() && await Api.verifyToken()) {
    runApp(MyApp(isLoggedIn: true));
    return;
  }

  runApp(MyApp(isLoggedIn: false));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({@required this.isLoggedIn});

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
      home: isLoggedIn ? UserInfoScreen() : LoginScreen(),
    );
  }
}
