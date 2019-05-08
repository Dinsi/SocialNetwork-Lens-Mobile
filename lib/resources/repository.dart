import 'dart:async';
import 'dart:io';

import 'comment_api_provider.dart';
import 'token_api_provider.dart';
import 'post_api_provider.dart';
import 'user_api_provider.dart';
import 'topic_api_provider.dart';
import '../models/topic.dart';
import '../models/post.dart';
import '../models/user.dart';

class Repository {
  final postsApiProvider = PostApiProvider();
  final commentsApiProvider = CommentApiProvider();
  final tokenApiProvider = TokenApiProvider();
  final userApiProvider = UserApiProvider();
  final topicsApiProvider = TopicApiProvider();

  Future<List<Post>> fetchPosts(int lastPostId) =>
      postsApiProvider.fetchPostList(lastPostId);

  Future<Post> fetchSinglePost(int postId) =>
      postsApiProvider.fetchSinglePost(postId);

  Future<dynamic> fetchComments(
          int commentLimit, int postId, String nextLink) =>
      commentsApiProvider.fetchCommentList(
          commentLimit, postId, nextLink);

  Future<int> changeVote(int postId, String change) =>
      postsApiProvider.changeVote(postId, change);

  Future<int> login(String username, String password) =>
      tokenApiProvider.login(username, password);

  Future<int> register(Map<String, String> fields) =>
      tokenApiProvider.register(fields);

  Future<List<Topic>> recommendedTopics() =>
      topicsApiProvider.fetchRecommendedTopics();

  Future<int> finishRegister(List<int> topicIds) =>
      userApiProvider.finishRegister(topicIds);

  Future<User> fetchUserInfo() => userApiProvider.fetchUserInfo();

  Future<int> uploadPost(File image, String title, String description) =>
      postsApiProvider.uploadPost(image, title, description);

  Future<bool> verifyToken() => tokenApiProvider.verifyToken();
}
