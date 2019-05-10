import 'topic.dart';

class User {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String name;
  final String email;
  final bool isActive;
  final bool isConfirmed;
  final bool hasFinishedRegister;
  final String avatar;
  final List<Topic> topics;

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
      this.topics);

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
            : setTopics((json['topics'] as List)));
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
    return data;
  }
}
