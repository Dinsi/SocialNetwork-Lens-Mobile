import 'dart:convert' show jsonEncode, jsonDecode;
import 'dart:io' show ContentType, HttpException, HttpHeaders, HttpStatus;

import 'package:http/http.dart' show Client;

import 'base_provider.dart';
import '../models/user.dart';

class TokenApiProvider extends BaseProvider {
  Client client = Client();

  Future<int> login(String username, String password) async {
    print('login');

    var response = await client.post('${super.baseUrl}token/',
        body: jsonEncode({'username': username, 'password': password}),
        headers: {HttpHeaders.contentTypeHeader: ContentType.json.value});

    switch (response.statusCode) {
      case HttpStatus.ok:
        final body = jsonDecode(response.body);
        await globals.cacheLogin(body['access'], body['refresh']);

        return 0;

      case HttpStatus.badRequest:
        return 1;

      default:
        throw HttpException('login'); //TODO add more errors as necessary
    }
  }

  Future<int> register(Map<String, String> fields) async {
    print('register');

    var response = await client.post('${super.baseUrl}users/',
        body: jsonEncode(fields),
        headers: {HttpHeaders.contentTypeHeader: ContentType.json.value});

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == HttpStatus.created) {
      return 0;
    }

    //throw HttpException('register'); TODO add more errors as necessary
    return 1;
  }

  Future<bool> verifyToken() async {
    //TODO fix verifyToken, returns false on other functions and does nothing
    print('verifyToken');
    
    var response = await client.post('${super.baseUrl}token/verify/',
        body: jsonEncode({'token': globals.accessToken}),
        headers: {HttpHeaders.contentTypeHeader: ContentType.json.value});

    if (response.statusCode != HttpStatus.ok) {
      response = await client.post('${super.baseUrl}token/refresh/',
          body: jsonEncode({'refresh': globals.refreshToken}),
          headers: {HttpHeaders.contentTypeHeader: ContentType.json.value});

      if (response.statusCode != HttpStatus.ok) {
        globals.clearCache();
        return false;
      }

      dynamic body = jsonDecode(response.body);
      globals.setAccessToken(body['access']);
    }

    return true;
  }
}
