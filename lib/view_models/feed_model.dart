import 'dart:async';

import 'package:aperture/view_models/base_model.dart';
import 'package:aperture/view_models/mixins/base_feed_model.dart';
import 'package:aperture/models/post.dart';

const _backendListSize = 20;

class FeedModel extends BaseModel with BaseFeedMixin<Post> {
  @override
  Future<void> fetch(bool refresh) async {
    List<Post> fetchedList;
    if (refresh || !listSubject.hasValue) {
      fetchedList = await repository.fetchPosts(null);
    } else {
      fetchedList = List<Post>.from(listSubject.value)
        ..addAll(await repository.fetchPosts(listSubject.value.last.id));
    }

    if (fetchedList.length != _backendListSize) {
      existsNext = false;
    }

    if (!listSubject.isClosed) {
      listSubject.sink.add(fetchedList);
    }
  }

  @override
  void afterInitialFetch(double circularIndicatorHeight) => null;

  bool get userIsConfirmed => appInfo.user.isConfirmed;
}
