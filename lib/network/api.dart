import 'dart:io';
import 'dart:async';
import 'dart:convert' show json /*, utf8*/;

import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as Http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aperture/globals.dart';
import 'package:aperture/models/post.dart';
import 'package:image/image.dart';

class Api {
  const Api();
  static final Globals globals = Globals();
  static const String _url = 'https://lens.technic.pt/api/v1/';
  static const String _postPath = 'posts/';
  static const String _loginPath = 'token/';
  static const String _refreshPath = 'token/refresh/';
  static const String _verifyPath = 'token/verify/';
  static const String _registerPath = 'users/';
  static const String _selfPath = 'users/self/';
  static const String _feedPath = 'feed/';
  static const String _upVotePostPath = 'upvote/'; //posts/{id}/upvote
  static const String _downVotePostPath = 'downvote/'; //posts/{id}/downvote
  static const String _removeVotePostPath =
      'removevote/'; //posts/{id}/removevote

  static Future<int> upload(
      File imageFile, String title, String description) async {
    verifyToken();

    Http.ByteStream stream =
        new Http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    int length = await imageFile.length();

    Uri uri = Uri.parse(_url + _postPath);

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

    if (response.statusCode == 201) {
      return 0;
    }
    
    return 1; //TODO add more errors as necessary
  }

  static Future<Http.Response> login(String username, String password) async {
    var response = await Http.post(Uri.parse(_url + _loginPath),
        body: json.encode({'username': username, 'password': password}),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});

    return response;
  }

  static Future<Http.Response> register(Map<String, String> fields) async {
    var response = await Http.post(Uri.parse(_url + _registerPath),
        body: json.encode(fields),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});

    return response;
  }

  static Future<Http.Response> getUserInfo() async {
    verifyToken();

    var response = await Http.get(Uri.parse(_url + _selfPath), headers: {
      HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken
    });

    return response;
  }

  static Future<bool> verifyToken() async {
    var response = await Http.post(Uri.parse(_url + _verifyPath),
        body: json.encode({'token': globals.accessToken}),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});

    if (response.statusCode != 200) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      response = await Http.post(Uri.parse(_url + _refreshPath),
          body: json.encode({'refresh': globals.refreshToken}),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'});

      if (response.statusCode != 200) {
        await prefs.clear();
        globals.removeTokens();

        return false;
      }

      dynamic body = json.decode(response.body);
      await prefs.setString('access', body['access']);
      globals.accessToken = body['access'];
    }

    return true;
  }

  static Future<List<Post>> feed(Post lastPost) async {
    verifyToken();

    List<Post> posts;
    var response = await Http.get(
        Uri.parse(_url +
            _feedPath +
            (lastPost != null ? "?after=${lastPost.id}" : "")),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken
        });

    print(response.body);

    if (response.body.isEmpty) {
      return null;
    }

    if (response.statusCode == 200) {
      dynamic body = json.decode(response.body);

      posts = new List<Post>();
      body.forEach((v) {
        posts.add(new Post.fromJson(v));
      });
    }

    return posts;
  }

  static Future<int> downVote(int id) async {
    verifyToken();

    print('downVote');
    var response = await Http.post(
        Uri.parse(_url + _postPath + '$id/' + _downVotePostPath),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken
        });

    print(response.body + response.statusCode.toString());

    return response.statusCode == 200 ? 0 : 1;
  }

  static Future<int> upVote(int id) async {
    verifyToken();

    print('upVote');
    var response = await Http.post(
        Uri.parse(_url + _postPath + '$id/' + _upVotePostPath),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken
        });

    print(response.body + response.statusCode.toString());

    return response.statusCode == 200 ? 0 : 1;
  }

  static Future<int> removeVote(int id) async {
    verifyToken();

    print('removeVote');
    var response = await Http.post(
        Uri.parse(_url + _postPath + '$id/' + _removeVotePostPath),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken
        });

    print(response.body + response.statusCode.toString());

    return response.statusCode == 200 ? 0 : 1;
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
