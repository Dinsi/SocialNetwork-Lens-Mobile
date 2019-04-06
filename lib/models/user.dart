import 'package:aperture/models/topic.dart';

class User {
  int id;
  String username;
  String firstName;
  String lastName;
  String name;
  String email;
  bool isActive;
  bool isConfirmed;
  String avatar;
  List<Topic> topics;

  User(
      {this.id = 0,
      this.username,
      this.firstName,
      this.lastName,
      this.name,
      this.email,
      this.isActive,
      this.isConfirmed,
      this.avatar,
      this.topics});

  User.fromJson(Map<String, dynamic> json, bool feed) {
    if (!feed) {
      firstName = json['first_name'];
      lastName = json['last_name'];
      email = json['email'];
      isActive = json['is_active'];
      isConfirmed = json['is_confirmed'];
      if (json['topics'] != null) {
        topics = new List<Topic>();
        json['topics'].forEach((v) {
          topics.add(new Topic.fromJson(v));
        });
      }
    }

    id = json['id'];
    username = json['username'];
    name = json['name'];
    avatar = json['avatar'];
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
    data['avatar'] = this.avatar;
    if (this.topics != null) {
      data['topics'] = this.topics.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
