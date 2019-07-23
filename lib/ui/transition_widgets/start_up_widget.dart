import 'package:aperture/ui/login_screen.dart';
import 'package:aperture/ui/transition_widgets/start_up_transition_widget.dart';
import 'package:aperture/view_models/providers/start_up_transition_bloc_provider.dart';
import 'package:aperture/view_models/startup_bloc.dart';
import 'package:flutter/material.dart';

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
            final bloc = StartUpTransitionBloc();

            final transitionWidget = StartUpTransitionBlocProvider(
              bloc,
              child: StartUpTransitionWidget(),
            );

            return snapshot.data ? transitionWidget : LoginScreen();
          } else {
            return const Scaffold(
              body: const Center(
                child: const CircularProgressIndicator(),
              ),
            );
          }
        },
      );
    }

    return LoginScreen();
  }
}
