class SearchResult {
  final int _id;
  final String _name;
  final int _type;
  final int _userId;

  const SearchResult(this._id, this._name, this._type, this._userId);

  int get id => _id;
  String get name => _name;
  int get type => _type;
  int get userId => _userId;

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
        json['id'], json['name'], json['type'], json['user_id']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    data['name'] = this._name;
    data['type'] = this._type;
    data['user_id'] = this._userId ?? null;
    return data;
  }
}
