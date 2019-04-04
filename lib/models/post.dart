import 'package:aperture/models/topic.dart';
import 'package:aperture/models/user.dart';

class Post {
  int id;
  String title;
  String description;
  User user;
  String image;
  List<Topic> topics; // String???
  int ups;
  int downs;

  Post(
      {this.title,
        this.description,
        this.user,
        this.image,
        this.topics,
        this.ups,
        this.downs});

  Post.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    user = new User.fromJson(json['user'], true);
    image = json['image'];
    if (json['topics'] != null) {
      topics = new List<Topic>();
      json['topics'].forEach((v) {
        topics.add(new Topic.fromJson(v));
      });
    }
    /*ups = json['ups'];
    downs = json['downs'];*/
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['description'] = this.description;
    data['image'] = this.image;
    data['user'] = this.user.toJson();
    if (this.topics != null) {
      data['topics'] = this.topics.map((v) => v.toJson()).toList();
    }
    /*data['ups'] = this.ups;
    data['downs'] = this.downs;*/
    return data;
  }
}