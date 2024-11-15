import 'package:hainong/common/util/util.dart';

class CataloguesModel {
  final bool removeSub;
  final List<CatalogueModel> list = [];
  CataloguesModel({this.removeSub = true});
  CataloguesModel fromJson(json) {
    if (json.isNotEmpty) {
      json.forEach((ele) {
        final temp = CatalogueModel(hasSub: !removeSub).fromJson(ele);
        if (removeSub) {
          if (temp.isParent) list.add(temp);
        } else list.add(temp);
      });
    }
    return this;
  }
}

class CatalogueModel {
  int id;
  String name;
  bool isParent, hasSub, expanded, selected;
  List<CatalogueModel>? subList;
  CatalogueModel({this.id = -1, this.name = '', this.isParent = true, this.hasSub = true,
    this.expanded = false, this.selected = false});

  CatalogueModel fromJson(Map<String, dynamic> json) {
    id = Util.getValueFromJson(json, 'id', -1);
    name = Util.getValueFromJson(json, 'name', '');
    isParent = Util.getValueFromJson(json, 'parent_id', '').toString().isEmpty;
    return this;
  }
}