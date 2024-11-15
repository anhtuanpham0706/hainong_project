import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart' as path;
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:hainong/features/cart/cart_model.dart';
import 'package:hainong/features/shop/shop_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hainong/common/api_client.dart';
import 'package:hainong/features/product/repository/product_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../constants.dart';
import '../multi_language.dart';

class Util {
  static Util? _instance;
  Util._();
  factory Util() {
    _instance ??= Util._();
    return _instance!;
  }

  Future<void> logFile(String content) async {
    try {
      Directory? folder;
      if (Platform.isIOS)
        folder = await path.getApplicationDocumentsDirectory();
      else folder = await DownloadsPathProvider.downloadsDirectory;

      final file = File(folder!.path + '/log_app_2nong_${Util.dateToString(DateTime.now(), pattern: 'dd_MM_yyyy_HH')}.txt');
      file.writeAsStringSync(content, mode: FileMode.append, flush: true);
    } catch (_) {}
  }

  static Future<ShopModel> getShop() => SharedPreferences.getInstance().then((prefs) {
      final Constants constants = Constants();
      final ShopModel shop = ShopModel();
      shop.id = prefs.getInt(constants.shopId)??-1;
      shop.hidden_phone = prefs.getInt(constants.shopHiddenPhone)??0;
      shop.hidden_email = prefs.getInt(constants.shopHiddenEmail)??0;
      shop.hide_toolbar = prefs.getInt(constants.shopHideToolbar)??0;
      shop.member_rate = prefs.getString('member_rate')??'';
      shop.user_level = prefs.getString('user_level')??'';
      shop.name = prefs.getString(constants.shopName)??'';
      shop.email = prefs.getString(constants.shopEmail)??'';
      shop.phone = prefs.getString(constants.shopPhone)??'';
      shop.address = prefs.getString('shop_address')??'';
      shop.province_id = prefs.getString(constants.shopProvinceId)??'';
      shop.province_name = prefs.getString(constants.shopProvinceName)??'';
      shop.district_id = prefs.getString(constants.shopDistrictId)??'';
      shop.district_name = prefs.getString(constants.shopDistrictName)??'';
      shop.website = prefs.getString(constants.shopWebsite)??'';
      shop.facebook = prefs.getString(constants.shopFacebook)??'';
      shop.description = prefs.getString(constants.shopDescription)??'';
      shop.shop_star = prefs.getInt(constants.shopStar)??0;
      shop.image = prefs.getString(constants.shopImage)??'';
      shop.background_image = prefs.getString('shop_background_image')??'';
      return shop;
  });

  static Map<int, CartModel> getCarts(SharedPreferences prefs) {
    String temp = prefs.getString('carts')??'';
    if (temp.isNotEmpty) {
      try {
        final json = jsonDecode(temp);
        if (json.isNotEmpty) {
          Map<int, CartModel> list = {};
          CartModel item;
          json.forEach((ele) {
            item = CartModel().fromJson(ele);
            list.putIfAbsent(item.shop_id, () => item);
          });
          return list;
        }
      } catch(_) {}
    }
    return {};
  }

  static void addCart(CartModel shop, CartDtlModel item, Map<int, CartModel> list, bool append) async {
    final prefs = await SharedPreferences.getInstance();
    if (list.isEmpty) list.addAll(getCarts(prefs));

    int id = shop.shop_id;
    if (!list.containsKey(id)) list.putIfAbsent(id, () => shop);

    if (item.quantity == 0) {
      list[id]!.items.removeWhere((ele) => ele.product_id == item.product_id);
      if (list[id]!.items.isEmpty) list.remove(id);
    } else {
      final items = list[id]!.items.where((ele) => (ele.product_id == item.product_id) && (ele.referral_code == item.referral_code));
      if (items.length == 1) {
        append ? items.first.quantity += item.quantity : items.first.quantity = item.quantity;
      } else {
        list[id]!.items.add(item);
      }
    }

    prefs.setString('carts', jsonEncode(list.values.toList()));
  }

  static double reducePrice(CartDtlModel item){
    double perPrice = (item.price * item.coupon_per_item) / 100;
    double discountPrice = item.discount_level;
    if(discountPrice <= perPrice){
      return discountPrice;
    }else{
      return perPrice;
    }
  }

  String formatNum(num value) {
    final array = value.toString().split('.');
    if (array.length == 2) {
      int rest = int.parse(array[1]);
      if (rest == 0) return Util.doubleToString(value < 1000 ? (value as double) : (value as double)/1000) + (value < 1000 ? '' : 'K');
    }
    return '';
  }

  String formatNum2(double num, {int digit = 0}) {
    String title = '';
    double count = 0;
    int digit2 = digit;
    if (num > 0) {
      if (num > 999999999999999999) {
        count = num/1000000000000000000;
        title = 'BB';
      } else if (num > 999999999999999) {
        count = num/1000000000000000;
        title = 'MB';
      } else if (num > 999999999999) {
        count = num/1000000000000;
        title = 'KB';
      } else if (num > 999999999) {
        count = num/1000000000;
        title = 'B';
      } else if (num > 999999) {
        count = num/1000000;
        title = 'M';
      } else if (num > 999) {
        count = num/1000;
        title = 'K';
      } else {
        digit2 = 0;
        count = num;
      }
      String temp = Util.doubleToString(count, digit: digit2);
      try {
        final arr = temp.split(',');
        if (arr.length == 2 && double.parse(arr[1]) == 0) temp = arr[0];
      } catch (_) {}
      return temp + title;
    }
    return '';
  }

  static void chooseEnv(String value) {
    switch(value) {
      case 'dev':
        Constants().domain = 'https://dev.hainong.vn';
        Constants().baseUrl = 'https://dev.panel.hainong.vn';
        Constants().baseUrlImage = 'https://dev.panel.hainong.vn';
        Constants().baseUrlIPortal = 'https://dev.id.hainong.vn';
        break;
      case 'staging':
        Constants().domain = 'https://staging.hainong.vn';
        Constants().baseUrl = 'https://staging.panel.hainong.vn';
        Constants().baseUrlImage = 'https://staging.panel.hainong.vn';
        Constants().baseUrlIPortal = 'https://staging.id.hainong.vn';
        break;
      case 'uat':
        Constants().domain = 'https://uat.hainong.vn';
        Constants().baseUrl = 'https://uat.panel.hainong.vn';
        Constants().baseUrlImage = 'https://uat.panel.hainong.vn';
        Constants().baseUrlIPortal = 'https://uat.id.hainong.vn';
        break;
      default:
        Constants().domain = 'https://hainong.vn';
        Constants().baseUrl = 'https://admin.hainong.vn';
        Constants().baseUrlImage = 'https://admin.hainong.vn';
        Constants().baseUrlIPortal = 'https://agrid.vn';
    }
  }

  static String getRealPath(String url) {
    bool hasDomain = url.contains('http://') || url.contains('https://');
    return hasDomain ? url : Constants().baseUrlImage + url;
  }

  static Future<void> trackActivities(String function, {String path = '', String method = 'onTap'}) async {
    ApiClient().trackApp(path, function, method: method);
  }

  static bool isImage(String url) => url.contains('.jpg') ||
      url.contains('.jpeg') ||
      url.contains('.png') ||
      url.contains('.gif') ||
      url.contains('.ico') ||
      url.contains('.svg');

  static bool isNullFromJson(json, String key) =>
      json.containsKey(key) && json[key] != null;

  static bool checkKeyFromJson(json, String key) =>
      json.containsKey(key) && json[key] != null && json.isNotEmpty;

  static dynamic getValueFromJson(json, String key, dynamic defaultValue) =>
      json.containsKey(key) && json[key] != null ? json[key] : defaultValue;

  static List<String> createHashTags(String str) {
    List<String> hashTags = [];
    List<String> array = str.trim().split(' ');
    if (array.isNotEmpty) {
      for (int i = array.length - 1; i > -1; i--)
        if (array[i].contains('#')) {
          List<String> tmp = array[i].split('#');
          if (tmp.isNotEmpty) hashTags.add(tmp[tmp.length - 1]);
        }
    }
    return hashTags;
  }

  static String strDateToString(String value, {String pattern = 'HH:mm dd/MM/yyyy'}) {
    final date = stringToDateTime(value);
    return dateToString(date, locale: Constants().localeVI, pattern: pattern);
  }

  static List<ItemModel> getUserTypeOption() {
    final List<ItemModel> list = [];

    ItemModel item = ItemModel();
    item.id = 'business';
    item.name = MultiLanguage.get(item.id);
    list.add(item);

    item = ItemModel();
    item.id = 'farmer';
    item.name = MultiLanguage.get(item.id);
    list.add(item);

    return list;
  }

  static List<ItemModel> getGenderOption() {
    final List<ItemModel> list = [];

    ItemModel item = ItemModel();
    item.id = 'male';
    item.name = MultiLanguage.get(item.id);
    list.add(item);

    item = ItemModel();
    item.id = 'female';
    item.name = MultiLanguage.get(item.id);
    list.add(item);

    item = ItemModel();
    item.id = 'other';
    item.name = MultiLanguage.get(item.id);
    list.add(item);

    return list;
  }

  static double stringToDouble(String value, {String? locale}) {
    final Constants constants = Constants();
    int decimalDigits = 0;
    if (locale == null || locale == constants.localeENLang) decimalDigits = 3;

    double? tmp = 0.0;
    try {
      final nfc =
      NumberFormat.currency(locale: locale, decimalDigits: decimalDigits);
      tmp = nfc.parse(value) as double?;
    } catch (_) {}
    return tmp!;
  }

  static String doubleToString(double value, {String? locale, int digit = 0}) {
    String tmp = value.toString();
    try {
      final nfc = NumberFormat.currency(locale: locale??Constants().localeVILang, decimalDigits: digit, name: '');
      tmp = nfc.format(value).trim();//.replaceAll(RegExp(nfc.currencyName!), '').trim();
    } catch (_) {}
    return tmp;
  }

  static String dateToString(DateTime date,
      {String? pattern, String? locale}) {
    locale ??= Constants().localeEN;
    pattern ??= 'yyyy.MM.dd';
    initializeDateFormatting(locale, null);
    return DateFormat(pattern, locale).format(date);
  }

  static DateTime stringToDateTime(String source,
      {String? pattern, String? locale}) {
    locale ??= Constants().localeVI;
    pattern ??= 'yyyy-MM-ddTHH:mm:ss';
    initializeDateFormatting(locale, null);
    return DateFormat(pattern, locale).parse(source);
  }

  static Future<List<File>> loadFilesFromNetwork(ProductRepository repository, List<ItemModel> root) async {
    final List<File> list = [];
    final String path = (await getApplicationDocumentsDirectory()).path + '/images/';
    for(int i = 0; i < root.length; i++) {
      final File? file = await repository.downloadImage(root[i].name, path);
      if (file != null) list.add(file);
    }
    return list;
  }

  static String getTimeAgo(String strDatetime) {
    final now = DateTime.now();
    final ago = Util.stringToDateTime(strDatetime);
    final dua = now.difference(ago);
    int temp;
    if (dua.inMinutes == 0) return 'Vừa xong';
    else if (dua.inMinutes > 0 && dua.inMinutes < 60) return '${dua.inMinutes} phút trước';
    else if (dua.inHours > 0 && dua.inHours < 24) return '${dua.inHours} giờ trước';
    else if (dua.inDays > 0 && dua.inDays < 7) return '${dua.inDays} ngày trước';
    else if (dua.inDays == 7) return '1 tuần trước';
    else if (dua.inDays > 7 && dua.inDays < 29) {
      temp = dua.inDays~/7;
      return '$temp tuần trước';
    }
    else if (dua.inDays == 30) return '1 tháng trước';
    else if (dua.inDays > 30 && dua.inDays < 365) {
      temp = dua.inDays~/30;
      return '$temp tháng trước';
    }
    else if (dua.inDays == 365) return '1 năm trước';
    else {
      temp = dua.inDays~/365;
      return '$temp năm trước';
    }
  }

  static Future<void> getPermission({bool hasCTV = false}) => SharedPreferences.getInstance().then((prefs) {
    if (hasCTV) Constants().contributeRole = jsonDecode(prefs.getString('contribute_role')??'{}');
    else {
      Constants().permission = prefs.getString('manager_type')??'member';
      Constants().userId = prefs.getInt('id');
    }
  });

  static void clearPermission({bool hasCTV = false}) {
    if (hasCTV) Constants().contributeRole = null;
    else {
      Constants().permission = null;
      Constants().userId = null;
    }
    Constants().funChatBotLink = null;
  }

  static String getExpired(String strDatetime) {
    final now = DateTime.now();
    final end = stringToDateTime(strDatetime);
    bool isExpired = end.isBefore(now);
    if (isExpired) return 'Hết hạn';
    int hours = end.difference(now).inHours % 24;
    int days = (end.difference(now).inHours / 24).round();
    String temp = '';
    if (days > 0) temp = 'Còn $days ngày';
    else if (hours > 0) temp = 'Còn $hours giờ';
    return temp.isNotEmpty ? temp : 'Hết hạn';
  }
}
