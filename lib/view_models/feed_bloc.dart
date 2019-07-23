import 'dart:async';

import 'package:aperture/view_models/base_feed_bloc.dart';
import 'package:aperture/models/post.dart';

class FeedBloc extends BaseFeedBloc {
  @override
  Future<void> fetch() async {
    List<Post> fetchedList = await repository
        .fetchPosts(postsList.isNotEmpty ? postsList.last.id : null);
    postsList.addAll(fetchedList);

    if (fetchedList.length != 20 || fetchedList.isEmpty) {
      existsNext = false;
    }

    if (!postsFetcher.isClosed) {
      postsFetcher.sink.add(postsList);
    }
  }

  bool get userIsConfirmed => appInfo.user.isConfirmed;
}
