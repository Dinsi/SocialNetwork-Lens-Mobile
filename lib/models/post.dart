import 'package:aperture/models/topic.dart';
import 'package:aperture/models/users/compact_user.dart';

class Post {
  int id;
  String title;
  String description;
  CompactUser user;
  String image;
  int width;
  int height;
  int votes;
  int userVote;
  int commentsLength;
  Topic location;

  Post(
      this.id,
      this.title,
      this.description,
      this.user,
      this.image,
      this.width,
      this.height,
      this.votes,
      this.userVote,
      this.commentsLength,
      this.location);

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      json['id'],
      json['title'],
      json['description'],
      CompactUser.fromJson(json['user']),
      json['image'],
      json['width'],
      json['height'],
      json['votes'],
      json['user_vote'],
      json['comments_length'],
      json['location'] == null ? null : Topic.fromJson(json['location']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['user'] = this.user.toJson();
    data['image'] = this.image;
    data['width'] = this.width;
    data['height'] = this.height;
    data['votes'] = this.votes;
    data['user_vote'] = this.userVote;
    data['comments_length'] = this.commentsLength;
    data['location'] = this.location.toJson();
    return data;
  }
}
