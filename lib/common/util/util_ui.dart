import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:graphic/graphic.dart';
import 'package:hainong/common/database_helper.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/features/profile/ui/profile_page.dart';
import 'package:hainong_chat_call_module/chat_call_core.dart';
import 'package:package_info/package_info.dart';
import 'package:hainong/common/ui/button_image_circle_widget.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:share/share.dart';
import 'package:hainong/features/login/login_page.dart';
import '../models/item_option.dart';
import '../ui/confirm_dialog_custom.dart';
import '../ui/label_custom.dart';
import '../ui/import_lib_base_ui.dart';
import '../import_lib_system.dart';
import 'package:chat_call_core/call_core.dart';

class UtilUI {
  static UtilUI? _instance;
  UtilUI._();
  factory UtilUI() {
    _instance ??= UtilUI._();
    return _instance!;
  }

  Future<bool> alertVerifyPhone(context, {callback}) async {
    if (Constants().isLogin && (await SharedPreferences.getInstance()).getString('phone') == '') {
      bool? value = await UtilUI.showCustomDialog(context, 'Hoàn thiện hồ sơ người dùng', isActionCancel: true,
          lblOK: 'Bổ sung ngay', lblCancel: 'Bỏ qua', alignMessageText: TextAlign.center);
      if (value != null && value == true) {
        UtilUI.goToNextPage(context, ProfilePage(callback: callback, showEditPhone: true));
        return true;
      }
    }
    return false;
  }

  List<MarkAnnotation> getPoints(data, {Color colorPoint = Colors.red, bool useDate2 = false}) {
    final List<MarkAnnotation> list = [];
    for (var ele in data) {
      list.add(MarkAnnotation(
        relativePath: Paths.circle(center: Offset.zero, radius: 5),
        style: Paint()..color = colorPoint,
        values: [useDate2 ? ele.created_at2 : ele.created_at, ele.price],
      ));
    }
    return list;
  }

  List<Figure> tooltip(Offset anchor, List<Tuple> selectedTuples) {
    String textContent = '';
    if (selectedTuples.length == 1) {
      final original = selectedTuples.single;
      if (original['price'] > 0) {
        textContent = 'Ngày: ' + Util.strDateToString(original['created_at'], pattern: 'dd/MM/yyyy HH:mm');
        textContent += '\nSP: ' + original['title'];
        textContent += '\nGiá: ' + Util.doubleToString(original['price']) + ' đ';
      } else {
        return [];
      }
    }

    return _renderFigure(anchor, textContent);
  }

  List<Figure> tooltip2(Offset anchor, List<Map<String, dynamic>> selectedTuples) {
    String textContent = '';
    if (selectedTuples.length == 1) {
      final original = selectedTuples.single;
      if (original['points'] > 0) {
        textContent = 'Ngày: ' + original['date'] + '\n';
        textContent += 'SP: ' + original['name'] + '\n';
        textContent += 'Giá: ' + Util.doubleToString(original['points']) + ' đ';
      } else {
        return [];
      }
    }

    return _renderFigure(anchor, textContent);
  }

  List<Figure> _renderFigure(Offset anchor, String textContent) {
    final padding = EdgeInsets.all(16.sp);
    final painter = TextPainter(text: TextSpan(text: textContent, style: TextStyle(fontSize: 32.sp)),
        textDirection: TextDirection.ltr);
    painter.layout();

    final width = padding.left + painter.width + padding.right;
    final height = padding.top + painter.height + padding.bottom;
    final paintPoint = getPaintPoint(anchor, width, height, Alignment.bottomCenter);
    final widow = Rect.fromLTWH(paintPoint.dx, paintPoint.dy, width, height);
    final widowPath = Path()..addRRect(RRect.fromRectAndRadius(widow, const Radius.circular(4)));

    List<Figure> figures = [];
    figures.add(ShadowFigure(widowPath, Colors.black38, .0));
    figures.add(PathFigure(widowPath, Paint()..color = Colors.black38));
    figures.add(TextFigure(painter, paintPoint + padding.topLeft));
    return figures;
  }

  static void shareTo(BuildContext context, String sharePath, String trackPath, String function) async {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    Share.share(Constants().domain + sharePath, subject: 'Chia sẻ', sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size).then((value) {
      //if (!Constants().domain.contains('beta')) showCustomAlertDialog(context, 'share done');
    }).catchError((e) {
      //if (!Constants().domain.contains('beta')) showCustomAlertDialog(context, 'error 1: $e');
    }).onError((error, stackTrace) {
      //if (!Constants().domain.contains('beta')) showCustomAlertDialog(context, 'error 2: $error');
    });
    Util.trackActivities(function, path: trackPath);
  }

  static void shareDeeplinkTo(BuildContext context, String sharePath, String trackPath, String function) async {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    Share.share(sharePath, subject: 'Chia sẻ', sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size).then((value) {
      //if (!Constants().domain.contains('beta')) showCustomAlertDialog(context, 'share done');
    }).catchError((e) {
      //if (!Constants().domain.contains('beta')) showCustomAlertDialog(context, 'error 1: $e');
    }).onError((error, stackTrace) {
      //if (!Constants().domain.contains('beta')) showCustomAlertDialog(context, 'error 2: $error');
    });
    Util.trackActivities(function, path: trackPath);
  }

  static Widget _addAction(context, buttonName, value, {Color bgColor = StyleCustom.buttonColor}) =>
      ElevatedButton(
          child: Text(buttonName),
          style: ElevatedButton.styleFrom(
              side: const BorderSide(
                color: Colors.transparent,
              ),
              primary: bgColor),
          onPressed: () {Navigator.of(context).pop(value);});

  static Widget createLabel(title, {textAlign = TextAlign.left, color = Colors.white,
    fontSize, fontWeight = FontWeight.bold, decoration = TextDecoration.none, style = FontStyle.normal,
    overflow = TextOverflow.ellipsis, int? line}) => Text(title, overflow: overflow, textAlign: textAlign,
      style: TextStyle(color: color, fontSize: fontSize??50.sp,
          fontWeight: fontWeight, decoration: decoration, fontStyle: style), maxLines: line);

  static Widget createButton(onPress, title, {rate, noWidth = false,
    color = StyleCustom.buttonColor, textColor = Colors.white,
    elevation = 5, borderColor = Colors.transparent,
    fontSize, padding, fontWeight = FontWeight.bold}) => Container(padding: padding??EdgeInsets.zero,
      width: noWidth?null:(rate??1.sw),
      child: createCustomButton(onPress, title, color: color, textColor: textColor,
          borderColor: borderColor, fontWeight: fontWeight, fontSize: fontSize));

  static Widget createCustomButton(onPress, title, {color = StyleCustom.buttonColor,
    textColor = Colors.white, elevation = 4.0,
    borderColor = Colors.transparent, fontSize,
    fontWeight = FontWeight.bold, borderWidth = 1.0, double? radius}) => ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: color,
            elevation: elevation,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius ?? 80.sp),
                side: BorderSide(color: borderColor, width: borderWidth)),
          ),onPressed: onPress,
      child: createLabel(title, color: textColor, fontWeight: fontWeight, fontSize: fontSize));

  static Widget createStars({Function(int)? onClick, MainAxisAlignment? mainAxisAlignment, bool hasFunction = false, rate = 0, double? size, color = Colors.yellow}) =>
      Row(mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center, children: [
        _createButtonStar(1, onClick: onClick, hasFunction: hasFunction, isOn: rate > 0, size: size, color: color),
        _createButtonStar(2, onClick: onClick, hasFunction: hasFunction, isOn: rate > 1, size: size, color: color),
        _createButtonStar(3, onClick: onClick, hasFunction: hasFunction, isOn: rate > 2, size: size, color: color),
        _createButtonStar(4, onClick: onClick, hasFunction: hasFunction, isOn: rate > 3, size: size, color: color),
        _createButtonStar(5, onClick: onClick, hasFunction: hasFunction, isOn: rate > 4, size: size, color: color),
      ]);

  static Widget _createStar({isOn = true, double? size, color = Colors.yellow}) =>
      Icon(Icons.star, color: isOn ? color : Colors.grey.shade300, size: size??40.sp);

  static Widget _createButtonStar(index, {Function(int)? onClick, bool hasFunction = false,
    isOn = true, double? size, color = Colors.yellow}) => hasFunction
      ? ButtonImageCircleWidget(size??40.sp, () => onClick!(index),
          child: Icon(Icons.star, color: isOn ? color : Colors.grey.shade300,
          size: size ?? 40.sp))
      : _createStar(isOn: isOn, size: size, color: color);

  static Future<bool?> showCustomDialog(context, message, {title, isActionCancel = false,
    lblOK, lblCancel, alignMessageText = TextAlign.left, isClose = false, Widget? extend}) {
    final LanguageKey languageKey = LanguageKey();
    title ??= MultiLanguage.get(languageKey.ttlWarning);
    lblOK ??= MultiLanguage.get(languageKey.btnOK);
    if (isActionCancel && lblCancel == null) lblCancel = MultiLanguage.get(languageKey.btnCancel);

    return showDialog(barrierDismissible: false, context: context,
        builder: (context) => Dialog(shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.sp))),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 1.sw, decoration: BoxDecoration(color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.sp), topRight: Radius.circular(30.sp))),
                  child: Padding(padding: EdgeInsets.all(40.sp), child: Stack(children: [
                    if (title != MultiLanguage.get(languageKey.ttlWarning) || isClose) Align(alignment: Alignment.topRight, child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(isClose ? null : false),
                        child: const Icon(Icons.close, color: Color(0xFF626262)))),
                    title == MultiLanguage.get(languageKey.ttlWarning) ?
                      Align(alignment: Alignment.centerLeft,
                          child: Row(children: [
                            Image.asset('assets/images/v5/ic_warning_dialog.png', width: 64.sp),
                            LabelCustom(' Thông tin', color: const Color(0xFF191919), size: 60.sp)
                          ])) :
                      Center(child: LabelCustom(title, color: const Color(0xFF191919), size: 60.sp))
                  ]))),
              Flexible(child: SingleChildScrollView(child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 40.sp),
                  child: LabelCustom(message, align: alignMessageText,
                      color: const Color(0xFF1F1F1F), weight: FontWeight.normal)))),
              if (extend != null) extend,
              Row(crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center, children: [
                    if (isActionCancel) Padding(padding: EdgeInsets.only(right: 40.sp),
                        child: ElevatedButton(style: ElevatedButton.styleFrom(primary: const Color(0xFFB7B7B7)),
                        child: LabelCustom(lblCancel), onPressed: () => Navigator.of(context).pop(false))),
                    ElevatedButton(style: ElevatedButton.styleFrom(primary: StyleCustom.buttonColor),
                        child: LabelCustom(lblOK), onPressed: () => Navigator.of(context).pop(true))
                  ]),
              SizedBox(height: 40.sp)
            ], crossAxisAlignment: alignMessageText == TextAlign.left ? CrossAxisAlignment.start : CrossAxisAlignment.center)));
  }

  static Future<dynamic> showConfirmDialog(final context, message, hintText, alertMsg,
      {title, lblOK, alignMessage = Alignment.centerLeft, alignMessageText = TextAlign.left,
        colorMessage = const Color(0xFF1F1F1F), hasSubOK = false, showMsg = true,
        autoClose = true, inputType = TextInputType.text, maxLength, line = 1,
        isCheckEmpty = true, action = TextInputAction.done, initContent = '',
        padding, inputFormatters, suffix, countDown = 45, funSetCountDown, String? compareValue}) =>
      showDialog(barrierDismissible: autoClose, context: context,
          builder: (context) => ConfirmDialogCustom(alertMsg, showMsg: showMsg,
              title: title, message: message, hintText: hintText, lblOK: lblOK,
              alignMessage: alignMessage, alignMessageText: alignMessageText,
              colorMessage: colorMessage, inputType: inputType, maxLength: maxLength,
              hasSubOK: hasSubOK, isCheckEmpty: isCheckEmpty, action: action, suffix: suffix,
              initContent: initContent, line: line, padding: padding, compareValue: compareValue,
              inputFormatters: inputFormatters, countDown: countDown, funSetCountDown: funSetCountDown));

  static Future<dynamic> showOptionDialog(BuildContext context, String title,
      values, String id, {bool hasTitle = true, bool allowOff = true, bool hasClose = false}) {
    return showDialog(context: context, barrierDismissible: allowOff,
        builder: (context) => Align(alignment: Alignment.center,
            child: Container(width: 0.8.sw,
                height: 150.sp * values.length + (hasTitle?120.sp:0),
                margin: EdgeInsets.only(top: 300.sp, bottom: 80.sp),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(30.sp)),
                child: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, 
                        children: createItems(context, title, values, id, hasTitle: hasTitle, hasClose: hasClose))))));
  }

  static List<Widget> createItems(BuildContext context, String title, values, String id, {bool hasTitle = true, bool hasClose = false}) {
    final line = Container(color: Colors.grey.shade300, height: 2.sp);
    List<Widget> list = [];
    if (hasTitle) {
      Widget temp;
      if (hasClose) {
        temp = Padding(child: Row(children: [
          Expanded(child: LabelCustom(title, color: Colors.black87, align: TextAlign.center)),
          ButtonImageWidget(100, () => Navigator.of(context).pop(false), Icon(Icons.close, size: 64.sp, color: Colors.grey)),
        ]), padding: EdgeInsets.only(left: 84.sp, right: 20.sp));
      } else temp = Center(child: LabelCustom(title, color: Colors.black87));
      list.add(SizedBox(height: 120.sp, child: temp));
    }
    for (var i = 0; i < values.length; i++) {
      list.add(line);
      list.add(OutlinedButton(
          style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: Colors.transparent,
              ),
              padding: EdgeInsets.zero),
          onPressed: () => Navigator.of(context).pop(values[i]),
          child: Container(color: id != values[i].id.toString() ? Colors.transparent : StyleCustom.buttonColor,
              width: 1.sw, height: 148.sp, alignment: Alignment.center, padding: EdgeInsets.symmetric(horizontal: 40.sp),
              child: LabelCustom(values[i].name,
                  color: id != values[i].id.toString() ? StyleCustom.primaryColor : Colors.white))));
    }
    return list;
  }

  static Future<bool?> showOptionDialog2(BuildContext context, String title, List<ItemOption> values,
      {Color? colorLine, FontWeight weight = FontWeight.normal, Color? bgItem}) {
    return showDialog(context: context, barrierDismissible: true,
        builder: (context) => Align(
            alignment: Alignment.center,
            child: Container(width: 0.8.sw,
                height: 160.sp * (values.length + 1) - 40.sp,
                margin: EdgeInsets.only(top: 120.sp, bottom: 40.sp),
                decoration: BoxDecoration(color: Colors.white,
                    borderRadius: BorderRadius.circular(30.sp)),
                child: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min,
                        children: createItems2(context, title, values, colorLine, weight, bgItem))))));
  }

  static List<Widget> createItems2(BuildContext context, String title, List<ItemOption> values, Color? colorLine, FontWeight weight, Color? bgItem) {
    final line = Container(color: colorLine??Colors.grey.shade300, height: 2.sp);
    List<Widget> list = [];
    list.add(SizedBox(height: 120.sp, child: Center(child: createLabel(title,
        color: StyleCustom.textColor6C, fontWeight: FontWeight.bold))));
    for (var i = 0; i < values.length; i++) {
      list.add(line);
      list.add(OutlinedButton(style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
        side: const BorderSide(
          color: Colors.transparent,
        )
      ),onPressed: () => values[i].isLock ? () {} : values[i].function(),
          child: _createItem(values[i], weight, bgItem)));
    }
    return list;
  }

  static Widget _createItem(ItemOption item, FontWeight weight, Color? bgItem) {
    final Color color = item.isLock ? Colors.black38 : const Color(0xFF4D4D4D);
    return Container(padding: EdgeInsets.only(left: 40.sp), width: 1.sw, height: 158.sp, color: bgItem,
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          if (item.assetPath.isNotEmpty) Image.asset(item.assetPath, height: 50.sp, width: 50.sp, color: color),
          if (item.icon != null) Padding(child: Icon(item.icon, size: 50.sp, color: color.withOpacity(0.5)),
            padding: EdgeInsets.only(right: 10.sp)),
          Flexible(child: createLabel(item.title, color: color, fontWeight: weight, line: 2))
        ]));
  }

  static void goBack(context, value) {Navigator.of(context).pop(value);}

  static void clearAllPages(context) {
    while (Navigator.of(context).canPop()) Navigator.of(context).pop(false);
    //Navigator.of(context).pop(false);
  }

  static void goToNextPage(context, page, {Function? funCallback}) { Navigator.push(context,
      MaterialPageRoute(builder: (context) => page)).then((value) {
        if (funCallback != null && value != null) funCallback(value);
  });}

  static void goToPage(context, page, Function? funCallback) { Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => page)).then((value) {
        if (funCallback != null && value != null) funCallback(value);});}

  static showDialogTimeout(context, {String? message}) => showCustomDialog(
      context, MultiLanguage.get(message??'msg_another_login')).then((value) {
      logout();
      clearAllPages(context);
      goToPage(context, LoginPage(), null);
  });

  static logout({bool isRemove = false}) => SharedPreferences.getInstance().then((prefs) async {
    await FirebaseMessaging.instance.deleteToken();
    final Constants constants = Constants();
    String device = prefs.getString('device_id')??'';
    String key = prefs.getString(constants.loginKey)??'';
    String pass = prefs.getString(constants.password)??'';
    String env = prefs.getString('env')??'';
    String cart = prefs.getString('carts')??'';
    String cartInfo = prefs.getString('cart_info')??'';
    bool remember = prefs.getBool(constants.isRemember)??false;
    String? keyFinger = prefs.getString(constants.loginKeyFinger);
    String? passFinger = prefs.getString(constants.passwordFinger);
    prefs.clear();
    constants.contributeRole = null;
    constants.isLogin = false;
    prefs.setBool('is_login', false);
    prefs.setString('env', env);
    prefs.setString('carts', cart);
    prefs.setString('cart_info', cartInfo);
    if(isRemove) return;
    prefs.setString('device_id', device);
    if(remember){
      prefs.setString(constants.loginKey, key);
      prefs.setString(constants.password, pass);
    } else {
      prefs.setString(constants.loginKey, '');
      prefs.setString(constants.password, '');
    }
    prefs.setBool(constants.isRemember, remember);
    if (keyFinger != null) prefs.setString(constants.loginKeyFinger, keyFinger);
    if (passFinger != null) prefs.setString(constants.passwordFinger, passFinger);
  });

  static Future<String> _getDeviceId() async {
    String imei = '';
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('device_id')) imei = prefs.getString('device_id')??'';
      if (imei.isEmpty) {
        imei = (await PlatformDeviceId.getDeviceId)??'';
        prefs.setString('device_id', imei);
      }
      return imei;
    } catch (_) {}
    return imei;
  }

  static Future<String> _getFirebaseToken() =>
    FirebaseMessaging.instance.getToken().then((String? token) async {
      assert(token != null);
      //print('token firebase: $token');
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('fb_token', token!);
      return token;
    });

  static Future<Map<String, String>> getDeviceInfo() async {
    final String token = await _getFirebaseToken();
    String imei;
    String type, name, os, version, apnsTopic;
    String? appleNoticeToken;
    version = (await PackageInfo.fromPlatform()).version;
    apnsTopic = (await PackageInfo.fromPlatform()).packageName;
    if (Platform.isAndroid) {
      type = 'Android';
      var androidInfo = await PlatformDeviceId.deviceInfoPlugin.androidInfo;
      os = androidInfo.version.release;
      name = androidInfo.model;
      imei = await _getDeviceId();
    } else {
      type = 'iOS';
      var iosInfo = await PlatformDeviceId.deviceInfoPlugin.iosInfo;
      os = iosInfo.systemVersion;
      name = iosInfo.name;
      imei = iosInfo.identifierForVendor;
      appleNoticeToken = await CallCore.getVoipToken() ?? "";
    }
    return {
      'imei': imei,
      'name': name,
      'type': type,
      'os': os,
      'version': version,
      'token': token,
      'apns_topic' : apnsTopic,
      'apple_notice_token' : appleNoticeToken ?? ""
    };
  }

  static void saveInfo(context, data, loginKey, password, {page, currentPas}) {
    SharedPreferences.getInstance().then((prefs) {
      final constants = Constants();
      if (loginKey != null && password != null) {
        final db = DBHelper();
        db.deleteHelper('id', 'ignore_phone_popup', 'setting');
        constants.isLogin = true;
        prefs.setBool('is_login', true);
        if (loginKey != prefs.getString(constants.loginKey)) {
          prefs.setString('carts', '');
          prefs.setString('cart_info', '');
        }
        prefs.setString(constants.loginKey, loginKey);
        prefs.setString(constants.password, password);
        final keyFinger = prefs.getString(constants.loginKeyFinger);
        final passFinger = prefs.getString(constants.passwordFinger);
        if (keyFinger != null && passFinger != null &&
            keyFinger.isNotEmpty && passFinger.isNotEmpty &&
            keyFinger != loginKey && passFinger != password) {
          prefs.setString(constants.loginKeyFinger, loginKey);
          prefs.setString(constants.passwordFinger, password);
        }
      }
      if (data.token_user.isNotEmpty) prefs.setString('token_user', data.token_user);
      if (data.token2_user.isNotEmpty) prefs.setString('token2_user', data.token2_user);
      if (loginKey != null) prefs.setString(constants.loginKey, loginKey);
      if (password != null) prefs.setString(constants.password, password);
      if (data.partner_type.isNotEmpty && currentPas != null) prefs.setString('current_password', currentPas);
      prefs.setInt('id', data.id);
      prefs.setString(constants.name, data.name);
      prefs.setString('email', data.email);
      prefs.setString('website', data.website);
      prefs.setString('phone', data.phone);
      prefs.setString('address', data.address);
      prefs.setString(constants.image, data.image);
      prefs.setString('background_image', data.background_image);
      prefs.setString('birthdate', data.birthdate);
      prefs.setString('gender', data.gender);
      prefs.setString('user_type', data.user_type);
      prefs.setString('province_id', data.province_id);
      prefs.setString(constants.provinceName, data.province_name);
      prefs.setString('district_id', data.district_id);
      prefs.setString('district_name', data.district_name);
      prefs.setString(constants.memberRate, data.member_rate);
      prefs.setString('user_level', data.user_level);
      prefs.setInt('hidden_phone', data.hidden_phone);
      prefs.setInt('hidden_email', data.hidden_email);
      prefs.setInt(constants.hideToolbar, data.hide_toolbar);
      prefs.setInt(constants.autoPlayVideo, data.auto_play_video);
      prefs.setInt('points', data.points);
      prefs.setDouble('acreage', data.acreage);
      prefs.setString('manager_type', data.manager_type);
      if (data.contribute_role != null) prefs.setString('contribute_role', jsonEncode(data.contribute_role));
      prefs.setStringList('hash_tags', data.has_tash_list.objectsToInts());
      prefs.setStringList('hash_tags_name', data.has_tash_list.objectsToStrings());
      prefs.setStringList('trees', data.tree_list.objectsToStrings());
      prefs.setString('partner_type', data.partner_type);
      prefs.setString('role_type', data.role_type);
      prefs.setString('current_referral_code', data.current_referral_code);
      prefs.setString('referral_link', data.referral_link);

      if (data.shop.id != -1) {
        prefs.setInt(constants.shopId, data.shop.id);
        prefs.setString(constants.shopName, data.shop.name);
        prefs.setString(constants.shopEmail, data.shop.email);
        prefs.setString('shop_address', data.shop.address);
        prefs.setString(constants.shopPhone, data.shop.phone);
        prefs.setString(constants.shopProvinceId, data.shop.province_id);
        prefs.setString(constants.shopProvinceName, data.shop.province_name);
        prefs.setString(constants.shopDistrictId, data.shop.district_id);
        prefs.setString(constants.shopDistrictName, data.shop.district_name);
        prefs.setString(constants.shopWebsite, data.shop.website);
        prefs.setString(constants.shopFacebook, data.shop.facebook);
        prefs.setString(constants.shopDescription, data.shop.description);
        prefs.setInt(constants.shopStar, data.shop.shop_star);
        prefs.setString(constants.shopImage, data.shop.image);
        prefs.setString('shop_background_image', data.shop.background_image);
        prefs.setInt(constants.shopHiddenPhone, data.shop.hidden_phone);
        prefs.setInt(constants.shopHiddenEmail, data.shop.hidden_email);
        prefs.setInt(constants.shopHideToolbar, data.shop.hide_toolbar);
      }
      chatCallUserInit(prefs);
      if (page != null) UtilUI.goToPage(context, page, null);
    });
  }

  static Widget createTextField(context, ctr, currentFocus, nextFocus, hintText,
      {isPassword = false, readOnly = false, enable = true, inputAction = TextInputAction.next,
      Widget? suffixIcon, Widget? prefixIcon, onPressIcon, inputType = TextInputType.text,
      maxLength, maxLines = 1, padding, fontSize, textColor = Colors.black, borderColor,
      Function? onSubmit, Function? onChanged, inputFormatters, double sizeBorder = 5.0,Color fillColor = Colors.white}) {

    final enabledBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(sizeBorder),
        borderSide: BorderSide(color: borderColor??StyleCustom.borderTextColor, width: 0.5));

    inputFormatters ??= <TextInputFormatter>[
      LengthLimitingTextInputFormatter(maxLength??1000000000)
    ];

    InputDecoration decoration = InputDecoration(
        filled: true,
        fillColor: fillColor,
        contentPadding: padding ?? EdgeInsets.fromLTRB(30.sp, 0, 30.sp, 0),
        suffixIcon: suffixIcon == null ? null : IconButton(onPressed: onPressIcon, icon: suffixIcon),
        hintText: hintText,
        border: enabledBorder,
        enabledBorder: enabledBorder,
        focusedBorder: enabledBorder,
        prefixIcon: prefixIcon
      );

    return TextField(
        style: TextStyle(color: textColor, fontSize: fontSize??40.sp),
        maxLines: maxLines,
        focusNode: currentFocus,
        onSubmitted: (term) {
          currentFocus.unfocus();
          if (context != null && nextFocus != null) FocusScope.of(context).requestFocus(nextFocus);
          if (inputAction == TextInputAction.done && onSubmit != null) onSubmit();
        },
        onChanged: (value) {
          if (onChanged != null) onChanged(ctr, value);
        },
        controller: ctr,
        textInputAction: inputAction,
        obscureText: isPassword,
        decoration: decoration,
        readOnly: readOnly,
        enabled: enable,
        keyboardType: inputType,
        inputFormatters: inputFormatters);
  }

  static Image imageDefault({String asset = 'assets/images/ic_default.png',
    BoxFit fit = BoxFit.fill, double? width, double? height}) => Image.asset(asset, fit: fit, scale: 0.5, width: width, height: height);

  static chatCallNavigation(
      BuildContext context, Function callBackNavigation) {
    if (ChatCallCore.isUserHasData()) {
      Constants().isLogin == true
          ? callBackNavigation()
          : UtilUI.showDialogTimeout(context,
              message: MultiLanguage.get('msg_login_create_account'));
    } else {
      SharedPreferences.getInstance().then((prefs) => chatCallUserInit(prefs));
      callBackNavigation();
    }
  }

  static Future<void> chatCallUserInit(SharedPreferences prefs) async {
    final userId = prefs.getInt("id").toString();
    final token = prefs.getString('token_user') ?? "";
    if (userId.isNotEmpty == true && token.isNotEmpty == true) {
      try {
        await ChatCallCore.cacheData(
            primaryColor: StyleCustom.primaryColor.toString(),
            domainUri: Constants().baseUrl);
        await ChatCallCore.cacheUserRoot(
            userId: prefs.getInt("id").toString(),
            name: prefs.getString(Constants().name) ?? "",
            email: prefs.getString('email') ?? "",
            phone: prefs.getString('phone') ?? "",
            imageUrl: prefs.getString(Constants().image) ?? "",
            token: prefs.getString('token_user') ?? "",
            roleType: prefs.getString('role_type') ?? "");
      } catch (_) {}
    }
  }

}
