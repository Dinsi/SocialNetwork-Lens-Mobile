import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:io' show HttpException, HttpHeaders, HttpStatus;
import 'dart:io';

import 'package:aperture/models/search_result.dart';
import 'package:aperture/models/topic.dart';
import 'package:aperture/resources/base_api_provider.dart';
import 'package:aperture/view_models/shared/subscription_app_bar.dart'
    show SubscriptionAction;
import 'package:http/http.dart' show Client;

class TopicApiProvider extends BaseApiProvider {
  Client client = Client();

  Future<List<Topic>> fetchRecommended() async {
    print('_topic_fetchRecommended_');

    final response = await client.get('${super.baseUrl}topics/recommended/',
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken
        });

    print('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      List<dynamic> body = (jsonDecode(response.body) as List);

      List<Topic> topicsList = List<Topic>(body.length);
      for (int i = 0; i < topicsList.length; i++) {
        topicsList[i] = Topic.fromJson(body[i]);
      }

      return topicsList;
    }

    throw HttpException('_topic_fetchRecommended_');
  }

  Future<Topic> fetchSingle(String topic) async {
    print('_topic_fetchSingle_');

    final response = await client.get('${super.baseUrl}topics/$topic/', headers: {
      HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken
    });

    print('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      return Topic.fromJson(jsonDecode(response.body));
    }

    throw HttpException('_topic_fetchSingle_');
  }

  Future<int> toggleSubscription(
      String topic, SubscriptionAction action) async {
    String printText = '_topic_toggleSubscription_';
    String actionPath;

    switch (action) {
      case SubscriptionAction.Subscribe:
        printText += 'subscribe_';
        actionPath = 'subscribe';
        break;
      case SubscriptionAction.Unsubscribe:
        printText += 'unsubscribe_';
        actionPath = 'unsubscribe';
    }

    print(printText);

    final response = await client.post(
      '${super.baseUrl}topics/$topic/$actionPath/',
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken
      },
    );

    print('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      return 0;
    }

    throw HttpException(printText);
  }

  Future<List<SearchResult>> fetchSearchResults(String query) async {
    print('_topic_fetchSearchResults_');

    final response = await client.post(
      '${super.baseUrl}topics/search/',
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.value,
        HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken
      },
      body: jsonEncode({"q": query}),
    );

    print('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      List<dynamic> body = jsonDecode(response.body) as List;
      List<SearchResult> results = List<SearchResult>(body.length);

      for (var i = 0; i < body.length; i++) {
        results[i] = SearchResult.fromJson(body[i]);
      }

      return results;
    }

    throw HttpException('_topic_fetchSearchResults_');
  }

  Future<int> bulkUpdate(List<Topic> changedTopics) async {
    print('_topic_bulkUpdate_');

    List<int> topicsNames = List<int>(changedTopics.length);
    for (var i = 0; i < changedTopics.length; i++) {
      topicsNames[i] = changedTopics[i].id;
    }

    final response = await client.post(
      '${super.baseUrl}topics/bulk/',
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken,
        HttpHeaders.contentTypeHeader: ContentType.json.value
      },
      body: jsonEncode({'topics': topicsNames}),
    );

    print('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      return 0;
    } //TODO assuming valid

    throw HttpException('_topic_bulkUpdate_');
  }
}
