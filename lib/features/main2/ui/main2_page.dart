import 'dart:async';
import 'package:floating_draggable_advn/floating_draggable_advn.dart';
import 'package:hainong/common/count_down_bloc.dart';
import 'package:hainong/common/ui/banner_2nong.dart';
import 'package:hainong/common/ui/google_ads.dart';
import 'package:hainong/common/ui/image_network_asset.dart';
import 'package:hainong/common/ui/chatbot_bottomsheet_dialog.dart';
import 'package:hainong/common/ui/avatar_circle_widget.dart';
import 'package:hainong/common/ui/import_lib_modules.dart';
import 'package:hainong/features/function/support/game/game_bloc.dart';
import 'package:hainong/features/home/bloc/home_state.dart';
import 'package:hainong/features/main/ui/animation_header_footer.dart';
import 'package:hainong/features/main/ui/main_page.dart';
import 'package:hainong/features/main/ui/import_lib_ui_main_page.dart';
import 'package:hainong/features/signup/ui/import_lib_ui_signup.dart';
import 'package:chat_call_core/shared/helper/call_helper.dart';
import 'package:chat_call_core/shared/helper/mapping_model_helper.dart';
import 'package:chat_call_core/shared/helper/navigator_page_helper.dart';
import 'main2_item.dart';
import 'search/components/searchable/dropdown_text_search.dart';
import '../main2_controller.dart';

class Main2Page extends BasePage {
  Main2Page({Key? key}) : super(key: key, pageState: Main2PageState());
}

class Main2PageState extends BasePageState with SingleTickerProviderStateMixin
    implements NavigationDrawerCallback, LoginOrCreateCallback, IMain2Controller {
  late Main2Controller ctr;

  Main2PageState () {
    ctr = Main2Controller(this);
  }

  @override
  void dispose() {
    ctr.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initMainBloc();
    _initGameBloc();
    ctr.initState();
    trackActivities('home_page', method: 'Open', path: 'Main Screen');
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => FloatingDraggableADVN(
    child: Scaffold(
        key: ctr.scaffoldKey, resizeToAvoidBottomInset: false,
        drawer: NavigationDrawer(this, ctr.shopName, ctr.shopImage, ctr.memberRate,
            ctr.province, ctr.version, ctr.userLevel, ctr.point, isMain2: true),
        body: WillPopScope(onWillPop: () async {
          ctr.back ++;
          if (ctr.back == 1) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nhấn lần nữa để thoát')));
          return Future.value(ctr.back > 1);
        }, child: GestureDetector(onTapDown: (value) => clearFocus(),
            child: Column(children: [
              Stack(children: [
                Container(padding: EdgeInsets.fromLTRB(48.sp, WidgetsBinding.instance.window.padding.top.sp + (Platform.isAndroid ? 48.sp : -10.sp), 48.sp, 48.sp),
                    color: const Color(0xFF00A96C), width: 1.sw,
                    child: Column(children: [
                      Row(children: [
                        BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is LoadHeaderState,
                            builder: (context, state) => ButtonImageWidget(200, () => goToLeftPage(ShopPage(drawerCallback: this)),
                                AvatarCircleWidget(size: 170.sp, stack: true, border: constants.isLogin && ctr.shopImage.isNotEmpty ?
                                Border.all(color: Colors.white30, width: 8.sp) : null,
                                    link: ctr.shopImage, assetsImageReplace: 'assets/images/v2/ic_avatar_drawer_v2.png'))),
                        SizedBox(width: 30.sp),
                        Expanded(child: BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is LoadHeaderState,
                            builder: (context, state) {
                              if (constants.isLogin) {
                                return Column(children: [
                                  LabelCustom('Xin chào,', weight: FontWeight.normal, size: 36.sp),
                                  const SizedBox(height: 2),
                                  LabelCustom(ctr.shopName.isNotEmpty ? ctr.shopName : 'Người dùng 2Nông', size: 48.sp),
                                ], crossAxisAlignment: CrossAxisAlignment.start);
                              }
                              return Row(children: [
                                ButtonImageWidget(200, () => UtilUI.goToPage(context, LoginPage(), null),
                                    Container(padding: EdgeInsets.symmetric(horizontal: 44.sp, vertical: 18.sp), decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(100),
                                        border: Border.all(color: const Color(0x55FFFFFF), width: 2.sp), color: const Color(0x0F000000)),
                                        child: LabelCustom('Đăng nhập', size: 45.sp), alignment: Alignment.center)),
                                const Expanded(child: SizedBox())
                              ]);
                            })),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: ButtonImageWidget(200, ctr.openNotify,
                            BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is CountNotificationMainState,
                                builder: (context, state) {
                                  int count = 0;
                                  try {
                                    if (state is CountNotificationMainState &&
                                        state.response.checkOK(passString: true)) count = int.parse(state.response.data);
                                  } catch (_) {}
                                  final size = count > 0 ? 80.sp : 100.sp;
                                  final bell = Image.asset('assets/images/ic_notification.png',
                                      color: Colors.white, width: size, height: size);
                                  if (count == 0) return bell;
                                  return Stack(alignment: Alignment.topCenter, children: [
                                    Padding(padding: EdgeInsets.only(top: 30.sp, right: 30.sp), child: bell),
                                    Container(child: LabelCustom(count < 100 ? count.toString() : '99+', size: 24.sp),
                                        height: 60.sp, width: 60.sp, alignment: Alignment.center,
                                        decoration: BoxDecoration(color: Colors.red,
                                            borderRadius: BorderRadius.circular(100)))
                                  ]);
                                }))),
                        ButtonImageWidget(200, ctr.openDrawer, Image.asset('assets/images/ic_menu2.png',
                            color: Colors.white, width: 120.sp, height: 120.sp))
                      ], mainAxisAlignment: MainAxisAlignment.start),
                      SizedBox(height: 40.sp),
                      DropdownTextSearch(
                          items: ctr.searchData,
                          color: const Color(0xFFCDCDCD),
                          hintText: 'Tìm kiếm',
                          sizeBorder: 8,
                          controller: ctr.ctrSearch,
                          onPressIcon: _clearSearch,
                          onSubmit: ctr.search,
                          size: 42.sp,
                          textColor: const Color(0xFF818181),
                          borderColor: Colors.transparent,
                          height: 132.sp,
                          iconSize: 55.sp,
                          paddingIcon: EdgeInsets.all(38.sp),
                          inputAction: TextInputAction.search,
                          isLoading: ctr.isSearchLoading,
                          onChange: ctr.handleOnChangeSearchText,
                          onCallBackPage: ctr.handleSearchNavigationPage)
                    ])),
                const Banner2Nong('home', loc: 'top')
              ]),
              Expanded(child: Stack(children: [
                Container(decoration: BoxDecoration(image: DecorationImage(
                    image: Image.asset('assets/images/v2/bg_main.png').image, fit: BoxFit.cover)),
                    width: 1.sw, height: 1.sh,
                    child: ListView(children: [
                      Main2Item('DIỄN ĐÀN NÔNG NGHIỆP', 'social_main2',
                              () => openPage(MainPage(index: 2, funDynamicLink: ctr.chatBotLink), 'Main Screen -> On Tap "Social" Button -> Open "Social" Screen')),
                      Main2Item('CHỢ NÔNG SẢN', 'market_main2',
                              () => openPage(MainPage(index: 4, funDynamicLink: ctr.chatBotLink), 'Main Screen -> On Tap "Market" Button -> Open "Market" Screen')),
                      BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is GetModulesState || newS is ChangeIndexHomeState,
                          builder: (context, state) => ctr.modules.list2.isNotEmpty ? Column(children: ctr.items()) : const SizedBox()),
                      GestureDetector(child: Container(alignment: Alignment.center,
                          margin: EdgeInsets.all(48.sp), padding: EdgeInsets.all(48.sp),
                          decoration: BoxDecoration(image: DecorationImage(
                              image: Image.asset('assets/images/v5/ic_bg_fun.png').image, fit: BoxFit.fill)),
                          child: Row(children: [
                            Image.asset('assets/images/ic_function.png', color: Colors.white, width: 52.sp, height: 52.sp),
                            SizedBox(width: 20.sp),
                            LabelCustom('Nâng cao', size: 56.sp, align: TextAlign.center, weight: FontWeight.w500)
                          ], mainAxisAlignment: MainAxisAlignment.center)),
                          onVerticalDragStart: (details) => goto12Advance(scroll: true),
                          onTap: goto12Advance)
                    ], padding: EdgeInsets.fromLTRB(48.sp, 68.sp, 24.sp, WidgetsBinding.instance.window.padding.bottom.sp + 48.sp))
                ),
                const Banner2Nong('home', loc: 'bottom'),
                Column(children: const [
                  // Banner2Nong('home', loc: 'bottom'),
                  GoogleAds()
                ], mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.end)
              ], alignment: Alignment.bottomRight))
            ])))),
    floatingWidgets: floatingIconWidgets(),
    floatingWidgetPositions: ctr.floatingIconOffset(),
    floatingWidgetHeights: ctr.floatingIconHeights(),
    floatingWidgetWidths: ctr.floatingIconWidths(),
  );

  @override
  void getValueFromSecondPage(value) {
    if (value == null) return;
    if (value.data is Post) (ctr.page?.pageState as HomePageState).reloadPage();
    else if (value.data is ProductModel) (ctr.page?.pageState as ProductListPageState).search(ctr.ctrSearch.text);
  }

  @override
  showLoginOrCreate() => showMessageLoginOrCreate();

  @override
  bool showMessageLoginOrCreate() {
    if (constants.isLogin) return false;
    UtilUI.showCustomDialog(context, MultiLanguage.get(LanguageKey().msgLoginOrCreate)).then((value) => ctr.openDrawer());
    return true;
  }

  @override
  goToLeftPage(page) {
    _closeDrawer();
    if (page is ShopPage) {
      if (!constants.isLogin) return;
      UtilUI.goToNextPage(context, page);
    } else {
      openPage(page, '');
    }
  }

  @override
  goToProfile() {
    _closeDrawer();
    openPage(ProfilePage(callback: ctr), '', isProfile: true);
  }

  @override
  refreshInfo() => ctr.initShop();

  @override
  logout() => bloc!.add(LogoutMainEvent());

  @override
  void goBack(value) => UtilUI.goBack(context, value);

  @override
  void openPage(page, String path, {bool clearAll = false, bool isProfile = false, bool hasCallback = false}) async {
    if (clearAll) while (Navigator.of(context).canPop()) {Navigator.of(context).pop();}
    UtilUI.goToNextPage(context, page, funCallback: hasCallback ? (value) {
      if (value != null && value is String && value == 'open_chatbot') showChatbotBottomSheet(context, ctr.chatBotLink);
    } : null);
    if (path.isNotEmpty) trackActivities('home_page', path: path);
  }

  @override
  void callBackgroundListener() {
    CallHelper.onListernerCallEvent(context, onCallBackAccept: (response) => bloc!.add(CallSuggestEvent(response, isSuggestCall: false)));
    setState(() {});
  }

  @override
  void goToPage(page, Function? funCallback) => UtilUI.goToPage(context, page, funCallback);

  @override
  void setStateMain(VoidCallback funSetState) => setState(funSetState);

  @override
  void openVideoCall() {
    if (showMessageLoginOrCreate()) return;
    _nextPage(context, ExpertPage(callBackContact: () {
      _nextPage(context, const HandbookPage(), 'Home Screen -> Open Hand Books Screen');
    }, callBackLogin: () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    }), 'Home Screen -> Open Call Expert Screen');
  }

  @override
  void goto12Advance({bool scroll = false}) {
    Constants().indexPage = 12;
    Constants().funChatBotLink = ctr.chatBotLink;
    if (scroll) {
      Navigator.of(context).push(PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) =>
          FunctionPage(ctr.modules.list),
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(child: child, position: animation.drive(Tween(begin: Offset(0, 1), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeInOut))))
      ));
      trackActivities('home_page', path: 'Main Screen -> On Tap "Functions" Button -> Open "Functions" Screen');
    } else openPage(FunctionPage(ctr.modules.list), 'Main Screen -> On Tap "Functions" Button -> Open "Functions" Screen');
  }

  @override
  void detailExpert(detail) {
    final result = MappingModelHelper.expertChatItem(data: detail);
    NavigatorPage.navigatorChatPage(context, request: result.copyWith(
        callType: "chat", dialerId: Constants().userId.toString(),
        roomName: Constants().userId.toString() + '-' + detail.id.toString(),
        isProfile: false, isExpert: false, isShowGuide: true, isShowCommentRate: true));
  }

  @override
  void detailCall(state) {
    CallHelper.onListernerCallStatus(response: state.response,
        onCallBackIncoming: () {
          if (state.isSuggestCall == true) {
            ctr.isCallShow = true;
            NavigatorPage.navigationCallSuggestPage(context, request: state.response, callBackDecline: () => ctr.isCallShow = null,
                callBackAccept: () {
                  NavigatorPage.navigatorCallPageTranfer(context, result: state.response);
                });
          } else {
            final data = state.response.copyWith(isCalled: false);
            NavigatorPage.navigationCallPage(context, request: data);
          }
        },
        onCallBackDecline: () {
          if (ctr.isCallShow != null) {
            ctr.isCallShow = null;
            Navigator.of(context).pop();
          }
        });
  }

  @override
  void checkPhone() async {
    //final prefs = await SharedPreferences.getInstance();
    //if ((prefs.getString('phone')??'').isEmpty) {
      final phoneBloc = CountDownBloc();
      final Widget ignore = Padding(child: Row(children: [
        ButtonImageWidget(0, () => ctr.tapIgnore(phoneBloc), BlocBuilder(bloc: phoneBloc, builder: (context, state) {
          bool active = false;
          if (state is CountDownState) active = state.value > 0;
          return Icon(active ? Icons.check_box : Icons.check_box_outline_blank, color: active ? StyleCustom.primaryColor : Colors.blue, size: 48.sp);
        })),
        const Expanded(child: LabelCustom(' Không hiển thị thông báo này thêm nữa', color: Color(0xFF1F1F1F), weight: FontWeight.normal))
      ]), padding: EdgeInsets.fromLTRB(20.sp, 0, 20.sp, 40.sp));
      UtilUI.showCustomDialog(context, 'Hoàn thiện hồ sơ người dùng', alignMessageText: TextAlign.left,
          isActionCancel: true, lblOK: 'Bổ sung ngay', lblCancel: 'Bỏ qua', extend: ignore).then((value) {
        if (value != null && value) {
          //_openPage(ProfilePage(callback: this, checkPhone: _checkPhone), '', isProfile: true);
          openPage(ProfilePage(callback: ctr, showEditPhone: true), '', isProfile: true);
        }
      }).whenComplete(() => ctr.saveIgnore(phoneBloc));
    //}
  }

  @override
  void showPopup(ads) {
    if (!mounted || ctr.stream.isPaused || ctr.isClose != null) return;
    ctr.scrollBloc = ScrollBloc(CollapseHeaderScrollState(false));
    showDialog(useSafeArea: false, barrierDismissible: false, context: context, builder: (context) =>
        Dialog(child: Container(color: Colors.black54, alignment: Alignment.center, child:
        AnimationHeaderFooter(ctr.scrollBloc!, 'header', const SizedBox(),
            Stack(alignment: Alignment.topRight, children: [
              GestureDetector(child: ClipRRect(borderRadius: BorderRadius.circular(15),
                  child: ImageNetworkAsset(path: ads['image'], width: 0.8.sw)),
                  onTap: () => ctr.closePopup(ads)),
              ButtonImageWidget(50, () => ctr.closePopup(ads, value: 'hidden'), Padding(padding: const EdgeInsets.all(5),
                  child: Icon(Icons.close, size: 86.sp, color: Colors.white)), color: Colors.black12)
            ]))),
            insetPadding: EdgeInsets.zero, backgroundColor: Colors.transparent, elevation: 0),
        barrierColor: Colors.transparent).whenComplete(() => ctr.scrollBloc!.close().whenComplete(() => ctr.scrollBloc = null));
    Timer(const Duration(milliseconds: 500), () {
      if (!mounted || ctr.stream.isPaused || ctr.isClose != null) {
        ctr.scrollBloc!.close().whenComplete(() => ctr.scrollBloc = null);
        bloc!.add(ClosePopupEvent());
        ctr.isClose = null;
        return;
      }
      ctr.scrollBloc!.add(CollapseHeaderScrollEvent(true));
    });
  }

  void _initMainBloc() {
    bloc = BlocProvider.of<MainBloc>(context);
    ctr.initMainBloc(bloc);
    ctr.blocHome.stream.listen((state) {
      if (state is SharePostHomeState && isResponseNotError(state.response, passString: true, showError: false)) {
        goBack(state);
      } else if (state is WarningPostHomeState && isResponseNotError(state.response)) {
        UtilUI.showCustomDialog(
            context, MultiLanguage.get(languageKey.msgWarningPostSuccess), title: MultiLanguage.get(languageKey.ttlAlert));
      } else if (state is TransferPointState && isResponseNotError(state.response, passString: true)) {
        UtilUI.showCustomDialog(context, MultiLanguage.get('msg_transfer'), title: MultiLanguage.get(languageKey.ttlAlert));
      }
    });
  }

  void _initGameBloc() {
    ctr.blocGame = GameBloc();
    ctr.blocGame.stream.listen((state) {
      if (state is GameListStatusState) {
        if (isResponseNotError(state.resp, showError: false)) {
          final response = state.resp.data;
          setState(() {
            ctr.luckyWheelDataInfo = response.firstWhere((item) => item['group_name'] == 'lucky_wheel', orElse: () => null);
          });
        }
        ctr.blocGame.close();
        ctr.blocGame = null;
      }
    });
    ctr.blocGame.add(FetchGameListStatusEvent());
  }

  void _clearSearch() {
    ctr.ctrSearch.text = '';
    clearFocus();
  }

  void _closeDrawer() {
    if (ctr.scaffoldKey.currentState != null && ctr.scaffoldKey.currentState!.isDrawerOpen) Navigator.pop(context);
  }

  void _nextPage(BuildContext context, dynamic page, String path) {
    UtilUI.goToNextPage(context, page);
    if (path.isNotEmpty) Util.trackActivities('home_page', path: path);
  }

  void _openGameVongXoay() async {
    if (ctr.luckyWheelDataInfo == null || showMessageLoginOrCreate()) return;
    //if (await UtilUI().alertVerifyPhone(context)) return;
    UtilUI.goToNextPage(context, GameItemPage(ctr.luckyWheelDataInfo));
  }

  List<Widget> floatingIconWidgets() {
    List<Widget> icons = [];
    if(ctr.isShowIconLuckyWheel()) icons.add(IconButton(onPressed: () => _openGameVongXoay(), tooltip: 'Game', icon: Image.asset("assets/images/chatbot/ic_vong_xoay.gif")));
    icons.add(IconButton(onPressed: () => showChatbotBottomSheet(context, ctr.chatBotLink),tooltip: 'Chatbot',icon: Image.asset("assets/images/chatbot/ic_chatbot_6.gif")));
    return icons;
  }
}