import 'package:hainong/common/util/util.dart';
import 'package:hainong/features/comment/model/sub_comment_model.dart';

class TechProCatsModel {
  final List<TechProCatModel> list = [];
  final String keyName;
  TechProCatsModel({this.keyName = 'name'});
  TechProCatsModel fromJson(json) {
    if (json.isNotEmpty) json.forEach((ele) => list.add(TechProCatModel().fromJson(ele, keyName: keyName)));
    return this;
  }
}

class TechProCatModel {
  String id = '', name = '', fullName = '', image = '', parent_id = '';
  TechProCatModel({this.name = '',this.id =''});
  TechProCatModel fromJson(Map<String, dynamic> json, {String keyName = 'name'}) {
    id = Util.getValueFromJson(json, 'id', '').toString();
    name = Util.getValueFromJson(json, keyName, '');
    image = Util.getValueFromJson(json, 'image', '');
    parent_id = Util.getValueFromJson(json, 'parent_id', '');
    return this;
  }
}

class TechnicalProcessesModel {
  final List<TechnicalProcessModel> list = [];
  TechnicalProcessesModel fromJson(json) {
    if (json.isNotEmpty) json.forEach((ele) => list.add(TechnicalProcessModel().fromJson(ele)));
    return this;
  }
}

class TechnicalProcessModel {
  int rate = 0;
  String title, content, image, created_at ,summary, id, classable_type, catalogue_name = '';
  SubCommentModel comment = SubCommentModel();
  TechnicalProcessModel({this.title = '', this.image = '', this.content = '', this.created_at = '',this.summary = '', this.id = '-1', this.classable_type = '', this.catalogue_name = ''});
  TechnicalProcessModel fromJson(Map<String, dynamic> json) {
    title = Util.getValueFromJson(json, 'title', '');
    content = Util.getValueFromJson(json, 'content', '');
    created_at = Util.getValueFromJson(json, 'created_at', '');
    image = Util.getValueFromJson(json, 'image', '');
    summary = Util.getValueFromJson(json, 'summary', '');
    id = Util.getValueFromJson(json, 'id', '-1').toString();
    classable_type = Util.getValueFromJson(json, 'classable_type', '');
    catalogue_name = Util.getValueFromJson(json, 'technical_process_catalogue_name', '');
    rate = Util.getValueFromJson(json, 'rate', .0).toInt();
    if (Util.isNullFromJson(json, 'comment')) comment.fromJson(json['comment']);
    return this;
  }

  void copy(TechnicalProcessModel value) {
    comment.id = value.comment.id;
    comment.rate = value.comment.rate;
  }
}
enum TypeTech{
  main, subMain, subProcess
}