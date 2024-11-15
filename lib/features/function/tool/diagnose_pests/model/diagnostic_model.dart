import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/util/util.dart';

class DiagnosticModel {
  final List<Diagnostic> diagnostics = [];
  final List<Summary> summaries = [];
  final Map<String, dynamic> tree = {};
  late List ids;
  DiagnosticModel fromJson(Map<String, dynamic> json) {
    if (Util.checkKeyFromJson(json, 'list')) json['list'].forEach((ele) => diagnostics.add(Diagnostic().fromJson(ele)));
    if (Util.checkKeyFromJson(json, 'summaries')) json['summaries'].forEach((ele) => summaries.add(Summary().fromJson(ele)));
    if (Util.checkKeyFromJson(json, 'category')) tree.addAll(json['category']);
    ids = Util.checkKeyFromJson(json, 'training_data_ids') ? json['training_data_ids'] : [];
    return this;
  }
}

class Diagnostic {
  final List<Summary> predicts = [];
  String item_id, message, image;
  Diagnostic({this.item_id = '', this.message = '', this.image = ''});
  Diagnostic fromJson(Map<String, dynamic> json) {
    bool success = Util.getValueFromJson(json, 'success', false);
    item_id = Util.getValueFromJson(json, 'item_id', '');
    image = Util.getValueFromJson(json, 'image', '');
    if (success) {
      if (Util.checkKeyFromJson(json, 'predict')) json['predict'].forEach((ele) => predicts.add(Summary().fromJson(ele)));
    } else message = Util.getValueFromJson(json, 'message', '');
    return this;
  }
}

class Summary {
  double percent;
  String suggest;
  ItemListModel images = ItemListModel();
  Summary({this.percent=0.0,this.suggest=''});
  Summary fromJson(Map<String, dynamic> json) {
    percent = Util.getValueFromJson(json, 'percent', 0.0);
    suggest = Util.getValueFromJson(json, 'suggest', '');
    if (Util.checkKeyFromJson(json, 'aidiagnostic_images')) {
      final temp = json['aidiagnostic_images'];
      if (temp.isNotEmpty) images.fromJson(temp);
    }
    return this;
  }
}