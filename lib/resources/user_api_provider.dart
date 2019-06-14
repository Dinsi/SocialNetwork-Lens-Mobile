import 'dart:convert' show jsonDecode, jsonEncode, utf8;
import 'dart:io' show ContentType, HttpException, HttpHeaders, HttpStatus;
import 'dart:io';

import 'package:async/async.dart' show DelegatingStream;
import 'package:http/http.dart'
    show ByteStream, Client, MultipartFile, MultipartRequest;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:path/path.dart';

import 'base_provider.dart';
import '../models/users/user.dart';

class UserApiProvider extends BaseProvider {
  Client client = Client();

  Future<User> fetchInfo() async {
    print('_user_fetchInfo_');

    var response = await client.get('${super.baseUrl}users/self/', headers: {
      HttpHeaders.authorizationHeader: 'Bearer ${globals.accessToken}'
    });

    print('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      dynamic body = jsonDecode(response.body);
      await globals.setUserFromMap(body);
      return User.fromJson(body);
    }

    throw HttpException('_user_fetchInfo_');
  }

  Future<User> fetchInfoById(int userId) async {
    print('_user_fetchInfoById_');

    var response = await client.get('${super.baseUrl}users/$userId/', headers: {
      HttpHeaders.authorizationHeader: 'Bearer ${globals.accessToken}'
    });

    print('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      return User.fromJson(jsonDecode(response.body));
    }

    throw HttpException('_user_fetchInfoById_');
  }

  Future<int> finishRegister(List<int> desiredTopics) async {
    print('_user_finishRegister_');

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

    throw HttpException('_user_finishRegister_');
  }

  Future<int> updateEmail(Map<String, String> fields) async {
    print('_user_updateEmail_');

    var response = await client.post(
      '${super.baseUrl}users/update_email/',
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken,
        HttpHeaders.contentTypeHeader: ContentType.json.value,
      },
      body: jsonEncode(fields),
    );

    print('${response.statusCode.toString()}\n${response.body}');

    switch (response.statusCode) {
      case HttpStatus.ok:
        return 0;
      case HttpStatus.badRequest:
        return 1;
      default:
        throw HttpException('_user_updateEmail_');
    }
  }

  Future<int> updatePassword(Map<String, String> fields) async {
    print('_user_updatePassword_');

    var response = await client.post(
      '${super.baseUrl}users/update_password/',
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken,
        HttpHeaders.contentTypeHeader: ContentType.json.value,
      },
      body: jsonEncode(fields),
    );

    print('${response.statusCode.toString()}\n${response.body}');

    switch (response.statusCode) {
      case HttpStatus.ok:
        return 0;
      case HttpStatus.badRequest:
        return 1;
      default:
        throw HttpException('_user_updatePassword_');
    }
  }

  Future<int> patch(Map<String, String> fields) async {
    print('_user_patch_');

    var response = await client.patch(
      '${super.baseUrl}users/self/',
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken,
        HttpHeaders.contentTypeHeader: ContentType.json.value,
      },
      body: jsonEncode(fields),
    );

    print('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      await globals.setUserFromMap(jsonDecode(response.body));
      return 0;
    }

    throw HttpException('_user_patch_');
  }

  Future<int> patchMultiPart(File imageFile, Map<String, String> fields) async {
    print("_user_patchMultiPart_");

    ByteStream stream =
        new ByteStream(DelegatingStream.typed(imageFile.openRead()));
    int length = await imageFile.length();

    Uri uri = Uri.parse('${super.baseUrl}users/self/');

    MultipartRequest request = new MultipartRequest("PATCH", uri);
    MultipartFile multipartFile = new MultipartFile(
      'avatar',
      stream,
      length,
      filename: basename(imageFile.path),
      contentType: MediaType('image', imageFile.path.split(".").last),
    );
    request.files.add(multipartFile);

    if (fields != null) {
      request.fields.addAll(fields);
    }

    request.headers.addAll(
        {HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken});

    var response = await request.send();
    print(response.statusCode);

    if (response.statusCode == HttpStatus.ok) {
      response.stream.transform(utf8.decoder).listen((value) async {
        await globals.setUserFromMap(jsonDecode(value));
        print(value);
      });
      return 0;
    } //TODO assuming success

    throw HttpException('_user_patchMultiPart_');
  }
}
