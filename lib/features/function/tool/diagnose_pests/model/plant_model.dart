import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/multi_language.dart';
import 'package:hainong/common/util/util.dart';

class PlantsModel {
  final List<PlantModel> list = [];
  final bool passUnknown;
  PlantsModel({this.passUnknown = false});
  PlantsModel fromJson(json) {
    if (json.isNotEmpty) json.forEach((ele) => list.add(PlantModel().fromJson(ele, passUnknown: passUnknown)));
    return this;
  }
}

class PlantModel extends ItemModel {
  final List<ItemModel> diagnostics = [];
  String icon;
  PlantModel({this.icon = '', String id = '', String name = '', bool selected = false}) : super(id: id, name: name, selected: selected);
  @override
  PlantModel fromJson(json, {String? keyName, bool passUnknown = false}) {
    id = Util.getValueFromJson(json, 'id', -1).toString();
    name = Util.getValueFromJson(json, 'name', '');
    icon = Util.getValueFromJson(json, 'icon', '');
    if (Util.isNullFromJson(json, 'diagnostics')) {
      json['diagnostics'].forEach((ele) {
        final item = ItemModel().fromJson(ele, keyName: 'name_vi');
        if (passUnknown || !item.name.toLowerCase().contains(MultiLanguage.get('lbl_unknown').toLowerCase())) diagnostics.add(item);
      });}
    return this;
  }
}