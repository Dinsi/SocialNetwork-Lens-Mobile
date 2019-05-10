import 'package:flutter/material.dart';

import '../transition_widget_bloc.dart';
export '../transition_widget_bloc.dart';

class TransitionWidgetBlocProvider extends InheritedWidget {
  TransitionWidgetBlocProvider({Key key, @required Widget child})
      : super(key: key, child: child);

  final TransitionWidgetBloc bloc = TransitionWidgetBloc();

  static TransitionWidgetBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(TransitionWidgetBlocProvider)
            as TransitionWidgetBlocProvider)
        .bloc;
  }

  @override
  bool updateShouldNotify(TransitionWidgetBlocProvider oldWidget) {
    return false;
  }
}
