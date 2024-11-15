import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:hainong/common/models/item_option.dart';
import 'package:hainong/common/ui/my_tooltip.dart';
import 'package:hainong/features/cart/cart_model.dart';
import 'package:hainong/features/cart/ui/cart_page.dart';
import 'package:hainong/features/comment/ui/comment_page.dart';
import 'package:hainong/features/main/bloc/main_bloc.dart';
import 'package:hainong/features/post/model/post.dart';
import 'package:hainong/features/product/bloc/product_detail_bloc.dart';
import 'package:hainong/features/product/ui/product_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:hainong/common/ui/avatar_circle_widget.dart';
import 'package:hainong/common/ui/button_image_circle_widget.dart';
import 'package:hainong/common/ui/slider_image_page.dart';
import 'package:hainong/features/comment/model/comment_model.dart';
import 'package:hainong/features/profile/ui/show_avatar_page.dart';
import 'package:hainong/features/rating/create_rating_page.dart';
import 'package:hainong/features/shop/ui/shop_page.dart';
import 'package:webviewx/webviewx.dart';
import 'import_ui_product.dart';
import 'product_list_horizontal_search_page.dart';
import 'product_list_page.dart';
import 'product_list_search_page.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;
  final ShopModel shop;
  final String? referralCode;
  const ProductDetailPage(this.product, this.shop, {this.referralCode, Key? key}):super(key:key);
  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    implements ChangeUICallback, ScrollCallback {
  final ScrollController _scroller = ScrollController();
  final ProductDetailBloc _bloc = ProductDetailBloc(ProductDetailState());
  final LanguageKey languageKey = LanguageKey();
  int _currentIndex = 0, _tabIndex = -1;
  bool _isFinished = false;
  WebViewXController? _controller;
  String? shareLinkProduct;

  @override
  void dispose() {
    Util.clearPermission();
    _bloc.close();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _bloc.stream.listen((state) {
      if (state is GetProDtlState && state.response.checkOK()) {
        widget.product.shop.id > 0 ? widget.product.view_count =
            state.response.data.view_count : widget.product.copy(state.response.data, full: true);
        widget.product.is_bought = state.response.data.is_bought;
        widget.product.copyReferrers(state.response.data);
      } else if (state is DeleteState && state.response.checkOK(passString: true)) UtilUI.goBack(context, 'delete');
      else if(state is GetReferralProductState){
        setState(() => shareLinkProduct = state.link);
      }
    });
    _bloc.add(GetReferralProductEvent(widget.product.id));
    _bloc.add(GetProDtlEvent(widget.product.id));
    Util.getPermission().then((value) {
      Timer(const Duration(seconds: 1), () {
        setState((){
          _tabIndex = 0;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: LabelCustom(MultiLanguage.get('ttl_product_detail'), color: Colors.white,
      align: TextAlign.center, size: 50.sp, weight: FontWeight.normal), centerTitle: true,
      actions: [
          (widget.product.shop.id > 0 && widget.shop.id == widget.product.shop.id) || Constants().permission == 'admin' 
          ? shareLinkProduct != null 
              ? IconButton(onPressed: _menu, icon: const Icon(Icons.more_vert, color: Colors.white)) 
              : loadingWidget()
          : shareLinkProduct != null 
              ? IconButton(onPressed: _shareTo, icon: Image.asset('assets/images/ic_share.png', width: 48.sp, height: 48.sp, color: Colors.white))
              : loadingWidget()
      ], elevation: 0),
    body: Stack(
      children: [
        ListView(padding: EdgeInsets.only(bottom: 20.sp), controller: _scroller, children: [
              OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Colors.transparent,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () => _showImagesPage(context,index: _currentIndex),
                  child: _createSliderImages(context, widget.product.images.list)),
              BlocBuilder(
                bloc: _bloc,
                  buildWhen: (old, news) => news is ChangeIndexSlideState,
                  builder: (context, state) {
                  if(widget.product.images.list.length > 1) {
                    return Container(
                            height: 60.sp,
                            alignment: Alignment.center,
                  child: ListView.builder(
                            padding: EdgeInsets.only(top: 20.sp),
                            itemCount: widget.product.images.list.length,
                            scrollDirection: Axis.horizontal,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            primary: false,
                            itemBuilder: (context, index) => Container(
                            width: 30.sp,
                            height: 30.sp,
                            margin: EdgeInsets.only(bottom: 5.sp,top: 5.sp,
                  left: 10.sp,right: 10.sp),
                  decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.sp),
                  color: index == _currentIndex
                  ? Colors.orange
                      : StyleCustom.primaryColor))),
                  );
                  }
                  return const SizedBox();
             }),
              Container(
                  color: StyleCustom.backgroundColor,
                  padding: EdgeInsets.fromLTRB(40.sp,40.sp,40.sp,80.sp),
                  child: _createNameAndPrice()),
              _createShop(),
              Container(color: StyleCustom.backgroundColor, height: 40.sp),
              BlocBuilder(bloc: _bloc,
                  buildWhen: (state1, state2) => state2 is ChangeTabProDtlState,
                  builder: (context, state) => _createTabs()),
              const DividerWidget(),
              BlocBuilder(bloc: _bloc,
                  buildWhen: (state1, state2) => state2 is ChangeTabProDtlState,
                  builder: (context, state) => _createTabBody(context, _tabIndex))
        ]),
        Loading(_bloc)
      ],
    )
  );

  void _menu() {
    final List<ItemOption> options = [];
    options.add(ItemOption('assets/images/ic_share.png', ' Chia sẻ', () => _shareTo(hideDialog: true), false));
    options.add(ItemOption('assets/images/ic_edit_post.png', MultiLanguage.get('lbl_edit_product'), () => _edit(), false));
    options.add(ItemOption('assets/images/ic_delete_circle.png', MultiLanguage.get('lbl_delete_product'), () => _delete(), false));
    UtilUI.showOptionDialog2(context, MultiLanguage.get('ttl_option'), options);
    Util.trackActivities('products', path: 'Product -> Option Menu Button -> Open Option Dialog');
  }

  void _edit() {
    Navigator.of(context).pop(true);
    UtilUI.goToNextPage(context, ProductPage(shopName: widget.product.shop.name, isCreate: false, product: widget.product, permission: Constants().permission), funCallback: _editPageCallback);
    Util.trackActivities('products', path: 'Product -> Option Dialog -> Choose "Edit Product" -> Open "Edit Product" Screen');
  }

  void _editPageCallback(value, {bool full = false}) {
    if (value != null) {
      widget.product.copy(value, full: full);
      widget.product.copyReferrers(value);
      if (_tabIndex != 0) return;
      _tabIndex = -1;
      _bloc.add(ChangeTabProDtlEvent());
      Timer(const Duration(milliseconds: 1500), () {
        _tabIndex = 0;
        _bloc.add(ChangeTabProDtlEvent());
        setState(() {});
      });
    }
  }

  void _delete() {
    Navigator.of(context).pop();
    UtilUI.showCustomDialog(context, MultiLanguage.get('msg_question_delete_product'), isActionCancel: true).then((value) {
      if(value != null && value) {
        _bloc.add(DeleteEvent(widget.product.id, Constants().permission));
        Util.trackActivities('products', path: 'Product -> Confirm Dialog -> OK Button -> Delete Product (id = ${widget.product.id})');
      } else Util.trackActivities('products', path: 'Product -> Confirm Dialog -> Cancel Button');
    });
    Util.trackActivities('products', path: 'Product -> Option Dialog -> Choose "Delete Product" -> Open Confirm Dialog');
  }

  Widget _createSliderImages(final BuildContext context, List<ItemModel> list) {
    if (list.isEmpty) return _createDefaultImage();
    if (list.length == 1) return _createImageNetwork(list[0].name);
    return CarouselSlider.builder(itemCount: list.length,
        options: CarouselOptions(viewportFraction: 1.0, autoPlay: true,
            onPageChanged: (index, reason) {
                _currentIndex = index;
                _bloc.add(ChangeIndexSlideEvent(index));
            }),
        itemBuilder: (context, index, realIndex) => _createImageNetwork(list[index].name)
    );
  }

  Widget _createDefaultImage() => Image.asset('assets/images/ic_default.png', width: 1.sw, height: 0.25.sh, fit: BoxFit.fill);

  Widget _createImageNetwork(String link) {
    return link.isEmpty ? _createDefaultImage() : FadeInImage.assetNetwork(
      imageErrorBuilder: (context, obj, trace) => _createDefaultImage(),
      placeholder: 'assets/images/ic_default.png', image: Util.getRealPath(link),
      width: 1.sw, height: 0.25.sh, imageScale: 0.5, fit: BoxFit.cover);
  }

  _showImagesPage(BuildContext context,{int index = 0}) => widget.product.images.list.length != 1
      ? UtilUI.goToNextPage(context, SliderImagePage(widget.product.images,index: index))
      : UtilUI.goToNextPage(context, ShowAvatarPage(widget.product.images.list[0].name));

  Widget _createNameAndPrice() => Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      UtilUI.createLabel(widget.product.title, color: Colors.black, fontSize: 50.sp,line: 3),
      SizedBox(height: 20.sp),
      Row(children: [
        UtilUI.createStars(rate: widget.product.rate),
        BlocBuilder(bloc: _bloc, buildWhen: (state1, state2) => state2 is GetProDtlState,
                builder: (context, state) {
                  String temp = widget.product.view_count > 0 ? Util().formatNum2(widget.product.view_count.toDouble() * 7, digit: 1) : '7';
                  temp += ' Lượt xem';
                  if (widget.product.qty_buy > 0) temp += ' - ' + Util.doubleToString(widget.product.qty_buy) + ' Đã bán';
                  temp = ' ($temp)';
                  return Text(temp, style: TextStyle(fontSize: 30.sp));
                })
      ]),
      Padding(padding: EdgeInsets.only(top: 100.sp, bottom: 30.sp),
            child: widget.product.quantity == 0 ? UtilUI.createLabel("Hết hàng", color: Colors.red, fontSize: 40.sp, fontWeight: FontWeight.normal) : Row(children: [
              UtilUI.createLabel(MultiLanguage.get('lbl_qty')+': ', color: Colors.black, fontSize: 40.sp, fontWeight: FontWeight.normal),
              UtilUI.createLabel(Util.doubleToString(widget.product.quantity,
                  locale: Constants().localeVILang), color: Colors.black, fontSize: 40.sp),
              UtilUI.createLabel(' ' + widget.product.unit_name, color: Colors.black, fontSize: 40.sp, fontWeight: FontWeight.normal)
            ], crossAxisAlignment: CrossAxisAlignment.end)),
      _createPriceUI(MultiLanguage.get(languageKey.lblRetailPrice), widget.product.retail_price),
      SizedBox(height: 30.sp),
      _createPriceUI(MultiLanguage.get(languageKey.lblWholesalePrice), widget.product.wholesale_price),
    ])),
    _createQRCode()
  ]);

  Widget _createPriceUI(String title, double price) {
    final unit = widget.product.unit_name.isEmpty ? ' đ' : ' đ/${widget.product.unit_name}';
    final temp = Util.doubleToString(price, locale: Constants().localeVILang) + unit;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(fontSize: 40.sp)),
      price > 0 ? MyTooltip(temp, UtilUI.createLabel(temp, color: Colors.deepOrange, fontSize: 60.sp)) :
      UtilUI.createLabel(MultiLanguage.get(languageKey.lblAboutUs), color: Colors.deepOrange, fontSize: 60.sp)
    ]);
  }

  Widget _createQRCode() {
    try {
      return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(alignment: Alignment.center, children: [
              widget.product.qr_code.contains('http') ?
              Image.network(widget.product.qr_code,
                  height: 190.sp, width: 190.sp, fit: BoxFit.fill, errorBuilder: (_,__,___) => const SizedBox()) :
              Image.memory(const Base64Decoder().convert(widget.product.qr_code),
                  height: 190.sp, width: 190.sp, fit: BoxFit.fill, errorBuilder: (_,__,___) => const SizedBox()),
              ButtonImageWidget(10, ()=>_gotoAppStore('qrcode'),Image.asset('assets/images/ic_border_qrcode.png',
                  height: 180.sp, width: 180.sp, fit: BoxFit.fill))
            ]),
            Container(
                width: 300.sp,
                padding: EdgeInsets.all(20.sp),
                child: Text(MultiLanguage.get('msg_scan_for_more_info'),
                    style: TextStyle(fontSize: 30.sp),
                    textAlign: TextAlign.center)),
            ButtonImageWidget(10, ()=>_gotoAppStore('viettelpay'),Image.asset('assets/images/ic_viettelpay.png',
                height: 180.sp, width: 180.sp, fit: BoxFit.fill))
          ]);
    } catch (_) {}
    return Container();
  }

  _gotoAppStore(String value) {
    String link = '';
    if (Platform.isIOS) {
      if (value == 'qrcode')
        link = 'https://apps.apple.com/vn/app/2n%C3%B4ng/id1450823993?l=vi#?platform=iphone';
      else link = 'https://apps.apple.com/vn/app/viettelpay/id1344204781?l=vi';
    } else {
      if (value == 'qrcode')
        link = 'https://play.google.com/store/apps/details?id=com.pvcfc.inong&hl=vi';
      else link = 'https://play.google.com/store/apps/details?id=com.bplus.vtpay&hl=vi';
    }
    //launchUrl(Uri.parse(Uri.encodeFull(link)), mode: LaunchMode.externalNonBrowserApplication);
    launch(Uri.encodeFull(link), enableJavaScript: true);
  }

  Widget _createShop() => ButtonImageWidget(0, _goToShop, Container(
    padding: EdgeInsets.all(40.sp), color: Colors.white, child: Row(children: [
      Stack(children: [
        AvatarCircleWidget(link: widget.product.shop.image, size: 150.sp),
        if (widget.product.shop.prestige == 1)
          Image.asset('assets/images/v8/ic_prestige_business.png', width: 64.sp)
      ], alignment: Alignment.bottomRight),
      SizedBox(width: 20.sp),
      Expanded(child: Column(children: [
        UtilUI.createLabel(widget.product.shop.name, color: Colors.black, fontSize: 50.sp),
        UtilUI.createLabel(widget.product.shop.district_name + ', ' +
          widget.product.shop.province_name,
          color: Colors.black, fontSize: 35.sp, fontWeight: FontWeight.normal)
      ], crossAxisAlignment: CrossAxisAlignment.start)),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        if (widget.product.shop.id > 0 && widget.shop.id != widget.product.shop.id)
          Padding(padding: EdgeInsets.only(right: 15.sp, bottom: 10.sp),
            child:ButtonImageWidget(25.sp, _order, Container(
              padding: EdgeInsets.symmetric(vertical: 20.sp, horizontal: 40.sp),
              child: Row(children: [
                Icon(Icons.add_shopping_cart, color: Colors.white, size: 42.sp),
                SizedBox(width: 10.sp),
                UtilUI.createLabel('Đặt hàng', fontSize: 32.sp, textAlign: TextAlign.center)
              ])),
            color: Colors.orange, elevation: 2)),
        ButtonImageWidget(30.sp, _callNow, Container(height: 100.sp, width: 300.sp,
          alignment: Alignment.centerRight, padding: EdgeInsets.only(right: 50.sp),
          decoration: BoxDecoration(image: DecorationImage(
            image: Image.asset('assets/images/ic_call_now.png').image)),
          child: UtilUI.createLabel(MultiLanguage.get('btn_call_now'), fontSize: 32.sp)))
      ])
    ])));

  Widget _createTabs() => Container(
      color: Colors.white,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _createTab(0, MultiLanguage.get('lbl_product_des'), _tabIndex == 0),
        _createTab(1, MultiLanguage.get('lbl_rate'), _tabIndex == 1),
        _createTab(2, MultiLanguage.get('lbl_product'), _tabIndex == 2),
      ]));

  Widget _createTab(int index, String title, bool active) => Expanded(
      child: Container(
          decoration: BoxDecoration(
              border: active
                  ? Border(
                      bottom: BorderSide(
                          color: StyleCustom.buttonColor, width: 10.sp))
                  : BoxBorder.lerp(null, null, 0.0)),
          child: ButtonImageWidget(
              5.sp,
              () {
                _tabIndex = index;
                _bloc.add(ChangeTabProDtlEvent());
              },
             Padding(
                  padding: EdgeInsets.all(40.sp),
                  child: UtilUI.createLabel(title,
                      textAlign: TextAlign.center,
                      color: Colors.black,
                      fontWeight:
                          active ? FontWeight.bold : FontWeight.normal)) )));

  Widget _createTabBody(final BuildContext context, int index) {
    switch (index) {
      case 0:
        _isFinished = false;
        _controller = null;
        return _createTabDescriptionBody();
      case 1:
        return BlocBuilder(
            bloc: _bloc,
            buildWhen: (state1, state2) => state2 is LoadRatingsProDtlState,
            builder: (context, state) => _createTabRateBody());
      case 2:
        return _createTabProductBody(context);
    }
    return const SizedBox();
  }

  Widget _createTabDescriptionBody() => Container(color: Colors.white, width: 1.sw,
      constraints: const BoxConstraints(maxHeight: 1000000),
      padding: EdgeInsets.all(40.sp), child: BlocBuilder(bloc: _bloc,
          buildWhen: (oldState, newState) => newState is HeightState,
          builder: (context, state) {
            double height = 10, hasHeight = 0;
            if (state is HeightState) {
              height = state.height;
              hasHeight = 1;
            }
            return WebViewX(jsContent: {EmbeddedJsContent(js: Constants().jvWebView, mobileJs: Constants().jvWebView)},
                initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.alwaysAllow,
                initialContent: widget.product.description,
                initialSourceType: SourceType.html,
                height: height,
                width: 1.sw,
                onWebViewCreated: (controller) => _controller = controller,
                webSpecificParams: const WebSpecificParams(webAllowFullscreenContent: false),
                mobileSpecificParams: const MobileSpecificParams(androidEnableHybridComposition: true),
                navigationDelegate: (navigation) async {
                  if (!_isFinished) return NavigationDecision.navigate;
                  String http = navigation.content.source;
                  if (!http.contains('http')) http = 'https://$http';
                  //if (await canLaunchUrl(Uri.parse(http))) launchUrl(Uri.parse(http));
                  //if (await canLaunchUrl(Uri.parse(http))) {
                    Util.isImage(http) ? UtilUI.goToNextPage(context, ShowAvatarPage(http)) : launchUrl(Uri.parse(http), mode: LaunchMode.externalApplication);
                  //}
                  return NavigationDecision.prevent;
                },
                onPageFinished: (value) async {
                  _isFinished = true;
                  if (hasHeight == 0) {
                    //await _controller?.evalRawJavascript(Constants().jvWebView);
                    //await Future.delayed(const Duration(seconds: 1));
                    await _controller?.scrollBy(0, 10);
                    String heightStr = await _controller?.evalRawJavascript(
                        "document.documentElement.scrollHeight") ?? "0";
                    _bloc.add(HeightEvent(double.parse(heightStr)));
                  }
                }
              );
          }),
    
  );

  Widget _createTabRateBody() =>
      Column(children: [
        widget.product.is_bought ? _createStars(context) : const SizedBox(),
        const DividerWidget(),
        CommentPage(Post(classable_id: widget.product.classable_id.toString(), classable_type:
        widget.product.classable_type), hasHeader: false, showTime: false, height: 0.5.sh)
      ]);

  Widget _createStars(BuildContext context) => Container(color: Colors.white,
    child: Column(children: [
      SizedBox(height: 60.sp),
      Padding(padding: EdgeInsets.all(20.sp), child: UtilUI.createLabel(
          widget.product.comment.rate > 0 ? 'Đánh giá của bạn' : 'Cho chúng tôi biết bạn đang nghĩ gì?',
          color: Colors.black, fontWeight: FontWeight.normal)),
      BlocBuilder(bloc: _bloc,
                buildWhen: (state1, state2) => state2 is RefreshStarProDtlState,
                builder: (context, state) => UtilUI.createStars(
                    onClick: (index) => _clickStart(context, index),
                    hasFunction: true,
                    rate: widget.product.comment.rate,
                    size: 65.sp)),
      SizedBox(height: 80.sp)
    ]));

  Widget _createTabProductBody(final BuildContext context) => SizedBox(height: 0.78.sh,
    child: Column(children: [
        _createNavigateNext('lbl_similar_product', () => _goToProductList(context,
          ProductListSearchPage(widget.shop,
            catalogueId: widget.product.product_catalogue_id.toString(),
            productId: widget.product.id.toString()))),
        BlocBuilder(bloc: _bloc, buildWhen: (oldS, newS) => newS is HideSimilarListState,
        builder: (context, state) {
          bool show = true;
          if (state is HideSimilarListState) show = false;
          return show ? SizedBox(height: 0.78.sh / 2 - 110.sp, child: ProductListPage(
            callback: this, scrollCallback: this, key: Key(DateTime.now().toString()),
            hideFilter: true, loadNext: false, initCatalogue: widget.product.product_catalogue_id,
            productId: widget.product.id.toString(), funHideList: () => _bloc.add(HideSimilarListEvent())))
          : const SizedBox();
        }),
        _createNavigateNext('lbl_other_product', () => _goToProductList(context,
          ProductListHorizontalSearchPage(widget.shop, productId: widget.product.id.toString(), hasExceptCatalogue: true))),
        BlocBuilder(bloc: _bloc, buildWhen: (oldS, newS) => newS is HideOtherListState,
          builder: (context, state) {
            bool show = true;
            if (state is HideOtherListState) show = false;
            return show ? SizedBox(height: 0.78.sh / 2 - 110.sp, child: ProductListHorizontalPage(widget.shop,
              key: Key(DateTime.now().toString()),
              productId: widget.product.id.toString(), hasExceptCatalogue: true, funHideList: ()=>_bloc.add(HideOtherListEvent())))
            : const SizedBox();
          })
    ]));

  Widget _createNavigateNext(String title, Function onPressed) => Container(
      padding: EdgeInsets.only(top: 40.sp, left: 40.sp, right: 20.sp),
      child: Row(children: [
        Expanded(child: Text(MultiLanguage.get(title))),
        ButtonImageCircleWidget(40.sp, onPressed,
            child: const Icon(Icons.navigate_next, color: StyleCustom.primaryColor))
      ]));

  collapseFooter(bool value) {}

  collapseHeader(bool value) {
    if (value) _scroller.animateTo(0.8.sh, duration: const Duration(milliseconds: 2000), curve: Curves.easeOut);
  }

  scrollTop() {
    _scroller.animateTo(0.0, duration: const Duration(milliseconds: 1000), curve: Curves.easeIn);
  }

  _clickStart(final BuildContext context, int index) {
    if (widget.product.comment.rate > 0) return;
    Constants().isLogin ? _goToProductList(context, CreateRatingPage(index,
        widget.product.classable_type, widget.product.classable_id, widget.product.comment.id)) :
      UtilUI.showCustomDialog(context, MultiLanguage.get(languageKey.msgLoginOrCreate));
  }

  void _goToShop() {
    if (widget.product.shop.id > 0 && widget.shop.id != widget.product.shop.id) {
      final page = ShopPage(business: widget.product.business_association_id,
          shop: widget.product.shop, isOwner: false, hasHeader: true, isView: true);
      page.pageState.callback = this;
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    }
  }

  void _order() => UtilUI.showConfirmDialog(context, widget.product.title, 'Nhập số lượng đặt',
    'Vui lòng nhập số lượng', title: 'Đặt hàng', suffix: Padding(padding: EdgeInsets.all(40.sp),
          child: Text(widget.product.unit_name, style: TextStyle(fontSize: 42.sp))), maxLength: 10,
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'\d*'))
    ], inputType: const TextInputType.numberWithOptions(signed: true)).then((value) {
      if (value != null && value is String) {
        double qty = double.parse(value);
        if (qty < 1) {
          UtilUI.showCustomDialog(context, 'Số lượng đặt phải lớn hơn 0').whenComplete(() => _order());
          return;
        }

        _bloc.add(LoadingEvent(true));
        String image = '';
        if (widget.product.images.list.isNotEmpty) image = widget.product.images.list[0].name;
        CartModel cart = CartModel(shop_id: widget.product.shop.id,
            seller_name: widget.product.shop.name, seller_image: widget.product.shop.image);
        CartDtlModel dtl = CartDtlModel(product_id: widget.product.id,
          product_name: widget.product.title, quantity: qty,
          price: widget.product.retail_price, image: image, unit_name: widget.product.unit_name,
          referral_code: widget.referralCode ?? "", discount_level: widget.product.discount_level, coupon_per_item: widget.product.coupon_per_item
        );
        Util.addCart(cart, dtl, {}, true);
        UtilUI.showCustomDialog(context, 'Sản phẩm đã thêm vào giỏ hàng thành công',
            title: 'Mua hàng', isActionCancel: true, lblOK: 'Xem giỏ hàng', lblCancel: 'Mua tiếp').then((value) {
              if (value != null && value) UtilUI.goToNextPage(context, CartPage());
        });
        _bloc.add(LoadingEvent(false));
        BlocProvider.of<MainBloc>(context).add(CountCartMainEvent());
      }
    });

  void _callNow() {
    //if (widget.product.shop.phone.isNotEmpty) launchUrl(Uri.parse("tel://" + widget.product.shop.phone));
    if (widget.product.shop.phone.isNotEmpty) launch("tel:" + widget.product.shop.phone);
  }

  _goToProductList(final BuildContext context, dynamic page) =>
      Navigator.push(context, MaterialPageRoute(builder: (context) => page))
          .then((value) => _pageCallback(value, context));

  _pageCallback(value, final BuildContext context) {
    if (value != null && value is CommentModel) {
      widget.product.comment.id = value.id;
      widget.product.comment.rate = value.rate;
      _bloc.add(RefreshStarProDtlEvent());
      BlocProvider.of<MainBloc>(context).add(ReloadListCommentEvent());
    } else setState(() {});
  }

  void _shareTo({bool hideDialog = false}) {
    if (hideDialog) Navigator.of(context).pop(false);
    shareLinkProduct?.isNotEmpty == true
      ? UtilUI.shareDeeplinkTo(context, shareLinkProduct!, 'Product Detail -> Option Share Dialog -> Choose "Share"', 'products')
      : UtilUI.shareTo(context, '/san-pham/${widget.product.id}', 'Product Detail -> Option Share Dialog -> Choose "Share"', 'products');
  }

  Widget loadingWidget() {
    return Padding(padding: EdgeInsets.only(right: 40.sp), child: const SizedBox(height: 20,width: 20,
    child: FittedBox(child:  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),strokeWidth: 6))));
  }
}