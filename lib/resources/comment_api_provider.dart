import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:io';

import 'package:http/http.dart' show Client;

import '../models/comment.dart';
import 'base_provider.dart';

class CommentApiProvider extends BaseProvider {
  Client client = Client();

  Future<dynamic> fetchCommentList(
      int commentLimit, int postId, String nextLink) async {
    print("fetchCommentList");
    final response = await client.get(
        nextLink ??
            "${super.baseUrl}posts/$postId/comments/?limit=$commentLimit",
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken
        });

    print(response.body.toString());

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
      throw HttpException('fetchCommentList');
    }
  }

  Future<Comment> postComment(int postId, String comment) async {
    print('postComment');

    var response = await client.post(
      '${super.baseUrl}posts/$postId/comments/',
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken,
        HttpHeaders.contentTypeHeader: ContentType.json.value,
      },
      body: jsonEncode({'text': comment}),
    );

    print('${response.statusCode.toString()}\n${response.body}');
    if (response.statusCode == HttpStatus.created) {
      return Comment.fromJson(jsonDecode(response.body));
    }

    throw HttpException('postComment');
  }
}