import 'dart:async';

import 'package:aperture/view_models/feed/base_feed_model.dart';
import 'package:aperture/models/post.dart';

class FeedModel extends BaseFeedModel {
  @override
  Future<void> fetch(bool refresh) async {
    List<Post> fetchedList;
    if (refresh || !postsFetcher.hasValue) {
      fetchedList = await repository.fetchPosts(null);
    } else {
      fetchedList = postsFetcher.value
        ..addAll(await repository.fetchPosts(postsFetcher.value.last.id));
    }

    if (fetchedList.length != 20 || fetchedList.isEmpty) {
      existsNext = false;
    }

    if (!postsFetcher.isClosed) {
      postsFetcher.sink.add(fetchedList);
    }
  }

  bool get userIsConfirmed => appInfo.user.isConfirmed;
}
