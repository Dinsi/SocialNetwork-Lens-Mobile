import 'package:aperture/models/post.dart';
import 'package:aperture/ui/core/base_view.dart';
import 'package:aperture/ui/shared/basic_post.dart';
import 'package:aperture/ui/shared/loading_lists/scroll_loading_list_view.dart';
import 'package:aperture/view_models/feed.dart';
import 'package:flutter/material.dart';

class FeedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SimpleBaseView<FeedModel>(
          builder: (_, model, __) {
            return model.userIsConfirmed
                ? _getPostWidgets(model)
                : Column(
                    children: <Widget>[
                      Container(
                        height: 50.0,
                        color: Colors.blue,
                        child: Center(
                          child: Text(
                            "Please confirm your email address",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _getPostWidgets(model),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _getPostWidgets(FeedModel model) {
    return RefreshIndicator(
      onRefresh: model.onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: model.onNotification,
        child: ScrollLoadingListView<Post>(
          model: model,
          widgetAdapter: (ObjectKey key, Post post) => BasicPost(
            key: key,
            post: post,
          ),
        ),
      ),
    );
  }
}
