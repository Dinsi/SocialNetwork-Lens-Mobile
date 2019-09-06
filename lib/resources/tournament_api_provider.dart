import 'dart:convert' show jsonDecode, jsonEncode, utf8;
import 'dart:io';

import 'package:aperture/models/post.dart';
import 'package:aperture/models/tournament_info.dart';
import 'package:aperture/resources/base_api_provider.dart';
import 'package:flutter/widgets.dart' show debugPrint;
import 'package:http/http.dart';

class TournamentApiProvider extends BaseApiProvider {
  Client client = Client();

  Future<TournamentInfo> fetchInfo() async {
    debugPrint("_tournament_fetchInfo_");
    final response = await client.get("${super.baseUrl}tournaments/current/",
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken
        });

    debugPrint('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      return TournamentInfo.fromJson(body);
    } else {
      // If that call was not successful, throw an error.
      throw HttpException('_tournament_fetchInfo_');
    }
  }

  Future<List<Post>> fetchPosts() async {
    debugPrint("_tournament_fetchPosts_");
    final response = await client.get(
      "${super.baseUrl}tournaments/posts/",
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken
      },
    );

    debugPrint('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      final List body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((post) => Post.fromJson(post)).toList();
    } else {
      // If that call was not successful, throw an error.
      throw HttpException('_tournament_fetchPosts_');
    }
  }

  Future<int> submitPost(int postId) async {
    debugPrint("_tournament_submitPost_");
    final response = await client.get(
      "${super.baseUrl}posts/$postId/submit/",
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken
      },
    );

    debugPrint('${response.statusCode.toString()}\n${response.body}');

    switch (response.statusCode) {
      case HttpStatus.created:
        return 0;
      case HttpStatus.notFound:
        // No active tournament is in progress
        return 1;
      case HttpStatus.notAcceptable:
        // Already made a submission (limit: 1 per user ?)
        return 2;
      default:
        throw HttpException('_tournament_submitPost_');
    }
  }

  Future<int> submitVote(int postId) async {
    debugPrint("_tournament_submitVote_");
    final response = await client.post(
      "${super.baseUrl}tournaments/vote/",
      body: jsonEncode({'post': postId}),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken,
        HttpHeaders.contentTypeHeader: ContentType.json.value,
      },
    );

    debugPrint('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.accepted) {
      return 0;
    }

    throw HttpException('_tournament_submitVote_');
  }
}
