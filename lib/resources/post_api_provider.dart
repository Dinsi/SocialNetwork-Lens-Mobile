import 'dart:async';
import 'dart:io' show File, HttpException, HttpHeaders, HttpStatus;
import 'dart:convert' show jsonDecode, utf8;

import 'package:aperture/models/post.dart';
import 'package:aperture/resources/base_api_provider.dart';
import 'package:aperture/view_models/core/enums/change_vote_action.dart';
import 'package:aperture/view_models/shared/basic_post.dart'
    show ChangeVoteAction;
import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart'
    show ByteStream, Client, MultipartFile, MultipartRequest;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

class PostApiProvider extends BaseApiProvider {
  Client client = Client();

  Future<List<Post>> fetchList(int lastPostId) async {
    print("_post_fetchList_");
    return await fetchPosts(
        "${super.baseUrl}feed/${(lastPostId != null ? "?after=$lastPostId" : "")}");
  }

  Future<List<Post>> fetchListByTopic(int lastPostId, String topic) async {
    print("_post_fetchListByTopic_");
    return await fetchPosts(
        "${super.baseUrl}topics/$topic/feed/${(lastPostId != null ? "?after=$lastPostId" : "")}");
  }

  Future<List<Post>> fetchListByUser(
      int lastPostId, String userUsername) async {
    print("_post_fetchListByUser_");
    return await fetchPosts(
        "${super.baseUrl}topics/$userUsername/feed/${(lastPostId != null ? "?after=$lastPostId" : "")}");
  }

  Future<List<Post>> fetchPosts(String uri) async {
    final response = await client.get(uri, headers: {
      HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken
    });

    debugPrint(response.body.toString(), wrapWidth: 1024);

    if (response.statusCode == HttpStatus.ok) {
      if (response.body.isEmpty) {
        return List<Post>();
      }

      List<dynamic> body = (jsonDecode(response.body) as List);
      List<Post> posts = List<Post>(body.length);
      for (int i = 0; i < body.length; i++) {
        posts[i] = Post.fromJson(body[i]);
      }

      return posts;
    } else {
      // If that call was not successful, throw an error.
      throw HttpException('_post_fetchPosts_');
    }
  }

  Future<Post> fetchSingle(int postId) async {
    print("_post_fetchSingle_");
    final response = await client.get("${super.baseUrl}posts/$postId/",
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken
        });

    print(response.body.toString());

    if (response.statusCode == HttpStatus.ok) {
      dynamic body = jsonDecode(response.body);
      return Post.fromJson(body);
    } else {
      // If that call was not successful, throw an error.
      throw HttpException('_post_fetchSingle_');
    }
  }

  Future<int> upload(File imageFile, String title, String description) async {
    //TODO verifyToken();

    print("_post_upload_");

    ByteStream stream =
        new ByteStream(DelegatingStream.typed(imageFile.openRead()));
    int length = await imageFile.length();

    Uri uri = Uri.parse('${super.baseUrl}posts/');

    MultipartRequest request = new MultipartRequest("POST", uri);
    MultipartFile multipartFile = new MultipartFile(
      'image',
      stream,
      length,
      filename: basename(imageFile.path),
      contentType: MediaType('image', imageFile.path.split(".").last),
    );
    request.files.add(multipartFile);

    final decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());

    request.fields.addAll({
      'title': title,
      'description': description,
      'width': decodedImage.width.toString(),
      'height': decodedImage.height.toString(),
    });

    request.headers.addAll(
      {HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken},
    );

    final response = await request.send();
    print(response.statusCode);
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });

    if (response.statusCode == HttpStatus.created) {
      return 0;
    }

    throw HttpException('_post_upload_'); //TODO add more errors as necessary
  }

  Future<int> changeVote(int postId, ChangeVoteAction action) async {
    String printText = '_post_changeVote_';
    String actionPath;

    switch (action) {
      case ChangeVoteAction.Up:
        printText += 'upvote_';
        actionPath = 'upvote';
        break;

      case ChangeVoteAction.Down:
        printText += 'downvote_';
        actionPath = 'downvote';
        break;

      case ChangeVoteAction.Remove:
        printText += 'removevote_';
        actionPath = 'removevote';
    }

    print(printText);

    final response = await client
        .post('${super.baseUrl}posts/$postId/$actionPath/', headers: {
      HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken
    });

    print(response.body + response.statusCode.toString());

    if (response.statusCode == HttpStatus.ok) {
      return 0;
    }

    throw HttpException(printText);
  }
}
