import 'package:aperture/view_models/feed_bloc.dart';
import 'package:flutter/material.dart';

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
