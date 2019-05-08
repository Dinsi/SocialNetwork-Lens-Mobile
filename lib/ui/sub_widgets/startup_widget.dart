import 'package:flutter/material.dart';

import '../../blocs/startup_bloc.dart';
import '../login_screen.dart';
import '../sub_widgets/transition_widget.dart';

class StartUpWidget extends StatefulWidget {
  @override
  _StartUpWidgetState createState() => _StartUpWidgetState();
}

class _StartUpWidgetState extends State<StartUpWidget> {
  @override
  void initState() {
    super.initState();
    startUpBloc.verifyToken();
  }

  @override
  void dispose() {
    startUpBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (startUpBloc.isUserLoggedIn) {
      return StreamBuilder<bool>(
        stream: startUpBloc.tokenStream,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            return snapshot.data ? TransitionWidget() : LoginScreen();
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

    return LoginScreen();
  }
}
