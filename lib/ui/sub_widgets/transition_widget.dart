import 'package:flutter/material.dart';

import '../user_info_screen.dart';
import '../recommended_topics_screen.dart';
import '../../blocs/providers/transition_widget_bloc_provider.dart';
import '../../models/user.dart';

class TransitionWidget extends StatefulWidget {
  const TransitionWidget({Key key}) : super(key: key);

  @override
  _TransitionWidgetState createState() => _TransitionWidgetState();
}

class _TransitionWidgetState extends State<TransitionWidget> {
  bool _isInit = true;
  TransitionWidgetBloc bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      bloc = TransitionWidgetBlocProvider.of(context);
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
