import 'dart:async';

import 'package:meta/meta.dart' show protected;

import '../resources/repository.dart';
import '../models/post.dart';
import '../resources/globals.dart';

abstract class BaseFeedBloc {
  @protected
  final Repository repository = Repository();

  @protected
  final Globals globals = Globals.getInstance();

  @protected
  final List<Post> postsList = List<Post>();

  @protected
  StreamController<List<Post>> postsFetcher =
      StreamController<List<Post>>.broadcast();

  void dispose() {
    postsFetcher.close();
  }

  Future<int> removeVote(int postId) async {
    return await repository.changeVote(postId, "removevote");
  }

  Future<int> downVote(int postId) async {
    return await repository.changeVote(postId, "downvote");
  }

  Future<int> upVote(int postId) async {
    return await repository.changeVote(postId, "upvote");
  }

  void clear() {
    postsList.clear();
  }

  Future<void> fetch();

  Stream<List<Post>> get posts => postsFetcher.stream;
  int get listLength => postsList.length;
}
