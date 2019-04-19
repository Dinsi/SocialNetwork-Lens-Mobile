class User {
  final int _id;
  final String _username;
  final String _firstName;
  final String _lastName;
  final String _name;
  final String _email;
  final bool _isActive;
  final bool _isConfirmed;
  final String _avatar;
  final List<_Topic> _topics;

  User(
      this._id,
      this._username,
      this._firstName,
      this._lastName,
      this._name,
      this._email,
      this._isActive,
      this._isConfirmed,
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
        json['avatar'],
        (json['topics'] as List).isEmpty
            ? List<_Topic>()
            : setTopics((json['topics'] as List)));
  }

  static List<_Topic> setTopics(List topics) {
    List<_Topic> topicList = List<_Topic>(topics.length);
    for (int i = 0; i < topicList.length; i++) {
      topicList[i] = _Topic.fromJson(topics[i]);
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
  String get avatar => _avatar;
  List<_Topic> get topics => _topics;
}

class _Topic {
  final int id;
  final String name;
  final int type;

  _Topic(this.id, this.name, this.type);

  factory _Topic.fromJson(Map<String, dynamic> json) {
    return _Topic(json['id'], json['name'], json['type']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['type'] = this.type;
    return data;
  }
}
