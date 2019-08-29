import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:io';

import 'package:aperture/models/comment.dart';
import 'package:aperture/resources/base_api_provider.dart';
import 'package:flutter/widgets.dart' show debugPrint;
import 'package:http/http.dart' show Client;

class CommentApiProvider extends BaseApiProvider {
  Client client = Client();

  Future<dynamic> fetchList(
      int commentLimit, int postId, String nextLink) async {
    debugPrint("_comment_fetchList_");
    final response = await client.get(
        nextLink ??
            "${super.baseUrl}posts/$postId/comments/?limit=$commentLimit",
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken
        });

    debugPrint(response.body.toString());

    if (response.statusCode == HttpStatus.ok) {
      if (response.body.isEmpty) {
        return List<Comment>();
      }

      dynamic body = jsonDecode(response.body);
      List<dynamic> commentsData = (body["results"] as List);
      List<Comment> comments = List<Comment>(commentsData.length);
      for (int i = 0; i < commentsData.length; i++) {
        comments[i] = Comment.fromJson(commentsData[i]);
      }

      return {"comments": comments, "nextLink": body["next"]};
    } else {
      // If that call was not successful, throw an error.
      throw HttpException('_comment_fetchList_');
    }
  }

  Future<Comment> post(int postId, String comment) async {
    debugPrint('_comment_post_');

    final response = await client.post(
      '${super.baseUrl}posts/$postId/comments/',
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken,
        HttpHeaders.contentTypeHeader: ContentType.json.value,
      },
      body: jsonEncode({'text': comment}),
    );

    debugPrint('${response.statusCode.toString()}\n${response.body}');
    if (response.statusCode == HttpStatus.created) {
      return Comment.fromJson(jsonDecode(response.body));
    }

    throw HttpException('_comment_post_');
  }
}