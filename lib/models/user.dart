import 'package:aperture/models/topic.dart';

class User {
  final int _id;
  final String _username;
  final String _firstName;
  final String _lastName;
  final String _name;
  final String _email;
  final bool _isActive;
  final bool _isConfirmed;
  final bool _finishedRegister;
  final String _avatar;
  final List<Topic> _topics;

  User(
      this._id,
      this._username,
      this._firstName,
      this._lastName,
      this._name,
      this._email,
      this._isActive,
      this._isConfirmed,
      this._finishedRegister,
      this._avatar,
      this._topics);

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
    List<Topic> topicList = List<Topic>(topics.length);
    for (int i = 0; i < topicList.length; i++) {
      topicList[i] = Topic.fromJson(topics[i]);
    }

    return topicList;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    data['username'] = this._username;
    data['first_name'] = this._firstName;
    data['last_name'] = this._lastName;
    data['name'] = this._name;
    data['email'] = this._email;
    data['is_active'] = this._isActive;
    data['is_confirmed'] = this._isConfirmed;
    data['finished_register'] = this._finishedRegister;
    data['avatar'] = this._avatar;
    data['topics'] = this._topics.map((v) => v.toJson()).toList();
    return data;
  }

  int get id => _id;
  String get username => _username;
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get name => _name;
  String get email => _email;
  bool get isActive => _isActive;
  bool get isConfirmed => _isConfirmed;
  bool get hasFinishedRegister => _finishedRegister;
  String get avatar => _avatar;
  List<Topic> get topics => _topics;
}
