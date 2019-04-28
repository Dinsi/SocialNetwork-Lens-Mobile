import 'package:aperture/network/api.dart';
import 'package:aperture/screens/recommended_topics_screen.dart';
import 'package:aperture/screens/user_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:aperture/globals.dart';

class TransitionWidget extends StatelessWidget {
  const TransitionWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Globals globals = Globals.getInstance();
    return FutureBuilder(
      future: () {
        if (globals.user != null) {
          return Future<int>.value(0);
        }

        return Api.userInfo();
      }(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (globals.user.hasFinishedRegister) {
            return UserInfoScreen();
          }

          return RecommendedTopicsScreen();
        } else {
          return const Scaffold(
            body: const SafeArea(
              child: const Center(
                child: const CircularProgressIndicator(),
              ),
            ),
          );
        }
      },
    );
  }
}
