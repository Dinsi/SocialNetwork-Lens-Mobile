import 'dart:collection';

import 'package:aperture/locator.dart';
import 'package:aperture/models/post.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/view_models/core/base_model.dart';
import 'package:aperture/view_models/core/mixins/base_feed.dart';

class TopicFeedModel extends BaseModel with BaseFeedMixin<Post> {
  final Repository _repository = locator<Repository>();

  String _topic;

  void init(String topic) {
    _topic = topic;
  }

  @override
  Future<void> fetch(bool refresh) async {
    UnmodifiableListView<Post> fetchedList;
    if (refresh || !listSubject.hasValue) {
      fetchedList = UnmodifiableListView<Post>(
          await _repository.fetchPostsByTopic(null, _topic));
    } else {
      fetchedList = UnmodifiableListView<Post>(
          List<Post>.from(listSubject.value)
            ..addAll(await _repository.fetchPostsByTopic(
                listSubject.value.last.id, _topic)));
    }

    if (fetchedList.length != 20) {
      existsNext = false;
    }

    if (!listSubject.isClosed) {
      listSubject.sink.add(fetchedList);
    }
  }

  @override
  void afterInitialFetch(double circularIndicatorHeight) => null;
}
