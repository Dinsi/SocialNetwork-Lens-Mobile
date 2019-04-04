import 'dart:io';
import 'dart:async';
import 'dart:convert' show json /*, utf8*/;

import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aperture/globals.dart';
import 'package:aperture/models/post.dart';

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
  static const String _feed = 'feed';

  static Future<http.StreamedResponse> upload(File imageFile) async {
    verifyToken();

    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();

    var uri = Uri.parse(_url + _postPath);

    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('original_file', stream, length,
        filename: basename(imageFile.path));

    //contentType: new MediaType('image', 'png'));

    request.files.add(multipartFile);
    request.fields.addAll({
      'title': basename(imageFile.path),
    });
    request.headers.addAll(
        {HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken});

    var response = await request.send();
    /*print(response.statusCode);
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });*/

    return response;
  }

  static Future<http.Response> login(String username, String password) async {
    var response = await http.post(Uri.parse(_url + _loginPath),
        body: json.encode({'username': username, 'password': password}),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});

    return response;
  }

  static Future<http.Response> register(Map<String, String> fields) async {
    var response = await http.post(Uri.parse(_url + _registerPath),
        body: json.encode(fields),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});

    return response;
  }

  static Future<http.Response> getUserInfo() async {
    var response = await http.get(Uri.parse(_url + _selfPath), headers: {
      HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken
    });

    return response;
  }

  static Future<bool> verifyToken() async {
    var response = await http.post(Uri.parse(_url + _verifyPath),
        body: json.encode({'token': globals.accessToken}),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});

    if (response.statusCode != 200) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      response = await http.post(Uri.parse(_url + _refreshPath),
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
    var response = await http.get(
        Uri.parse(_url + _feed + (lastPost != null ? "?after=${lastPost.id}" : "")),
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

  /*Future<Map<String, dynamic>> _getJson(Uri uri) async {
    HttpClient httpClient = HttpClient();

    try {
      final httpRequest = await httpClient.getUrl(uri);
      final httpResponse = await httpRequest.close();
      if (httpResponse.statusCode != HttpStatus.ok) {
        return null;
      }
      // The response is sent as a Stream of bytes that we need to convert to a
      // `String`.
      final responseBody = await httpResponse.transform(utf8.decoder).join();
      // Finally, the string is parsed into a JSON object.
      return json.decode(responseBody);

    } on Exception catch (e) {
      print('$e');
      return null;
    }
  }*/
}
