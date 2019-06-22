import 'package:aperture/models/collections/compact_collection.dart';
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
  bool hasFinishedRegister;
  String avatar;
  final List<Topic> topics;
  String headline;
  String location;
  String bio;
  String publicEmail;
  String website;
  final List<CompactCollection> collections;

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
      this.website,
      this.collections);

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
          : (json['topics'] as List)
              .map((topic) => Topic.fromJson(topic))
              .toList(),
      json['headline'],
      json['location'],
      json['bio'],
      json['public_email'],
      json['website'],
      (json['collections'] as List).isEmpty
          ? List<CompactCollection>()
          : (json['collections'] as List)
              .map((topic) => CompactCollection.fromJson(topic))
              .toList(),
    );
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
    data['collections'] = this.collections.map((v) => v.toJson()).toList();
    return data;
  }
}
