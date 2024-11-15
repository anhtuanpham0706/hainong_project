import 'package:hainong/common/util/util.dart';

class FollowModel {
  bool is_followed;

  FollowModel({this.is_followed = false});

  FollowModel fromJson(json) {
    is_followed = Util.isNullFromJson(json, 'is_followed') ? json['is_followed'] : false;
    return this;
  }
}
