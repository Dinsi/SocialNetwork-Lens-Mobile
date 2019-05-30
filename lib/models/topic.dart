class Topic {
  final int id;
  final String name;
  final int type;

  Topic(this.id, this.name, this.type);

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(json['id'], json['name'], json['type']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['type'] = this.type;
    return data;
  }

  @override
  String toString() {
    return name;
  }
}
