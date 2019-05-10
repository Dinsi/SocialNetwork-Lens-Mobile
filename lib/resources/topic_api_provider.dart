import 'dart:convert' show jsonDecode;
import 'dart:io' show HttpException, HttpHeaders, HttpStatus;

import 'package:http/http.dart' show Client;

import 'base_provider.dart';
import '../models/topic.dart';

class TopicApiProvider extends BaseProvider {
  Client client = Client();

  Future<List<Topic>> fetchRecommended() async {
    print('fetchRecommendedTopics');

    var response = await client.get('${super.baseUrl}topics/recommended/',
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken
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

    throw HttpException('fetchRecommendedTopics');
  }

  Future<Topic> fetchSingle(String topic) async {
    print('fetchSingle');

    var response = await client.get('${super.baseUrl}topics/$topic/', headers: {
      HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken
    });

    print('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      return Topic.fromJson(jsonDecode(response.body));
    }

    throw HttpException('fetchSingle');
  }

  Future<int> toggleSubscription(
      String topic, String subscriptionIntent) async {
    print('toggleSubscription');

    var response = await client
        .post('${super.baseUrl}topics/$topic/$subscriptionIntent/', headers: {
      HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken
    });

    print('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      return 0;
    }

    throw HttpException('toggleSubscription');
  }
}
