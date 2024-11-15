import 'package:hainong/common/database_helper.dart';
import 'package:hainong/common/util/util.dart';

class ModuleModels {
  final List<Map<String, ModuleModel>> list = [];
  final Map<String, ModuleModel> list2 = {};

  ModuleModels();

  clear() {
    list.clear();
    list2.clear();
  }

  setAll(ModuleModels value) {
    list.addAll(value.list);
    list2.addAll(value.list2);
  }

  ModuleModels fromJson(json) {
    if (json.isNotEmpty) {
      final db = DBHelperUtil();
      DBHelper().updateHelper('status', 'show', tblName: 'module', values: {'status': ''});

      final Map<String, Map<String, ModuleModel>> listTemp = {};
      ModuleModel temp;
      json.forEach((ele) {
        temp = ModuleModel().fromJson(ele);

        if (!listTemp.containsKey(temp.group_type)) listTemp.putIfAbsent(temp.group_type, () => {});
        listTemp[temp.group_type]!.update(temp.app_type, (value) => temp, ifAbsent: () => temp);

        list2.putIfAbsent(temp.app_type, () => temp);

        db.setModule({
          'app_type': temp.app_type,
          'group_type': temp.group_type,
          'group_name': temp.group_name,
          'name': temp.name,
          'icon': temp.icon,
          'status': Util.getValueFromJson(ele, 'status', ''),
        });
      });

      if (listTemp.isNotEmpty) list.addAll(listTemp.values);
    }
    return this;
  }
}

class ModuleModel {
  String group_type, app_type, icon, group_name, name;
  bool status;
  String getTblName() => 'module';
  ModuleModel({
    this.app_type = '',
    this.group_type = '',
    this.group_name = '',
    this.name = '',
    this.icon = '',
    this.status = false
  });
  ModuleModel fromJson(Map<String, dynamic> json, {bool isSQL = false, bool isNew = false}) {
    group_type = Util.getValueFromJson(json, 'group_type', '');
    group_name = Util.getValueFromJson(json, 'group_name', '');
    name = Util.getValueFromJson(json, 'name', '');
    app_type = Util.getValueFromJson(json, 'app_type', '');
    icon = Util.getValueFromJson(json, 'icon', '');
    status = Util.getValueFromJson(json, 'status', '') == 'show';
    return isNew ? ModuleModel(app_type: app_type, group_type: group_type, group_name: group_name, name: name, status: status, icon: icon) : this;
  }
  String toString() => '\n\napp_type: $app_type'
      '\ngroup_type: $group_type'
      '\ngroup_name: $group_name'
      '\nname: $name'
      '\nicon: $icon'
      '\nstatus: $status';
}