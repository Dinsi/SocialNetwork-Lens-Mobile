class CompactUser {
  final int id;
  final String username;
  final String name;
  final String avatar;

  CompactUser(this.id, this.username, this.name, this.avatar);

  factory CompactUser.fromJson(Map<String, dynamic> json) {
    return CompactUser(
        json['id'], json['username'], json['name'], json['avatar']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    data['name'] = this.name;
    data['avatar'] = this.avatar;
    return data;
  }
}
