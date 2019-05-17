import 'topic.dart';

class User {
  int id;
  String username;
  String firstName;
  String lastName;
  String name;
  String email;
  bool isActive;
  bool isConfirmed;
  bool hasFinishedRegister;
  String avatar;
  final List<Topic> topics;
  String headline;
  String location;
  String bio;
  String publicEmail;
  String website;

  User(
      this.id,
      this.username,
      this.firstName,
      this.lastName,
      this.name,
      this.email,
      this.isActive,
      this.isConfirmed,
      this.hasFinishedRegister,
      this.avatar,
      this.topics,
      this.headline,
      this.location,
      this.bio,
      this.publicEmail,
      this.website);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        json['id'],
        json['username'],
        json['first_name'],
        json['last_name'],
        json['name'],
        json['email'],
        json['is_active'],
        json['is_confirmed'],
        json['finished_register'],
        json['avatar'],
        (json['topics'] as List).isEmpty
            ? List<Topic>()
            : setTopics((json['topics'] as List)),
        json['headline'],
        json['location'],
        json['bio'],
        json['public_email'],
        json['website']);
  }

  static List<Topic> setTopics(List topics) {
    List<Topic> topicList = List<Topic>();
    topics.forEach((topic) => topicList.add(Topic.fromJson(topic)));
    return topicList;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['name'] = this.name;
    data['email'] = this.email;
    data['is_active'] = this.isActive;
    data['is_confirmed'] = this.isConfirmed;
    data['finished_register'] = this.hasFinishedRegister;
    data['avatar'] = this.avatar;
    data['topics'] = this.topics.map((v) => v.toJson()).toList();
    data['headline'] = this.headline;
    data['location'] = this.location;
    data['bio'] = this.bio;
    data['public_email'] = this.publicEmail;
    data['website'] = this.website;
    return data;
  }
}
