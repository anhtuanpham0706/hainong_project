class User {
  int? id;
  String? name;
  String? image;

  User({this.id, this.name, this.image});

  User fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    id = json['name'] ?? '';
    id = json['image'] ?? '';
    return this;
  }
}
