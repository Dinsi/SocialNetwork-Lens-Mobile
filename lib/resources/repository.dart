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
import '../models/comment.dart';
import '../models/search_result.dart';

class Repository {
  final postsApiProvider = PostApiProvider();
  final commentsApiProvider = CommentApiProvider();
  final tokenApiProvider = TokenApiProvider();
  final userApiProvider = UserApiProvider();
  final topicsApiProvider = TopicApiProvider();

  Future<List<Post>> fetchPosts(int lastPostId) =>
      postsApiProvider.fetchList(lastPostId);

  Future<List<Post>> fetchPostsByTopic(int lastPostId, String topic) =>
      postsApiProvider.fetchListByTopic(lastPostId, topic);

  Future<List<Post>> fetchPostsByUser(int lastPostId, String userUsername) =>
      postsApiProvider.fetchListByUser(lastPostId, userUsername);

  Future<Post> fetchSinglePost(int postId) =>
      postsApiProvider.fetchSingle(postId);

  Future<dynamic> fetchComments(
          int commentLimit, int postId, String nextLink) =>
      commentsApiProvider.fetchList(commentLimit, postId, nextLink);

  Future<int> changeVote(int postId, String change) =>
      postsApiProvider.changeVote(postId, change);

  Future<int> login(String username, String password) =>
      tokenApiProvider.login(username, password);

  Future<int> register(Map<String, String> fields) =>
      tokenApiProvider.register(fields);

  Future<List<Topic>> recommendedTopics() =>
      topicsApiProvider.fetchRecommended();

  Future<int> finishRegister(List<int> topicIds) =>
      userApiProvider.finishRegister(topicIds);

  Future<User> fetchUserInfo() => userApiProvider.fetchInfo();

  Future<int> uploadPost(File image, String title, String description) =>
      postsApiProvider.uploadPost(image, title, description);

  Future<bool> verifyToken() => tokenApiProvider.verify();

  Future<int> toggleTopicSubscription(
          String topic, String subscriptionIntent) =>
      topicsApiProvider.toggleSubscription(topic, subscriptionIntent);

  Future<Comment> postComment(int postId, String comment) =>
      commentsApiProvider.post(postId, comment);

  Future<Topic> fetchSingleTopic(String topic) =>
      topicsApiProvider.fetchSingle(topic);

  Future<int> patchUser(Map<String, String> fields) =>
      userApiProvider.patch(fields);

  Future<int> patchUserMultiPart(File imageFile, Map<String, String> fields) =>
      userApiProvider.patchMultiPart(imageFile, fields);

  Future<User> fetchUserInfoById(int userId) =>
      userApiProvider.fetchInfoById(userId);

  Future<List<SearchResult>> fetchSearchResults(String query) =>
      topicsApiProvider.fetchSearchResults(query);
}
