import 'package:aperture/models/post.dart';
import 'package:aperture/ui/core/base_view.dart';
import 'package:aperture/ui/shared/basic_post.dart';
import 'package:aperture/ui/shared/loading_lists/scroll_loading_list_view.dart';
import 'package:aperture/ui/shared/app_bars/subscription_app_bar.dart';
import 'package:aperture/view_models/topic_feed.dart';
import 'package:flutter/material.dart';

class TopicFeedScreen extends StatelessWidget {
  final String topic;

  const TopicFeedScreen({this.topic});

  @override
  Widget build(BuildContext context) {
    return SimpleBaseView<TopicFeedModel>(
      onModelReady: (model) => model.init(topic),
      builder: (_, model, __) {
        return SafeArea(
          child: Scaffold(
            appBar: SubscriptionAppBar(
              topicOrUser: topic,
              title: Text("#$topic"),
            ),
            body: RefreshIndicator(
              onRefresh: model.onRefresh,
              child: NotificationListener<ScrollNotification>(
                onNotification: model.onNotification,
                child: ScrollLoadingListView(
                  model: model,
                  widgetAdapter: (ObjectKey key, Post post) => BasicPost(
                    key: key,
                    post: post,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
