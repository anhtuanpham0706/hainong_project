import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/features/admin/admin_page.dart';
import 'package:hainong/features/function/info_news/news/ui/news_favorite_list_page.dart';
import 'package:hainong/features/function/info_news/news/ui/news_manage_list_page.dart';
import 'package:hainong/features/function/support/user_guide/user_guide_page.dart';
import 'package:hainong/features/home/ui/follower_list_page.dart';
import 'package:hainong/features/home/ui/list_like_post_page.dart';
import 'package:hainong/features/introduction_history/introduction_history_page.dart';
import 'package:hainong/features/login/login_page.dart';
import 'package:hainong/features/main/ui/main_page.dart';
import 'package:hainong/features/membership_package/mem_package_using_list_page.dart';
import 'package:hainong/features/order_history/order_history_page.dart';
import 'package:hainong/features/product/ui/product_list_favourite_page.dart';
import 'package:hainong/features/profile/ui/contact_page.dart';
import 'package:hainong/features/setting/setting_page.dart';
import 'package:hainong/features/shop/shop_model.dart';
import 'package:hainong/features/shop/ui/shop_page.dart';
import 'package:package_info/package_info.dart';
import 'package:hainong/common/ui/avatar_circle_widget.dart';
import 'package:hainong/common/ui/divider_widget.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import '../main_repository.dart';
import '../total_model.dart';

abstract class NavigationDrawerCallback {
  void logout();

  void goToLeftPage(BasePage page);

  void goToProfile();

  void refreshInfo();
}

class NavigationDrawer extends StatefulWidget {
  final bool isMain2;
  String? shopName, shopImage, memberRate, province, userLevel;
  String version, env = '', referral = '', link = '';
  int? point;
  final NavigationDrawerCallback callback;

  NavigationDrawer(this.callback, this.shopName, this.shopImage, this.memberRate, this.province, this.version,
    this.userLevel, this.point, {this.isMain2 = false,Key? key}) : super(key: key) {
      if (version.isEmpty) {
        PackageInfo.fromPlatform().then((value) => version = value.version);
      }

      SharedPreferences.getInstance().then((prefs) {
        final Constants constants = Constants();
        shopName = prefs.getString(constants.name)??'';
        shopImage = prefs.getString(constants.image)??'';
        memberRate = prefs.getString(constants.memberRate)??'';
        province = prefs.getString(constants.provinceName)??'';
        referral = prefs.getString('current_referral_code')??'';
        link = prefs.getString('referral_link')??'';
        userLevel = prefs.getString('user_level')??'';
        point = prefs.getInt('points')??0;
        constants.permission = prefs.getString('manager_type') ?? 'member';
        if (prefs.containsKey('contribute_role') &&
            constants.contributeRole == null) constants.contributeRole = jsonDecode(prefs.getString('contribute_role') ?? '{}');
        env = prefs.getString('env') ?? '';
        if (env.isNotEmpty) env = ' - $env';
      });
  }

  @override
  _NavigationDrawerState createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  final DrawerBloc _bloc = DrawerBloc();
  final Widget line = Padding(padding: EdgeInsets.symmetric(horizontal: 50.sp), child: const DividerWidget(color: Colors.black26));

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _bloc.stream.listen((state) {
      if (state is LoadInfoState) widget.callback.refreshInfo();
    });
    if (Constants().isLogin) {
      _bloc.add(LoadStatusMemberPackageEvent());
      _bloc.add(LoadInfoEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Constants().isLogin) {
      return Drawer(child: BlocBuilder(bloc: _bloc, buildWhen: (state1, state2) => state2 is LoadInfoState,
        builder: (context, state) {
          return Container(color: Colors.white, child: Column(children: <Widget>[
            _createShop(state),
            BlocBuilder(bloc: _bloc, builder: (context, stateStt) {
              bool show = true;
              if (stateStt is LoadStatusMemberPackageState) show = stateStt.isSign;
              return show ? const SizedBox() : Container(height: 300.sp,
                child: Row(children: [
                  Column(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LabelCustom('Sử dụng toàn bộ\ntính năng của 2Nông',size: 36.sp,color: Colors.black87,align: TextAlign.left,),
                      InkWell(
                          onTap: () {
                            UtilUI.goBack(context, false);
                            UtilUI.goToNextPage(context, MemPackageUsingListPage());
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 30.sp,vertical: 15.sp),
                            padding: EdgeInsets.symmetric(horizontal: 35.sp,vertical: 30.sp),
                            decoration: BoxDecoration(color: const Color(0xFF1AAD80),
                                borderRadius: BorderRadius.circular(50.sp)),
                            child: Text("Đăng ký gói cước >>", textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 38.sp))
                          ))
                    ]),
                  SizedBox(child: Image.asset('assets/images/v8/ic_member_package_sign.png',
                    fit: BoxFit.fill), height: 210.sp)
                ]), color: const Color(0XFFE8F6E0));
            }, buildWhen: (oldS, newS) => newS is LoadStatusMemberPackageState),
            Expanded(child: ListView(padding: EdgeInsets.only(left: 15.sp, top: 20.sp), children: [
              _createDrawerBodyItem('assets/images/v5/ic_home_page_v5.png',
                  MultiLanguage.get('lbl_my_shop'), context, () {
                    widget.callback.goToLeftPage(ShopPage(drawerCallback: widget.callback));
                  },
                  showTotal: false, showIcon: false),
              line,
              _createDrawerBodyItem('assets/images/v2/ic_favorite_liked_v3.png',
                  MultiLanguage.get('lbl_favourite_like_post'), context, () => _goToLikePosts(),
                  total: state is LoadInfoState ? state.total.total_like_posts : 0,
                  showTotal: state is LoadInfoState && state.total.total_like_posts > 0,
                  showIcon: false, colors: const Color(0xFFEC312A)),
              line,
              _createDrawerBodyItem('assets/images/v2/ic_news_favorite_v3.png',
                  MultiLanguage.get('lbl_favourite_like_news'), context, () => _goToNewsFavorite(context),
                  showTotal: false,
                  showIcon: false, colors: const Color(0xFFFF7A00)),
              line,
              _createDrawerBodyItem('assets/images/v2/ic_saved_product_v3.png',
                  MultiLanguage.get('lbl_saved_products'), context, () => _goToFavouriteProducts(),
                  showIcon: false, colors: const Color(0xFFF4B231),
                  total: state is LoadInfoState ? state.total.total_products : 0,
                  showTotal: state is LoadInfoState && state.total.total_products > 0),
              line,
              _createDrawerBodyItem('assets/images/ic_invoice_user.png',
                  'Lịch sử đơn hàng', context, () => _openOrderHistory(),
                  showIcon: false, colorIcon: Colors.green, colors: Colors.green,
                  total: state is LoadInfoState ? state.total.total_shop_invoice : 0,
                  showTotal: state is LoadInfoState && state.total.total_shop_invoice > 0),
              line,
              _createDrawerBodyItem('assets/images/v2/ic_introduction_history_v3.png',
                  'Giới thiệu Hai Nông', context, () => _openIntroductionHistory(),
                  showIcon: false, colors: const Color(0xFFF4B231), showTotal: false),
              line,
              _createDrawerBodyItem('assets/images/v2/ic_follow_v3.png', MultiLanguage.get('lbl_followers'),
                  context, () {
                    if (state is LoadInfoState) {
                      _goToFollowers(state.total.total_followers,
                          state.total.total_followings,state.total.total_follow_posts);
                    }}, showTotal: false, showIcon: false),
              line,
              _createDrawerBodyItem('assets/images/v2/ic_fun_entertain_v3.png', MultiLanguage.get('lbl_entertain'),
                  context, () => _goToUserGuid(context), showTotal: false, showIcon: false),
              line,
              _createDrawerBodyItem('assets/images/v2/ic_setting_v3.png', MultiLanguage.get('lbl_setting'),
                  context, () => _goToSetting(context), showTotal: false, showIcon: false),
              line,
              _createDrawerBodyItem('assets/images/v2/ic_exit_v3.png', MultiLanguage.get('lbl_logout'),
                  context, () => _confirmLogout(context), showTotal: false, showIcon: false)
            ])),
            const DividerWidget(color: Colors.black26),
            Container(padding: EdgeInsets.all(40.sp),
                child: LabelCustom(MultiLanguage.get('lbl_user_version') + widget.version + widget.env,
                    align: TextAlign.center, color: Colors.black, size: 35.sp, weight: FontWeight.normal))
          ]));
        }));
    }
    return Drawer(child: Column(children: [
      Container(width: 1.sw, decoration: const BoxDecoration(image: DecorationImage(
        image: AssetImage('assets/images/v2/ic_background_menu_v3.png'), fit: BoxFit.cover),
        color: Colors.white),
        child: Container(padding: EdgeInsets.fromLTRB(52.sp, 150.sp, 52.sp, 0),
          color: const Color(0xFF00553C).withOpacity(0.6), child: Column(
            mainAxisAlignment: MainAxisAlignment.end, children: [
              Row(children: [
                ImageIcon(const AssetImage('assets/images/v2/ic_location_v2.png'), size: 60.sp, color: Colors.white),
                Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 20.sp), child:
                  LabelCustom(widget.province!, weight: FontWeight.normal))),
                GestureDetector(onTap: ()=> _showMessageLoginOrCreate(context),
                  child: ImageIcon(const AssetImage('assets/images/v2/ic_contact_v2.png'), size: 60.sp, color: Colors.white)),
              ]),
              Padding(padding: EdgeInsets.only(top: 40.sp),
                child: AvatarCircleWidget(border: Border.all(
                  color: Colors.white, width: 4.0), size: 250.sp,
                  assetsImageReplace: 'assets/images/v2/ic_avatar_drawer_v2.png')),
              Container(width: 0.4.sw, child: UtilUI.createCustomButton(
                () => _loginOrSignUp(context, LoginPage()), MultiLanguage.get('btn_login_lower'),
                elevation: 0.0, color: Colors.transparent, textColor: Colors.white,
                borderColor: Colors.white, radius: 0.0), padding: EdgeInsets.only(top: 40.sp, bottom: 60.sp))
            ]))),
      Expanded(child: Container(
                  color: Colors.white,
                  child: ListView(padding: EdgeInsets.only(left: 5, top: 20.sp), children: [
                    _createDrawerBodyItem(
                        'assets/images/v2/ic_post_new_v3.png',
                        MultiLanguage.get('btn_post_post2'),
                        context,
                            () => _showMessageLoginOrCreate(context),
                        showTotal: false,showIcon: false),
                    line,
                    _createDrawerBodyItem(
                        'assets/images/v2/ic_post_product_v3.png',
                        MultiLanguage.get('btn_post_product'),
                        context,
                            () => _showMessageLoginOrCreate(context),
                        showTotal: false,showIcon: false),
                    line,
                    _createDrawerBodyItem(
                        'assets/images/v2/ic_fun_entertain_v3.png',
                        MultiLanguage.get('lbl_entertain'),
                        context, () => _goToUserGuid(context),
                        showTotal: false,showIcon: false)
                  ]),
                )),
      const DividerWidget(color: Colors.black26),
      Container(padding: EdgeInsets.all(40.sp),
          child: LabelCustom(MultiLanguage.get('lbl_user_version') + widget.version + widget.env,
              align: TextAlign.center, color: Colors.black, size: 35.sp, weight: FontWeight.normal))
    ]));
  }

  Widget _createDrawerHeader() => Container(width: 1.sw,
    decoration: const BoxDecoration(color: Color(0xFF0D986F),
      image: DecorationImage(image: AssetImage('assets/images/v2/ic_background_menu_v3.png'), fit: BoxFit.cover)),
    child: Container(padding: EdgeInsets.fromLTRB(52.sp, 150.sp, 52.sp, 0), color: const Color(0xFF00553C).withOpacity(0.6),
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Row(children: [
            ImageIcon(const AssetImage('assets/images/v2/ic_location_v2.png'), size: 60.sp, color: Colors.white),
            Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 20.sp), child:
            LabelCustom(widget.province!, weight: FontWeight.normal))),
            GestureDetector(onTap: ()=> _openContact(context),
              child: ImageIcon(const AssetImage('assets/images/v2/ic_contact_v2.png'), size: 60.sp,color: Colors.white,))
          ]),
          Padding(padding: EdgeInsets.symmetric(vertical: 40.sp), child: ButtonImageWidget(200,
              () => widget.callback.goToLeftPage(ShopPage(drawerCallback: widget.callback)),
              AvatarCircleWidget(border: Border.all(color: Colors.white30, width: 8.sp),
              size: 250.sp, link: widget.shopImage!, stack: true, assetsImageReplace: 'assets/images/v2/ic_avatar_drawer_v2.png'))),
          GestureDetector(onTap: () => _goToProfile(), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Flexible(child: LabelCustom(widget.shopName!, size: 60.sp, align: TextAlign.center)),
            Padding(padding: EdgeInsets.only(left: 10.sp),
              child: ImageIcon(const AssetImage('assets/images/v2/Ic_change_profile_v2.png'), size: 42.sp,color: Colors.white))
          ])),
          Padding(padding: EdgeInsets.symmetric(vertical: 10.sp), child: Wrap(children: [
            if (widget.userLevel!.isNotEmpty) LabelCustom(widget.userLevel! + (widget.point! > 0 ? ' - ' : ''), weight: FontWeight.normal),
            if (widget.point! > 0) LabelCustom(widget.point!.toString() + MultiLanguage.get('lbl_point'), weight: FontWeight.normal)
          ])),
          Wrap(runAlignment: WrapAlignment.center, alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, children: [
            LabelCustom(widget.memberRate!, weight: FontWeight.normal),
            Constants().permission != null && Constants().permission!.isNotEmpty && !Constants().permission!.contains('member') ?
              ButtonImageWidget(5, () => _openManagementReport(context), Container(decoration: BoxDecoration(border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(5)), padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: LabelCustom(Constants().permission!.toUpperCase(), weight: FontWeight.normal))) : const SizedBox(width: 4),
            if (Constants().contributeRole != null && Constants().contributeRole!.isNotEmpty)
              ButtonImageWidget(5, () => _openManagementContent(context), Container(decoration: BoxDecoration(border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(5)), padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
                child: const LabelCustom('CTV', weight: FontWeight.normal))),
            if (widget.referral.isNotEmpty)
              Padding(padding: EdgeInsets.only(top: 16.sp), child: Row(children: [
                LabelCustom(widget.referral, weight: FontWeight.w500, size: 48.sp),
                Padding(padding: EdgeInsets.symmetric(horizontal: 20.sp), child: ButtonImageWidget(5, () {
                  Clipboard.setData(ClipboardData(text: widget.referral));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mã giới thiệu đã được lưu")));
                }, Icon(Icons.copy, color: Colors.white, size: 48.sp))),
                ButtonImageWidget(5, () {
                  if (widget.link.isNotEmpty) UtilUI.shareDeeplinkTo(context, widget.link, 'Profile Referral Link -> Option Share Dialog -> Choose "Share"', 'Home Screen');
                }, Icon(Icons.share, color: Colors.white, size: 48.sp))
              ], mainAxisAlignment: MainAxisAlignment.center))
          ]),
          SizedBox(height: 60.sp)
        ])));

  Widget _createDrawerBodyItem(String assetPath, String text, BuildContext context, Function onPressed,
      {int total = 0, bool showTotal = true, bool showIcon = true,
        Color colors = Colors.transparent, Color? colorIcon}) =>
      Material(
        color: Colors.white,
          child: InkWell(
          child: Padding(padding: EdgeInsets.symmetric(vertical: 44.sp,horizontal: 50.sp), child: Row(children: <Widget>[
            Image.asset(assetPath, height: 60.sp, width: 60.sp, color: colorIcon),
            SizedBox(width: 42.sp),
            Expanded(child: Row(children: [
              Expanded(child: Text(text, style: TextStyle(
                  fontSize: 48.sp, color: Colors.black))),
              if (showTotal)
                Container(
                decoration: BoxDecoration(
                    color: colors,
                  borderRadius: BorderRadius.all(Radius.circular(20.sp))
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.sp,vertical: 4.sp),
                child: Text(showTotal ? '$total' : '',
                    style: TextStyle(fontSize: 30.sp, color: Colors.white)),
              )
            ])),
            showIcon ? Icon(Icons.navigate_next,
                size: 70.sp, color: Colors.white) : Container(),
          ])),
          onTap: () {onPressed();}));

  Widget _createShop(state) {
    if (state is LoadInfoState) {
      ShopModel shop = state.shop;
      widget.shopImage = shop.image;
      widget.shopName = shop.name;
      widget.province = shop.province_name;
      widget.referral = shop.website;
      widget.link = shop.facebook;
    }
    return _createDrawerHeader();
  }

  void _showMessageLoginOrCreate(context) =>
      UtilUI.showCustomDialog(context, MultiLanguage.get(LanguageKey().msgLoginOrCreate));

  void _loginOrSignUp(BuildContext context, page) => UtilUI.goToPage(context, page, null);

  void _confirmLogout(BuildContext context) =>
      UtilUI.showCustomDialog(context, MultiLanguage.get('msg_logout_confirm'), isActionCancel: true).then((value) {
        if (value != null && value) {
          widget.callback.logout();
          Util.trackActivities('home_page', method: 'onTap', path: 'Logout');
        }
      });

  void _goToProfile() {
    widget.callback.goToProfile();
    Util.trackActivities('home_page', method: 'Open', path: 'Profile Screen');
  }

  void _goToLikePosts() {
    widget.callback.goToLeftPage(ListLikePostPage(isMain2: widget.isMain2));
    Util.trackActivities('home_page', method: 'Open', path: 'List Posts Liked Screen');
  }

  void _goToFollowers(int follower, int following, int followPosts) {
    widget.callback.goToLeftPage(FollowerListPage(follower, following,followPosts, isMain2: widget.isMain2));
    Util.trackActivities('home_page', method: 'Open', path: 'Follower List Screen');
  }

  void _goToFavouriteProducts() {
    widget.callback.goToLeftPage(ProductListFavouritePage(isMain2: widget.isMain2));
    Util.trackActivities('home_page', method: 'Open', path: 'Favorite List Products Screen');
  }

  void _goToNewsFavorite(BuildContext context) {
    UtilUI.goBack(context, false);
    UtilUI.goToNextPage(context, NewsFavoriteListPage());
    Util.trackActivities('home_page', method: 'Open', path: 'News Favorite Screen');
  }

  void _goToSetting(BuildContext context) {
    UtilUI.goBack(context, false);
    UtilUI.goToNextPage(context, SettingPage());
    Util.trackActivities('home_page', method: 'Open', path: 'Setting Screen');
  }

  void _goToUserGuid(BuildContext context) {
    UtilUI.goBack(context, false);
    UtilUI.goToNextPage(context, const UserGuidePage());
    Util.trackActivities('home_page', method: 'Open', path: 'User Guide Screen');
  }

  void _openContact(BuildContext context) {
    UtilUI.goBack(context, false);
    UtilUI.goToNextPage(context, ContactPage());
    Util.trackActivities('home_page', method: 'Open', path: 'Contact Screen');
  }

  void _openManagementReport(BuildContext context) {
    if (Constants().permission!= null && Constants().permission! != 'member') {
      UtilUI.goBack(context, false);
      UtilUI.goToNextPage(context, AdminPage(Constants().permission! == 'admin'));
      Util.trackActivities('home_page', method: 'Open', path: 'Admin Screen');
    }
  }

  void _openManagementContent(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('phone') == '') {
      UtilUI.showCustomDialog(context, 'Tài khoản của bạn hiện chưa có số điện thoại, vui lòng nhập để có trải nghiệm tốt hơn', isActionCancel: true)
          .then((value) {
        if (value != null && value == true) {
          if(Navigator.of(context).canPop()) {Navigator.pop(context, false);}
          UtilUI.goToNextPage(context, MainPage(index: 4));
        }
      });
      return;
    }
    if (Constants().contributeRole != null && Constants().contributeRole!.isNotEmpty) {
      UtilUI.goBack(context, false);
      UtilUI.goToNextPage(context, NewsManageListPage());
      Util.trackActivities('home_page', method: 'Open', path: 'Management News Screen');
    }
  }

  void _openOrderHistory() {
    UtilUI.goBack(context, false);
    UtilUI.goToNextPage(context, OrderHistoryPage());
    Util.trackActivities('home_page', method: 'Open', path: 'Order History Screen');
  }

  void _openIntroductionHistory() {
    UtilUI.goBack(context, false);
    UtilUI.goToNextPage(context, IntroductionHistoryPage());
    Util.trackActivities('home_page', method: 'Open', path: 'Introduction History Screen');
  }
}

class LoadInfoState extends BaseState {
  final ShopModel shop;
  final TotalModel total;
  LoadInfoState(this.shop, this.total);
}
class LoadInfoEvent extends BaseEvent {}
class DrawerBloc extends BaseBloc {
  DrawerBloc() {
    on<LoadInfoEvent>(_getShop);
    on<LoadStatusMemberPackageEvent>((event, emit) async {
      dynamic data = await ApiClient().getData('base/option?key=membership_package');
      if (data != null && (data[0]['value']??'false') == 'true') {
        data = await ApiClient().getData('membership_packages/membership_packages/current_package');
        if (data == null || (data['id']??-1) < 0) emit(LoadStatusMemberPackageState(false));
      }
    });
  }

  _getShop(event, emit) async {
    final Constants constants = Constants();
    final prefs = await SharedPreferences.getInstance();
    final ShopModel shop = ShopModel();
    shop.id = prefs.getInt(constants.shopId)??-1;
    shop.name = prefs.getString(constants.shopName)??'';
    if (shop.name.isEmpty) shop.name = prefs.getString(constants.name)??'';
    shop.email = prefs.getString(constants.shopEmail)??'';
    shop.phone = prefs.getString(constants.shopPhone)??'';
    shop.province_id = prefs.getString(constants.shopProvinceId)??'';
    shop.province_name = prefs.getString(constants.shopProvinceName)??'';
    shop.district_id = prefs.getString(constants.shopDistrictId)??'';
    shop.district_name = prefs.getString(constants.shopDistrictName)??'';
    shop.website = prefs.getString('current_referral_code')??'';
    shop.facebook = prefs.getString('referral_link')??'';
    shop.shop_star = prefs.getInt(constants.shopStar)??0;
    shop.image = prefs.getString(constants.shopImage)??'';
    final total = TotalModel();
    final response = await MainRepository().getTotal();
    if (response.checkOK()) total.copy(response.data);
    emit(LoadInfoState(shop, total));
  }
}
