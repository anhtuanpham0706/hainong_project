import 'package:hainong/common/util/util.dart';

class WeatherListModels {
  final List<WeatherListModel> list = [];

  WeatherListModels fromJson(json) {
    if (json != null && json.isNotEmpty) json.forEach((v) => list.add(WeatherListModel().fromJson(v)));
    return this;
  }
}

class WeatherListModel {
  int id,cityid,province_id;
  String created_at, update_at, delete_at;
  String name, lat, lng;
  bool selected;
  WeatherListModel({this.id = -1,
    this.cityid = -1,
    this.created_at = '',
    this.update_at = '',
    this.delete_at = '',
    this.name = '',
    this.province_id = -1,
    this.lat = '',
    this.lng = '',
  this.selected = false});
  WeatherListModel fromJson(Map<String, dynamic> json) {
    try {
      id = Util.getValueFromJson(json, 'id', -1);
      name = Util.getValueFromJson(json, 'name', '');
      cityid = Util.getValueFromJson(json, 'cityid', -1);
      created_at = Util.getValueFromJson(json, 'created_at', '');
      update_at = Util.getValueFromJson(json, 'update_at', '');
      delete_at = Util.getValueFromJson(json, 'detele_at', '');
      province_id = Util.getValueFromJson(json, 'province_id', -1);
      lat = Util.getValueFromJson(json, 'lat', '').toString();
      lng = Util.getValueFromJson(json, 'lng', '').toString();
    } catch (_) {}
    return this;
  }
}