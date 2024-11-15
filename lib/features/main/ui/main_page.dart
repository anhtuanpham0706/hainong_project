import 'dart:async';
import 'package:floating_draggable_advn/floating_draggable_advn.dart';
import 'package:hainong/common/ui/banner_2nong.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/button_post_page_custom.dart';
import 'package:hainong/features/cart/ui/cart_item.dart';
import 'package:hainong/features/discount_code/dis_code_list_page.dart';
import 'package:hainong/features/function/info_news/market_price/ui/market_price_page.dart';
import 'package:hainong/features/home/ui/import_ui_home.dart';
import 'package:hainong/features/main/ui/header_main.dart';
import 'package:hainong/features/shop/shop_model.dart';
import 'package:hainong_chat_call_module/presentation/pages/friends_page.dart';
import 'package:hainong/common/ui/chatbot_bottomsheet_dialog.dart';
import 'animation_header_footer.dart';
import 'import_lib_ui_main_page.dart';

class MainPage extends BasePage {
  final int index;
  final Function? funDynamicLink, funReloadPrePage;
  final bool goProfileStore;
  MainPage({Key? key, this.index = 1, this.funDynamicLink, this.funReloadPrePage, this.goProfileStore = false}) : super(key: key, pageState: MainPageState());
  goToLeftPage(page) => (pageState as MainPageState).goToLeftPage(page);
  selectMenuItem(int index) => (pageState as MainPageState).selectMenuItem(index);
}

//class MainPageState extends BasePageState implements ChangeUICallback, NavigationDrawerCallback, LoginOrCreateCallback, ProfilePageCallback {
class MainPageState extends BasePageState implements ChangeUICallback, LoginOrCreateCallback, ProfilePageCallback {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _ctrSearch = TextEditingController();
  final _focusSearch = FocusNode();
  dynamic _page;
  final ChangeHeaderBloc _subBloc = ChangeHeaderBloc(ChangeHeaderState());
  final ScrollBloc _scrollBloc = ScrollBloc(ScrollState());
  String _shopName = '', _shopImage = '', _province = '';//, _memberRate = '', _version = '', _userLevel = '';
  final int lastMenu = 4;
  int _index = 2;//, _point = 0;
  late StreamSubscription _stream;
  final HomeBloc _subShopBloc = HomeBloc(HomeState());
  late StreamSubscription _subShopStream;
  bool isSignMemPackage = false;

  @override
  void dispose() {
    if (Constants().isLogin) Constants().indexPage = null;
    final reload = (widget as MainPage).funReloadPrePage;
    if (reload != null) reload();
    _stream.cancel();
    _subBloc.close();
    _subShopBloc.close();
    _subShopStream.cancel();
    _scrollBloc.close();
    _page = null;
    _ctrSearch.removeListener(_listenerSearch);
    _ctrSearch.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _initMainBloc();
    SharedPreferences.getInstance().then((prefs) {
      if (constants.isLogin) _setShop(prefs, cond: true);
    });
    //PackageInfo.fromPlatform().then((value) {
    //  _version = value.version;
    //});
    super.initState();
    _ctrSearch.addListener(_listenerSearch);
  }

  void _listenerSearch() => _scrollBloc.add(HideClearScrollEvent(_ctrSearch.text.isEmpty));

  _initShop() => SharedPreferences.getInstance().then((prefs) => _setShop(prefs));

  void _setShop(SharedPreferences prefs, {bool cond = false}) {
    if (cond || constants.isLogin) {
      _shopName = prefs.getString(constants.name)??'';
      _shopImage = prefs.getString(constants.image)??'';
      //_memberRate = prefs.getString(constants.memberRate)??'';
      _province = prefs.getString(constants.provinceName)??'';
      //_userLevel = prefs.getString('user_level')??'';
      //_point = prefs.getInt('points')??0;
    }
  }

  _initMainBloc() {
    bloc = BlocProvider.of<MainBloc>(context);
    _stream = bloc!.stream.listen((state) {
      if (state is LogoutMainState) {
        UtilUI.goToPage(context, LoginPage(), null);
      } else if (state is ChangeIndexState) {
        _index = state.index;
        Constants().indexPage = _index;
        switch (state.index) {
          case 0: UtilUI.goBack(context, false); return;
          case 2:
            if (!_subBloc.isClosed) {
              _subBloc.add(ChangeHeaderEvent(hasHeader: true, icon: Padding(padding: EdgeInsets.only(right: 40.sp),
                  child: buttonHelper(url: 'https://help.hainong.vn/muc/11')), createUI: ButtonPostCustom(
                      (open) => _create(PostPage(_shopName, _shopImage, openGallery: open)), titleMessage: 'Bạn hãy đặt câu hỏi tại đây ...')));
            }
            return;
          case 4:
            if (!_subBloc.isClosed) {
              _subBloc.add(ChangeHeaderEvent(hasHeader: true, icon: Row(children: [
                buttonHelper(),
                SizedBox(width: 40.sp),
                ButtonImageWidget(100, () => UtilUI.goToNextPage(context, DisCodeListPage()),
                  Image.asset('assets/images/v8/ic_dis_code.png', color: Colors.white, height: 56.sp)),
                const CartNumber()
              ], crossAxisAlignment: CrossAxisAlignment.center), createUI: ButtonPostCustom(
                      (open) => _create(ProductPage(shopName: _shopName, openGallery: open)), titleMessage: 'Bạn muốn đăng bán sản phẩm gì?')));
            }
            return;
          default:
            if (!_subBloc.isClosed) _subBloc.add(ChangeHeaderEvent());
            return;
        }
      } else if (state is GetLocationState) {
        if(_province == '') {
          _province = state.response.data;
        }
      } //else if(state is LoadStatusMemberPackageState){
        //isSignMemPackage = state.isSign;
      //}
    });
    _subShopStream = _subShopBloc.stream.listen((state) {
      if (state is LoadShopHomeState) {
        _handleLoadShop(state);
      }
    });
    //if (Constants().isLogin) bloc!.add(LoadStatusMemberPackageEvent());
    bloc!.add(ChangeIndexEvent(index: (widget as MainPage).index));
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => FloatingDraggableADVN(
    child: Scaffold(
        key: _scaffoldKey, resizeToAvoidBottomInset: false,
        //drawer: NavigationDrawer(this, _shopName, _shopImage, _memberRate, _province, _version, _userLevel, _point,isSignMemPackage: isSignMemPackage,),
        body: GestureDetector(
              onTapDown: (value) => clearFocus(),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                HeaderMain(_scrollBloc, _subBloc, _ctrSearch, _focusSearch, _search, _clearSearch),
                Expanded(child: Container(color: StyleCustom.backgroundColor, child: BlocBuilder(bloc: bloc,
                    buildWhen: (state1, state2) => state2 is ChangeIndexState,
                    builder: (context, state) {
                      if (state is ChangeIndexState && state.index > 0) return _getPage(state.index, state.subPage);
                      return const SizedBox();
                    }))),
                BlocBuilder(bloc: bloc, buildWhen: (state1, state2) => state2 is ChangeIndexState,
                    builder: (context, state) {
                      if (state is ChangeIndexState) {
                        switch(state.index) {
                          case 2: return const Banner2Nong('post', key: Key('post'));
                          case 3: return const Banner2Nong('market_price', key: Key('market'));
                          case 4: return const Banner2Nong('market', key: Key('market_price'));
                        }
                      }
                      return const SizedBox();
                    }),
                Container(
                  height: 0.5, decoration:BoxDecoration(
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 5,
                        blurRadius: 9, offset: const Offset(0, 1))]),
                ),
                AnimationHeaderFooter(_scrollBloc, 'footer',
                    BlocBuilder(bloc: bloc, buildWhen: (state1, state2) => state2 is ChangeIndexState,
                        builder: (context, state) => BottomNavigationBar(
                            selectedFontSize: 34.sp, unselectedFontSize: 34.sp,
                            showSelectedLabels: true, showUnselectedLabels: true, type: BottomNavigationBarType.fixed,
                            currentIndex: state is MainState ? (state.index > lastMenu ? lastMenu : state.index) : _index,
                            selectedItemColor: StyleCustom.primaryColor, unselectedItemColor: const Color(0xFF818181),
                            onTap: (value) => selectMenuItem(value), backgroundColor: Colors.white,
                            items: [
                              BottomNavigationBarItem(label: 'Trang chủ', icon: IconWidget(assetPath: 'assets/images/ic_home.png', size: 72.sp)),
                              BottomNavigationBarItem(label: 'Tư vấn', icon: IconWidget(assetPath: 'assets/images/v2/ic_call_history_v3.png', size: 72.sp)),
                              BottomNavigationBarItem(label: 'Diễn đàn', icon: IconWidget(assetPath: 'assets/images/ic_social_home.png', size: 72.sp)),
                              BottomNavigationBarItem(label: 'Giá cả', icon: IconWidget(assetPath: 'assets/images/v5/ic_market_price_menu.png', size: 72.sp)),
                              BottomNavigationBarItem(label: 'Chợ 2Nông', icon: IconWidget(assetPath: 'assets/images/ic_market.png', size: 72.sp))
                            ])),
                    const SizedBox()),
        ]))),
      floatingWidgets: [IconButton(onPressed: () => showChatbotBottomSheet(context, (widget as MainPage).funDynamicLink),
        tooltip: 'Chatbot', icon: Image.asset("assets/images/chatbot/ic_chatbot_6.gif"))],
      floatingWidgetPositions: [Offset(0.8.sw, 0.66.sh)],
      floatingWidgetHeights: const [106],
      floatingWidgetWidths: const [106]);

  @override
  void getValueFromSecondPage(value) {
    if (value == null) return;
    if (value.data is Post) (_page?.pageState as HomePageState).reloadPage();
    else if (value.data is ProductModel) (_page?.pageState as ProductListPageState).search(_ctrSearch.text);
  }

  dynamic _getPage(int index, BasePage? subPage) {
    if (subPage != null) {
      final icon = SizedBox(width: 200.sp);
      if (subPage is ShopPage) {
        _subBloc.add(ChangeHeaderEvent(hasHeader: false));
      } else if (subPage is ProductListFavouritePage) {
        _subBloc.add(ChangeHeaderEvent(
            icon: icon,
            hasHeader: true,
            title: MultiLanguage.get('ttl_saved_products'),
            hideSearch: true));
      } else if (subPage is FollowerListPage) {
        _subBloc.add(ChangeHeaderEvent(
            icon: icon,
            hasHeader: true,
            title: MultiLanguage.get('ttl_followers'),
            hideSearch: true));
      } else if (subPage is ListLikePostPage) {
        _subBloc.add(ChangeHeaderEvent(
            icon: icon,
            hasHeader: true,
            title: MultiLanguage.get('ttl_liked_posts'),
            hideSearch: true));
      }
      _newPage(subPage);
    } else {
      if (index == 2 && _page is! HomePage)
        _newPage(HomePage(callback: this, loginCallback: this));
      else if (index == 4 && _page is! ProductListPage) {
        _newPage(ProductListPage(callback: this, loginCallback: this));
        bloc!.add(CountCartMainEvent());
      } else if (index == 1 && _page is! FriendsPage)
        UtilUI.chatCallNavigation(context, () {
          _newPage(FriendsPage(callBackLogin: _showMessageLoginOrCreate, isAppBarArrow: false, callBackProfile:(shopId) => _subShopBloc.add(LoadShopHomeEvent(context, shopId))));
        });
      else if (index == 3 && _page is! MarketPricePage) _newPage(MarketPricePage(hasBack: false));
      //else if (index == 5 && _page is! ProfilePage) _newPage(ProfilePage(callback: this));
    }
    return _page??const SizedBox();
  }

  _newPage(dynamic page) {
    _ctrSearch.text = '';
    if (_page != null) _page = null;
    _page = page;
    _focusSearch.requestFocus();
    //Timer(const Duration(seconds: 3), () => clearFocus());
  }

  void _create(page) async {
    if (constants.isLogin) {
      //if (await UtilUI().alertVerifyPhone(context, callback: this)) return;
      UtilUI.goToNextPage(context, page, funCallback: getValueFromSecondPage);
      String path = 'Social Screen -> Post Button -> Open Create Post Screen', function = '';
      if (page is ProductPage) {
        function = 'products';
        path = 'Market Screen -> Post Product Button -> Open Create Product Screen';
      }
      trackActivities(function, path: path);
    } else _showMessageLoginOrCreate();
  }

  _search() {
    clearFocus();
    _page!.search(_ctrSearch.text);
    String path = 'Social Screen -> Search Button -> Search Posts with content = "${_ctrSearch.text}"', function = '';
    if (_page is ProductPage) {
      function = 'products';
      path = 'Market Screen -> Search Button -> Search Products with content = "${_ctrSearch.text}"';
    }
    trackActivities(function, path: path);
  }

  _clearSearch() {
    _ctrSearch.text = '';
    _search();
    String path = 'Social Screen -> Clear Button -> Clear content of searching', function = '';
    if (_page is ProductPage) {
      function = 'products';
      path = 'Market Screen -> Clear Button -> Clear content of searching';
    }
    trackActivities(function, path: path);
  }

  _openDrawer() => _scaffoldKey.currentState!.openDrawer();

  _closeDrawer() {
    if (_scaffoldKey.currentState != null && _scaffoldKey.currentState!.isDrawerOpen) {
      Navigator.pop(context);
      String path = 'Social Screen', function = '';
      if (_page is ProductPage) {
        function = 'products';
        path = 'Market Screen';
      }
      trackActivities(function, path: '$path -> Close Left Menu');
    }
  }

  selectMenuItem(int index) {
    //if (index == lastMenu) _openDrawer();
    //else if (constants.isLogin || index != lastMenu - 1) bloc!.add(ChangeIndexEvent(index: index));
    if (constants.isLogin || index != 1) bloc!.add(ChangeIndexEvent(index: index));
    else _showMessageLoginOrCreate();

    String page = '', function = '';
    switch(index) {
      case 0: page = 'Home Screen'; function = 'home_page'; break;
      case 2: page = 'Social Screen'; function = 'social'; break;
      case 4: page = 'Market Screen'; function = 'products'; break;
      case 1: page = 'Friend Screen'; function = 'expert_advices'; break;
      case 3: page = 'Market Price'; function = 'martket_price';
    }
    trackActivities(function, path: 'Sub Home screen -> Bottom Menu -> Open $page');
  }

  _handleLoadShop(LoadShopHomeState state) {
    if (state.response.data is String) return;
    ShopModel shop = state.response.data as ShopModel;
    if (shop.id > -1) {
      UtilUI.goToNextPage(state.context, ShopPage(shop: state.response.data,
            isOwner: false, hasHeader: true, isView: true));
      Util.trackActivities('social', path: 'Post -> Information User/Shop -> Open Shop Screen');
    }
  }

  _showMessageLoginOrCreate() => UtilUI.showCustomDialog(
      context, MultiLanguage.get(LanguageKey().msgLoginOrCreate)).then((value) => _openDrawer());

  collapseHeader(bool value) => _scrollBloc.add(CollapseHeaderScrollEvent(value));

  collapseFooter(bool value) => _scrollBloc.add(CollapseFooterScrollEvent(value));

  goToLeftPage(page) {
    if (page is TempPage) {
      _closeDrawer();
      Timer(const Duration(milliseconds: 500), () => UtilUI.goBack(context, false));
      return;
    }

    if (_page.runtimeType == page.runtimeType) {
      UtilUI.goBack(context, false);
      return;
    }

    _scrollBloc.add(CollapseFooterScrollEvent(false));
    page.pageState.callback = this;
    if (page is ShopPage) bloc!.add(ChangeIndexEvent(index: _index));
    bloc!.add(ChangeIndexEvent(index: -1, subPage: page));
    _closeDrawer();
  }

  goToProfile() {
    _scrollBloc.add(CollapseFooterScrollEvent(false));
    bloc!.add(ChangeIndexEvent(index: _index));
    _closeDrawer();
  }

  logout() => bloc!.add(LogoutMainEvent());

  showLoginOrCreate() => _showMessageLoginOrCreate();

  updateProfile() => _initShop();

  refreshInfo() => _initShop();
}
