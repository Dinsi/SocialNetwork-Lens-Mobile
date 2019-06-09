import 'dart:convert' show jsonEncode, jsonDecode;
import 'dart:io' show ContentType, HttpException, HttpHeaders, HttpStatus;

import 'package:http/http.dart' show Client;

import 'base_provider.dart';

class TokenApiProvider extends BaseProvider {
  Client client = Client();

  Future<int> login(String username, String password) async {
    print('_token_login_');

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
        throw HttpException('_token_login_');
    }
  }

  Future<int> register(Map<String, String> fields) async {
    print('_token_register_');

    var response = await client.post('${super.baseUrl}users/',
        body: jsonEncode(fields),
        headers: {HttpHeaders.contentTypeHeader: ContentType.json.value});

    print(response.statusCode);
    print(response.body);

    switch (response.statusCode) {
      case HttpStatus.created:
        return 0;

      case HttpStatus.badRequest:
        return 1; // Username is taken

      default:
        throw HttpException('_token_register_');
    }
  }

  Future<bool> verify() async {
    //TODO fix verify, returns false on other functions and does nothing
    print('_token_verify_');
    
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
