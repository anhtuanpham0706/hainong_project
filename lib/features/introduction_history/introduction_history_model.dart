

import 'package:hainong/common/util/util.dart';

class IntroductionHistoryModel {
  int total_points;
  final List modified_list = [];
  IntroductionHistoryModel({this.total_points = 0});

  IntroductionHistoryModel fromJson(Map<String, dynamic> json) {
    total_points = Util.getValueFromJson(json, 'total_points', 0);
    if (Util.isNullFromJson(json, 'modified_list')) {
      json['modified_list'].forEach((ele) => modified_list.add(ele));
    }
    return this;
  }

  IntroductionHistoryModel copy(IntroductionHistoryModel value) {
    total_points = value.total_points;
    modified_list.addAll(value.modified_list);
    return this;
  }
}