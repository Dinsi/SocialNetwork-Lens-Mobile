import 'package:aperture/models/users/compact_user.dart';

class Comment {
  final int id;
  final CompactUser user;
  final String text;

  Comment(this.id, this.user, this.text);

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
        json['id'], CompactUser.fromJson(json['user']), json['text']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user'] = this.user.toJson();
    data['text'] = this.text;
    return data;
  }
}
