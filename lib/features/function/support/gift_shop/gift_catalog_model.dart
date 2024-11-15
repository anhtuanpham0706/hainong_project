import 'package:hainong/common/util/util.dart';

class GiftCatalogModels {
  final List<GiftCatalogModel> list = [];
  GiftCatalogModels fromJson(json) {
    if (json.isNotEmpty) json.forEach((ele) => list.add(GiftCatalogModel().fromJson(ele)));
    return this;
  }
}

class GiftCatalogModel {
  int id,order;
  String image,fullname,status,slug,name;

  GiftCatalogModel({this.id = -1,this.order = -1,this.fullname = '',this.status = ''
   ,this.slug = '' ,this.image = '',this.name = ''});

  GiftCatalogModel fromJson(Map<String, dynamic> json) {
    id = Util.getValueFromJson(json, 'id', -1);
    name = Util.getValueFromJson(json, 'name', "");
    order = Util.getValueFromJson(json, 'order', -1);
    image = Util.getValueFromJson(json, 'image', "");
    fullname = Util.getValueFromJson(json, 'fullname', "");
    status = Util.getValueFromJson(json, 'status', "");
    slug = Util.getValueFromJson(json, 'slug', "");
    return this;
  }
}