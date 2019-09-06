import 'dart:convert' show jsonDecode, jsonEncode, utf8;
import 'dart:io' show ContentType, HttpException, HttpHeaders, HttpStatus;

import 'package:aperture/resources/base_api_provider.dart';
import 'package:aperture/view_models/login.dart';
import 'package:flutter/widgets.dart' show debugPrint;
import 'package:http/http.dart' show Client;
import 'package:http/http.dart';

class TokenApiProvider extends BaseApiProvider {
  Client client = Client();

  Future<int> login(String username, String password) async {
    debugPrint('_token_login_');

    final response = await client.post('${super.baseUrl}token/',
        body: jsonEncode({'username': username, 'password': password}),
        headers: {HttpHeaders.contentTypeHeader: ContentType.json.value});

    switch (response.statusCode) {
      case HttpStatus.ok:
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        await appInfo.cacheLogin(body['access'], body['refresh']);

        return 0;

      case HttpStatus.unauthorized:
        return 1;

      default:
        throw HttpException('_token_login_');
    }
  }

  Future<int> register(Map<LoginField, String> fields) async {
    debugPrint('_token_register_');

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

    debugPrint(response.statusCode.toString());
    debugPrint(response.body);

    switch (response.statusCode) {
      case HttpStatus.created:
        return 0;

      case HttpStatus.badRequest:
        final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

        // 1 -> username is taken
        // 2 -> email is taken
        return body.entries.first.key == 'username' ? 1 : 2;

      default:
        throw HttpException('_token_register_');
    }
  }

  Future<bool> verify() async {
    debugPrint('_token_verify_');

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

      dynamic body = jsonDecode(utf8.decode(response.bodyBytes));
      appInfo.setAccessToken(body['access']);
    }

    return true;
  }
}
