import 'package:hainong/common/util/util.dart';

class ReceivePointsModel {
  final List<ReceivePointModel> list = [];
  ReceivePointsModel fromJson(json) {
    if (json.isNotEmpty) json.forEach((ele) => list.add(ReceivePointModel().fromJson(ele)));
    return this;
  }
}

class ReceivePointModel {
  int id, point_give,times_day;
  String event_name, created_at;
  int point_histories_count;
  ReceivePointModel({this.id = -1, this.point_give = 0, this.times_day = 0, this.event_name = '', this.created_at = '',this.point_histories_count = 0});
  ReceivePointModel fromJson(Map<String, dynamic> json) {
    id = Util.getValueFromJson(json, 'id', -1);
    point_give = Util.getValueFromJson(json, 'point_give', 0);
    times_day = Util.getValueFromJson(json, 'times_day', 0);
    event_name = Util.getValueFromJson(json, 'event_name', '');
    created_at = Util.getValueFromJson(json, 'created_at', '');
    point_histories_count = Util.getValueFromJson(json, 'point_histories_count', 0);
    return this;
  }
}
