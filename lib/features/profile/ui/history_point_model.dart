import 'package:hainong/features/profile/point_bloc.dart';
import 'package:hainong/common/util/util.dart';

class HistoryPointModel {
  int current_points,total_points;
  final List<PointModel> modified_list = [];
  HistoryPointModel({this.current_points = 0,this.total_points = 0});

  HistoryPointModel fromJson(Map<String, dynamic> json) {
    current_points = Util.getValueFromJson(json, 'current_points', 0);
    total_points = Util.getValueFromJson(json, 'total_points', 0);
    if (Util.isNullFromJson(json, 'modified_list')) {
      json['modified_list'].forEach((ele) => modified_list.add(PointModel().fromJson(ele)));
    }
    return this;
  }

  HistoryPointModel copy(HistoryPointModel value) {
    current_points = value.current_points;
    total_points = value.total_points;
    modified_list.addAll(value.modified_list);
    return this;
  }
}