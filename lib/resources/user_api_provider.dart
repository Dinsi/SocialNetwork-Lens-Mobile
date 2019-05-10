import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:io' show ContentType, HttpException, HttpHeaders, HttpStatus;

import 'package:http/http.dart' show Client;

import 'base_provider.dart';
import '../models/user.dart';

class UserApiProvider extends BaseProvider {
  Client client = Client();

  Future<User> fetchInfo() async {
    print('fetchUserInfo');

    var response = await client.get('${super.baseUrl}users/self/', headers: {
      HttpHeaders.authorizationHeader: 'Bearer ${globals.accessToken}' 
    });

    if (response.statusCode == HttpStatus.ok) {
      print(response.body);
      dynamic body = jsonDecode(response.body);
      await globals.setUserFromMap(body);
      return User.fromJson(body);
    }

    throw HttpException('fetchUserInfo');
  }

  Future<int> finishRegister(List<int> desiredTopics) async {
    print('finishRegister');

    var response = await client.post(
      '${super.baseUrl}users/finish_register/',
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken,
        HttpHeaders.contentTypeHeader: ContentType.json.value,
      },
      body: jsonEncode({'topics': desiredTopics}),
    );

    print('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      await globals.setUserFromMap(jsonDecode(response.body));
      return 0;
    }

    throw HttpException('finishRegister');
  }
}
