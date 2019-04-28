import 'dart:io';
import 'dart:async';
import 'dart:convert' show json /*, utf8*/;

import 'package:aperture/models/comment.dart';
import 'package:aperture/models/topic.dart';
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
  static final Http.Client client = Http.Client();
  static const String _baseUrl = 'https://lens.technic.pt/api/v1/';
  static const String _posts = 'posts/';
  static const String _token = 'token/';
  static const String _refresh = 'token/refresh/';
  static const String _verify = 'token/verify/';
  static const String _users = 'users/';
  static const String _self = 'self/';
  static const String _feed = 'feed/';
  static const String _upVote = 'upvote/'; //posts/{id}/upvote
  static const String _downVote = 'downvote/'; //posts/{id}/downvote
  static const String _removeVote = 'removevote/'; //posts/{id}/removevote
  static const String _comments = 'comments/'; //posts/{id}/comments
  static const String _recommendedTopics = 'topics/recommended/';
  static const String _finishRegister = 'finish_register/';

  static Future<int> upload(
      File imageFile, String title, String description) async {
    verifyToken();

    Http.ByteStream stream =
        new Http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    int length = await imageFile.length();

    Uri uri = Uri.parse(_baseUrl + _posts);

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

    throw HttpException(uri.toString()); //TODO add more errors as necessary
  }


  static Future<int> login(String username, String password) async {
    print('login');

    String uri = _baseUrl + _token;
    var response = await client.post(uri,
        body: json.encode({'username': username, 'password': password}),
        headers: {HttpHeaders.contentTypeHeader: ContentType.json.value});

    switch (response.statusCode) {
      case HttpStatus.ok:
        final body = json.decode(response.body);
        await globals.cacheLogin(body['access'], body['refresh']);

        return 0;

      case HttpStatus.badRequest:
        return 1;

      default:
        throw HttpException(uri); //TODO add more errors as necessary
    }
  }


  static Future<int> register(Map<String, String> fields) async {
    String uri = _baseUrl + _users;

    var response = await client.post(uri,
        body: json.encode(fields),
        headers: {HttpHeaders.contentTypeHeader: ContentType.json.value});

    if (response.statusCode == HttpStatus.created) {
      return 0;
    }

    throw HttpException(uri); //TODO add more errors as necessary
  }


  static Future<int> userInfo() async {
    verifyToken();

    String uri = _baseUrl + _users + _self;
    var response = await client.get(uri, headers: {
      HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken
    });

    if (response.statusCode == HttpStatus.ok) {
      await globals.setUser(json.decode(response.body));
      return 0;
    }

    throw HttpException(uri);
  }


  static Future<bool> verifyToken() async {
    //TODO fix verifyToken, returns false on other functions and does nothing
    String uri = _baseUrl + _verify;

    var response = await client.post(uri,
        body: json.encode({'token': globals.accessToken}),
        headers: {HttpHeaders.contentTypeHeader: ContentType.json.value});

    if (response.statusCode != HttpStatus.ok) {
      response = await client.post(Uri.parse(_baseUrl + _refresh),
          body: json.encode({'refresh': globals.refreshToken}),
          headers: {HttpHeaders.contentTypeHeader: ContentType.json.value});

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

    String uri =
        _baseUrl + _feed + (lastPostId != null ? "?after=$lastPostId" : "");

    var response = await client.get(uri, headers: {
      HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken
    });

    print(response.body);

    if (response.body.isEmpty || response.statusCode != HttpStatus.ok) {
      return List<Post>();
    }

    dynamic body = json.decode(response.body);
    List<Post> posts = List<Post>();
    body.forEach((v) {
      posts.add(Post.fromJson(v));
    });

    return posts;
  }


  static Future<int> downVote(int postId) async {
    print('downVote');

    verifyToken();

    String uri = _baseUrl + _posts + '$postId/' + _downVote;

    var response = await client.post(uri, headers: {
      HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken
    });

    print(response.body + response.statusCode.toString());

    if (response.statusCode == HttpStatus.ok) {
      return 0;
    }

    throw HttpException(uri);
  }


  static Future<int> upVote(int postId) async {
    print('upVote');

    verifyToken();

    String uri = _baseUrl + _posts + '$postId/' + _upVote;

    var response = await client.post(uri, headers: {
      HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken
    });

    print(response.body + response.statusCode.toString());

    if (response.statusCode == HttpStatus.ok) {
      return 0;
    }

    throw HttpException(uri);
  }


  static Future<int> removeVote(int postId) async {
    print('removeVote');

    verifyToken();

    String uri = _baseUrl + _posts + '$postId/' + _removeVote;
    var response = await client.post(uri, headers: {
      HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken
    });

    print(response.body + response.statusCode.toString());

    if (response.statusCode == HttpStatus.ok) {
      return 0;
    }

    throw HttpException(uri);
  }


  static Future<List<Comment>> comments(int postId) async {
    print('comments');

    verifyToken();

    String uri = _baseUrl + _posts + '$postId/' + _comments;

    var response = await client.get(uri, headers: {
      HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken
    });

    print('${response.statusCode.toString()}\n${response.body}');
    if (response.statusCode == HttpStatus.ok) {
      dynamic body = json.decode(response.body);
      if ((body as List).isEmpty) {
        return List<Comment>();
      }

      List<Comment> commentsList = List<Comment>();
      body.forEach((v) {
        commentsList.add(Comment.fromJson(v));
      });

      return commentsList;
    }

    throw HttpException(uri);
  }


  static Future<Comment> postComment(int postId, String comment) async {
    print('postComments');

    verifyToken();

    String uri = _baseUrl + _posts + '$postId/' + _comments;
    var response = await client.post(
      uri,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken,
        HttpHeaders.contentTypeHeader: ContentType.json.value,
      },
      body: json.encode({'text': comment}),
    );

    print('${response.statusCode.toString()}\n${response.body}');
    if (response.statusCode == HttpStatus.created) {
      return Comment.fromJson(json.decode(response.body));
    }

    throw HttpException(uri);
  }


  static Future<List<Topic>> recommendedTopics() async {
    print('recommendedTopics');

    verifyToken();

    String uri = _baseUrl + _recommendedTopics;

    var response = await client.get(uri, headers: {
      HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken
    });

    print('${response.statusCode.toString()}\n${response.body}');
    if (response.statusCode == HttpStatus.ok) {
      List<dynamic> body = (json.decode(response.body) as List);

      List<Topic> topicsList = List<Topic>(body.length);
      for (int i = 0; i < topicsList.length; i++) {
        topicsList[i] = Topic.fromJson(body[i]);
      }

      return topicsList;
    }

    throw HttpException(uri);
  }


  static Future<int> finishRegister(List<int> desiredTopics) async {
    print('finishRegister');

    verifyToken();

    String uri = _baseUrl + _users + _finishRegister;

    var response = await client.post(
      uri,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken,
        HttpHeaders.contentTypeHeader: ContentType.json.value,
      },
      body: json.encode({'topics': desiredTopics}),
    );

    print('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      await globals.setUser(json.decode(response.body));
      return 0;
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
