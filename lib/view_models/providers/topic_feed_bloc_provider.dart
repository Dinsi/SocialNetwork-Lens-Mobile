import 'package:aperture/view_models/topic_feed_bloc.dart';
import 'package:flutter/material.dart';

class TopicFeedBlocProvider extends InheritedWidget {
  TopicFeedBlocProvider(this.bloc,
      {Key key, this.child})
      : super(key: key, child: child);

  final Widget child;
  final TopicFeedBloc bloc;

  static TopicFeedBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(TopicFeedBlocProvider)
            as TopicFeedBlocProvider)
        .bloc;
  }

  @override
  bool updateShouldNotify(TopicFeedBlocProvider oldWidget) => false;
}
