import 'dart:collection';

import 'package:aperture/locator.dart';
import 'package:aperture/models/post.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/view_models/core/base_model.dart';
import 'package:aperture/view_models/core/mixins/base_feed.dart';

const _backendListSize = 20;

class TopicFeedModel extends BaseModel with BaseFeedMixin<Post> {
  final Repository _repository = locator<Repository>();

  String _topic;

  void init(String topic) {
    _topic = topic;
  }

  @override
  Future<void> fetch(bool refresh) async {
    int fetchedListSize;
    UnmodifiableListView<Post> postList;

    if (refresh || !listSubject.hasValue) {
      final fetchedList = await _repository.fetchPostsByTopic(null, _topic);

      fetchedListSize = fetchedList.length;

      postList = UnmodifiableListView<Post>(fetchedList);
    } else {
      final fetchedList = await _repository.fetchPostsByTopic(
          listSubject.value.last.id, _topic);

      fetchedListSize = fetchedList.length;

      postList = UnmodifiableListView<Post>(
          List<Post>.from(listSubject.value)..addAll(fetchedList));
    }

    if (fetchedListSize != _backendListSize) {
      existsNext = false;
    }

    if (!listSubject.isClosed) {
      listSubject.sink.add(postList);
    }
  }
}
