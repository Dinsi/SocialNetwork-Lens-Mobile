import 'dart:io';
import 'dart:async';
import 'dart:convert' show json /*, utf8*/;

import 'package:aperture/models/comment.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as Http;

import 'package:aperture/globals.dart';
import 'package:aperture/models/post.dart';
import 'package:image/image.dart';

class Api {
  const Api();
  static final Globals globals = Globals.getInstance();
  static const String _url = 'https://lens.technic.pt/api/v1/';
  static const String _post = 'posts/';
  static const String _token = 'token/';
  static const String _refresh = 'token/refresh/';
  static const String _verify = 'token/verify/';
  static const String _register = 'users/';
  static const String _self = 'users/self/';
  static const String _feed = 'feed/';
  static const String _upVote = 'upvote/'; //posts/{id}/upvote
  static const String _downVote = 'downvote/'; //posts/{id}/downvote
  static const String _removeVote = 'removevote/'; //posts/{id}/removevote
  static const String _comments = 'comments/'; //posts/{id}/comments

  static Future<int> upload(
      File imageFile, String title, String description) async {
    verifyToken();

    Http.ByteStream stream =
        new Http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    int length = await imageFile.length();

    Uri uri = Uri.parse(_url + _post);

    Http.MultipartRequest request = new Http.MultipartRequest("POST", uri);
    Http.MultipartFile multipartFile = new Http.MultipartFile(
      'image',
      stream,
      length,
      filename: basename(imageFile.path),
      contentType: MediaType('image', imageFile.path.split(".").last),
    );
    request.files.add(multipartFile);

    Image image = decodeImage(imageFile.readAsBytesSync());
    request.fields.addAll({
      'title': title,
      'description': description,
      'width': image.width.toString(),
      'height': image.height.toString(),
    });
    request.headers.addAll(
        {HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken});

    var response = await request.send();
    /*print(response.statusCode);
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });*/

    if (response.statusCode == HttpStatus.created) {
      return 0;
    }

    return 1; //TODO add more errors as necessary
  }

  static Future<int> login(String username, String password) async {
    var response = await Http.post(Uri.parse(_url + _token),
        body: json.encode({'username': username, 'password': password}),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      await globals.cacheLogin(body['access'], body['refresh']);

      return 0;
    }
    return 1; //TODO add more errors as necessary
  }

  static Future<int> register(Map<String, String> fields) async {
    var response = await Http.post(Uri.parse(_url + _register),
        body: json.encode(fields),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});

    if (response.statusCode == HttpStatus.created) {
      return 0;
    }
    return 1; //TODO add more errors as necessary
  }

  static Future<int> userInfo() async {
    verifyToken();

    var response = await Http.get(Uri.parse(_url + _self), headers: {
      HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken
    });

    if (response.statusCode == HttpStatus.ok) {
      await globals.setUser(json.decode(response.body));
      return 0;
    }
    return 1;
  }

  static Future<bool> verifyToken() async {
    //TODO fix verifyToken, returns false on other functions and does nothing
    var response = await Http.post(Uri.parse(_url + _verify),
        body: json.encode({'token': globals.accessToken}),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});

    if (response.statusCode != HttpStatus.ok) {
      response = await Http.post(Uri.parse(_url + _refresh),
          body: json.encode({'refresh': globals.refreshToken}),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'});

      if (response.statusCode != HttpStatus.ok) {
        globals.clearCache();
        return false;
      }

      dynamic body = json.decode(response.body);
      globals.setAccessToken(body['access']);
    }

    return true;
  }

  static Future<List<Post>> feed(int lastPostId) async {
    verifyToken();

    var response = await Http.get(
        Uri.parse(
            _url + _feed + (lastPostId != null ? "?after=$lastPostId" : "")),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken
        });

    print(response.body);

    if (response.body.isEmpty || response.statusCode != HttpStatus.ok) {
      return List<Post>();
    }

    dynamic body = json.decode(response.body);
    List<Post> posts = List<Post>((body as List).length);
    for (int i = 0; i < posts.length; i++) {
      posts[i] = Post.fromJson((body as List)[i]);
    }

    return posts;
  }

  static Future<int> downVote(int postId) async {
    verifyToken();

    print('downVote');
    var response = await Http.post(
        Uri.parse(_url + _post + '$postId/' + _downVote),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken
        });

    print(response.body + response.statusCode.toString());

    return response.statusCode == HttpStatus.ok ? 0 : 1;
  }

  static Future<int> upVote(int postId) async {
    verifyToken();

    print('upVote');
    var response = await Http.post(
        Uri.parse(_url + _post + '$postId/' + _upVote),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken
        });

    print(response.body + response.statusCode.toString());

    return response.statusCode == HttpStatus.ok ? 0 : 1;
  }

  static Future<int> removeVote(int postId) async {
    verifyToken();

    print('removeVote');
    var response = await Http.post(
        Uri.parse(_url + _post + '$postId/' + _removeVote),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken
        });

    print(response.body + response.statusCode.toString());

    return response.statusCode == HttpStatus.ok ? 0 : 1;
  }

  static Future<List<Comment>> comments(int postId) async {
    verifyToken();

    print('comments');
    var uri = _url + _post + '$postId/' + _comments;
    var response = await Http.get(uri, headers: {
      HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken
    });

    print('${response.statusCode.toString()}\n${response.body}');
    if (response.statusCode == HttpStatus.ok) {
      List<dynamic> body = (json.decode(response.body) as List);
      if (body.isEmpty) {
        return List<Comment>();
      }

      List<Comment> commentsList = List<Comment>(body.length);
      for (int i = 0; i < commentsList.length; i++) {
        commentsList[i] = Comment.fromJson(body[i]);
      }

      return commentsList;
    }

    throw HttpException(uri);
  }
  /*Future<Map<String, dynamic>> _getJson(Uri uri) async {
    HttpClient HttpClient = HttpClient();

    try {
      final HttpRequest = await HttpClient.getUrl(uri);
      final HttpResponse = await HttpRequest.close();
      if (HttpResponse.statusCode != HttpStatus.ok) {
        return null;
      }
      // The response is sent as a Stream of bytes that we need to convert to a
      // `String`.
      final responseBody = await HttpResponse.transform(utf8.decoder).join();
      // Finally, the string is parsed into a JSON object.
      return json.decode(responseBody);

    } on Exception catch (e) {
      print('$e');
      return null;
    }
  }*/
}
