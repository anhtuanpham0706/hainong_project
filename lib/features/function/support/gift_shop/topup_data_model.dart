import 'package:hainong/common/util/util.dart';

class TopUpModels {
  final List<TopUpModel> list = [];
  TopUpModels fromJson(json) {
    if (json.isNotEmpty) json.forEach((ele) => list.add(TopUpModel().fromJson(ele)));
    return this;
  }
}

class TopUpModel {
  int id, point,amount;
  String image,created_at, updated_at,capacity,carrier;
  TopUpModel({this.id = -1,this.capacity = "",this.carrier = '',this.image = '',
    this.updated_at = '',this.created_at = '',
    this.point = -1,this.amount = -1});
  TopUpModel fromJson(Map<String, dynamic> json) {
    id = Util.getValueFromJson(json, 'id', -1);
    capacity = Util.getValueFromJson(json, 'capacity', '');
    carrier = Util.getValueFromJson(json, 'carrier', '');
    point = Util.getValueFromJson(json, 'point', -1);
    created_at = Util.getValueFromJson(json, 'created_at', '');
    updated_at = Util.getValueFromJson(json, 'updated_at', '');
    amount = Util.getValueFromJson(json, 'amount', -1);
    image = Util.getValueFromJson(json, 'image', '');
    return this;
  }
}