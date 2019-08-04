import 'dart:async';
import 'dart:collection';

import 'package:aperture/view_models/core/base_model.dart';
import 'package:aperture/view_models/core/mixins/base_feed.dart';
import 'package:aperture/models/post.dart';

const _backendListSize = 20;

class FeedModel extends BaseModel with BaseFeedMixin<Post> {
  // TODO cover empty list case

  @override
  Future<void> fetch(bool refresh) async {
    UnmodifiableListView<Post> fetchedList;
    if (refresh || !listSubject.hasValue) {
      fetchedList =
          UnmodifiableListView<Post>(await repository.fetchPosts(null));
    } else {
      fetchedList = UnmodifiableListView<Post>(
          List<Post>.from(listSubject.value)
            ..addAll(await repository.fetchPosts(listSubject.value.last.id)));
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

  bool get userIsConfirmed => appInfo.currentUser.isConfirmed;
}
