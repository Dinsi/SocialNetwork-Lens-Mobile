import 'dart:async';

import 'package:aperture/locator.dart';
import 'package:aperture/models/comment.dart';
import 'package:aperture/models/post.dart';
import 'package:aperture/resources/repository.dart';

const int _commentLimit = 10;

class PostDetailsBloc {
  final Repository _repository = locator<Repository>();
  StreamController<List<Comment>> _commentsFetcher =
      StreamController<List<Comment>>.broadcast();

  List<Comment> _commentsList = List<Comment>();
  final int _postId;
  String _nextLink;

  PostDetailsBloc(this._postId);

  Future fetchComments() async {
    var fetched =
        await _repository.fetchComments(_commentLimit, _postId, _nextLink);
    if (fetched is Map) {
      this._nextLink = fetched["nextLink"];
      fetched = (fetched["comments"] as List);
    }

    this._commentsList.addAll(fetched);

    if (!_commentsFetcher.isClosed) {
      _commentsFetcher.sink.add(_commentsList);
    }
  }

  Future<Comment> postComment(String comment) async {
    Comment result = await _repository.postComment(
        _postId, comment); //TODO assuming result is valid

    this._commentsList.insert(0, result);

    if (!_commentsFetcher.isClosed) {
      _commentsFetcher.sink.add(_commentsList);
    }

    return result;
  }

  void dispose() {
    _commentsFetcher.close();
  }

  Future<Post> clearAndFetch() async {
    this._commentsList = List<Comment>();
    this._nextLink = null;
    Future<Post> updatedPost = this.fetchPost();
    await this.fetchComments();
    return await updatedPost;
  }

  Future<Post> fetchPost() async {
    return await _repository.fetchSinglePost(_postId);
  }

  Future<int> removeVote() async {
    return await _repository.changeVote(_postId, "removevote");
  }

  Future<int> downVote() async {
    return await _repository.changeVote(_postId, "downvote");
  }

  Future<int> upVote() async {
    return await _repository.changeVote(_postId, "upvote");
  }

  Stream<List<Comment>> get comments => _commentsFetcher.stream;
  bool get existsNext => _nextLink != null;
  bool get hasComments => _commentsList.isNotEmpty;
}
