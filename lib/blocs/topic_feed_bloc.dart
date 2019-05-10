import 'dart:async' show StreamController;

import '../models/topic.dart';
import '../models/post.dart';
import 'base_feed_bloc.dart';
import 'enums/subscribe_button.dart';

class TopicFeedBloc extends BaseFeedBloc {
  TopicFeedBloc(this._topic);

  final String _topic;
  StreamController<SubscribeButton> _subscribeButtonFetcher =
      StreamController<SubscribeButton>.broadcast();

  @override
  Future<void> fetch() async {
    List<Post> fetchedList = await repository.fetchPostsByTopic(
        postsList.isNotEmpty ? postsList.last.id : null, _topic);
    postsList.addAll(fetchedList);

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

  @override
  void dispose() {
    super.dispose();
    _subscribeButtonFetcher.close();
  }

  void initSubscribeButton() {
    return userIsSubscribed()
        ? _subscribeButtonFetcher.sink.add(SubscribeButton.unsubscribe)
        : _subscribeButtonFetcher.sink.add(SubscribeButton.subscribe);
  }

  bool userIsSubscribed() {
    for (Topic topic in globals.user.topics) {
      if (topic.name == _topic) {
        return true;
      }
    }

    return false;
  }

  String get topic => _topic;
  Stream<SubscribeButton> get subscriptionButton =>
      _subscribeButtonFetcher.stream;
}
