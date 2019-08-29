import 'dart:async';
import 'dart:io';

import 'package:aperture/locator.dart';
import 'package:aperture/models/collections/collection.dart';
import 'package:aperture/models/comment.dart';
import 'package:aperture/models/post.dart';
import 'package:aperture/models/search_result.dart';
import 'package:aperture/models/topic.dart';
import 'package:aperture/models/tournament_info.dart';
import 'package:aperture/models/users/user.dart';
import 'package:aperture/resources/collection_api_provider.dart';
import 'package:aperture/resources/comment_api_provider.dart';
import 'package:aperture/resources/post_api_provider.dart';
import 'package:aperture/resources/token_api_provider.dart';
import 'package:aperture/resources/topic_api_provider.dart';
import 'package:aperture/resources/tournament_api_provider.dart';
import 'package:aperture/resources/user_api_provider.dart';
import 'package:aperture/view_models/core/enums/change_vote_action.dart';
import 'package:aperture/view_models/edit_profile.dart';
import 'package:aperture/view_models/login.dart';
import 'package:aperture/view_models/shared/basic_post.dart'
    show ChangeVoteAction;
import 'package:aperture/view_models/shared/subscription_app_bar.dart'
    show SubscriptionAction;

class Repository {
  final postsApiProvider = locator<PostApiProvider>();
  final commentsApiProvider = locator<CommentApiProvider>();
  final tokenApiProvider = locator<TokenApiProvider>();
  final userApiProvider = locator<UserApiProvider>();
  final topicsApiProvider = locator<TopicApiProvider>();
  final collectionsApiProvider = locator<CollectionApiProvider>();
  final tournamentsApiProvider = locator<TournamentApiProvider>();

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

  Future<int> changeVote(int postId, ChangeVoteAction action) =>
      postsApiProvider.changeVote(postId, action);

  Future<int> login(String username, String password) =>
      tokenApiProvider.login(username, password);

  Future<int> register(Map<LoginField, String> fields) =>
      tokenApiProvider.register(fields);

  Future<List<Topic>> recommendedTopics() =>
      topicsApiProvider.fetchRecommended();

  Future<int> finishRegister(List<int> topicIds) =>
      userApiProvider.finishRegister(topicIds);

  Future<User> fetchUserInfo() => userApiProvider.fetchInfo();

  Future<int> uploadPost(File image, String title, String description) =>
      postsApiProvider.upload(image, title, description);

  Future<bool> verifyToken() => tokenApiProvider.verify();

  Future<int> toggleTopicSubscription(
          String topic, SubscriptionAction action) =>
      topicsApiProvider.toggleSubscription(topic, action);

  Future<Comment> postComment(int postId, String comment) =>
      commentsApiProvider.post(postId, comment);

  Future<Topic> fetchSingleTopic(String topic) =>
      topicsApiProvider.fetchSingle(topic);

  Future<int> patchUser(Map<EditProfileField, String> fields) =>
      userApiProvider.patch(fields);

  Future<int> patchUserMultiPart(
          File imageFile, Map<EditProfileField, String> fields) =>
      userApiProvider.patchMultiPart(imageFile, fields);

  Future<User> fetchUserInfoById(int userId) =>
      userApiProvider.fetchInfoById(userId);

  Future<List<SearchResult>> fetchSearchResults(
          String query, int lastResultId) =>
      topicsApiProvider.fetchSearchResults(query, lastResultId);

  Future<int> bulkUpdateTopics(List<Topic> changedTopics) =>
      topicsApiProvider.bulkUpdate(changedTopics);

  Future<int> updateUserEmail(String email, String password) =>
      userApiProvider.updateEmail(email, password);

  Future<int> changeUserPassword(String oldPassword, String newPassword,
          String confirmationPassword) =>
      userApiProvider.updatePassword(
          oldPassword, newPassword, confirmationPassword);

  Future<Collection> appendPostToCollection(int collectionId, int postId) =>
      collectionsApiProvider.appendPost(collectionId, postId);

  Future<Collection> postNewCollection(String collectionName) =>
      collectionsApiProvider.postNew(collectionName);

  Future<Collection> fetchCollection(int collectionId) =>
      collectionsApiProvider.fetch(collectionId);

  Future<TournamentInfo> fetchTournamentInfo() =>
      tournamentsApiProvider.fetchInfo();

  Future<List<Post>> fetchTournamentPosts() =>
      tournamentsApiProvider.fetchPosts();

  Future<int> submitPostToCurrentTournament(int postId) =>
      tournamentsApiProvider.submitPost(postId);
}
