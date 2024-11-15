import 'dart:async';
import 'dart:convert';
import 'package:chat_call_core/call_core.dart';
import 'package:chat_call_core/presentation/call/call_bloc.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/count_down_bloc.dart';
import 'package:hainong/common/database_helper.dart';
import 'package:hainong/common/import_lib_system.dart';
import 'package:hainong/common/ui/base_page.dart';
import 'package:hainong/common/ui/import_lib_modules.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/features/function/tool/map_task/map_task_page.dart';
import 'package:hainong/features/function/tool/map_task/models/map_deep_link_model.dart';
import 'package:hainong/features/function/tool/map_task/models/map_enum.dart';
import 'package:package_info/package_info.dart';

import '../home/bloc/home_bloc.dart';
import '../login/login_page.dart';
import '../main/bloc/main_bloc.dart';
import '../main/bloc/scroll_bloc.dart';
import '../main/ui/main_page.dart';
import '../notification/ui/notification_list_page.dart';
import '../order_history/order_history_page.dart';
import '../post/ui/post_detail_page.dart';
import '../product/ui/product_detail_page.dart';
import '../profile/ui/profile_page.dart';
import '../reset_password_page.dart';
import '../shop/shop_model.dart';
import '../signup/ui/signup_page.dart';
import 'ui/main2_item.dart';
import 'ui/search/models/home_search_model.dart';
import 'ui/search/models/home_search_params.dart';

abstract class IMain2Controller {
  void callBackgroundListener();
  void goToPage(page, Function? funCallback);
  void setStateMain(VoidCallback funSetState);
  void openPage(page, String path, {bool clearAll = false, bool isProfile = false, bool hasCallback = false});
  void openVideoCall();
  bool showMessageLoginOrCreate();
  void showPopup(ads);
  void checkPhone();
  void goBack(value);
  void goto12Advance({bool scroll = false});
  void detailExpert(detail);
  void detailCall(state);
  bool isResponseNotError(BaseResponse state, {bool passString = false, bool showError = true});
}

class Main2Controller with WidgetsBindingObserver implements ProfilePageCallback {
  final _localNotify = FlutterLocalNotificationsPlugin();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ctrSearch = TextEditingController();
  late StreamSubscription stream;
  BasePage? page;
  String shopName = '', shopImage = '', memberRate = '', province = '', version = '', userLevel = '';
  final ModuleModels modules = ModuleModels();
  int point = 0, back = 0, shopId = -1;
  List<HomeSearchModel>? searchData;
  bool isSearchLoading = false;
  final ShopModel shop = ShopModel();
  final HomeBloc blocHome = HomeBloc(HomeState());
  bool? isCallShow, _hasLink, isClose, _showLoc, _isFirst = true;
  dynamic blocGame, luckyWheelDataInfo, _loadModule;
  ScrollBloc? scrollBloc;

  IMain2Controller callback;
  BaseBloc? bloc;

  Main2Controller(this.callback);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) _showLoc = null;
    if (state == AppLifecycleState.resumed) {
      if (Constants().isLogin) bloc!.add(CountNotificationMainEvent());
      initShop();
      if (_showLoc == null) _determinePosition();
    }
  }

  @override
  updateProfile() => initShop();

  void dispose() {
    isClose = true;
    stream.cancel();
    page = null;
    ctrSearch.dispose();
    blocHome.close();
    searchData?.clear();
    modules.clear();
    if (Constants().isLogin) WidgetsBinding.instance.removeObserver(this);
  }

  void initState() {
    PackageInfo.fromPlatform().then((value) => version = value.version);
    if (Constants().isLogin) {
      WidgetsBinding.instance.addObserver(this);
      _initNotification();
      bloc!.add(CountNotificationMainEvent());
    }
    initShop();
    _initDynamicLinks();
    callback.callBackgroundListener();
    _gotoPage();
    Timer(const Duration(milliseconds: 1500), () => bloc!.add(LoadPestsMainEvent()));
    _determinePosition();
  }

  List<Widget> items() {
    final List<Widget> list = [];
    if (checkShow('news') || checkShow('video') || checkShow('short_video')) {
      list.add(Main2Item('TIN TỨC NÔNG NGHIỆP', 'news_main2', _goto5News));
    }
    //if (_checkShow('video')) {
    //  list.add(Main2Item('TIN TỨC VIDEO', 'video_main2', _goto6Video));
    //}
    if (checkShow('market_price')) {
      list.add(Main2Item('GIÁ CẢ THỊ TRƯỜNG', 'market_price_main2',
              () => callback.openPage(MainPage(index: 3, funDynamicLink: chatBotLink), 'Main Screen -> On Tap "Market Price" Button -> Open "Market Price" Screen')));
    }
    if (checkShow('traning_data')) {
      list.add(Main2Item('CHẨN ĐOÁN SÂU BỆNH', 'pest_diagnosis_main2', _goto7PestDiagnosis));
    }
    if (checkShow('mini_game') && list.length < 4) {
      list.add(Main2Item('MINI GAME', 'mini_game_main2', _goto11Game));
    }
    if (checkShow('weather') && list.length < 4) {
      list.add(Main2Item('THỜI TIẾT NÔNG VỤ', 'weather_main2', _goto8Weather));
    }
    if (checkShow('online_counseling') && list.length < 4) {
      list.add(Main2Item('HỖ TRỢ TRỰC TIẾP', 'online_counseling_main2', _goto9Call));
    }
    /*if (checkShow('diagnostic_map') && list.length < 4) {
      list.add(Main2Item('BẢN ĐỒ SÂU BỆNH', 'diagnostic_map_main2', _goto10Map));
    }*/
    return list;
  }

  bool checkShow(String key) => modules.list2.containsKey(key) && modules.list2[key]!.status;

  void _initDynamicLinks() {
    FirebaseDynamicLinks.instance.onLink.listen(_dynamicLinkResult);
    FirebaseDynamicLinks.instance.getInitialLink().then((dynamicLink) {
      if (dynamicLink != null) _dynamicLinkResult(dynamicLink);
    });
  }

  void _dynamicLinkResult(PendingDynamicLinkData dynamicLink) {
    if (chatBotLink(dynamicLink)) {
      _hasLink = true;
      return;
    }
    if (_referralLink(dynamicLink)) {
      _hasLink = true;
      return;
    }
    if (dynamicLink.link.queryParameters.containsKey('tab')) {
      _hasLink = true;
      switch(dynamicLink.link.queryParameters['tab']) {
        case 'social':
          callback.openPage(MainPage(index: 2, funDynamicLink: chatBotLink), 'Main Screen -> Open "Social" Screen', clearAll: true);
          break;
        case 'market':
          callback.openPage(MainPage(index: 4, funDynamicLink: chatBotLink), 'Main Screen -> Open "Product" Screen', clearAll: true);
          break;
        case 'pest':
          callback.openPage(DiagnosePestsPage(), 'Main Screen -> Open "Diagnose Pests" Screen', clearAll: true);
          break;
        case 'invoice':
          callback.openPage(OrderHistoryPage(), 'Main Screen -> Open "Order history" Screen', clearAll: true);
          break;
        case 'expert': callback.openVideoCall(); return;
        case 'market_price':
          callback.openPage(MainPage(index: 3, funDynamicLink: chatBotLink), 'Main Screen -> Open "Market price" Screen', clearAll: true);
          break;
        default:
          if (dynamicLink.link.queryParameters.containsKey('code')) {
            callback.openPage(TraceabilityPage(url: Constants().baseUrl,
                device_id: "98D31C75-4658-4CB0-BF0E-B6129F0C973D", isLink: true,
                code: dynamicLink.link.queryParameters['code']??''),
                'Main Screen -> Open "Traceability" Screen', clearAll: true);
          }
      }
    }
  }

  bool chatBotLink(PendingDynamicLinkData dynamicLink) {
    if (dynamicLink.link.queryParameters.containsKey('type') && dynamicLink.link.queryParameters['type'] == 'chatbot') {
      String id;
      if (dynamicLink.link.queryParameters.containsKey('page')) {
        switch(dynamicLink.link.queryParameters['page']) {
          case 'expert':
            if (callback.showMessageLoginOrCreate()) return true;
            id = dynamicLink.link.queryParameters['expert_id']??'';
            if (id.isNotEmpty) bloc!.add(GetDetailMainEvent(id, 'expert'));
            break;
          case 'all_missions':
            id = dynamicLink.link.queryParameters['mission_id']??'';
            id.isEmpty ? callback.openPage(MissionListPage(), '', clearAll: true) : bloc!.add(GetDetailMainEvent(id, 'all_missions'));
            break;
          case 'current_joins':
            if (callback.showMessageLoginOrCreate()) return true;
            id = dynamicLink.link.queryParameters['mission_id']??'';
            id.isEmpty ? callback.openPage(MissionPartListPage(), '', clearAll: true) : bloc!.add(GetDetailMainEvent(id, 'current_joins'));
            break;
          case 'user_missions':
            if (callback.showMessageLoginOrCreate()) return true;
            id = dynamicLink.link.queryParameters['mission_id']??'';
            id.isEmpty ? callback.openPage(MissionListPage(isOwner: true), '', clearAll: true) : bloc!.add(GetDetailMainEvent(id, 'user_missions', extend: 'owner'));
            break;
          case 'social':
            bloc!.add(GetDetailMainEvent(dynamicLink.link.queryParameters['post_id']??'', 'post'));
            break;
          case 'profile':
            if (callback.showMessageLoginOrCreate()) return true;
            callback.openPage(ProfilePage(callback: this), '', clearAll: true, isProfile: true);
            break;
          case 'change_password':
            if (callback.showMessageLoginOrCreate()) return true;
            callback.openPage(ResetPasswordPage('', isChangeCurrent: true), '', clearAll: true);
            break;
          case 'create':
            if (callback.showMessageLoginOrCreate()) return true;
            callback.openPage(MissionMineDetailPage(null), '', clearAll: true);
            break;
          case 'map':
            callback.openPage(MissionMapPage(), '', clearAll: true);
            break;
          case 'new_question':
            callback.openPage(const HandbookPage(isCreate: true), '', clearAll: true);
        }
        return true;
      }

      if (dynamicLink.link.queryParameters.containsKey('module')) {
        switch(dynamicLink.link.queryParameters['module']) {
          case 'news':
            id = dynamicLink.link.queryParameters['article_id']??'';
            id.isEmpty ? callback.openPage(NewsListPage(), '', clearAll: true) : bloc!.add(GetDetailMainEvent(id, 'news'));
            break;
          case 'market_price':
            id = dynamicLink.link.queryParameters['market_place_id']??'';
            id.isEmpty ? callback.openPage(MarketPricePage(), '', clearAll: true) : bloc!.add(GetDetailMainEvent(id, 'market_price'));
            break;
          case 'mini_game':
            id = dynamicLink.link.queryParameters['mini_event_id']??'';
            id.isEmpty ? callback.openPage(GamePage(), '', clearAll: true) : bloc!.add(GetDetailMainEvent(id, 'mini_game'));
            break;
          case 'handbook_of_pest':
            id = dynamicLink.link.queryParameters['diagnostic_new_id']??'';
            id.isEmpty ? callback.openPage(const HandbookPage(), '', clearAll: true) : bloc!.add(GetDetailMainEvent(id, 'handbook_of_pest'));
            break;
          case 'technical_process':
            id = dynamicLink.link.queryParameters['technical_process_id']??'';
            id.isEmpty ? callback.openPage(TechnicalProcessListPage(), '', clearAll: true) : bloc!.add(GetDetailMainEvent(id, 'technical_process'));
            break;
          case 'knowledge_handbook':
            id = dynamicLink.link.queryParameters['knowledge_handbook_id']??'';
            id.isEmpty ? callback.openPage(const HandbookPage(), '', clearAll: true) : bloc!.add(GetDetailMainEvent(id, 'knowledge_handbook'));
            break;
          case 'weather':
            callback.openPage(WeatherListPage(), '', clearAll: true);
            break;
          case 'video':
            callback.openPage(NewsListPage(isVideo: true), '', clearAll: true);
            break;
          case 'traning_data':
            callback.openPage(DiagnosePestsPage(), '', clearAll: true);
            break;
          case 'business_association':
            callback.openPage(BAListPage(), '', clearAll: true);
            break;
          case 'diagnostic_map':
            callback.openPage(const MapPage(), '', clearAll: true);
            break;
          case 'farming_manager':
            Util.getPermission();
            callback.openPage(const FarmManagePage(), '', clearAll: true);
            break;
          case 'shop_gitf':
            if (callback.showMessageLoginOrCreate()) return true;
            callback.openPage(GiftShopPage(), '', clearAll: true);
            break;
          case 'mission':
            callback.openPage(const MissionPage(), '', clearAll: true);
            break;
          case 'chat_message':
            if (callback.showMessageLoginOrCreate()) return true;
            callback.openPage(FriendListPage(), '', clearAll: true);
        }
        return true;
      }
      return true;
    }
    return false;
  }

  bool _referralLink(PendingDynamicLinkData dynamicLink) {
    if (dynamicLink.link.queryParameters.containsKey('module')) {
      String? referralCode = dynamicLink.link.queryParameters['referral_code']??'';
      switch(dynamicLink.link.queryParameters['module']) {
        case 'account':
          callback.openPage(SignUpPage(referralCode: referralCode, referralType: "link"), 'Dynamic link -> Open "Signup" Screen', clearAll: true);
          break;
        case 'product':
          final productId = dynamicLink.link.path.split("/").last;
          if (productId.isNotEmpty) {
            if (referralCode.isEmpty) {
              bloc!.add(GetDetailMainEvent(productId, 'product', extend: ""));
            } else {
              bloc!.add(CheckProductReferralPointEvent(productId, referralCode));
            }
          }
          break;
        case 'agency_map':
          final id = dynamicLink.link.path.split("/").last;
          final lat = dynamicLink.link.queryParameters['lat'] ?? "";
          final lng = dynamicLink.link.queryParameters['lng'] ?? "";
          final agency_type = dynamicLink.link.queryParameters['agency_type'] ?? "";
          var tab = MapModelEnum.store;
          if(agency_type == "shop") {
            tab = MapModelEnum.store;
          } else {
            tab = MapModelEnum.storage;
          }
          final data = MapDeepLinkModel(id: id, lat: lat, lng: lng, menu: MapMenuEnum.model, tab: tab);
          if (id.isNotEmpty && lat.isNotEmpty && lng.isNotEmpty) {
            callback.openPage(MapTaskPage(deepLink: data), '', clearAll: true);
          }
          break;
        case 'demonstration_paradigm_map':
          final id = dynamicLink.link.path.split("/").last;
          final lat = dynamicLink.link.queryParameters['lat'] ?? "";
          final lng = dynamicLink.link.queryParameters['lng'] ?? "";
          final data = MapDeepLinkModel(id: id, lat: lat, lng: lng, menu: MapMenuEnum.model, tab: MapModelEnum.demonstration);
          if (id.isNotEmpty && lat.isNotEmpty && lng.isNotEmpty) {
            callback.openPage(MapTaskPage(deepLink: data), '', clearAll: true);
          }
          break;
        case 'diagnostic_map':
          final id = dynamicLink.link.path.split("/").last;
          final lat = dynamicLink.link.queryParameters['lat'] ?? "";
          final lng = dynamicLink.link.queryParameters['lng'] ?? "";
          final classable_type = dynamicLink.link.queryParameters['classable_type'] ?? "";
          final data = MapDeepLinkModel(id: id, lat: lat, lng: lng, menu: MapMenuEnum.pet, classable_type: classable_type);
          if (id.isNotEmpty && lat.isNotEmpty && lng.isNotEmpty) {
            callback.openPage(MapTaskPage(deepLink: data), '', clearAll: true);
          }
          break;
      }
      return true;
    }
    return false;
  }

  void initMainBloc(mainBloc) {
    bloc = mainBloc;
    stream = bloc!.stream.listen((state) async {
      if (state is LogoutMainState) {
        callback.goToPage(LoginPage(), null);
      } else if (state is GetModulesState) {
        _loadModule = _loadModule == null ? 1 : 2;
        modules.clear();
        modules.setAll(state.data);
        if (_loadModule != null && _loadModule == 2) {
          callback.setStateMain(() {});
          _loadModule = null;
        }
      } else if (state is MessageOpenState) {
        _notifyGotoScreen(state.message.data);
      } else if (state is MessageState) {
        _onMessage(state.message);
      } else if (state is GetLocationState && province.isEmpty){
        province = state.response.data;
      } else if (state is HomeSearchMainState){
        searchData = state.data;
      } else if (state is LoadingSearchState){
        callback.setStateMain(() => isSearchLoading = state.isLoading);
      } else if (state is CallSuggestState) {
        runningShowCallBar();
        callback.detailCall(state);
      } else if (state is CountNotificationMainState) {
        if (_isFirst == null) return;
        _isFirst = null;
        final db = DBHelperUtil();
        if (await db.showIgnorePhonePopup()) {
          final prefs = await SharedPreferences.getInstance();
          if ((prefs.getString('phone')??'').isEmpty) callback.checkPhone();
        }
      } else if (state is GetDetailMainState) {
        switch(state.type) {
          case 'expert':
            callback.detailExpert(state.data);
            break;
          case 'product': callback.openPage(ProductDetailPage(state.data, shop, referralCode: state.extend), '', clearAll: true);
          break;
          case 'post': callback.openPage(PostDetailPage(state.data, 0, blocHome, shopId.toString(), null), '', clearAll: true);
          break;
          case 'news': callback.openPage(NewsDetailPage(state.data, 1, isVideo: state.extend ?? false), '', clearAll: true);
          break;
          case 'market_price': callback.openPage(MarketPriceDtlPage(state.data, (){}), '', clearAll: true);
          break;
          case 'mini_game': callback.openPage(GameItemPage(state.data), '', clearAll: true);
          break;
          case 'handbook_of_pest': callback.openPage(PestsHandbookDetailPage(state.data), '', clearAll: true);
          break;
          case 'technical_process': callback.openPage(TechnicalProcessDetailPage(state.data), '', clearAll: true);
          break;
          case 'knowledge_handbook': callback.openPage(HandBookDetailPage(state.data), '', clearAll: true);
          break;
          default:
            if (state.type == 'all_missions' || state.type == 'current_joins' || state.type == 'user_missions') {
              callback.openPage(state.extend.isEmpty ? MissionDetailPage(state.data)
                  : MissionMineDetailPage(state.data), '', clearAll: true);
            }
        }
      } else if (state is ShowPopupAdsMainState && state.ads != null) {
        callback.showPopup(state.ads);
      } else if (state is CheckProductReferralPointState){
        bloc!.add(GetDetailMainEvent(state.id, 'product', extend: state.isReferral ? state.referralCode : ''));
      }
    });
    bloc!.add(GetModulesEvent());
    getShop();
  }

  void initShop() => SharedPreferences.getInstance().then((prefs) {
    if (Constants().isLogin) {
      shopId = prefs.getInt(Constants().shopId)??-1;
      shopName = prefs.getString(Constants().name)??'';
      shopImage = prefs.getString(Constants().image)??'';
      memberRate = prefs.getString(Constants().memberRate)??'';
      province = prefs.getString(Constants().provinceName)??'';
      userLevel = prefs.getString('user_level')??'';
      point = prefs.getInt('points')??0;

      shop.name = shopName;
      shop.province_name = province;
      shop.district_name = prefs.getString(Constants().shopDistrictName) ?? '';
      shop.image = shopImage;

      bloc!.add(LoadHeaderEvent());
    }
  });

  Future<void> _initNotification() async {
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) _notifyGotoScreen(message.data);
    });
    await _localNotify.initialize(
        InitializationSettings(android: const AndroidInitializationSettings('ic_notification'),
            iOS: IOSInitializationSettings(
                onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) {
                  _notifyGotoScreen(jsonDecode(payload??''));
                }
            )),
        onSelectNotification: (value) => _notifyGotoScreen(jsonDecode(value??'')));

    final notificationAppLaunchDetails = await _localNotify.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      _notifyGotoScreen(jsonDecode(notificationAppLaunchDetails?.payload ?? ''));
    }
  }

  void _onMessage(RemoteMessage message) => bloc!.add(CountNotificationMainEvent());

  void _notifyGotoScreen(Map<String, dynamic> json) => openNotify(clear: true);

  void search() {
    if (ctrSearch.text.length >= 4) {
      bloc!.add(GetHomeSearchMainEvent(HomeSearchParams(keyword: ctrSearch.text)));
    }
  }

  openDrawer() => scaffoldKey.currentState!.openDrawer();

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    //if (!serviceEnabled) return Future.error(MultiLanguage.get('msg_gps_disable'));

    permission = await Geolocator.checkPermission();
    //if (permission == LocationPermission.deniedForever) return Future.error(MultiLanguage.get('msg_gps_deny_forever'));

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      //if (permission != LocationPermission.whileInUse &&
      //    permission != LocationPermission.always) return Future.error(MultiLanguage.get('msg_gps_denied'));
    }
    Geolocator.getCurrentPosition().then((value) {
      _showLoc = false;
      bloc!.add(GetLocationEvent(value.latitude.toString(), value.longitude.toString(), isUpdate: Constants().isLogin));
    }).catchError((e) {
      _showLoc = true;
    }).onError((e, stackTrace) {
      _showLoc = true;
    });
  }

  void openNotify({bool clear = false}) {
    if (callback.showMessageLoginOrCreate()) return;
    Constants().funChatBotLink = chatBotLink;
    callback.openPage(NotificationListPage(modules.list2), 'Home Screen -> On Tap "Notification" Icon -> Open "Notification" Screen', clearAll: clear, hasCallback: true);
  }

  void getShop() => SharedPreferences.getInstance().then((prefs) {
    shop.id = prefs.getInt(Constants().shopId) ?? -1;
    shop.name = prefs.getString(Constants().shopName) ?? '';
    shop.province_name = prefs.getString(Constants().shopProvinceName) ?? '';
    shop.district_name = prefs.getString(Constants().shopDistrictName) ?? '';
    shop.image = prefs.getString(Constants().shopImage) ?? '';
  });

  void handleOnChangeSearchText(String text) {
    if (text.isEmpty) searchData = null;
  }

  void handleSearchNavigationPage(type, id) {
    switch (type) {
      case "Article":
        bloc!.add(GetDetailMainEvent(id, 'news'));
        break;
      case "Video":
        bloc!.add(GetDetailMainEvent(id, 'news', extend: true));
        break;
      case "Product":
        bloc!.add(GetDetailMainEvent(id, 'product'));
        break;
      case "Post":
        bloc!.add(GetDetailMainEvent(id, 'post'));
        break;
      case "MarketPrice":
        bloc!.add(GetDetailMainEvent(id, 'market_price'));
    }
  }

  void _goto5News({String type = 'Button'}) {
    Constants().indexPage = 5;
    callback.openPage(NewsListPage(), 'Main Screen -> On Tap "News" $type -> Open "News" Screen');
  }

  void _goto6Video() {
    Constants().indexPage = 6;
    callback.openPage(NewsListPage(isVideo: true), 'Main Screen -> On Tap "Video" Button -> Open "Video" Screen');
  }

  void _goto7PestDiagnosis({String type = 'Button'}) {
    Constants().indexPage = 7;
    callback.openPage(DiagnosePestsPage(), 'Main Screen -> On Tap "Pest Diagnosis" $type -> Open "Pest Diagnosis" Screen');
  }

  void _goto8Weather({String type = 'Button'}) {
    Constants().indexPage = 8;
    callback.openPage(WeatherListPage(), 'Main Screen -> On Tap "Weather" $type -> Open "Weather" Screen');
  }

  void _goto9Call() {
    Constants().indexPage = 9;
    callback.openVideoCall();
  }

  void _goto10Map() {
    Constants().indexPage = 10;
    callback.openPage(const MapPage(), 'Main Screen -> On Tap "Diagnostic Map" Button -> Open "Diagnostic Map" Screen');
  }

  void _goto11Game() {
    Constants().indexPage = 11;
    callback.openPage(GamePage(), 'Main Screen -> On Tap "Mini Game" Button -> Open "Mini Game" Screen');
  }

  void _gotoPage() => Timer(const Duration(seconds: 1), () {
    if (_hasLink != null) {
      _hasLink = null;
      return;
    }
    switch (Constants().indexPage) {
      case 1: callback.openPage(MainPage(index: 1, funDynamicLink: chatBotLink), 'Main Screen -> Open "Call Expert" Screen'); break;
      case 2: callback.openPage(MainPage(index: 2, funDynamicLink: chatBotLink), 'Main Screen -> Open "Social" Screen'); break;
      case 3: callback.openPage(MainPage(index: 3, funDynamicLink: chatBotLink), 'Main Screen -> Open "Market Price" Screen'); break;
      case 4: callback.openPage(MainPage(index: 4, funDynamicLink: chatBotLink), 'Main Screen -> Open "Product" Screen'); break;
      case 5: _goto5News(); break;
      case 6: _goto6Video(); break;
      case 7: _goto7PestDiagnosis(); break;
      case 8: _goto8Weather(); break;
      case 9: _goto9Call(); break;
      case 10: _goto10Map(); break;
      case 11: _goto11Game(); break;
      case 12: callback.goto12Advance(); break;
    }
    if (Constants().isLogin) Constants().indexPage = null;
  });

  void runningShowCallBar() {
    Future.delayed(const Duration(seconds: 60), () => appCallBloc.add(ShowCallbarEvent(false)));
  }

  bool isShowIconLuckyWheel() => checkShow('mini_game') && luckyWheelDataInfo != null;

  List<Offset> floatingIconOffset(){
    List<Offset> icons = [];
    if(isShowIconLuckyWheel()) icons.add(Offset(0.80.sw, 0.62.sh));
    icons.add(Offset(0.76.sw, 0.72.sh));
    return icons;
  }

  List<double> floatingIconHeights(){
    List<double> icons = [];
    if(isShowIconLuckyWheel()) icons.add(76);
    icons.add(106);
    return icons;
  }

  List<double> floatingIconWidths(){
    List<double> icons = [];
    if(isShowIconLuckyWheel()) icons.add(76);
    icons.add(106);
    return icons;
  }

  void closePopup(dynamic ads, {String value = 'show'}) {
    callback.goBack(null);
    ApiClient().postAPI(Constants().apiVersion + 'advertisements', 'POST', BaseResponse(), body: {
      'module_name': ads['show_position']??'',
      'popup_type': (ads['popup_type']??-1).toString(),
      'advertisementable_type': ads['classable_type']??'',
      'advertisementable_id': (ads['classable_id']??-1).toString(),
      'popup_value': value
    });

    if (value != 'show') {
      ads = null;
      return;
    }

    switch(ads['show_position']) {
      case 'post':
        _openPopupDetail(ads, 2, 'Social', () => callback.openPage(MainPage(index: 2, funDynamicLink: chatBotLink), 'Main Screen -> On Tap "Social" Popup -> Open "Social" Screen'));
        break;
      case 'market':
        _openPopupDetail(ads, 4, 'Market', () => callback.openPage(MainPage(index: 4, funDynamicLink: chatBotLink), 'Main Screen -> On Tap "Market" Popup -> Open "Market" Screen'));
        break;
      case 'article':
        _openPopupDetail(ads, 5, 'News', () => _goto5News(type: 'Popup'));
        break;
      case 'pest':
        _openPopupDetail(ads, 7, 'Pest Diagnosis', () => _goto7PestDiagnosis(type: 'Popup'));
        break;
      case 'weather':
        _openPopupDetail(ads, 8, 'Weather', () => _goto8Weather(type: 'Popup'));
        break;
      default:
        _openPopupDetail(ads, 100, 'Advertisement', (){});
    }
    ads = null;
  }

  void _openPopupDetail(dynamic ads, int index, String screen, Function funOpen) {
    if ((ads['description']??'').isNotEmpty) {
      callback.openPage(PopupDetail(ads['name'] ?? '', ads['description'] ?? '', ads['image'] ?? ''),
          'Main Screen -> On Tap "$screen" Popup -> Open "Popup Detail" Screen');
    } else if (Constants().indexPage != index) funOpen();
  }

  void tapIgnore(phoneBloc) => phoneBloc.add(CountDownEvent(value: phoneBloc.state.value == 0 ? 1 : 0));

  void saveIgnore(phoneBloc) {
    DBHelperUtil().setIgnorePhonePopup(phoneBloc.state.value > 0 ? '9999-12-31' : Util.dateToString(DateTime.now(), pattern: 'yyyy-MM-dd'));
    phoneBloc.close();
  }
}