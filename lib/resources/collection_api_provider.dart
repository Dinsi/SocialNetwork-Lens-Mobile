import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:io';

import 'package:aperture/models/collections/collection.dart';
import 'package:aperture/resources/base_api_provider.dart';
import 'package:flutter/widgets.dart' show debugPrint;
import 'package:http/http.dart';

class CollectionApiProvider extends BaseApiProvider {
  Client client = Client();

  Future<Collection> fetch(int collectionId) async {
    debugPrint('_collection_fetch_');

    final response = await client.get(
      '${super.baseUrl}collections/$collectionId/',
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken,
      },
    );

    debugPrint('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      return Collection.fromJson(jsonDecode(response.body));
    }

    throw HttpException('_collection_fetch_');
  }

  Future<Collection> appendPost(int collectionId, int postId) async {
    debugPrint('_collection_appendPost_');

    final response = await client.patch(
      '${super.baseUrl}collections/$collectionId/append/',
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken,
        HttpHeaders.contentTypeHeader: ContentType.json.value,
      },
      body: jsonEncode({'post': postId}),
    );

    debugPrint('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      return Collection.fromJson(jsonDecode(response.body));
    }

    throw HttpException('_collection_appendPost_');
  }

  Future<Collection> postNew(String collectionName) async {
    debugPrint('_collection_postNew_');

    final response = await client.post(
      '${super.baseUrl}collections/',
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken,
        HttpHeaders.contentTypeHeader: ContentType.json.value,
      },
      body: jsonEncode({'name': collectionName}),
    );

    debugPrint('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.created) {
      return Collection.fromJson(jsonDecode(response.body));
    }

    throw HttpException('_collection_postNew_');
  }

  Future<int> bulkDelete(List<int> collectionIdList) async {
    debugPrint('_collection_bulkDelete_');

    final response = await client.post(
      '${super.baseUrl}collections/bulkdelete/',
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken,
        HttpHeaders.contentTypeHeader: ContentType.json.value,
      },
      body: jsonEncode({'collections': collectionIdList}),
    );

    debugPrint('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      return 0;
    }

    throw HttpException('_collection_bulkDelete_');
  }

  Future<int> bulkPostRemove(int collectionId, List<int> postIdList) async {
    debugPrint('_collection_bulkPostRemove_');

    final response = await client.post(
      '${super.baseUrl}collections/$collectionId/bulkremove/',
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + appInfo.accessToken,
        HttpHeaders.contentTypeHeader: ContentType.json.value,
      },
      body: jsonEncode({'posts': postIdList}),
    );

    debugPrint('${response.statusCode.toString()}\n${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      return 0;
    }

    throw HttpException('_collection_bulkPostRemove_');
  }
}
