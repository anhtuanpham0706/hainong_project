import 'package:hainong/common/util/util.dart';

class BadReportModels {
  final List<BadReportModel> list = [];
  BadReportModels fromJson(json) {
    if (json.isNotEmpty) json.forEach((ele) => list.add(BadReportModel().fromJson(ele)));
    return this;
  }
}

class BadReportModel {
  int id = -1, userId = -1, objId = -1;
  String content = '', created_at = '', reason = '', name = '', image = '', type = 'comment', classable_type = '';

  BadReportModel fromJson(Map<String, dynamic> json) {
    id = Util.getValueFromJson(json, 'id', -1);
    created_at = Util.getValueFromJson(json, 'created_at', '');
    reason = Util.getValueFromJson(json, 'reason', '');
    classable_type = Util.getValueFromJson(json, 'classable_type', '');
    if (Util.checkKeyFromJson(json, 'warningable')) {
      objId = Util.getValueFromJson(json['warningable'], 'id', -1);
      content = Util.getValueFromJson(json['warningable'], 'content', '');
      String temp = Util.getValueFromJson(json['warningable'], 'classable_type', '');
      if (temp == 'SubComment') objId = Util.getValueFromJson(json['warningable'], 'comment_id', -1);
    }
    if (Util.checkKeyFromJson(json, 'post')) {
      objId = Util.getValueFromJson(json['post'], 'id', -1);
      content = Util.getValueFromJson(json['post'], 'title', '');
      type = 'post';
    }
    if (Util.checkKeyFromJson(json, 'user')) {
      userId = Util.getValueFromJson(json['user'], 'id', -1);
      name = Util.getValueFromJson(json['user'], 'name', '');
      image = Util.getValueFromJson(json['user'], 'image', '');
    }
    return this;
  }
}