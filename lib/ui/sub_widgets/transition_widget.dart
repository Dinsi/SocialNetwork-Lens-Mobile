import 'package:flutter/material.dart';

import '../user_info_screen.dart';
import '../recommended_topics_screen.dart';
import '../../models/user.dart';
import '../../blocs/transition_widget_bloc.dart';

class TransitionWidget extends StatefulWidget {
  const TransitionWidget({Key key}) : super(key: key);

  @override
  _TransitionWidgetState createState() => _TransitionWidgetState();
}

class _TransitionWidgetState extends State<TransitionWidget> {
  @override
  void initState() {
    super.initState();
    transitionWidgetBloc.fetchUserInfo();
  }

  @override
  void dispose() { 
    transitionWidgetBloc.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream: transitionWidgetBloc.stream,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.hasFinishedRegister) {
            return const UserInfoScreen();
          }

          return const RecommendedTopicsScreen();
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
