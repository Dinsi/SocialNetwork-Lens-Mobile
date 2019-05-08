import 'dart:async';

import '../resources/globals.dart';
import '../resources/repository.dart';
import '../models/post.dart';

class FeedBloc {
  final Repository _repository = Repository();
  final Globals _globals = Globals.getInstance();
  StreamController<List<Post>> _postsFetcher =
      StreamController<List<Post>>.broadcast();

  List<Post> _postsList = List<Post>();
  int _lastId;

  Future<int> fetchPosts() async {
    if (_postsFetcher.isClosed) {
      _postsFetcher = StreamController<List<Post>>.broadcast();
    }

    List<Post> fetchedList = await _repository.fetchPosts(_lastId);

    this._lastId = fetchedList.last.id;
    this._postsList.addAll(fetchedList);

    if (!_postsFetcher.isClosed) {
      _postsFetcher.sink.add(_postsList);
    }

    return fetchedList.length;
  }

  void clear() {
    this._postsList = List<Post>();
    this._lastId = null;
  }

  void dispose() {
    this._lastId = null;
    this._postsList = List<Post>();
    _postsFetcher.close();
  }

  Future<int> removeVote(int postId) async {
    return await _repository.changeVote(postId, "removevote");
  }

  Future<int> downVote(int postId) async {
    return await _repository.changeVote(postId, "downvote");
  }

  Future<int> upVote(int postId) async {
    return await _repository.changeVote(postId, "upVote");
  }

  Stream<List<Post>> get posts => _postsFetcher.stream;
  bool get userIsConfirmed => _globals.user.isConfirmed;
}

final feedBloc = FeedBloc();
