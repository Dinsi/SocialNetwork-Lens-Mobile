class SearchResult {
  final int id;
  final String name;
  final int type;
  final int userId;

  SearchResult(this.id, this.name, this.type, this.userId);

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
        json['id'], json['name'], json['type'], json['user_id']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['type'] = this.type;
    data['user_id'] = this.userId ?? null;
    return data;
  }
}
