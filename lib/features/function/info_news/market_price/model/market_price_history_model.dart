import 'package:hainong/common/util/util.dart';

class MkPHistoriesModel {
  final List<MkPHistoryModel> list = [];
  MkPHistoriesModel fromJson(json, {String title = ''}) {
    if (json.isNotEmpty) json.forEach((ele) => list.add(MkPHistoryModel().fromJson(ele, title: title)));
    return this;
  }
}

class MkPHistoryModel {
  String created_at = '', updated_at = '', deleted_at ='';
  double price = .0, min_price = .0, max_price = .0, price_difference =.0;
  int provinceId = 0,districtId = 0, created_at2 = 0;
  String title = '' ,user_name = '',agricultural_type = '' ,unit = '';
  int market_place_id = 0, id = 0;
  MkPHistoryModel({this.created_at2 = 0});
  MkPHistoryModel fromJson(Map<String, dynamic> json, {String title = ''}) {
    this.title = title;
    created_at = Util.getValueFromJson(json, 'created_at', '');
    if (created_at.isNotEmpty) created_at2 = Util.stringToDateTime(created_at).millisecondsSinceEpoch;
    updated_at = Util.getValueFromJson(json, 'updated_at', '');
    deleted_at = Util.getValueFromJson(json, 'deleted_at', '');
    agricultural_type = Util.getValueFromJson(json, 'agricultural_type', '');
    price = Util.getValueFromJson(json, 'price', .0);
    min_price = Util.getValueFromJson(json, 'min_price', .0);
    max_price = Util.getValueFromJson(json, 'max_price', .0);
    price_difference = Util.getValueFromJson(json, 'price_difference', .0);
    market_place_id = Util.getValueFromJson(json, 'market_place_id', 0);
    id = Util.getValueFromJson(json, 'id', 0);
    user_name = Util.getValueFromJson(json, 'user_name', '');
    unit = Util.getValueFromJson(json, 'unit', '');
    return this;
  }
}