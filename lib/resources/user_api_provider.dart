import 'dart:convert' show jsonDecode, jsonEncode, utf8;
import 'dart:io' show ContentType, File, HttpException, HttpHeaders, HttpStatus;

import 'package:aperture/models/users/user.dart';
import 'package:aperture/resources/base_api_provider.dart';
import 'package:aperture/view_models/edit_profile.dart';
import 'package:async/async.dart' show DelegatingStream;
import 'package:http/http.dart'
    show ByteStream, Client, MultipartFile, MultipartRequest;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:flutter/widgets.dart' show debugPrint;
import 'package:path/path.dart';

class UserApiProvider extends BaseApiProvider {
  Client client = Client();

  Future<User> fetchInfo() async {
    debugPrint('_user_fetchInfo_');

    final response = await client.get('${super.baseUrl}users/self/', headers: {
      HttpHeaders.authorizationHeader: 'Bearer ${appInfo.accessToken}'
    });

    debugPrint('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      dynamic body = jsonDecode(response.body);
      await appInfo.setUserFromMap(body);
      return User.fromJson(body);
    }

    throw HttpException('_user_fetchInfo_');
  }

  Future<User> fetchInfoById(int userId) async {
    debugPrint('_user_fetchInfoById_');

    final response = await client.get('${super.baseUrl}users/$userId/',
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ${appInfo.accessToken}'
        });

    debugPrint('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      return User.fromJson(jsonDecode(response.body));
    }

    throw HttpException('_user_fetchInfoById_');
  }

  Future<int> finishRegister(List<int> desiredTopics) async {
    debugPrint('_user_finishRegister_');

    final response = await client.post(
      '${super.baseUrl}users/finish_register/',
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken,
        HttpHeaders.contentTypeHeader: ContentType.json.value,
      },
      body: jsonEncode({'topics': desiredTopics}),
    );

    debugPrint('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      await appInfo.setUserFromMap(jsonDecode(response.body));
      return 0;
    }

    throw HttpException('_user_finishRegister_');
  }

  Future<int> updateEmail(String email, String password) async {
    debugPrint('_user_updateEmail_');

    final Map<String, String> fields = {
      'email': email,
      'password': password,
    };

    final response = await client.post(
      '${super.baseUrl}users/update_email/',
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken,
        HttpHeaders.contentTypeHeader: ContentType.json.value,
      },
      body: jsonEncode(fields),
    );

    debugPrint('${response.statusCode.toString()}\n${response.body}');

    switch (response.statusCode) {
      case HttpStatus.ok:
        return 0;
      case HttpStatus.badRequest:
        return 1;
      default:
        throw HttpException('_user_updateEmail_');
    }
  }

  Future<int> updatePassword(String oldPassword, String newPassword,
      String confirmationPassword) async {
    debugPrint('_user_updatePassword_');

    final Map<String, String> fields = {
      'password': oldPassword,
      'new_password': newPassword,
      'new_password_confirm': confirmationPassword,
    };

    final response = await client.post(
      '${super.baseUrl}users/update_password/',
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken,
        HttpHeaders.contentTypeHeader: ContentType.json.value,
      },
      body: jsonEncode(fields),
    );

    debugPrint('${response.statusCode.toString()}\n${response.body}');

    switch (response.statusCode) {
      case HttpStatus.ok:
        return 0;
      case HttpStatus.badRequest:
        return 1;
      default:
        throw HttpException('_user_updatePassword_');
    }
  }

  Future<int> patch(Map<EditProfileField, String> fields) async {
    debugPrint('_user_patch_');

    final Map<String, String> stringFields = _getStringFields(fields);

    final response = await client.patch(
      '${super.baseUrl}users/self/',
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken,
        HttpHeaders.contentTypeHeader: ContentType.json.value,
      },
      body: jsonEncode(stringFields),
    );

    debugPrint('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      await appInfo.setUserFromMap(jsonDecode(response.body));
      return 0;
    }

    throw HttpException('_user_patch_');
  }

  Future<int> patchMultiPart(
      File imageFile, Map<EditProfileField, String> fields) async {
    debugPrint("_user_patchMultiPart_");

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
      Map<String, String> stringFields = _getStringFields(fields);
      request.fields.addAll(stringFields);
    }

    request.headers.addAll(
        {HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken});

    final response = await request.send();
    debugPrint(response.statusCode.toString());

    if (response.statusCode == HttpStatus.ok) {
      response.stream.transform(utf8.decoder).listen((value) async {
        await appInfo.setUserFromMap(jsonDecode(value));
        debugPrint(value);
      });
      return 0;
    }

    throw HttpException('_user_patchMultiPart_');
  }

  Map<String, String> _getStringFields(Map<EditProfileField, String> fields) {
    final Map<String, String> stringFields = {};

    fields.forEach((fieldType, value) {
      switch (fieldType) {
        case EditProfileField.FirstName:
          stringFields['first_name'] = fields[fieldType];
          break;
        case EditProfileField.LastName:
          stringFields['last_name'] = fields[fieldType];
          break;
        case EditProfileField.Headline:
          stringFields['headline'] = fields[fieldType];
          break;
        case EditProfileField.Location:
          stringFields['location'] = fields[fieldType];
          break;
        case EditProfileField.Bio:
          stringFields['bio'] = fields[fieldType];
          break;
        case EditProfileField.PublicEmail:
          stringFields['public_email'] = fields[fieldType];
          break;
        case EditProfileField.Website:
          stringFields['website'] = fields[fieldType];
      }
    });

    return stringFields;
  }
}
