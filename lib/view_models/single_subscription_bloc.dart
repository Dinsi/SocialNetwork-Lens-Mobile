import 'dart:async';

import 'package:aperture/view_models/feed/base_feed_model.dart';
import 'package:aperture/view_models/enums/subscribe_button.dart';
import 'package:aperture/models/post.dart';
import 'package:aperture/models/topic.dart';

abstract class SingleSubscriptionBloc extends BaseFeedModel {
  StreamController<SubscribeButton> _subscribeButtonFetcher =
      StreamController<SubscribeButton>.broadcast();

  final String _topic;

  SingleSubscriptionBloc(this._topic);

  @override
  void dispose() {
    _subscribeButtonFetcher.close();
    super.dispose();
  }

  @override
  Future<void> fetch(bool refresh) async {
    List<Post> fetchedList;
    if (refresh || !postsFetcher.hasValue) {
      fetchedList = await repository.fetchPostsByTopic(null, _topic);
    } else {
      fetchedList = postsFetcher.value
        ..addAll(await repository.fetchPostsByTopic(
            postsFetcher.value.last.id, _topic));
    }

    if (fetchedList.length != 20 || fetchedList.isEmpty) {
      existsNext = false;
    }

    if (!postsFetcher.isClosed) {
      postsFetcher.sink.add(fetchedList);
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

        await appInfo.addTopicToUser(topicObj);

        print(appInfo.user.topics);

        _subscribeButtonFetcher.sink.add(SubscribeButton.unsubscribe);
      } else {
        await appInfo.removeTopicFromUser(_topic);

        print(appInfo.user.topics);

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
    for (Topic topic in appInfo.user.topics) {
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
