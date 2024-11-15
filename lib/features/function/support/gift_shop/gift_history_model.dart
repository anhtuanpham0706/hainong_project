import 'package:hainong/common/util/util.dart';
import 'gift_model.dart';

class GiftHistoryModels {
  final List<GiftHistoryModel> list = [];
  GiftHistoryModels fromJson(json) {
    if (json.isNotEmpty) json.forEach((ele) => list.add(GiftHistoryModel().fromJson(ele)));
    return this;
  }
}

class GiftHistoryModel {
  int id, user_id,points,store_id,classable_id;
  String status, store_type,created_at, classable_type,gift_name,image;
  late GiftModel gift_info;
  GiftHistoryModel({this.id = -1, this.classable_type = '',this.user_id = -1,this.status = '',this.store_type ='',
     this.created_at = '',this.classable_id = -1,
    this.points = -1,this.store_id =-1,this.gift_name = '',this.image = ''}) {
    gift_info = GiftModel();
  }
  GiftHistoryModel fromJson(Map<String, dynamic> json) {
    id = Util.getValueFromJson(json, 'id', -1);
    user_id = Util.getValueFromJson(json, 'user_id', -1);
    status = Util.getValueFromJson(json, 'status', '');
    points = Util.getValueFromJson(json, 'points', 0);
    store_type = Util.getValueFromJson(json, 'store_type', '');
    store_id = Util.getValueFromJson(json, 'store_id', -1);
    created_at = Util.getValueFromJson(json, 'created_at', '');
    classable_id = Util.getValueFromJson(json, 'classable_id', -1);
    classable_type = Util.getValueFromJson(json, 'classable_type', "");
    gift_name = Util.getValueFromJson(json, 'gift_name', "");
    image = Util.getValueFromJson(json, 'image', "");
    if (Util.isNullFromJson(json, 'gift_info')) gift_info.fromJson(json['gift_info']);
    return this;
  }
}