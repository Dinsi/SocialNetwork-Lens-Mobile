import 'dart:async';
import 'dart:io' show File, HttpException, HttpHeaders, HttpStatus;
import 'dart:convert' show jsonDecode;

import 'package:async/async.dart';
import 'package:http/http.dart'
    show ByteStream, Client, MultipartFile, MultipartRequest;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' show Image, decodeImage;
import 'package:path/path.dart';

import '../models/post.dart';
import 'base_provider.dart';

class PostApiProvider extends BaseProvider {
  Client client = Client();

  Future<List<Post>> fetchList(int lastPostId) async {
    print("fetchPostList");
    return await fetchPosts("${super.baseUrl}feed/${(lastPostId != null ? "?after=$lastPostId" : "")}");
  }

  Future<List<Post>> fetchListByTopic(int lastPostId, String topic) async {
    print("fetchPostListByTopic");
    return await fetchPosts("${super.baseUrl}topics/$topic/feed/${(lastPostId != null ? "?after=$lastPostId" : "")}"); 
  }

  Future<List<Post>> fetchPosts(String uri) async {
    final response = await client.get(uri, headers: {
      HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken
    });

    print(response.body.toString());

    if (response.statusCode == HttpStatus.ok) {
      if (response.body.isEmpty) {
        return List<Post>();
      }

      List<dynamic> body = (jsonDecode(response.body) as List);
      List<Post> posts = List<Post>(body.length);
      for (int i = 0; i < body.length; i++) {
        posts[i] = Post.fromJson(body[i]);
      }

      return posts;
    } else {
      // If that call was not successful, throw an error.
      throw HttpException('fetchPosts');
    }
  }

  Future<Post> fetchSingle(int postId) async {
    print("fetchSinglePost");
    final response = await client.get("${super.baseUrl}posts/$postId/",
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken
        });

    print(response.body.toString());

    if (response.statusCode == HttpStatus.ok) {
      dynamic body = jsonDecode(response.body);
      return Post.fromJson(body);
    } else {
      // If that call was not successful, throw an error.
      throw HttpException('fetchSinglePost');
    }
  }

  Future<int> uploadPost(
      File imageFile, String title, String description) async {
    //TODO verifyToken();

    print("uploadPost");

    ByteStream stream =
        new ByteStream(DelegatingStream.typed(imageFile.openRead()));
    int length = await imageFile.length();

    Uri uri = Uri.parse('${super.baseUrl}posts/');

    MultipartRequest request = new MultipartRequest("POST", uri);
    MultipartFile multipartFile = new MultipartFile(
      'image',
      stream,
      length,
      filename: basename(imageFile.path),
      contentType: MediaType('image', imageFile.path.split(".").last),
    );
    request.files.add(multipartFile);

    Image image = decodeImage(imageFile.readAsBytesSync());
    request.fields.addAll({
      'title': title,
      'description': description,
      'width': image.width.toString(),
      'height': image.height.toString(),
    });

    request.headers.addAll(
        {HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken});

    var response = await request.send();
    /*print(response.statusCode);
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });*/

    if (response.statusCode == HttpStatus.created) {
      return 0;
    }

    throw HttpException('uploadPost'); //TODO add more errors as necessary
  }

  Future<int> changeVote(int postId, String change) async {
    print(change);

    var response = await client.post('${super.baseUrl}posts/$postId/$change/',
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ' + globals.accessToken
        });

    print(response.body + response.statusCode.toString());

    if (response.statusCode == HttpStatus.ok) {
      return 0;
    }

    throw HttpException(change);
  }
}
