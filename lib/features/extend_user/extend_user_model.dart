import 'package:hainong/common/util/util.dart';

class ListAppExtendUserModel {
  final List<AppExtendUserModel> list = [];

  ListAppExtendUserModel fromJson(json) {
    if (json != null && json.isNotEmpty) json.forEach((v) => list.add(AppExtendUserModel().fromJson(v)));
    return this;
  }
}
class AppExtendUserModel {
  int id;
  String name;
  String dateUpdate;

  AppExtendUserModel({this.id = -1, this.name = '', this.dateUpdate = ''});

  AppExtendUserModel fromJson(json) {
    try {
      id = Util.getValueFromJson(json, 'id', -1);
      name = Util.getValueFromJson(json, 'app_session_name', '');
      dateUpdate = Util.getValueFromJson(json, 'updated_at', '');
    } catch (_) {}
    return this;
  }
}

enum TypeFlowData{
  Floor1,
  Floor2,
  Floor3,
}
