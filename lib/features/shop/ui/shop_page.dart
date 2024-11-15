import 'package:hainong/common/database_helper.dart';
import 'package:hainong/common/ui/button_custom.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/tab_item.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import 'package:hainong/common/ui/permission_image_page_state.dart';
import 'package:hainong/features/extend_user/ui/extend_user_page.dart';
import 'package:hainong/features/home/ui/import_ui_home.dart';
import 'package:hainong/features/membership_package/mem_package_using_list_page.dart';
import 'package:hainong/features/profile/ui/point_list_page.dart';
import 'package:hainong/features/profile/ui/profile_page.dart';
import 'album_page.dart';
import 'import_ui_shop.dart';
import '../album_model.dart';
import '../bloc/album_bloc.dart';

class ShopPage extends BasePage {
  final ChangeUICallback? callback;
  final NavigationDrawerCallback? drawerCallback;
  final ShopModel? shop;
  final bool isOwner, isView, hasHeader;
  final int business;

  ShopPage(
      {Key? key, this.callback,
      this.drawerCallback,
      this.shop,
      this.isOwner = true,
      this.isView = false,
      this.hasHeader = false,
      this.business = -1})
      : super(key: key, pageState: _ShopPageState()) {
    pageState.callback = callback;
  }
}

class _ShopPageState extends PermissionImagePageState implements ChangeUICallback, ProfilePageCallback {
  final List<bool> _selectTab = [true, false, false];
  bool _isFollow = false;
  int _otherPage = 1, _point = 0, _page = 1;
  final _otherScroller = ScrollController();
  final List<Widget> _otherList = [];
  final ShopModel _shop = ShopModel();
  final ScrollBloc _scrollBloc = ScrollBloc(ScrollState());
  final List<ItemModel> _imageTypes = [];
  List<AlbumModel> _listAlbum = [];
  TextEditingController? _ctrPhone, _ctrPoint;
  FocusNode? _focusPhone, _focusPoint;
  late Widget _header;
  String _friendStatus = "";
  int? _countClick;

  @override
  void loadFiles(List<File> files) {
    if (files.isEmpty) return;
    bloc!.add(UploadBackgroundImageShopEvent(files.first.path));
  }

  @override
  void dispose() {
    _listAlbum.clear();;
    _otherList.clear();
    _selectTab.clear();
    _scrollBloc.close();
    _otherScroller.dispose();
    _ctrPhone?.dispose();
    _ctrPoint?.dispose();
    _focusPhone?.dispose();
    _focusPoint?.dispose();
    super.dispose();
  }

  @override
  initState() {
    _initImageTypes();
    bloc = ShopBloc(ShopState());
    _initScroller();
    super.initState();
    _initBloc();
    _header = Container(width: 1.sw, decoration: _decoration(), margin: EdgeInsets.fromLTRB(40.sp, 20.sp, 40.sp, 20.sp), child: subBodyUI());
    _otherList.add(_header);
  }

  @override
  void getValueFromSecondPage(value) {
    if (value != null) {
      if (value is BaseResponse) {
        if (value.msgCreateProduct == value.msg || value.msgUpdateProduct == value.msg) {
          _loadProducts();
        } else if (value.msgCreatePost == value.msg) {
          _changeTab(2);
          Timer(const Duration(milliseconds: 500), () => _changeTab(0));
        }
      } else if (value is bool && value) {
        bloc!.add(LoadShopEvent());
        (widget as ShopPage).drawerCallback!.refreshInfo();
      }
    }
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Scaffold(
      body: GestureDetector(onTapUp: (value) {clearFocus();},
          child: Stack(children: [
            Column(children: [
              Expanded(flex: 28, child: Image.asset('assets/images/ic_line_header.png',
                  fit: BoxFit.fill, width: 1.sw)),
              Expanded(flex: 72, child: Container(color: StyleCustom.backgroundColor))
            ]),
            createUI(),
            //Loading(bloc)
          ])));

  @override
  Widget createHeaderUI() {
    //final header = (widget as ShopPage).hasHeader;
    final logo = GestureDetector(child: Image.asset('assets/images/ic_logo.png', height: 120.sp), onTap: () async {
      _countClick ??= 0;
      _countClick = _countClick! + 1;
      bool isOn = true;
      if (_countClick! > 20) {
        _countClick = null;
        isOn = await DBHelperUtil().setLogFile();
        UtilUI.showCustomDialog(context, 'Đã ${isOn?'mở':'tắt'} chế độ log file').whenComplete(() {
          if (isOn) checkPermissions(ItemModel(id: languageKey.lblGallery, name: 'Đọc file'));
        });
      }
    });
    return Padding(padding: EdgeInsets.only(top: 40.sp + WidgetsBinding.instance.window.padding.top.sp, left: 20.sp),
        child: Stack(children: [
          logo,
          Align(alignment: Alignment.centerLeft, child: IconButton(onPressed: () => UtilUI.goBack(context, false),
              icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back, color: Colors.white)))
        ], alignment: Alignment.center));
  }

  @override
  Widget createBodyUI() => Expanded(child: createFieldsSubBody());

  @override
  Widget subBodyUI() {
    final isOwner = (widget as ShopPage).isOwner;
    return Column(children: [
      BlocBuilder(bloc: bloc, buildWhen: (state1, state2) => state2 is LoadShopState || state2 is ReloadBackgroundImageShopState,
          builder: (context, state) => Container(
              decoration: BoxDecoration(
                color: Colors.grey,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20.sp), topRight: Radius.circular(20.sp)),
                  image: DecorationImage(
                      colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.75), BlendMode.dstIn),
                      image: FadeInImage.assetNetwork(
                          placeholder: '',
                          imageErrorBuilder: (_, __, ___) => const SizedBox(),
                          placeholderErrorBuilder: (_, __, ___) => const SizedBox(),
                          image: Util.getRealPath(_shop.background_image)).image,
                      fit: BoxFit.cover)),
              child: Stack(alignment: Alignment.topRight,
                  children: [
                    Column(children: [
                      Padding(padding: EdgeInsets.only(top: 40.sp, bottom: 20.sp), child: subBodyHeaderUI()),
                      Row(children: [
                        if (isOwner) Flexible(child: Row(children: [
                              Icon(Icons.edit_outlined, color: Colors.transparent, size: 36.sp),
                              Flexible(child: UtilUI.createLabel("Thông tin", color: Colors.transparent, fontSize: 30.sp, fontWeight: FontWeight.bold))
                            ], mainAxisSize: MainAxisSize.min)),
                        Flexible(child: UtilUI.createLabel(_shop.name, color: _shop.background_image.isEmpty ?
                            Colors.black87 : Colors.white, fontSize: 42.sp, textAlign: TextAlign.center, line: 2)),
                        if (isOwner) Flexible(child: GestureDetector(onTap: _goToProfile, child: Row(children: [
                            Icon(Icons.edit_outlined, color: const Color(0xFFFFCD1B), size: 36.sp),
                            Flexible(child: UtilUI.createLabel("Thông tin", color: const Color(0xFFFFCD1B), fontSize: 30.sp, fontWeight: FontWeight.bold))
                          ], mainAxisSize: MainAxisSize.min)))
                      ], mainAxisAlignment: MainAxisAlignment.center),
                      UtilUI.createStars(rate: _shop.shop_star),
                      if (isOwner)
                        BlocBuilder(bloc: bloc,
                            buildWhen: (statePoint1, statePoint2) => statePoint2 is GetPointState,
                            builder: (context, statePoint) {
                              if (statePoint is GetPointState) _point = statePoint.point;
                              return Padding(padding: EdgeInsets.only(top: 10.sp),
                                  child: Wrap(children: [
                                    if (_shop.user_level.isNotEmpty)
                                      UtilUI.createLabel(_shop.user_level, color:  _shop.background_image.isEmpty ? Colors.black87 :  Colors.white,
                                          fontSize: 40.sp, fontWeight: FontWeight.bold),
                                    _point == 0 ? const SizedBox() : UtilUI.createLabel((_shop.user_level.isEmpty? '' : ' - ') + _point.toString() + MultiLanguage.get('lbl_point'), color:  _shop.background_image.isEmpty ? Colors.black87 :  Colors.white,
                                        fontSize: 40.sp, fontWeight: FontWeight.bold)
                                  ], crossAxisAlignment: WrapCrossAlignment.center));
                            }),
                      Wrap(children: [
                        if (!isOwner && _shop.user_level.isNotEmpty)
                          UtilUI.createLabel(_shop.user_level + (_shop.member_rate.isEmpty ? '' : ' - '), color:  _shop.background_image.isEmpty ? Colors.black87 :  Colors.white,
                              fontSize: 40.sp, fontWeight: FontWeight.bold),
                        if (_shop.member_rate.isNotEmpty)
                          UtilUI.createLabel(_shop.member_rate, color:  _shop.background_image.isEmpty ? Colors.black87 :  Colors.white,
                              fontSize: 40.sp, fontWeight: FontWeight.bold),
                      ]),
                      if(isOwner) Row(children: [
                        BlocBuilder(bloc: bloc, builder: (context, stateStt) {
                          bool show = false;
                          if (stateStt is LoadStatusMemberPackageState) show = stateStt.isSign;
                          return show ? Padding(padding: EdgeInsets.only(right: 20.sp),
                            child: ButtonCustom(() => UtilUI.goToNextPage(context, MemPackageUsingListPage()),
                              'Gói cước sử dụng', elevation: .0, size: 35.sp, color: const Color(0xFFDDB13F))) : const SizedBox();
                        }, buildWhen: (oldS, newS) => newS is LoadStatusMemberPackageState && newS.isSign),
                        UtilUI.createCustomButton(_openExtendUserPage,
                            MultiLanguage.get('btn_extend_user'),
                            color: const Color(0xFF03B273), fontSize: 35.sp, elevation: .0)
                      ], mainAxisAlignment: MainAxisAlignment.center),
                      Wrap(children: [
                        if (isOwner)
                          BlocBuilder(bloc: bloc,
                              buildWhen: (statePoint1, statePoint2) => statePoint2 is GetPointState,
                              builder: (context, statePoint) {
                                if (statePoint is GetPointState) _point = statePoint.point;
                                return _point == 0 ? const SizedBox() : ButtonCustom(_showDialogTransferPoint,
                                    MultiLanguage.get('ttl_transfer_point'), elevation: .0, size: 35.sp,
                                    color: const Color(0xFFDDB13F));
                              }),
                        isOwner ? UtilUI.createCustomButton(_showPointList,
                            MultiLanguage.get('lbl_point_list'),
                            color: const Color(0xFF03B273), fontSize: 35.sp, elevation: .0)
                            : BlocBuilder(bloc: bloc, buildWhen: (stateFollow1, stateFollow2) =>
                        stateFollow2 is GetFollowShopState || stateFollow2 is FollowShopState ||
                            stateFollow2 is UnFollowShopState,
                            builder: (context, stateFollow) => UtilUI.createCustomButton(
                                () => _followShop(context),
                                MultiLanguage.get(_isFollow ? 'btn_unfollow' : 'btn_follow'),
                                fontSize: 35.sp, elevation: .0,
                                color: _isFollow ? Colors.black26 : Colors.deepOrangeAccent)),
                         BlocBuilder(bloc: bloc, buildWhen: (stateFriend1, stateFriend2) =>
                            stateFriend2 is GetFriendStatusState || stateFriend2 is AddFriendState || stateFriend2 is UnFriendState,
                            builder: (context, stateFriend) {
                              return isFriendShow() ?
                               UtilUI.createCustomButton(
                                      () => postFriendStatus(), getFriendStatusName(),
                                      fontSize: 35.sp,
                                      elevation: .0,
                                      color: getFriendStatusColor())
                                  : const SizedBox();
                            }),
                      ], crossAxisAlignment: WrapCrossAlignment.center, spacing: 20.sp),
                      DividerWidget(margin: EdgeInsets.only(top: 20.sp))
                    ]),
                    if (isOwner)
                      _shop.background_image.isEmpty ? Container(width: 25, height: 25, margin: EdgeInsets.all(20.sp),
                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                          child: ButtonImageCircleWidget(25, () => _uploadBackgroundImage(),
                              child: Icon(Icons.photo_camera, color: Colors.white, size: 40.sp)))
                          : Column(children: [
                        Container(width: 25, height: 25, margin: EdgeInsets.all(20.sp),
                            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(20)),
                            child: ButtonImageCircleWidget(25, () => _deleteBackgroundImage(),
                                child: const Icon(Icons.close, color: Colors.white38, size: 20))),
                        Container(width: 25, height: 25, margin: EdgeInsets.only(right:20.sp, left: 20.sp),
                            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                            child: ButtonImageCircleWidget(25, ()=>_uploadBackgroundImage(),
                                child: Icon(Icons.camera_alt_outlined, color: Colors.white, size: 40.sp)))
                      ])
                  ]))),
      BlocBuilder(bloc: bloc, buildWhen: (state1, state2) => state2 is ChangeTabShopState,
          builder: (context, state) => Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              SizedBox(width: 20.sp),
              TabItem('lbl_posts', 0, _selectTab[0], _changeTab,size: 42.sp, expanded: false),
              TabItem('Thông tin shop', 2, _selectTab[2], _changeTab,size: 42.sp,parseTitle: false),
              TabItem('lbl_shop', 1, _selectTab[1], _changeTab,size: 42.sp, expanded: false),
              SizedBox(width: 20.sp)
          ])),
    ]);
  }

  @override
  Widget subBodyHeaderUI() => BlocBuilder(bloc: bloc, buildWhen: (state1, state2) => state2 is LoadShopState,
      builder: (context, state) => ButtonImageCircleWidget(200.sp,
        () {goToSubPage(ShowAvatarPage(_shop.image));}, link: _shop.image));

  @override
  Widget createFooterUI() => const SizedBox();

  @override
  Widget createFieldsSubBody() => BlocBuilder(bloc: bloc,
      buildWhen: (oldState, newState) => newState is ChangeTabShopState,
      builder: (context, state) => _selectTabUI());

  Widget _selectTabUI() {
    if (_selectTab[0]) return _createTabPost();
    else if (_selectTab[1]) return _createTabProduct();
    else if (_selectTab[2]) return _createTabAboutUs();
    else return const SizedBox();
  }

  Widget _albumUser() {
    return BlocBuilder(
        bloc: bloc,
        buildWhen: (OldState, NewState) => NewState is LoadAlbumUserState || NewState is ChangeTabShopState,
        builder: (context, state) {
          final List<Widget> list_album = [];
          if(_listAlbum.isNotEmpty){
            for(int i = 0; i < _listAlbum.length; i++) {
              list_album.add(
                  InkWell(
                      onTap: () {
                        UtilUI.goToNextPage(context, AlbumPage(_listAlbum,_reloadAlbum,album_id: _listAlbum[i].id,is_user: (widget as ShopPage).isOwner,title: _listAlbum[i].name,),funCallback: _reloadAlbum);
                      },
                      child: Container(height: 230.sp,
                        decoration: BoxDecoration(
                            color: StyleCustom.primaryColor,
                            borderRadius: BorderRadius.all(Radius.circular(20.sp)),
                            border: Border.all(color: Colors.black,width: 2.sp),
                            image: DecorationImage(
                                image: _listAlbum[i].thumbnail.name.isNotEmpty
                                    ? FadeInImage.assetNetwork(
                                    image: _listAlbum[i].thumbnail.name,
                                    placeholder: 'assets/images/bg_white.png')
                                    .image
                                    : Image.asset('assets/images/bg_white.png').image,
                                fit: BoxFit.cover)
                        ),
                        padding: EdgeInsets.all(20.sp),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 40.sp,
                              width: 40.sp,
                              child: Icon(Icons.photo_library_outlined,color: _listAlbum[i].thumbnail.name.isNotEmpty ? Colors.white : Colors.black,size: 40.sp,),
                            ),
                            SizedBox(width: 12.sp,),
                            Text(_listAlbum[i].name,style: TextStyle(fontSize: 40.sp,color: _listAlbum[i].thumbnail.name.isNotEmpty ? Colors.white : Colors.black ,fontWeight: _listAlbum[i].thumbnail.name.isNotEmpty ? FontWeight.bold : FontWeight.normal),),
                          ],
                        ),
                      ),
                    ),
              );
            }
            // if((widget as ShopPage).isOwner) {
            //   list_album.add(
            //       GestureDetector(
            //           onTap: () {
            //             _showDialogAddAlbum();
            //           },
            //           child: Container(
            //             decoration: BoxDecoration(
            //                 color: Colors.transparent,
            //                 borderRadius: BorderRadius.all(Radius.circular(40.sp)),
            //                 border: Border.all(color: Colors.black,width: 2.sp)
            //             ),
            //             padding: EdgeInsets.all(20.sp),
            //             child: Row(
            //               mainAxisSize: MainAxisSize.min,
            //               children: [
            //                 SizedBox(
            //                   height: 40.sp,
            //                   width: 40.sp,
            //                   child: Icon(Icons.add,color: Colors.black,size: 40.sp,),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ),
            //   );
            // }
            return Padding(padding: EdgeInsets.fromLTRB(40.sp, 20.sp, 40.sp, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(runSpacing: 20.sp, spacing: 20.sp, children: list_album,alignment: WrapAlignment.start),
                    if((widget as ShopPage).isOwner) GestureDetector(
                      onTap: () {
                        _showDialogAddAlbum();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(top: 30.sp, bottom: 20.sp),
                        width: 1.sw,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10.sp)),
                            boxShadow: [BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 7,
                                offset: const Offset(0, 1) // changes position of shadow
                            )]
                        ),
                        padding: EdgeInsets.all(25.sp),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 50.sp,
                              width: 50.sp,
                              child: Icon(Icons.add_photo_alternate_outlined,color: Colors.black,size: 50.sp,),
                            ),
                            UtilUI.createLabel(" Thêm album", color: Colors.black87,
                                fontSize: 40.sp, fontWeight: FontWeight.bold)
                          ],
                        ),
                      ),
                    )
                  ],
                ));
          }
          return const SizedBox();
        });
  }

  BoxDecoration _decoration() => BoxDecoration(borderRadius: BorderRadius.circular(20.sp), color: Colors.white,
    boxShadow: [
      BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 1))
    ]);

  Widget _createTabPost() {
    String shopId = '';
    ShopPage page = widget as ShopPage;
    if (page.shop != null) shopId = page.shop!.id == -1 ? '' : page.shop!.id.toString();
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(child: HomePage(isMyPost: page.isOwner, isView: page.isView, shopId: shopId, callback: this,
        hasHighlight: false, allowGotoShop: false, isShop: true, hasPadding: true, header: Column(
            children: [
              _header,
              _albumUser(),
            ], crossAxisAlignment: CrossAxisAlignment.start
          ))),
      SizedBox(height: 10.sp),
      if (!page.isView) ElevatedButton(
        onPressed: () {UtilUI.goToNextPage(context, PostPage(_shop.name, _shop.image), funCallback: getValueFromSecondPage);},
            style: ElevatedButton.styleFrom(
                side: const BorderSide(
                  color: Colors.transparent,
                ),
                primary: StyleCustom.buttonColor),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.camera_alt, color: Colors.white),
          SizedBox(width: 20.sp),
          UtilUI.createLabel(MultiLanguage.get('btn_create_post')),
        ]))
    ]);
  }

  Widget _createTabProduct() => Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
    Expanded(child: BlocBuilder(bloc: bloc, buildWhen: (oldState, newState) => newState is LoadOtherProductsShopState,
          builder: (context, state) => _otherList.isEmpty ? SizedBox(width: 1.sw) :
            ListView.builder(controller: _otherScroller, padding: EdgeInsets.zero,
              itemCount: _otherList.length, itemBuilder: (context, index) => _otherList[index]))),
    if (!(widget as ShopPage).isView) ElevatedButton(
            onPressed: () {
              UtilUI.goToNextPage(context, ProductPage(shopName: _shop.name),
                  funCallback: getValueFromSecondPage);
            },
            style: ElevatedButton.styleFrom(
                side: const BorderSide(
                  color: Colors.transparent,
                ),
                primary: StyleCustom.buttonColor),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.camera_alt, color: Colors.white),
              SizedBox(width: 20.sp),
              UtilUI.createLabel(MultiLanguage.get('btn_upload_product')),
    ]))
  ]);

  Widget _createTabAboutUs() => SingleChildScrollView(child: Column(children: [
    _header,
    Container(margin: EdgeInsets.fromLTRB(40.sp, 20.sp, 40.sp, 40.sp), padding: EdgeInsets.all(40.sp), decoration: _decoration(),
      child: BlocBuilder(bloc: bloc, buildWhen: (oldState, newState) => newState is LoadShopState,
        builder: (context, state) => Column(mainAxisSize: MainAxisSize.min, children: [
            _createRowAboutUs('assets/images/ic_location.png', _shop.district_name + ', ' + _shop.province_name, 'location'),
            SizedBox(height: 40.sp),
            _createRowAboutUs('assets/images/ic_phone.png', _shop.hidden_phone == 1 ? _shop.phone : _hiddenString(_shop.phone), 'phone'),
            SizedBox(height: 40.sp),
            _createRowAboutUs('assets/images/ic_email.png', _shop.hidden_email == 1 ? _shop.email : _hiddenString(_shop.email), 'email'),
            SizedBox(height: 40.sp),
            _createRowAboutUs('assets/images/ic_website.png', _shop.website, 'url')
        ])))
  ]));

  Widget _createRowAboutUs(String assetPath, String title, String type) => ButtonImageWidget(10.sp, () => _goTo(type, title),
      Row(children: [
        Image.asset(assetPath, height: 50.sp, width: 50.sp),
        Padding(padding: EdgeInsets.all(10.sp)), Expanded(child: Text(title, style: TextStyle(fontSize: 40.sp, color: Colors.black)))
      ]));

  String _hiddenString(String value) {
    String temp = '';
    for (int i = value.length - 1; i > -1; i--) temp += '*';
    return temp;
  }

  _initImageTypes() {
    setOnlyImage();
    _imageTypes.add(ItemModel(id: languageKey.lblCamera, name: MultiLanguage.get(languageKey.lblCamera)));
    _imageTypes.add(ItemModel(id: languageKey.lblGallery, name: MultiLanguage.get(languageKey.lblGallery)));
  }
  void _showDialogAddAlbum() {
    clearFocus();
    UtilUI.showConfirmDialog(
        context,
        "Nhập tên cho album mới",
        '', "Tên album không thể để trắng",
        title: "Thêm album mới",
        inputType: TextInputType.text,)
        .then((value) {
      if (value is String) {
        bloc!.add(CreateNewAlbumEvent(value));
      }
    });
  }

  _goTo(String type, String value) {
    if (value.isNotEmpty) {
      switch (type) {
        case 'location':
          //launchUrl(Uri.parse('https://www.google.com/maps/place/$value'));
          launch(Uri.encodeFull('https://www.google.com/maps/place/$value'), enableJavaScript: true);
          break;
        case 'phone':
          //launchUrl(Uri.parse('tel:$value'));
          launch('tel:$value');
          break;
        case 'email':
          //launchUrl(Uri.parse("mailto:$value"));
          launch("mailto:$value");
          break;
        case 'url':
          //launchUrl(Uri.parse(Uri.encodeFull(value)));
          launch(Uri.encodeFull(value), enableJavaScript: true);
    }}
  }

  _initScroller() {
    _otherScroller.addListener(() {
      if (_otherPage > 0 && _otherScroller.position.maxScrollExtent ==
          _otherScroller.position.pixels) bloc!.add(LoadOtherProductsShopEvent(_shop.id, _otherPage, (widget as ShopPage).business));
    });
  }

  _initBloc() {
    bloc!.stream.listen((state) {
      if (state is FollowShopState) {
        if (isResponseNotError(state.response)) _isFollow = true;
      } else if (state is UnFollowShopState) {
        isResponseNotError(state.response, showError: false) ? _isFollow = false
        : bloc!.add(GetFollowShopEvent(_shop.classable_type, _shop.classable_id));
      } else if (state is GetFollowShopState) {
        if (isResponseNotError(state.response)) _isFollow = state.response.data.is_followed;
      } else if (state is LoadShopState) {
        ShopPage page = widget as ShopPage;
        page.shop != null ? _shop.copy(page.shop!) : _shop.copy(state.shop);
        bloc!.add(LoadAlbumUserEvent(_shop.id, _page));
        if (_shop.user_id > 0) bloc!.add(GetFriendStatusEvent(userId: _shop.user_id.toString()));
        if (!page.isOwner && constants.isLogin) bloc!.add(GetFollowShopEvent(_shop.classable_type, _shop.classable_id));
        _loadProducts();
      } else if (state is ChangeTabShopState) {
        _selectTab[state.index] = state.status;
      } else if (state is LoadOtherProductsShopState) _handleResponseLoadOtherProducts(state);
      else if (state is DeleteProductShopState) _handleResponseDeleteProduct(state);
      else if (state is PinProductShopState) _handleResponsePinProduct(state);
      else if (state is UploadBackgroundImageShopState) _handleResponseUploadBackgroundImage(state);
      else if (state is DeleteBackgroundImageShopState) _handleResponseDeleteBackgroundImage(state);
      else if (state is TransferPointShopState) _handleTransferPoint(state);
      else if (state is GetPointState) {
        (widget as ShopPage).drawerCallback!.refreshInfo();
      } else if(state is LoadAlbumUserState && isResponseNotError(state.response)){
        _listAlbum = state.response.data.list;
      } else if (state is CreateNewAlbumState && isResponseNotError(state.response,passString: true)){
        _reloadAlbum(true);
      } else if (state is GetFriendStatusState) {
        _friendStatus = state.status;
      } else if (state is AddFriendState) {
        _friendStatus = "sent";
      } else if (state is UnFriendState) {
        _friendStatus = "none";
      }
    });
    bloc!.add(LoadShopEvent());
    if ((widget as ShopPage).isOwner) {
      bloc!.add(GetPointEvent());
      bloc!.add(LoadStatusMemberPackageEvent());
    }
  }
  void _reloadAlbum(dynamic value){
    if(value) {
      _listAlbum.clear();
      _page = 1;
      bloc!.add(LoadAlbumUserEvent(_shop.id, _page));
    }
  }

  _changeTab(int index) {
    if (_selectTab[index]) return;
    bloc!.add(ChangeTabShopEvent(0, false));
    bloc!.add(ChangeTabShopEvent(1, false));
    bloc!.add(ChangeTabShopEvent(2, false));
    bloc!.add(ChangeTabShopEvent(index, !_selectTab[index]));
  }

  _loadProducts() {
    _otherPage = 1;
    _otherList.removeRange(1, _otherList.length);
    final page = widget as ShopPage;
    bloc!.add(LoadOtherProductsShopEvent(page.isOwner ? -1 : _shop.id, _otherPage, page.business));
  }

  _handleResponseLoadOtherProducts(LoadOtherProductsShopState state) {
    if (isResponseNotError(state.response)) {
      final List<ProductModel> listTemp = state.response.data.list;
      if (listTemp.isNotEmpty) {
        for(int i = 0; i < listTemp.length; i++) {
          _otherList.add(ProductItemPage(listTemp[i], _shop, () => _editProduct(listTemp, i),
             () => _deleteProduct(listTemp, i), () => _pinProduct(listTemp, i),
             isView: !(widget as ShopPage).isOwner, setShopId: true, margin: EdgeInsets.symmetric(vertical: 20.sp, horizontal: 40.sp)));
        }
        if (_otherPage == 1) setState((){});
      } else if (_otherPage == 1) setState((){});
      listTemp.length == constants.limitPage ? _otherPage++ : _otherPage = 0;
    }
  }

  _editProduct(List<ProductModel> list, int index) => UtilUI.goToNextPage(context, ProductPage(shopName: _shop.name,
      isCreate: false, product: list[index]), funCallback: getValueFromSecondPage);

  _deleteProduct(List<ProductModel> list, int index) => UtilUI.showCustomDialog(context,
    "${MultiLanguage.get('msg_confirm_delete_product')}\"${list[index].title}\"",
    isActionCancel: true, title: MultiLanguage.get('ttl_confirm'), lblOK: MultiLanguage.get('btn_delete')
  ).then((value) {
    if (value!) bloc!.add(DeleteProductShopEvent(list[index].id));
  });

  _pinProduct(List<ProductModel> list, int index) => bloc!.add(PinProductShopEvent(list[index].id));

  _handleResponseDeleteProduct(DeleteProductShopState state) {
    if (isResponseNotError(state.response, passString: true)) _loadProducts();
  }

  _handleResponsePinProduct(PinProductShopState state) {
    if (isResponseNotError(state.response)) _loadProducts();
  }

  @override
  collapseHeader(bool value) {}

  @override
  collapseFooter(bool value) {}

  @override
  updateProfile() {
    bloc!.add(LoadShopEvent());
    (widget as ShopPage).drawerCallback!.refreshInfo();
  }

  _goToProfile() => UtilUI.goToNextPage(context, ProfilePage(callback: this));

  _followShop(context) {
    if (constants.isLogin) {
      _isFollow?bloc!.add(UnFollowShopEvent(_shop.classable_type, _shop.classable_id))
      : bloc!.add(FollowShopEvent(_shop.classable_type, _shop.classable_id));
    } else _showLoginOrCreate(context);
  }

  _showLoginOrCreate(context) {
    final LanguageKey languageKey = LanguageKey();
    UtilUI.showCustomDialog(context, MultiLanguage.get(languageKey.msgLoginOrCreate));
  }

  _uploadBackgroundImage() {
    if((widget as ShopPage).isOwner) selectImage(_imageTypes);
  }

  _handleResponseUploadBackgroundImage(UploadBackgroundImageShopState state) {
    if (isResponseNotError(state.response)) {
      UtilUI.saveInfo(context, state.response.data, null, null);
      _shop.background_image = state.response.data.shop.background_image;
      bloc!.add(ReloadBackgroundImageShopEvent());
    }
  }

  _deleteBackgroundImage() => bloc!.add(DeleteBackgroundImageShopEvent());

  _handleResponseDeleteBackgroundImage(DeleteBackgroundImageShopState state) {
    if (isResponseNotError(state.response)) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('background_image', '');
        prefs.setString('shop_background_image', '');
        _shop.background_image = '';
        bloc!.add(ReloadBackgroundImageShopEvent());
      });
    }
  }

  void _showDialogTransferPoint() {
    if (_ctrPhone == null) {
      _ctrPhone = TextEditingController();
      _ctrPoint = TextEditingController();
      _focusPhone = FocusNode();
      _focusPoint = FocusNode();
    }
    Timer(const Duration(seconds: 1), () => _focusPhone!.requestFocus());
    showDialog(context: context, builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.sp))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.sp),
                    topRight: Radius.circular(30.sp))),
            width: 1.sw,
            child: Padding(
              padding: EdgeInsets.all(40.sp),
              child: Stack(
                children: [
                  Align(child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(false),
                      child: const Icon(Icons.close, color: StyleCustom.textColor6E)),
                      alignment: Alignment.topRight),
                  Center(child: LabelCustom(MultiLanguage.get('ttl_transfer_point'), color: StyleCustom.textColor19, size: 60.sp))
                ],
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.all(40.sp),
              child: TextFieldCustom(_ctrPhone!, _focusPhone!, _focusPoint!, MultiLanguage.get('msg_enter_recipient_phone'),
                  inputAction: TextInputAction.next,
                  type: TextInputType.number)),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.sp),
              child: TextFieldCustom(_ctrPoint!, _focusPoint!, null, MultiLanguage.get('lbl_input_point'),
                  inputAction: TextInputAction.done,
                  type: TextInputType.number)),
          Container(width: 1.sw, padding: EdgeInsets.all(40.sp),
              child: ButtonCustom(_checkPhonePoint, MultiLanguage.get(languageKey.btnOK)))
        ],
      ),
    )).then((value) {
      if (value != null && value is int) _transferPoint(value);
    });
  }

  void _checkPhonePoint() async {
    FocusScope.of(context).unfocus();
    if (_ctrPhone!.text.isEmpty) {
      UtilUI.showCustomDialog(context, MultiLanguage.get('msg_empty_phone_number')).then((value) => _focusPhone!.requestFocus());
      return;
    }
    if (_ctrPhone!.text.contains(_shop.phone)) {
      UtilUI.showCustomDialog(context, MultiLanguage.get('msg_is_your_phone')).then((value) => _focusPhone!.requestFocus());
      return;
    }
    if (_ctrPoint!.text.isEmpty) {
      UtilUI.showCustomDialog(context, MultiLanguage.get('msg_input_point')).then((value) => _focusPoint!.requestFocus());
      return;
    }

    int point = 0;
    try {
      point = int.parse(_ctrPoint!.text);
    } catch(_) {}
    final prefs = await SharedPreferences.getInstance();
    if (point > (prefs.getInt('points')??0)) {
      UtilUI.showCustomDialog(context, MultiLanguage.get('msg_enough_point'))
          .then((value) => _focusPoint!.requestFocus());
      return;
    }
    point > 0 ? Navigator.of(context).pop(point) : _focusPoint!.requestFocus();
  }

  void _transferPoint(int point) {
    bloc!.add(TransferPointShopEvent(_ctrPoint!.text, _ctrPhone!.text));
    _ctrPhone?.text = '';
    _ctrPoint?.text = '';
  }

  void _handleTransferPoint(TransferPointShopState state) {
    if (isResponseNotError(state.response, passString: true)) {
      bloc!.add(GetPointEvent());
      UtilUI.showCustomDialog(context, MultiLanguage.get('msg_transfer'), title: MultiLanguage.get(languageKey.ttlAlert));
    }
  }

  void _openExtendUserPage() => UtilUI.goToNextPage(context, ExtendUserPage(), );

  void _showPointList() => UtilUI.goToNextPage(context, PointListPage(), funCallback: _pointCallback);

  void _pointCallback(value) => bloc!.add(GetPointEvent());

  bool isFriendShow() {
    return (_friendStatus != "" && _friendStatus != "wait_accept") ? true : false;
  }

  String getFriendStatusName() {
    switch (_friendStatus) {
      case "none":
        return MultiLanguage.get('lbl_add_friend');
      case "friend":
        return MultiLanguage.get('lbl_remove_friend');
      case "sent":
        return MultiLanguage.get('lbl_request_friend');
      case "wait_accept":
      default:
        return "";
    }
  }

  Color getFriendStatusColor() {
    switch (_friendStatus) {
      case "none":
        return Colors.green;
      case "friend":
        return Colors.red;
      case "sent":
        return Colors.grey;
      case "wait_accept":
      default:
        return Colors.grey;
    }
  }

  void postFriendStatus(){
    switch (_friendStatus) {
      case "none":
        bloc!.add(PostAddFriendStatusEvent(phone: _shop.phone));
        break;
      case "friend":
        bloc!.add(PostUnFriendStatusEvent(friendId: _shop.user_id.toString()));
        break;
    }
  }
}
