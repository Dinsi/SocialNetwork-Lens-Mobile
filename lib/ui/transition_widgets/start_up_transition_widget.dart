import 'package:aperture/models/users/user.dart';
import 'package:aperture/ui/recommended_topics_screen.dart';
import 'package:aperture/ui/user_info_screen.dart';
import 'package:aperture/view_models/providers/start_up_transition_bloc_provider.dart';
import 'package:aperture/view_models/start_up_transition_widget_bloc.dart';
import 'package:flutter/material.dart';

class StartUpTransitionWidget extends StatefulWidget {
  const StartUpTransitionWidget({Key key}) : super(key: key);

  @override
  _StartUpTransitionWidgetState createState() => _StartUpTransitionWidgetState();
}

class _StartUpTransitionWidgetState extends State<StartUpTransitionWidget> {
  bool _isInit = true;
  StartUpTransitionBloc bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      bloc = StartUpTransitionBlocProvider.of(context);
      bloc.fetchUserInfo();
      _isInit = false;
    }
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream: bloc.stream,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.hasFinishedRegister) {
            return const UserInfoScreen();
          }

          return const RecommendedTopicsScreen();
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
}
