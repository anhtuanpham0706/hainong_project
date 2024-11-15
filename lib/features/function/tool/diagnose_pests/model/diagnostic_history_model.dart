import 'package:hainong/common/util/util.dart';

class DiagnosticHistoriesModel {
  final List<DiagnosticHistoryModel> list = [];
  DiagnosticHistoriesModel fromJson(json) {
    if (json.isNotEmpty)
      json.forEach((ele) => list.add(DiagnosticHistoryModel().fromJson(ele)));
    return this;
  }
}

class DiagnosticHistoryModel {
  double percent;
  String image, suggest, address, category_name, created_at,user_name;
  List<AiResults> ai_results = [];
  DiagnosticHistoryModel({this.percent=0.0,this.image='',this.created_at='',this.suggest='',this.address='',this.category_name='',this.user_name = ''});
  DiagnosticHistoryModel fromJson(Map<String, dynamic> json) {
    percent = Util.getValueFromJson(json, 'percent', 0.0);
    image = Util.getValueFromJson(json, 'image', '');
    suggest = Util.getValueFromJson(json, 'suggest', '');
    address = Util.getValueFromJson(json, 'address', '');
    category_name = Util.getValueFromJson(json, 'category_name', '');
    created_at = Util.getValueFromJson(json, 'created_at', '');
    user_name = Util.getValueFromJson(json, 'user_name', '');
    if (Util.checkKeyFromJson(json, 'ai_results')) json['ai_results'].forEach((ele) => ai_results.add(AiResults().fromJson(ele)));
    return this;
  }
}

class AiResults {
  double percent;
  String suggest,suggest_en,image;

  AiResults({this.percent=0.0,this.suggest='',this.suggest_en = '',this.image = ''});
  AiResults fromJson(Map<String, dynamic> json) {
    percent = Util.getValueFromJson(json, 'percent', 0.0);
    suggest = Util.getValueFromJson(json, 'suggest', '');
    suggest_en = Util.getValueFromJson(json, 'suggest_en', '');
    image = Util.getValueFromJson(json, 'image', '');
    return this;
  }
}

