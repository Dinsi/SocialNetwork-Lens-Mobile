import 'package:aperture/models/collections/compact_collection.dart';
import 'package:aperture/models/topic.dart';
import 'package:aperture/models/users/compact_user.dart';

class User extends CompactUser {
  String firstName;
  String lastName;
  String email;
  bool isActive;
  bool isConfirmed;
  bool hasFinishedRegister;
  final List<Topic> topics;
  String headline;
  String location;
  String bio;
  String publicEmail;
  String website;
  final List<CompactCollection> collections;

  User(
      int id,
      String username,
      this.firstName,
      this.lastName,
      String name,
      this.email,
      this.isActive,
      this.isConfirmed,
      this.hasFinishedRegister,
      String avatar,
      this.topics,
      this.headline,
      this.location,
      this.bio,
      this.publicEmail,
      this.website,
      this.collections)
      : super(id, username, name, avatar);

  User.initial()
      : this.firstName = '',
        this.lastName = '',
        this.email = '',
        this.topics = null,
        this.headline = '',
        this.location = '',
        this.bio = '',
        this.publicEmail = '',
        this.website = '',
        this.collections = null,
        super(0, '', '', '');

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
    final Map<String, dynamic> data = super.toJson();
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['email'] = this.email;
    data['is_active'] = this.isActive;
    data['is_confirmed'] = this.isConfirmed;
    data['finished_register'] = this.hasFinishedRegister;
    data['topics'] = this.topics.map((v) => v.toJson()).toList();
    data['headline'] = this.headline;
    data['location'] = this.location;
    data['bio'] = this.bio;
    data['public_email'] = this.publicEmail;
    data['website'] = this.website;
    data['collections'] = this.collections.map((v) => v.toJson()).toList();
    return data;
  }

  static User from(User user) {
    return User(
        user.id,
        user.username,
        user.firstName,
        user.lastName,
        user.name,
        user.email,
        user.isActive,
        user.isConfirmed,
        user.hasFinishedRegister,
        user.avatar,
        user.topics,
        user.headline,
        user.location,
        user.bio,
        user.publicEmail,
        user.website,
        user.collections);
  }
}
