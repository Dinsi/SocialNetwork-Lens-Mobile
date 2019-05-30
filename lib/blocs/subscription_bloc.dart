import 'dart:async';

import 'base_feed_bloc.dart';
import 'enums/subscribe_button.dart';
import '../models/topic.dart';
import '../models/post.dart';

abstract class SubscriptionBloc extends BaseFeedBloc {
  StreamController<SubscribeButton> _subscribeButtonFetcher =
      StreamController<SubscribeButton>.broadcast();

  final String _topic;

  SubscriptionBloc(this._topic);

  @override
  void dispose() {
    _subscribeButtonFetcher.close();
    super.dispose();
  }

  @override
  Future<void> fetch() async {
    List<Post> fetchedList = await repository.fetchPostsByTopic(
        postsList.isNotEmpty ? postsList.last.id : null, _topic);
    postsList.addAll(fetchedList);

    if (fetchedList.length != 20 || fetchedList.isEmpty) {
      existsNext = false;
    }

    if (!postsFetcher.isClosed) {
      postsFetcher.sink.add(postsList);
    }
  }

  Future<void> toggleSubscribe(String subscriptionIntent) async {
    subscriptionIntent == 'subscribe'
        ? _subscribeButtonFetcher.sink.add(SubscribeButton.subscribeInactive)
        : _subscribeButtonFetcher.sink.add(SubscribeButton.unsubscribeInactive);

    int result = await repository.toggleTopicSubscription(
        _topic, subscriptionIntent); //TODO assuming result is valid

    if (result == 0) {
      if (subscriptionIntent == 'subscribe') {
        Topic topicObj = await repository.fetchSingleTopic(_topic);

        await globals.addTopicToUser(topicObj);

        print(globals.user.topics);

        _subscribeButtonFetcher.sink.add(SubscribeButton.unsubscribe);
      } else {
        await globals.removeTopicFromUser(_topic);

        print(globals.user.topics);

        _subscribeButtonFetcher.sink.add(SubscribeButton.subscribe);
      }
    }
  }

  SubscribeButton initSubscribeButton() {
    if (_subscribeButtonFetcher.isClosed) {
      return null;
    }

    return userIsSubscribed()
        ? SubscribeButton.unsubscribe
        : SubscribeButton.subscribe;
  }

  bool userIsSubscribed() {
    for (Topic topic in globals.user.topics) {
      if (topic.name == _topic) {
        return true;
      }
    }

    return false;
  }

  Stream<SubscribeButton> get subscriptionButton =>
      _subscribeButtonFetcher.stream;
  String get topic => _topic;
}
