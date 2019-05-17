import 'package:flutter/material.dart';

import '../transition_widget_bloc.dart';
export '../transition_widget_bloc.dart';

class TransitionWidgetBlocProvider extends InheritedWidget {
  TransitionWidgetBlocProvider(this.bloc, {Key key, this.child})
      : super(key: key, child: child);

  final Widget child;
  final TransitionWidgetBloc bloc;

  static TransitionWidgetBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(TransitionWidgetBlocProvider)
            as TransitionWidgetBlocProvider)
        .bloc;
  }

  @override
  bool updateShouldNotify(TransitionWidgetBlocProvider oldWidget) => false;
}
