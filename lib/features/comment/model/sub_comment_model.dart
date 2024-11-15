import 'package:hainong/common/util/util.dart';

class SubCommentModel {
  int id;
  int rate;

  SubCommentModel({
    this.id = -1,
    this.rate = 0,
  });

  SubCommentModel fromJson(Map<String, dynamic> json) {
    try {
      id = Util.isNullFromJson(json, 'id') ? json['id'] : -1;
      rate = Util.isNullFromJson(json, 'rate') ? json['rate'] : 0;
    } catch(e) {
      return SubCommentModel();
    }
    return this;
  }
}
