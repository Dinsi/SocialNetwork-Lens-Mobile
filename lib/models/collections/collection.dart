import 'package:aperture/models/collections/base_collection.dart';
import 'package:aperture/models/post.dart';

class Collection extends BaseCollection {
  final List<Post> posts;

  Collection(
      int id, String name, int length, String cover, this.posts)
      : super(id, name, length, cover);

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      json['id'],
      json['name'],
      json['length'],
      json['cover'],
      (json['posts'] as List).isEmpty
          ? List<Post>()
          : (json['posts'] as List).map((post) => Post.fromJson(post)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['posts'] = this.posts.map((v) => v.toJson()).toList();
    return data;
  }
}
