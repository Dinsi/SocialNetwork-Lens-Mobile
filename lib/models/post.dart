import 'package:aperture/models/topic.dart';
import 'package:aperture/models/user.dart';

class Post {
  int id;
  String title;
  String description;
  User user;
  String image;
  List<Topic> topics; // String???
  int votes;
  int width;
  int height;
  int userVote;
  int commentsLength;

  Post(
      {this.id,
      this.title,
      this.description,
      this.user,
      this.image,
      this.topics,
      this.votes,
      this.width,
      this.height,
      this.userVote,
      this.commentsLength});

  factory Post.fromJson(Map<String, dynamic> json) {
    return new Post(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        user: new User.fromJson(json['user'], true),
        image: json['image'],
        topics: () {
          if (json['topics'] != null) {
            List<Topic> topicsList = new List<Topic>();
            json['topics'].forEach((v) {
              topicsList.add(new Topic.fromJson(v));
            });
            return topicsList;
          }
          return new List<Topic>();
        }(),
        votes: json['votes'],
        width: json['width'],
        height: json['height'],
        userVote: json['user_vote'],
        commentsLength: json['comments_length']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['image'] = this.image;
    data['user'] = this.user.toJson();
    if (this.topics != null) {
      data['topics'] = this.topics.map((v) => v.toJson()).toList();
    }
    data['image'] = this.image;
    data['votes'] = this.votes;
    data['width'] = this.width;
    data['height'] = this.height;
    data['user_vote'] = this.userVote;
    data['comments_length'] = this.commentsLength;
    return data;
  }
}
