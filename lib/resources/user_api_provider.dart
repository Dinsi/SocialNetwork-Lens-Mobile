import 'dart:convert' show jsonDecode, jsonEncode, utf8;
import 'dart:io' show ContentType, HttpException, HttpHeaders, HttpStatus;
import 'dart:io';

import 'package:async/async.dart' show DelegatingStream;
import 'package:http/http.dart'
    show ByteStream, Client, MultipartFile, MultipartRequest;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:path/path.dart';

import 'base_provider.dart';
import '../models/user.dart';

class UserApiProvider extends BaseProvider {
  Client client = Client();

  Future<User> fetchInfo() async {
    print('fetchInfo');

    var response = await client.get('${super.baseUrl}users/self/', headers: {
      HttpHeaders.authorizationHeader: 'Bearer ${globals.accessToken}'
    });

    print('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      dynamic body = jsonDecode(response.body);
      await globals.setUserFromMap(body);
      return User.fromJson(body);
    }

    throw HttpException('fetchInfo');
  }

  Future<User> fetchInfoById(int userId) async {
    print('fetchInfoById');

    var response = await client.get('${super.baseUrl}users/$userId/', headers: {
      HttpHeaders.authorizationHeader: 'Bearer ${globals.accessToken}'
    });

    print('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      return User.fromJson(jsonDecode(response.body));
    }

    throw HttpException('fetchInfoById');
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

  Future<int> patch(Map<String, String> fields) async {
    print('patch');

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

    throw HttpException('patch');
  }

  Future<int> patchMultiPart(File imageFile, Map<String, String> fields) async {
    print("patchMultiPart");

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

    throw HttpException('patchMultiPart');
  }
}
