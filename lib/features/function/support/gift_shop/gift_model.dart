import 'package:hainong/common/util/util.dart';

class GiftModels {
  final List<GiftModel> list = [];
  GiftModels fromJson(json) {
    if (json.isNotEmpty) json.forEach((ele) => list.add(GiftModel().fromJson(ele)));
    return this;
  }
}

class GiftModel {
  int id, classable_id,quantity,points,store_gift_catalogue_id,quantity_exchanged;
  String name, description, image, status, created_at, start_date, end_date, classable_type;
  GiftModel({this.id = -1, this.quantity = -1, this.name = '', this.image = '', this.classable_type = '', this.description = '',
    this.start_date = '', this.end_date = '', this.created_at = '',  this.status = '',this.classable_id = -1,
    this.points = -1,this.store_gift_catalogue_id = -1,this.quantity_exchanged = -1});
  GiftModel fromJson(Map<String, dynamic> json) {
    id = Util.getValueFromJson(json, 'id', -1);
    name = Util.getValueFromJson(json, 'name', '');
    description = Util.getValueFromJson(json, 'description', '');
    quantity = Util.getValueFromJson(json, 'quantity', -1);
    status = Util.getValueFromJson(json, 'status', '');
    points = Util.getValueFromJson(json, 'points', 0);
    start_date = Util.getValueFromJson(json, 'start_date', '');
    image = Util.getValueFromJson(json, 'image', '');
    created_at = Util.getValueFromJson(json, 'created_at', '');
    end_date = Util.getValueFromJson(json, 'end_date', '');
    classable_id = Util.getValueFromJson(json, 'classable_id', -1);
    classable_type = Util.getValueFromJson(json, 'classable_type', "");
    quantity_exchanged = Util.getValueFromJson(json, 'quantity_exchanged', -1);
    store_gift_catalogue_id = Util.getValueFromJson(json, 'store_gift_catalogue_id', -1);
    return this;
  }
}