class MenuItemMap {
  int id;
  String image;
  String name;
  String value;
  String color;

  MenuItemMap({this.id = -1, this.image = '', this.name = '', this.value = '', this.color = "#FFFFFF"});

  void setValue({int id = -1, String name = '', String image = '', String value = '', String color = ''}) {
    this.id = id;
    this.name = name;
    this.image = image;
    this.value = value;
    this.color = color;
  }

  MenuItemMap copy({
    int? id,
    String? name,
    String? image,
    String? value,
    String? color,
  }) {
    return MenuItemMap(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      value: color ?? this.value,
      color: color ?? this.color,
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is MenuItemMap && runtimeType == other.runtimeType && id == other.id && name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

class ColorItemMap {
  int id;
  String name;
  String value;
  String value2;
  String color;
  ColorItemMap({this.id = -1, this.name = '', this.value = '', this.value2 = '', this.color = "#FFFFFF"});
}
