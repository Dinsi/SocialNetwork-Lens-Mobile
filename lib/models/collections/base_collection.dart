abstract class BaseCollection {
  final int id;
  String name;
  int length;
  String cover;

  BaseCollection(this.id, this.name, this.length, this.cover);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['length'] = this.length;
    data['cover'] = this.cover;
    return data;
  }
}
