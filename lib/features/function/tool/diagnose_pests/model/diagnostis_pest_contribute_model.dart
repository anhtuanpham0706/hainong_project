import 'package:hainong/common/util/util.dart';

class DiagnostisPestContributeModel {
  int? id;
  int? user_id;
  String? title;
  String? content;
  String? created_at;
  String? updated_at;

  DiagnostisPestContributeModel({
    this.id,
    this.user_id,
    this.title,
    this.content,
    this.created_at,
    this.updated_at,
  });

  DiagnostisPestContributeModel fromJson(Map<String, dynamic> json) {
    id = Util.getValueFromJson(json, 'id', 0);
    user_id = Util.getValueFromJson(json, 'user_id', '');
    title = Util.getValueFromJson(json, 'title', '');
    content = Util.getValueFromJson(json, 'content', '');
    created_at = Util.getValueFromJson(json, 'created_at', '');
    updated_at = Util.getValueFromJson(json, 'updated_at', '');
    return this;
  }
}
