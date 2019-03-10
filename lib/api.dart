import 'dart:io';
import 'dart:async';
import 'dart:convert' show json, utf8;

import 'package:proof_of_concept/globals.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;

/// For this app, the only [Category] endpoint we retrieve from an API is Currency.
///
/// If we had more, we could keep a list of [Categories] here.
const apiCategory = {
  'name': 'Currency',
  'route': 'currency',
};

class Api {
  final String _url = 'https://lens.technic.pt/api';
  final String _imagePath = '/v1/images/';
  final String _loginPath = '/token/';
  /*final String _refreshPath = '/token/refresh/';
  final String _verifyPath = '/token/verify/';*/
  final String _registerPath = '/v1/users/';
  final String _selfPath = '/v1/users/self/';

  Future<void> upload(File imageFile) async {
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();
    var token = Globals().accessToken;

    var uri = Uri.parse(_url + _imagePath);

    print(basename(imageFile.path));
    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('original_file', stream, length,
        filename: basename(imageFile.path));

    //contentType: new MediaType('image', 'png'));

    request.files.add(multipartFile);
    request.fields.addAll({
      'title': basename(imageFile.path),
    });
    request.headers
        .addAll({HttpHeaders.authorizationHeader: 'Bearer ' + token});

    var response = await request.send();
    print(response.statusCode);
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });
  }

  Future<http.Response> login(String username, String password) async {
    var response = await http.post(Uri.parse(_url + _loginPath),
        body: json.encode({'username': username, 'password': password}),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});

    return response;
  }

  Future<http.Response> register(Map<String, String> fields) async {
    var response = await http.post(Uri.parse(_url + _registerPath),
        body: json.encode(fields),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});

    return response;
  }

  Future<http.Response> getUserInfo() async {
    var response = await http.get(
        Uri.parse(_url + _selfPath),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ' + Globals().accessToken
        }
    );

    return response;
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
