import 'package:hainong/common/util/util.dart';


class AdvancePointModel {
  int current_point;
  int applied_point;
  int min_advance_point;

  AdvancePointModel({
    this.current_point = 0,
    this.applied_point = 0,
    this.min_advance_point = 0,
  });

  AdvancePointModel fromJson(json) {
    current_point = (Util.isNullFromJson(json, 'current_point') ? json['current_point'] : 0);
    applied_point = (Util.isNullFromJson(json, 'applied_point') ? json['applied_point'] : 0);
    min_advance_point = (Util.isNullFromJson(json, 'min_advance_point') ? json['min_advance_point'] : 0);
    return this;
  }

  void copy(AdvancePointModel value) {
    current_point = value.current_point;
    applied_point = value.applied_point;
    min_advance_point = value.min_advance_point;
  }
}
