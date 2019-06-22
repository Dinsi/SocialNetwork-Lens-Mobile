import 'package:aperture/models/collections/base_collection.dart';

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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['posts'] = this.posts;
    return data;
  }
}
