import 'package:flutter/material.dart';

import '../../blocs/feed_bloc.dart';

class FeedBlocProvider extends InheritedWidget {
  FeedBlocProvider(this.bloc, {Key key, this.child})
      : super(key: key, child: child);

  final Widget child;
  final FeedBloc bloc;

  static FeedBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(FeedBlocProvider)
            as FeedBlocProvider)
        .bloc;
  }

  @override
  bool updateShouldNotify(FeedBlocProvider oldWidget) => false;
}
