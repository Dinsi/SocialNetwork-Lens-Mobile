import 'dart:convert' show jsonDecode;
import 'dart:io' show HttpException, HttpHeaders, HttpStatus;

import 'package:http/http.dart' show Client;

import 'base_provider.dart';
import '../models/topic.dart';

class TopicApiProvider extends BaseProvider {
  Client client = Client();

  Future<List<Topic>> fetchRecommendedTopics() async {
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
}
