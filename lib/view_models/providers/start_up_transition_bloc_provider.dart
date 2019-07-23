import 'package:flutter/material.dart';

import '../start_up_transition_widget_bloc.dart';
export '../start_up_transition_widget_bloc.dart';

class StartUpTransitionBlocProvider extends InheritedWidget {
  StartUpTransitionBlocProvider(this.bloc, {Key key, this.child})
      : super(key: key, child: child);

  final Widget child;
  final StartUpTransitionBloc bloc;

  static StartUpTransitionBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(StartUpTransitionBlocProvider)
            as StartUpTransitionBlocProvider)
        .bloc;
  }

  @override
  bool updateShouldNotify(StartUpTransitionBlocProvider oldWidget) => false;
}
