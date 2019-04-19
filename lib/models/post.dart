class Post {
  final int _id;
  final String _title;
  final String _description;
  final _User _user;
  final String _image;
  final int _width;
  final int _height;
  final int _votes;
  final int _userVote;
  final int _commentsLength;

  const Post(
      this._id,
      this._title,
      this._description,
      this._user,
      this._image,
      this._width,
      this._height,
      this._votes,
      this._userVote,
      this._commentsLength);

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        json['id'],
        json['title'],
        json['description'],
        _User.fromJson(json['user']),
        json['image'],
        json['width'],
        json['height'],
        json['votes'],
        json['user_vote'],
        json['comments_length']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    data['title'] = this._title;
    data['description'] = this._description;
    data['user'] = this._user.toJson();
    data['image'] = this._image;
    data['width'] = this._width;
    data['height'] = this._height;
    data['votes'] = this._votes;
    data['user_vote'] = this._userVote;
    data['comments_length'] = this._commentsLength;
    return data;
  }

  int get id => _id;
  String get title => _title;
  String get description => _description;
  _User get user => _user;
  String get image => _image;
  int get width => _width;
  int get height => _height;
  int get votes => _votes;
  int get userVote => _userVote;
  int get commentsLength => _commentsLength;
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
