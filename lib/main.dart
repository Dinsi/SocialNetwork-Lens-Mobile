import 'dart:async';

import 'package:aperture/network/api.dart';
import 'package:aperture/user_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:aperture/auth/ui/login_screen.dart';
import 'package:flutter/services.dart' show SystemChrome, DeviceOrientation;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aperture/globals.dart';

Future<void> main() async {
  //TODO remove for full view pictures
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  if (prefs.getBool('isLoggedIn') != null) {
    Globals()
        .cacheTokens(prefs.getString('access'), prefs.getString('refresh'));

    if (await Api.verifyToken()) {
      runApp(MyApp(isLoggedIn: true));
      return;
    }
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
