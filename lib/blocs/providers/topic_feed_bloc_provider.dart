import 'package:flutter/material.dart';

import '../../blocs/topic_feed_bloc.dart';

class TopicFeedBlocProvider extends InheritedWidget {
  TopicFeedBlocProvider(
      {Key key, @required String topic, @required Widget child})
      : bloc = TopicFeedBloc(topic),
        super(key: key, child: child);

  final TopicFeedBloc bloc;

  static TopicFeedBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(TopicFeedBlocProvider)
            as TopicFeedBlocProvider).bloc;
  }

  @override
  bool updateShouldNotify(TopicFeedBlocProvider oldWidget) {
    return true;
  }
}
