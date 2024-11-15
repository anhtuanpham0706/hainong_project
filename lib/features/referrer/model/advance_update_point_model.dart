import 'package:hainong/common/util/util.dart';


class AdvanceUpdatePointModel {
  int id;
  int point;
  int pointable_id;

  AdvanceUpdatePointModel({
    this.id = 0,
    this.point = 0,
    this.pointable_id = 0,
  });

  AdvanceUpdatePointModel fromJson(json) {
    id = (Util.isNullFromJson(json, 'id') ? json['id'] : 0);
    point = (Util.isNullFromJson(json, 'point') ? json['point'] : 0);
    pointable_id = (Util.isNullFromJson(json, 'pointable_id') ? json['pointable_id'] : 0);
    return this;
  }
}
