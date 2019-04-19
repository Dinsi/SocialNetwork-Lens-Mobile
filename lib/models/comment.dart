class Comment {
  final int _id;
  final _User _user;
  final String _text;

  Comment(this._id, this._user, this._text);

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
        json['id'], _User.fromJson(json['user']), json['text']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    data['user'] = this._user.toJson();
    data['text'] = this._text;
    return data;
  }

  int get id => _id;
  _User get user => _user;
  String get text => _text;
}


class _User {
  final int _id;
  final String _username;
  final String _name;
  final String _avatar;

  _User(this._id, this._username, this._name, this._avatar);

  factory _User.fromJson(Map<String, dynamic> json) {
    return _User(json['id'], json['username'], json['name'], json['avatar']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    data['username'] = this._username;
    data['name'] = this._name;
    data['avatar'] = this._avatar;
    return data;
  }

  int get id => _id;
  String get username => _username;
  String get name => _name;
  String get avatar => _avatar;
}
