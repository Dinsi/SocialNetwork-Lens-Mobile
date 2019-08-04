import 'package:aperture/locator.dart';
import 'package:aperture/models/topic.dart';
import 'package:aperture/resources/app_info.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/view_models/core/base_model.dart';

enum SubscriptionAppBarViewState {
  Inactive,
  Subscribe,
  Unsubscribe,
  DisabledSubscribe,
  DisabledUnsubscribe
}

enum SubscriptionAction { Subscribe, Unsubscribe }

class SubscriptionAppBarModel extends StateModel<SubscriptionAppBarViewState> {
  final AppInfo _appInfo = locator<AppInfo>();
  final Repository _repository = locator<Repository>();

  String _topicOrUser;

  SubscriptionAppBarModel() : super(SubscriptionAppBarViewState.Inactive);

  void init(String topicOrUser) {
    _topicOrUser = topicOrUser;
    setState(_getSubscriptionState());
  }

  Future<void> toggleSubscribe() async {
    bool wantsSubscription = state == SubscriptionAppBarViewState.Subscribe;

    wantsSubscription
        ? setState(SubscriptionAppBarViewState.DisabledSubscribe)
        : setState(SubscriptionAppBarViewState.DisabledUnsubscribe);

    int result = await _repository.toggleTopicSubscription(
      _topicOrUser,
      wantsSubscription
          ? SubscriptionAction.Subscribe
          : SubscriptionAction.Unsubscribe,
    ); //TODO assuming result is valid

    if (result == 0) {
      if (wantsSubscription) {
        Topic topicObj = await _repository.fetchSingleTopic(_topicOrUser);

        await _appInfo.addTopicToUser(topicObj);

        setState(SubscriptionAppBarViewState.Unsubscribe);
      } else {
        await _appInfo.removeTopicFromUser(_topicOrUser);

        setState(SubscriptionAppBarViewState.Subscribe);
      }
    }
  }

  SubscriptionAppBarViewState _getSubscriptionState() {
    for (Topic topic in _appInfo.currentUser.topics) {
      if (topic.name == _topicOrUser) {
        return SubscriptionAppBarViewState.Unsubscribe;
      }
    }

    return SubscriptionAppBarViewState.Subscribe;
  }

  String get topicOrUser => _topicOrUser;
}
