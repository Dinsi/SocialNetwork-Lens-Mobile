import 'dart:convert' show jsonEncode, jsonDecode;
import 'dart:io' show ContentType, HttpException, HttpHeaders, HttpStatus;

import 'package:aperture/resources/base_api_provider.dart';
import 'package:aperture/view_models/login.dart';
import 'package:http/http.dart' show Client;
import 'package:http/http.dart';

// TODO fix after token functionality clarification

class TokenApiProvider extends BaseApiProvider {
  Client client = Client();

  Future<int> login(String username, String password) async {
    print('_token_login_');

    final response = await client.post('${super.baseUrl}token/',
        body: jsonEncode({'username': username, 'password': password}),
        headers: {HttpHeaders.contentTypeHeader: ContentType.json.value});

    switch (response.statusCode) {
      case HttpStatus.ok:
        final body = jsonDecode(response.body);
        await appInfo.cacheLogin(body['access'], body['refresh']);

        return 0;

      case HttpStatus.badRequest:
        return 1;

      default:
        throw HttpException('_token_login_');
    }
  }

  Future<int> register(Map<LoginField, String> fields) async {
    print('_token_register_');

    final requestFields = {
      'username': fields[LoginField.SignUpUsername],
      'first_name': fields[LoginField.SignUpFirstName],
      'last_name': fields[LoginField.SignUpLastName],
      'email': fields[LoginField.SignUpEmail],
      'password': fields[LoginField.SignUpPassword]
    };

    final response = await client.post('${super.baseUrl}users/',
        body: jsonEncode(requestFields),
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

    Response response = await client.post('${super.baseUrl}token/verify/',
        body: jsonEncode({'token': appInfo.accessToken}),
        headers: {HttpHeaders.contentTypeHeader: ContentType.json.value});

    if (response.statusCode != HttpStatus.ok) {
      response = await client.post('${super.baseUrl}token/refresh/',
          body: jsonEncode({'refresh': appInfo.refreshToken}),
          headers: {HttpHeaders.contentTypeHeader: ContentType.json.value});

      if (response.statusCode != HttpStatus.ok) {
        appInfo.clearCache();
        return false;
      }

      dynamic body = jsonDecode(response.body);
      appInfo.setAccessToken(body['access']);
    }

    return true;
  }
}
