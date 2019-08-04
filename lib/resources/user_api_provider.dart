import 'dart:convert' show jsonDecode, jsonEncode, utf8;
import 'dart:io' show ContentType, File, HttpException, HttpHeaders, HttpStatus;

import 'package:aperture/models/users/user.dart';
import 'package:aperture/resources/base_api_provider.dart';
import 'package:async/async.dart' show DelegatingStream;
import 'package:http/http.dart'
    show ByteStream, Client, MultipartFile, MultipartRequest;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:path/path.dart';

class UserApiProvider extends BaseApiProvider {
  Client client = Client();

  Future<User> fetchInfo() async {
    print('_user_fetchInfo_');

    final response = await client.get('${super.baseUrl}users/self/', headers: {
      HttpHeaders.authorizationHeader: 'Bearer ${appInfo.accessToken}'
    });

    print('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      dynamic body = jsonDecode(response.body);
      await appInfo.setUserFromMap(body);
      return User.fromJson(body);
    }

    throw HttpException('_user_fetchInfo_');
  }

  Future<User> fetchInfoById(int userId) async {
    print('_user_fetchInfoById_');

    final response = await client.get('${super.baseUrl}users/$userId/', headers: {
      HttpHeaders.authorizationHeader: 'Bearer ${appInfo.accessToken}'
    });

    print('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      return User.fromJson(jsonDecode(response.body));
    }

    throw HttpException('_user_fetchInfoById_');
  }

  Future<int> finishRegister(List<int> desiredTopics) async {
    print('_user_finishRegister_');

    final response = await client.post(
      '${super.baseUrl}users/finish_register/',
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken,
        HttpHeaders.contentTypeHeader: ContentType.json.value,
      },
      body: jsonEncode({'topics': desiredTopics}),
    );

    print('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      await appInfo.setUserFromMap(jsonDecode(response.body));
      return 0;
    }

    throw HttpException('_user_finishRegister_');
  }

  Future<int> updateEmail(Map<String, String> fields) async {
    print('_user_updateEmail_');

    final response = await client.post(
      '${super.baseUrl}users/update_email/',
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken,
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

    final response = await client.post(
      '${super.baseUrl}users/update_password/',
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken,
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

    final response = await client.patch(
      '${super.baseUrl}users/self/',
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken,
        HttpHeaders.contentTypeHeader: ContentType.json.value,
      },
      body: jsonEncode(fields),
    );

    print('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      await appInfo.setUserFromMap(jsonDecode(response.body));
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
        {HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken});

    final response = await request.send();
    print(response.statusCode);

    if (response.statusCode == HttpStatus.ok) {
      response.stream.transform(utf8.decoder).listen((value) async {
        await appInfo.setUserFromMap(jsonDecode(value));
        print(value);
      });
      return 0;
    } //TODO assuming success

    throw HttpException('_user_patchMultiPart_');
  }
}
