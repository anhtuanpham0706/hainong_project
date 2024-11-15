import 'package:hainong/common/constants.dart';
import 'package:hainong/common/util/util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Languages {
  String en = 'assets/json/en.json';
  String vi = 'assets/json/vi.json';
}

class MultiLanguage {
  static late Map<String, dynamic> _phrases;

  static Future<void> setLanguage({String lang = 'assets/json/vi.json', bool setEnv = false, bool setLogin = false}) async {
    var prefs = await SharedPreferences.getInstance();
    if (setEnv) Util.chooseEnv(prefs.getString('env')??'');
    if (setLogin) Constants().isLogin = prefs.getBool('is_login')??false;

    if (prefs.containsKey('lang') &&
        prefs.getString('lang')!.isNotEmpty) lang = prefs.getString('lang')??lang;

    var file = await rootBundle.loadString(lang);
    await prefs.setString('lang', lang);
    _phrases = jsonDecode(file);
  }

  static String get(String key) => _phrases.containsKey(key) ? _phrases[key]! : key;
}
