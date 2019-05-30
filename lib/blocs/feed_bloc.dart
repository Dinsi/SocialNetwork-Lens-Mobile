import 'dart:async';

import '../models/post.dart';
import 'base_feed_bloc.dart';

class FeedBloc extends BaseFeedBloc {
  @override
  Future<void> fetch() async {
    List<Post> fetchedList = await repository
        .fetchPosts(postsList.isNotEmpty ? postsList.last.id : null);
    postsList.addAll(fetchedList);

    if (fetchedList.length != 20 || fetchedList.isEmpty) {
      existsNext = false;
    }

    print(fetchedList.length);

    if (!postsFetcher.isClosed) {
      postsFetcher.sink.add(postsList);
    }
  }

  bool get userIsConfirmed => globals.user.isConfirmed;
}
