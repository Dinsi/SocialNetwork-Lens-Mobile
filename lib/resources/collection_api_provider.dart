import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:io';

import 'package:aperture/models/collections/collection.dart';
import 'package:aperture/resources/base_provider.dart';
import 'package:http/http.dart';

class CollectionApiProvider extends BaseProvider {
  Client client = Client();

  Future<Collection> fetch(int collectionId) async {
    print('_collection_fetch_');

    var response = await client.get(
      '${super.baseUrl}collections/$collectionId/',
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken,
      },
    );

    print('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      //TODO only covers valid path
      return Collection.fromJson(jsonDecode(response.body));
    }

    throw HttpException('_collection_fetch_');
  }

  Future<Collection> appendPost(int collectionId, int postId) async {
    print('_collection_appendPost_');

    var response = await client.patch(
      '${super.baseUrl}collections/$collectionId/append/',
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken,
        HttpHeaders.contentTypeHeader: ContentType.json.value,
      },
      body: jsonEncode({'post': postId}),
    );

    print('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      //TODO only covers valid path
      return Collection.fromJson(jsonDecode(response.body));
    }

    throw HttpException('_collection_appendPost_');
  }

  Future<Collection> postNew(String collectionName) async {
    print('_collection_postNew_');

    var response = await client.post(
      '${super.baseUrl}collections/',
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken,
        HttpHeaders.contentTypeHeader: ContentType.json.value,
      },
      body: jsonEncode({'name': collectionName}),
    );

    print('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.created) {
      //TODO only covers valid path
      return Collection.fromJson(jsonDecode(response.body));
    }

    throw HttpException('_collection_postNew_');
  }
}
