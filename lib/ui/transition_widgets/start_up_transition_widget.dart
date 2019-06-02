import 'package:flutter/material.dart';

import '../user_info_screen.dart';
import '../recommended_topics_screen.dart';
import '../../blocs/providers/start_up_transition_bloc_provider.dart';
import '../../models/user.dart';

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
