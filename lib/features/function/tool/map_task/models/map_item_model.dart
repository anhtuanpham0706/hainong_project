import 'package:hainong/common/multi_language.dart';
import 'package:hainong/common/util/util.dart';

class MapItemModels {
  final List<MapItemModel> list = [];

  MapItemModels fromJson(json) {
    if (json != null && json.isNotEmpty) json.forEach((v) => list.add(MapItemModel().fromJson(v)));
    return this;
  }
}

class MapItemModel {
  String id, name, image, color;
  bool selected;
  dynamic options;
  MapItemModel({this.id = '', this.name = '', this.image = '', this.color = '', this.selected = false, this.options});

  MapItemModel fromJson(json, {String? keyName}) {
    id = Util.getValueFromJson(json, keyName ?? 'key', '');
    name = Util.getValueFromJson(json, keyName ?? 'name', '');
    image = Util.getValueFromJson(json, keyName ?? 'image', '');
    options = Util.getValueFromJson(json, keyName ?? 'options', '');
    return this;
  }

  void setValue({String id = '', String name = '', String image = '', String color = '', List<dynamic>? options}) {
    this.id = id;
    this.name = name;
    this.image = image;
    this.color = color;
    this.options = options;
  }

  MapItemModel copy({
    String? id,
    String? name,
    String? image,
    String? color,
    bool? selected,
    dynamic options,
  }) {
    return MapItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      color: color ?? this.color,
      selected: selected ?? this.selected,
      options: options ?? this.options,
    );
  }

  List<dynamic> getOptions() {
    if (options is List) {
      return (options as List).map((e) => e).toList();
    }
    return [];
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is MapItemModel && runtimeType == other.runtimeType && id == other.id && name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

class TreePetModel {
  final String name;
  List<TreeModel> children;
  TreePetModel(this.name, this.children);
}

class TreesModel {
  final List<TreeModel> list = [];
  final bool passUnknown;
  TreesModel({this.passUnknown = false});
  TreesModel fromJson(json) {
    if (json.isNotEmpty) json.forEach((ele) => list.add(TreeModel().fromJson(ele, passUnknown: passUnknown)));
    return this;
  }
}

class TreeModel extends PetModel {
  final List<PetModel> diagnostics = [];
  String icon;
  TreeModel({this.icon = '', String id = '', String name = '', bool selected = false}) : super(id: id, name: name, selected: selected);
  @override
  TreeModel fromJson(json, {String? keyName, bool passUnknown = false}) {
    id = Util.getValueFromJson(json, 'id', -1).toString();
    name = Util.getValueFromJson(json, 'name', '');
    icon = Util.getValueFromJson(json, 'icon', '');
    if (Util.isNullFromJson(json, 'diagnostics')) {
      json['diagnostics'].forEach((ele) {
        final item = PetModel().fromJson(ele);
        if (passUnknown || !item.name.toLowerCase().contains(MultiLanguage.get('lbl_unknown').toLowerCase())) diagnostics.add(item);
      });
    }
    return this;
  }
}

class PetModel {
  String id, name;
  String? image;
  bool selected;
  PetModel({this.id = '', this.name = '', this.image, this.selected = false});

  PetModel fromJson(json, {String? keyName}) {
    id = Util.getValueFromJson(json, 'id', -1).toString();
    name = Util.getValueFromJson(json, keyName ?? 'name_vi', '');
    image = Util.getValueFromJson(json, keyName ?? 'image', '');
    return this;
  }

  void setValue(String id, String name, {String? image}) {
    this.id = id;
    this.name = name;
    this.image = image;
  }
}
