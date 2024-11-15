import 'package:hainong/common/util/util.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../features/function/module_model.dart';

class DBHelper {
  static DBHelper? _instance;
  Future<Database>? db;

  DBHelper._() {
    getDatabasesPath().then((path) {
      db = openDatabase(join(path, '2nong.db'), version: 8, onCreate: (dataB, version) async {
        _addSetting(dataB);
        _upgradeAds(dataB);
        _addModules(dataB);
        return _addBanners(dataB);
        //return _addCoupons(dataB);
      }, onUpgrade: (dataB, oldV, newV) async {
        if (newV == 5) {
          _addSetting(dataB);
          return _upgradeAds(dataB);
        }
        if (newV == 8) {
          _addSetting(dataB);
          _upgradeAds(dataB);
          _addModules(dataB);
          return _addBanners(dataB);
        }
        /*if (newV == ?) { //build 1.0.?
          _addSetting(dataB);
          _upgradeAds(dataB);
          _addModules(dataB);
          _addBanners(dataB);
          return _addCoupons(dataB);
        }*/
      });
    });
  }

  factory DBHelper() => _instance!;

  static void initDB() => _instance ??= DBHelper._();

  Future<void> _addSetting(Database dataB) async {
    return dataB.execute('CREATE TABLE IF NOT EXISTS setting ('
        'id TEXT PRIMARY KEY,'
        'value TEXT);');
  }

  Future<void> _upgradeAds(Database dataB) {
    dataB.execute('DROP TABLE IF EXISTS ads');
    return dataB.execute('CREATE TABLE IF NOT EXISTS ads5 ('
        'id INTEGER PRIMARY KEY,'
        'is_view INTEGER,'
        'is_use INTEGER,'
        'popup_type INTEGER,'
        'image TEXT,'
        'name TEXT,'
        'description TEXT,'
        'show_position TEXT,'
        'classable_type TEXT,'
        'classable_id INTEGER,'
        'display_order INTEGER);');
  }

  Future<void> _addModules(Database dataB) async {
    return dataB.execute('CREATE TABLE IF NOT EXISTS module ('
        'app_type TEXT PRIMARY KEY,'
        'group_type TEXT,'
        'group_name TEXT,'
        'name TEXT,'
        'status TEXT,'
        'icon TEXT);');
  }

  Future<void> _addBanners(Database dataB) async {
    return dataB.execute('CREATE TABLE IF NOT EXISTS banner ('
        'id INTEGER PRIMARY KEY,'
        'name TEXT,'
        'description TEXT,'
        'image TEXT,'
        'show_position TEXT,'
        'order_ban INTEGER,'
        'is_use INTEGER,'
        'is_view INTEGER,'
        'classable_type TEXT,'
        'classable_id INTEGER,'
        'location TEXT);');
  }

  /*Future<void> _addCoupons(Database dataB) async {
    return dataB.execute('CREATE TABLE IF NOT EXISTS coupon ('
        'id INTEGER PRIMARY KEY,'
        'coupon_code TEXT,'
        'value REAL,'
        'max_value REAL,'
        'min_invoice_value REAL,'
        'invoice_users_percent REAL,'
        'coupon_type TEXT,'
        'start_date TEXT,'
        'end_date TEXT,'
        'classable_type TEXT,'
        'classable_id INTEGER,'
        'image TEXT);');
  }*/

  Future<int> _insert(String tblName, {dynamic objModel, Map<String, dynamic>? values, ConflictAlgorithm conflict = ConflictAlgorithm.replace}) async {
    if (db == null) return -1;
    final temp = await db!;
    if (objModel != null) {
      return temp.insert(objModel.getTblName(), objModel.toJson(), conflictAlgorithm: conflict);
    } else if (values != null) {
      return temp.insert(tblName, values, conflictAlgorithm: conflict);
    }
    return -1;
  }

  Future<int> insertHelper({String tblName = '', dynamic objModel, Map<String, dynamic>? values, ConflictAlgorithm conflict = ConflictAlgorithm.replace}) =>
    _insert(tblName, objModel: objModel, values: values, conflict: conflict);

  Future<int> _update(String tblName, String fieldName, dynamic value, {dynamic objModel, Map<String, dynamic>? values}) async {
    try {
      if (db == null) return -1;
      final temp = await db!;
      if (objModel != null) {
        return temp.update(objModel.getTblName(), objModel.toJson(), where: ' $fieldName = ? ', whereArgs: [value]).catchError((e) => -1).onError((error, stackTrace) => -1);
      } else if (values != null) {
        return temp.update(tblName, values, where: ' $fieldName = ? ', whereArgs: [value]).catchError((e) => -1).onError((error, stackTrace) => -1);
      }
    } catch(_) {}
    return -1;
  }

  Future<int> updateHelper(String fieldName, dynamic value, {String tblName = '', dynamic objModel,
    Map<String, dynamic>? values}) => _update(tblName, fieldName, value, objModel: objModel, values: values);

  Future<int> _delete(String tblName, String fieldName, dynamic value) async {
    if (db == null) return -1;
    final temp = await db!;
    return temp.delete(tblName, where: ' $fieldName = ? ', whereArgs: [value]).catchError((e) {
      return -1;
    }).onError((error, stackTrace) {
      return -1;
    });
  }

  Future<int> deleteHelper(String fieldName, dynamic value, String tblName) => _delete(tblName, fieldName, value);

  Future<List<dynamic>> getAllModelWithCond(dynamic objModel, {String? orderBy, String? cond, int? limit, int? offset, bool isNew = true}) async {
    List<dynamic> list = [];
    if (db == null) return list;
    final temp = await db!;
    final query = await temp.query(objModel.getTblName(), orderBy: orderBy, where: cond, limit: limit, offset: offset);
    for (var ele in query) {
      list.add(objModel.fromJson(ele, isSQL: true, isNew: isNew));
    }
    return list;
  }

  Future<List<dynamic>?> getAllJsonWithCond(String tblName, {String? orderBy, String? cond, int? limit, int? offset}) async {
    try {
      if (db == null) return null;
      final temp = await db!;
      return temp.query(tblName, orderBy: orderBy, where: cond, limit: limit, offset: offset);
    } catch (_) {}
    return null;
  }

  Future<dynamic> getModelById(String fieldName, int id, dynamic objModel) async {
    if (db == null) return objModel;
    final temp = await db!;
    final query = await temp.query(objModel.getTblName(), where: '$fieldName = ?', whereArgs: [id]);
    if (query.isNotEmpty) objModel.fromJson(query.first, isSQL: true);
    return objModel;
  }

  Future<dynamic> getJsonById(String fieldName, dynamic id, String tblName) async {
    try {
      if (db == null) return null;
      final temp = await db!;
      final query = await temp.query(tblName, where: '$fieldName = ?', whereArgs: [id]);
      if (query.isNotEmpty) return query.first;
    } catch (_) {}
    return null;
  }

  Future<void> clearDB() async {
    if (db == null) return;
    await (await db!).delete('ads5');
    await (await db!).delete('setting');
    await (await db!).delete('module');
    //await (await db!).delete('coupon');
    return;
  }

  Future<void> clearTable(String table) async {
    if (db == null) return;
    await (await db!).delete(table);
    return;
  }
}

class DBHelperUtil {
  DBHelperUtil();

  Future<bool> setLogFile() async {
    bool isOn = true;
    try {
      final db = DBHelper();
      final values = await db.getJsonById('id', 'log_file', 'setting');
      if (values == null || values.isEmpty) {
        db.insertHelper(tblName: 'setting', values: {'id': 'log_file', 'value': 'on'});
      } else {
        isOn = values['value'] == 'on';
        db.updateHelper('id', 'log_file', tblName: 'setting', values: {'id': 'log_file', 'value': isOn ? 'off' : 'on'});
        isOn = !isOn;
      }
    } catch (_) {}
    return isOn;
  }

  Future<bool> hasLogFile() async {
    bool isOn = false;
    try {
      final values = await DBHelper().getJsonById('id', 'log_file', 'setting');
      if (values != null && values.isNotEmpty) isOn = values['value'] == 'on';
    } catch (_) {}
    return isOn;
  }

  Future<bool> isSwipeLeft() async {
    bool isOn = true;
    final db = DBHelper();
    final values = await db.getJsonById('id', 'news_swipe_left', 'setting');
    if (values == null || values.isEmpty) {
      db.insertHelper(tblName: 'setting', values: {'id': 'news_swipe_left', 'value': 'off'});
    } else {
      isOn = false;
    }
    return isOn;
  }

  Future<void> clearAdsModule() async {
    DBHelper().clearTable('ads5');
    DBHelper().clearTable('module');
    DBHelper().clearTable('banner');
  }

  Future<void> setModule(newValues) async {
    try {
      final db = DBHelper();
      final values = await db.getJsonById('app_type', newValues['app_type'], 'module');
      if (values == null || values.isEmpty) {
        db.insertHelper(tblName: 'module', values: newValues);
      } else {
        db.updateHelper('app_type', newValues['app_type'], tblName: 'module', values: newValues);
      }
    } catch (_) {}
  }

  Future<ModuleModels?> getModules() async {
    final list = await DBHelper().getAllModelWithCond(ModuleModel());
    if (list.isNotEmpty) {
      final modules = ModuleModels();
      final Map<String, Map<String, ModuleModel>> listTemp = {};
      for(ModuleModel item in list) {
        if (!listTemp.containsKey(item.group_type)) listTemp.putIfAbsent(item.group_type, () => {});
        listTemp[item.group_type]!.update(item.app_type, (value) => item, ifAbsent: () => item);
        modules.list2.putIfAbsent(item.app_type, () => item);
      }
      modules.list.addAll(listTemp.values);
      return modules;
    }
    return null;
  }

  /*Future<void> setCoupon(newValues) async {
    try {
      final db = DBHelper();
      db.clearTable('coupon');
      db.insertHelper(tblName: 'coupon', values: newValues);
    } catch (_) {}
  }*/

  Future<bool> showIgnorePhonePopup() async {
    bool isIgnore = true;
    try {
      final values = await DBHelper().getJsonById('id', 'ignore_phone_popup', 'setting');
      if (values != null && values.isNotEmpty) {
        final DateTime now = DateTime.now();
        final DateTime temp = DateTime(now.year, now.month, now.day);
        return temp.compareTo(Util.stringToDateTime(values['value']??'0001-01-01', pattern: 'yyyy-MM-dd')) > 0;
      }
    } catch (_) {}
    return isIgnore;
  }

  Future<void> setIgnorePhonePopup(String value) async {
    try {
      final db = DBHelper();
      final values = await db.getJsonById('id', 'ignore_phone_popup', 'setting');
      if (values == null || values.isEmpty) {
        db.insertHelper(tblName: 'setting', values: {'id': 'ignore_phone_popup', 'value': value});
      } else {
        db.updateHelper('id', 'ignore_phone_popup', tblName: 'setting', values: {'value': value});
      }
    } catch (_) {}
  }
}