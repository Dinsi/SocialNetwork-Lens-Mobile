class Post {
  int id;
  String title;
  String description;
  _User user;
  String image;
  int width;
  int height;
  int votes;
  int userVote;
  int commentsLength;

  Post(
      this.id,
      this.title,
      this.description,
      this.user,
      this.image,
      this.width,
      this.height,
      this.votes,
      this.userVote,
      this.commentsLength);

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
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['user'] = this.user.toJson();
    data['image'] = this.image;
    data['width'] = this.width;
    data['height'] = this.height;
    data['votes'] = this.votes;
    data['user_vote'] = this.userVote;
    data['comments_length'] = this.commentsLength;
    return data;
  }
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
