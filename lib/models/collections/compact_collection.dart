import 'package:aperture/models/collections/base_collection.dart';
import 'package:aperture/models/collections/collection.dart';

class CompactCollection extends BaseCollection {
  final List<int> posts;

  CompactCollection(int id, String name, int length, String cover, this.posts)
      : super(id, name, length, cover);

  factory CompactCollection.fromJson(Map<String, dynamic> json) {
    return CompactCollection(
      json['id'],
      json['name'],
      json['length'],
      json['cover'],
      (json['posts'] as List).isEmpty
          ? List<int>()
          : (json['posts'] as List).cast<int>(),
    );
  }

  factory CompactCollection.fromCollection(Collection data) {
    return CompactCollection(
      data.id,
      data.name,
      data.length,
      data.cover,
      data.posts.isEmpty ? List() : data.posts.map((post) => post.id).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['posts'] = this.posts;
    return data;
  }
}
