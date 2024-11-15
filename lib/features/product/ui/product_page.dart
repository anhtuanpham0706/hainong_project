import 'dart:async';
import 'dart:io';
import 'package:hainong/common/models/file_byte.dart';
import 'package:hainong/common/ui/permission_image_page_state.dart';
import 'package:hainong/features/login/login_model.dart';
import 'package:hainong/features/product/ui/edit_to_html_page.dart';
import 'package:hainong/features/profile/ui/show_avatar_page.dart';
import 'package:hainong/features/referrer/model/referrer_model.dart';
import 'package:hainong/features/referrer/ui/referrer_list_page.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webviewx/webviewx.dart';
import 'image_item_page.dart';
import 'import_ui_product.dart';

class ProductPage extends BasePage {
  final bool isCreate, openGallery;
  final ProductModel? product;
  final String shopName;
  final String? permission;
  final int idBusiness;

  ProductPage({Key? key, this.isCreate = true, this.idBusiness = -1, this.shopName = '', this.product, this.permission,
    this.openGallery = false}) : super(key: key, pageState: _ProductPageState());
}

class _ProductPageState extends PermissionImagePageState {
  final TextEditingController _ctrId = TextEditingController(),
      _ctrName = TextEditingController(),
      _ctrShop = TextEditingController(),
      _ctrProType = TextEditingController(),
      _ctrCatalogue = TextEditingController(),
      _ctrDescription = TextEditingController(),
      _ctrQuantity = TextEditingController(),
      _ctrUnit = TextEditingController(),
      _ctrRetailPrice = TextEditingController(),
      _ctrWholesalePrice = TextEditingController(),
      _ctrReferrerUser = TextEditingController(),
      _ctrCouponPerProduct = TextEditingController(),
      _ctrDiscountLevelPriceProduct = TextEditingController(),
      _ctrIntructionPointProduct = TextEditingController();
  final FocusNode _focusId = FocusNode(),
      _focusName = FocusNode(),
      _focusShop = FocusNode(),
      _focusProType = FocusNode(),
      _focusCatalogue = FocusNode(),
      _focusDescription = FocusNode(),
      _focusQuantity = FocusNode(),
      _focusUnit = FocusNode(),
      _focusRetailPrice = FocusNode(),
      _focusWholesalePrice = FocusNode(),
      _focusReferrarUser = FocusNode(),
      _focusCouponPerProduct = FocusNode(),
      _focusDiscountLevelPriceProduct = FocusNode(),
      _focusIntructionPointProduct = FocusNode();
  final Map<String, String> _values = {};
  final List<FileByte> _images = [];
  final List<ItemModel> _imageTypes = [], _proTypes = [
    ItemModel(id: 'agricultural_materials_market', name: 'Chợ Vật Tư'),
    ItemModel(id: 'agricultural_wholesale_market', name: 'Chợ Sỉ Nông Nghiệp'),
    ItemModel(id: 'farmers_markets', name: 'Chợ Nông Sản')
  ];
  final List<CatalogueModel> _catalogues = [];
  final Map<String, ItemModel> _selectCats = {};
  final _subBloc = ProductListBloc(ProductListState());
  final List<ReferrerModel> _selectReferrers = [], _selectFriends = [];
  List<ItemModel>? _units;
  bool hotPick = false, _isFinished = false, _showKeyboard = false, _hasUpdateAdvancePoint = false;
  String _description = '';
  WebViewXController? _controller;
  int _productId = -1 ,_currentPoint = 0, _currentAdvancePoint = 0, _appliedPoint = 0, _minAdvancePoint = 0;
  bool? _hasAdvancePoint;
  ProductModel? _currentProductData;

  @override
  loadFiles(List<File> files) async {
    if (files.isEmpty) return;
    showLoadingPermission();
    bool hasFile = false;
    for(int i = 0; i < files.length; i++) {
      if (Util.isImage(files[i].path) && _images.length < 10) {
        hasFile = true;
        _images.add(FileByte(files[i].readAsBytesSync(), files[i].path));
      }
    }
    if (hasFile) bloc!.add(LoadImageProductEvent());
    else showLoadingPermission(value: false);
  }

  @override
  void showLoadingPermission({bool value = true}) => bloc!.add(LoadingEvent(value));

  @override
  openCameraGallery() {
    if (pass) {
      resetCheckPermission();
      ProductPage page = widget as ProductPage;
      bloc!.add(DownloadImagesProductEvent(page.product!.images.list));
    } else super.openCameraGallery();
  }

  @override
  void dispose() {
    _ctrId.dispose();
    _ctrName.dispose();
    _ctrShop.dispose();
    _ctrProType.dispose();
    _ctrCatalogue.dispose();
    _ctrDescription.dispose();
    _ctrQuantity.dispose();
    _ctrUnit.dispose();
    _ctrRetailPrice.dispose();
    _ctrWholesalePrice.dispose();
    _ctrCouponPerProduct.dispose();
    _ctrDiscountLevelPriceProduct.dispose();
    _ctrIntructionPointProduct.dispose();
    _focusId.removeListener(_listenFocus);
    _focusName.removeListener(_listenFocus);
    _focusShop.removeListener(_listenFocus);
    _focusProType.removeListener(_listenFocus);
    _focusCatalogue.removeListener(_listenFocus);
    _focusDescription.removeListener(_listenFocus);
    _focusQuantity.removeListener(_listenFocus);
    _focusUnit.removeListener(_listenFocus);
    _focusRetailPrice.removeListener(_listenFocus);
    _focusWholesalePrice.removeListener(_listenFocus);
    _focusReferrarUser.removeListener(_listenFocus);
    _focusCouponPerProduct.removeListener(_listenFocus);
    _focusIntructionPointProduct.removeListener(_listenFocus);
    _focusDiscountLevelPriceProduct.removeListener(_listenFocus);
    _focusId.dispose();
    _focusName.dispose();
    _focusShop.dispose();
    _focusProType.dispose();
    _focusCatalogue.dispose();
    _focusDescription.dispose();
    _focusQuantity.dispose();
    _focusUnit.dispose();
    _focusRetailPrice.dispose();
    _focusWholesalePrice.dispose();
    _focusCouponPerProduct.dispose();
    _focusReferrarUser.dispose();
    _focusDiscountLevelPriceProduct.dispose();
    _focusIntructionPointProduct.dispose();
    _values.clear();
    _images.clear();
    _imageTypes.clear();
    _proTypes.clear();
    _catalogues.clear();
    _selectCats.clear();
    _subBloc.close();
    _units?.clear();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void clearFocus() {}

  @override
  initState() {
    multiSelect = true;
    setOnlyImage();
    ProductPage page = widget as ProductPage;
    _ctrShop.text = page.shopName;
    bloc = ProductBloc(hasUpdateInfo: true);
    super.initState();

    if (page.product != null && page.product!.images.list.isNotEmpty) {
      pass = true;
      checkPermissions(ItemModel(id: languageKey.lblGallery));
    }

    _focusListeners(_ctrWholesalePrice, _focusWholesalePrice);
    _focusListeners(_ctrRetailPrice, _focusRetailPrice);
    _focusListeners(_ctrQuantity, _focusQuantity);
    _focusListeners(_ctrCouponPerProduct, _focusCouponPerProduct, isNumberDefault: false);
    _focusListeners(_ctrDiscountLevelPriceProduct, _focusDiscountLevelPriceProduct, isNumberDefault: false);
    _focusListeners(_ctrIntructionPointProduct, _focusIntructionPointProduct, isNumberDefault: false);
    _initImageTypes();
    _setOption(_ctrProType, 'lbl_market');
    _setOption(_ctrCatalogue, languageKey.lblCatalogue);
    _setOption(_ctrUnit, languageKey.lblUnit);
    if (isHasBusiness()) _proTypes.add(ItemModel(id: 'producer_market', name: 'Chợ Nhà Sản xuất'));
    if (page.isCreate) _setOption(_ctrProType, 'lbl_market',
        id: _proTypes[isHasBusiness() ? 3 : 2].id, name: _proTypes[isHasBusiness() ? 3 : 2].name);
    else if (page.product != null) _initProduct(page.product!);

    bloc!.stream.listen((state) {
      if (state is LoadUnitProductState) _handleResponseLoadUnit(state);
      else if (state is PostProductState) _handleResponse(state);
      else if (state is EditProductState) _handleResponse(state);
      else if (state is DownloadImagesProductState) _handleDownloadImages(state.response);
      else if (state is ShowKeyboardState) {
        _showKeyboard = state.value;
        if (!_showKeyboard) _myClearFocus();
      }
      else if (state is GetAdvancePointsState) _handleAdvancePoints(state);
      else if (state is AdvancePointsUpdateState) _handleAdvancePointsUpdate(state.response);
      else if (state is GetProfileState) _handleGetProfile(state);
      //else if (state is EditDescriptionState) _description = state.description;
    });
    _subBloc.stream.listen((state) {
      if (state is LoadCatalogueState) _handleResponseLoadCatalogue(state);
      else if (state is LoadSubCatalogueState) _handleLoadSubCatalogue(state);
      else if (state is SelectedCatalogueState) {
        final cat = _selectCats.values.last;
        _changedOption(ItemModel(id: cat.id, name: cat.name), _ctrCatalogue, languageKey.lblCatalogue);
      }
    });
    //bloc!.add(EditDescriptionEvent(_description));
    if(!page.isCreate && page.product != null && !isHasBusiness()) {
      _productId = page.product!.id;
      bloc!.add(GetAdvancePointsEvent(_productId));
    }
    if (_ctrProType.text.isNotEmpty) _loadCatalogues(isClear: false);
    bloc!.add(LoadUnitProductEvent());
    bloc!.add(CheckHotPickProductEvent());
    _focusId.addListener(_listenFocus);
    _focusName.addListener(_listenFocus);
    _focusProType.addListener(_listenFocus);
    _focusCatalogue.addListener(_listenFocus);
    _focusDescription.addListener(_listenFocus);
    _focusShop.addListener(_listenFocus);
    _focusUnit.addListener(_listenFocus);
    _focusQuantity.addListener(_listenFocus);
    _focusRetailPrice.addListener(_listenFocus);
    _focusWholesalePrice.addListener(_listenFocus);
    _focusReferrarUser.addListener(_listenFocus);
    Timer(const Duration(milliseconds: 1000), () {
      if ((widget as ProductPage).openGallery) checkPermissions(_imageTypes[1]);
    });
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    final padding = Padding(padding: EdgeInsets.all(20.sp));
    return WillPopScope(onWillPop: () async {
      bool show = false;
      if (bloc!.state is ShowCataloguesState) show = (bloc!.state as ShowCataloguesState).value;
      if (show) _showCatalogues(value: false);
      return !show;
    }, child: Scaffold(appBar: AppBar(elevation: 5, centerTitle: true,
        title: LabelCustom((widget as ProductPage).product != null ? 'Cập nhật sản phẩm' : 'Tạo sản phẩm', size: 50.sp),
        actions: [
          IconButton(onPressed: _onClickPost, icon: LabelCustom(MultiLanguage.get((widget as ProductPage).product != null ?
            languageKey.btnSave : languageKey.btnPost), size: 50.sp, weight: FontWeight.normal), iconSize: 150.sp)
        ]
      ),
      body: Stack(alignment: Alignment.bottomCenter,
        children: [
          SingleChildScrollView(physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: 80.sp, horizontal: 50.sp),
              child: Container(
                  color: StyleCustom.backgroundColor,
                  child: Column(
                        children: [
                          _createListImageUI(),
                          padding,
                          UtilUI.createTextField(
                              context,
                              _ctrId,
                              _focusId,
                              _focusName,
                              MultiLanguage.get('lbl_product_code')),
                          padding,
                          UtilUI.createTextField(
                              context,
                              _ctrName,
                              _focusName,
                              _focusCatalogue,
                              MultiLanguage.get('lbl_product_name') +
                                  '*'),
                          padding,
                          UtilUI.createTextField(
                              context,
                              _ctrProType,
                              _focusProType,
                              _focusCatalogue,
                              'Danh mục chợ*',
                              suffixIcon: const Icon(Icons.arrow_drop_down),
                              readOnly: true,
                              onPressIcon: () {
                                if (!isHasBusiness()) _selectOption(_proTypes, _ctrProType, 'lbl_market');
                              }),
                          padding,
                          UtilUI.createTextField(
                              context,
                              _ctrCatalogue,
                              _focusCatalogue,
                              _focusDescription,
                              'Danh mục sản phẩm*',
                              suffixIcon: const Icon(Icons.arrow_drop_down),
                              readOnly: true,
                              onPressIcon: _showCatalogues),
                          padding,
                          Row(children: [
                            BlocBuilder(
                                bloc: bloc,
                                buildWhen: (oldState, newState) =>
                                newState is CheckHotPickProductState,
                                builder: (context, state) => Checkbox(
                                    value: hotPick,
                                    materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                    activeColor: StyleCustom.primaryColor,
                                    onChanged: (value) => _checkHotPick(value!))),
                            Text(MultiLanguage.get('lbl_highlight_products'))
                          ]),
                          padding,
                          UtilUI.createTextField(context, _ctrShop, _focusShop,
                              _focusDescription, '',
                              textColor: Colors.blueAccent),
                          padding,
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 15.sp),
                                child: Text(MultiLanguage.get('lbl_product_des')),
                              ),
                              GestureDetector(
                                onTap: (){
                                  UtilUI.goToNextPage(context, EditorToHtmlPage(result: _description),funCallback: _updateDescription);
                                },
                                child: SizedBox(
                                  height: 60.sp,
                                  width: 60.sp,
                                  child: Image.asset('assets/images/ic_edit_post.png'),
                                ),
                              ),
                              // IconButton(
                              //   iconSize: 25.sp,
                              //     onPressed: (){
                              //   UtilUI.goToNextPage(context, EditorToHtmlPage(result: _description),funCallback: _updateDecription);
                              // }, icon: Image.asset('assets/images/ic_edit_post.png')),
                            ],
                          ),
                          BlocBuilder(bloc: bloc,
                              buildWhen: (oldState, newState) => newState is SetHeightState,
                              builder: (context, state) {
                                double height = 10;
                                if (state is SetHeightState) height = state.height;
                                if (height < 0) {
                                  _isFinished = false;
                                  _controller = null;
                                  Timer(const Duration(milliseconds: 1500), () => bloc!.add(SetHeightEvent(10)));
                                  return const SizedBox();
                                }
                                return WebViewX(jsContent: {EmbeddedJsContent(js: Constants().jvWebView, mobileJs: Constants().jvWebView)},
                                    initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.alwaysAllow,
                                    initialContent: _description.isNotEmpty ? _description : 'Nhập mô tả ...',
                                    initialSourceType: SourceType.html,
                                    height: height, width: 1.sw,
                                    onWebViewCreated: (controller) {
                                      _controller ??= controller;
                                    },
                                    webSpecificParams: const WebSpecificParams(webAllowFullscreenContent: false),
                                    mobileSpecificParams: const MobileSpecificParams(
                                      androidEnableHybridComposition: true
                                    ),
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
                                      if (!_isFinished) {
                                        _isFinished = true;
                                        //await _controller?.evalRawJavascript(constants.jvWebView);
                                        //await Future.delayed(const Duration(seconds: 1));
                                        await _controller?.scrollBy(0, 10);
                                        String heightStr = await _controller
                                            ?.evalRawJavascript(
                                            "document.documentElement.scrollHeight") ?? "0";
                                        bloc!.add(SetHeightEvent(double.parse(heightStr)));
                                      }
                                    }
                                );
                          }),
                          padding,
                          UtilUI.createTextField(
                              context,
                              _ctrUnit,
                              _focusUnit,
                              _focusRetailPrice,
                              'Đơn vị tính*',
                              suffixIcon: const Icon(Icons.arrow_drop_down),
                              readOnly: true,
                              onPressIcon: () => _selectOption(
                                  _units!, _ctrUnit, languageKey.lblUnit)),
                          padding,
                          UtilUI.createTextField(
                              context,
                              _ctrQuantity,
                              _focusQuantity,
                              _focusRetailPrice,
                              MultiLanguage.get('lbl_qty'),
                              onChanged: (ctr, value) =>
                                  _onTextChanged(_ctrQuantity, value),
                              inputType: TextInputType.number),
                          padding,
                          UtilUI.createTextField(
                              context,
                              _ctrRetailPrice,
                              _focusRetailPrice,
                              _focusWholesalePrice,
                              MultiLanguage.get(languageKey.lblRetailPrice) +
                                  '*',
                              suffixIcon: Text(constants.defaultCurrency),
                              onChanged: (ctr, value) =>
                                  _onTextChanged(_ctrRetailPrice, value),
                              inputType: TextInputType.number),
                          padding,
                          UtilUI.createTextField(
                              context,
                              _ctrWholesalePrice,
                              _focusWholesalePrice,
                              null,
                              MultiLanguage.get(languageKey.lblWholesalePrice),
                              suffixIcon: Text(constants.defaultCurrency),
                              inputType: TextInputType.number,
                              onChanged: (ctr, value) =>
                                  _onTextChanged(_ctrWholesalePrice, value),
                              inputAction: TextInputAction.done),
                          if(!isHasBusiness()) ... [
                                padding,
                                Align(
                                alignment: Alignment.centerLeft,
                                child: Text(MultiLanguage.get('lbl_referrers'),style: const TextStyle(fontSize: 15))),
                                padding,
                                if(_hasAdvancePoint == true || !isPoints())...[
                                  Align(alignment: Alignment.centerLeft, child: Text(!isPoints() ? '(Tính năng đã khóa do không đủ điểm)' : '(Tính năng đã khóa do chưa ứng điểm)', style: TextStyle(color: Colors.red),)),
                                  padding,
                                ],
                                TextFieldTags<String>(
                                    textfieldTagsController: StringTagController(),
                                    initialTags: referrerListName(),
                                    letterCase: LetterCase.normal,
                                    textSeparators: const [' ', ','],
                                    inputFieldBuilder: (context, inputFieldValues) {
                                      return GestureDetector(
                                        onTap: () => onHandlePressIconReferrer(inputFieldValues),
                                        child: UtilUI.createTextField(
                                            context,
                                            _ctrReferrerUser,
                                            _focusReferrarUser,
                                            _focusCouponPerProduct,
                                            isHasReferrer() ? "" : MultiLanguage.get('lbl_referrers'),
                                            suffixIcon: Icon(Icons.arrow_drop_down),
                                            onChanged: inputFieldValues.onTagChanged,
                                            enable: false,
                                            onSubmit: inputFieldValues.onTagSubmitted,
                                            prefixIcon: prefixIconReferrer(inputFieldValues),
                                            readOnly: true),
                                      );
                                    }),
                                padding,
                                UtilUI.createTextField(
                                    context,
                                    _ctrCouponPerProduct,
                                    _focusCouponPerProduct,
                                    _focusDiscountLevelPriceProduct,
                                    MultiLanguage.get('lbl_percent_discount_product'),
                                    enable: isHasReferrer(),
                                    suffixIcon: Text("%"),
                                    onChanged: (ctr, value) => _onTextChanged(_ctrCouponPerProduct, value),
                                    inputType: TextInputType.number),
                                padding,
                                UtilUI.createTextField(
                                    context,
                                    _ctrDiscountLevelPriceProduct,
                                    _focusDiscountLevelPriceProduct,
                                    _focusIntructionPointProduct,
                                    MultiLanguage.get('lbl_number_discount_product'),
                                    enable: isHasReferrer(),
                                    suffixIcon: Text(constants.defaultCurrency),
                                    onChanged: (ctr, value) => _onTextChanged(_ctrDiscountLevelPriceProduct, value),
                                    inputType: TextInputType.number),
                                padding,
                                UtilUI.createTextField(
                                    context,
                                    _ctrIntructionPointProduct,
                                    _focusIntructionPointProduct,
                                    _focusIntructionPointProduct,
                                    MultiLanguage.get('lbl_point_referral_success'),
                                    enable: isHasReferrer(),
                                    suffixIcon: Text("điểm", style: TextStyle(fontSize: 12)),
                                    onChanged: (ctr, value) =>_onTextChanged(_ctrIntructionPointProduct, value),
                                    inputType: TextInputType.number),
                                padding,
                              ],
                          if(isShowAdvancePointsBottom())
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(children: [
                                    const Text('Điểm ứng còn lại : ',style: TextStyle(fontSize: 17)),
                                    Text((_appliedPoint.toString()) + " điểm",style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 17)),
                                  ]),
                                  UtilUI.createCustomButton(() {
                                    showDialogReferral();
                                  }, _hasAdvancePoint! ? 'Ứng' : 'Rút', color: _hasAdvancePoint! ? StyleCustom.buttonColor : StyleCustom.primaryColor, radius: 16.sp, fontSize: 16.0)
                                ])
                        ]
                      ))),
          BlocBuilder(bloc: bloc,
              buildWhen: (oldState, newState) => newState is ShowCataloguesState,
              builder: (context, state) {
                bool show = false;
                if(state is ShowCataloguesState) show = state.value;
                return show ? Container(color: Colors.white, child: Column(children: [
                  Expanded(child: ListView.builder(padding: EdgeInsets.zero,
                      itemCount: _catalogues.length,
                      itemBuilder: (context, index) => ProductCatalogueItem(_subBloc, index,
                          _catalogues[index], _loadSubCatalogue, _selectedSub, _unselectedSub, _selectCats, first: -1)
                  )),
                  Padding(padding: EdgeInsets.all(20.sp),
                      child: UtilUI.createButton(() => _showCatalogues(value: false), 'Chọn'))
                ])) : const SizedBox();
              }),
          Loading(bloc)
        ]
      ),
      floatingActionButton: BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is ShowKeyboardState,
      builder: (context, state) => (state is ShowKeyboardState && state.value) ? IconButton(
        onPressed: () => bloc!.add(ShowKeyboardEvent(false)),
        tooltip: 'Ẩn bàn phím', iconSize: 46, padding: EdgeInsets.zero,
        icon: const Icon(Icons.keyboard, color: StyleCustom.primaryColor),
      ) : const SizedBox())
    ));
  }

  Widget _createListImageUI() => Row(children: [
        Expanded(child: _createImageUI()),
        DottedBorder(
            padding: EdgeInsets.all(50.sp),
            strokeWidth: 1,
            color: Colors.grey,
            dashPattern: const [4],
            child: IconButton(
                onPressed: () {
                  _myClearFocus();
                  if(_images.length < 10) {
                    selectImage(_imageTypes);
                  } else {
                    UtilUI.showCustomDialog(context, 'Chỉ được phép tải lên tối đa 10 ảnh.',title: "Thông báo");
                  }
                  },
                icon: Icon(Icons.add, size: 100.sp, color: Colors.grey)))
      ]);

  Widget _createImageUI() => SizedBox(height: 240.sp, child: BlocBuilder(bloc: bloc,
    buildWhen: (oldState, newState) => newState is LoadImageProductState,
    builder: (context, state) => ListView.builder(scrollDirection: Axis.horizontal, itemCount: _images.length,
      physics: const BouncingScrollPhysics(), addRepaintBoundaries: false,
      itemBuilder: (context, index) => ImageItemProduct(File(_images[index].name), () => _deleteImage(index)))));

  void _myClearFocus() {
    final FocusScopeNode currentScope = FocusScope.of(context);
    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
      bloc!.add(ShowKeyboardEvent(false));
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }

  void _listenFocus() {
    final FocusScopeNode currentScope = FocusScope.of(context);
    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus && !_showKeyboard) bloc!.add(ShowKeyboardEvent(true));
    if (!_focusName.hasFocus && _ctrName.text.isNotEmpty) {
      final first = _ctrName.text.substring(0, 1).toUpperCase();
      _ctrName.text = first + _ctrName.text.substring(1, _ctrName.text.length);
    }
  }

  _initProduct(ProductModel product) {
    hotPick = product.hot_pick;
    _ctrName.text = product.title;
    _ctrId.text = product.product_code;
    _description = product.description;
    _ctrShop.text = product.optional_name;
    _ctrQuantity.text =
        Util.doubleToString(product.quantity, locale: constants.localeVILang);
    _ctrRetailPrice.text =
        Util.doubleToString(product.retail_price, locale: constants.localeVILang);
    _ctrWholesalePrice.text =
        Util.doubleToString(product.wholesale_price, locale: constants.localeVILang);
    if (product.product_catalogue_id > 0)
      _setOption(_ctrCatalogue, languageKey.lblCatalogue,
          id: product.product_catalogue_id.toString(), name: product.catalogue_name);
    if (product.product_unit_id > 0)
      _setOption(_ctrUnit, languageKey.lblUnit,
          id: product.product_unit_id.toString(), name: product.unit_name);
    _setOption(_ctrProType, 'lbl_market', id: product.product_type, name: _getNameFromType(product.product_type));
    if (product.referrerProducts.list.isNotEmpty) {
      _selectReferrers.addAll(product.referrerProducts.list);
    }
    if (product.discount_level > 0){
      _ctrDiscountLevelPriceProduct.text =
          Util.doubleToString(product.discount_level.toDouble(), locale: constants.localeVILang);
    }
    if (product.coupon_per_item > 0){
      _ctrCouponPerProduct.text = product.coupon_per_item.toString();
    }
    if (product.intruction_point > 0){
      _ctrIntructionPointProduct.text = product.intruction_point.toString();
    }
  }

  _initImageTypes() {
    _imageTypes.add(ItemModel(
        id: languageKey.lblCamera,
        name: MultiLanguage.get(languageKey.lblCamera)));
    _imageTypes.add(ItemModel(
        id: languageKey.lblGallery,
        name: MultiLanguage.get(languageKey.lblGallery)));
  }

  _deleteImage(int index) {
    _images.removeAt(index);
    bloc!.add(LoadImageProductEvent());
  }

  _selectOption(List<ItemModel>? list, TextEditingController ctr, String key) {
    _myClearFocus();
    if (list != null) {
      UtilUI.showOptionDialog(context, MultiLanguage.get(key), list, _values[key]!)
        .then((value) => _setOption(ctr, key, id: value!.id, name: value.name))
        .whenComplete(() {
          if (key == 'lbl_market') _loadCatalogues();
        });
    }
  }

  _setOption(TextEditingController ctr, String key, {id = '', name = ''}) {
    ctr.text = name;
    _values.update(key, (value) => id, ifAbsent: () => id);
  }

  String _getNameFromType(String type) {
    switch(type) {
      case 'agricultural_materials_market': return 'Chợ Vật Tư';
      case 'agricultural_wholesale_market': return 'Chợ Sỉ Nông Nghiệp';
      case 'producer_market': return 'Chợ Nhà Sản xuất';
      default: return 'Chợ Nông Sản';
    }
  }

  void _loadCatalogues({bool isClear = true}) {
    if (isClear) {
      _selectCats.clear();
      _catalogues.clear();
      _setOption(_ctrCatalogue, languageKey.lblCatalogue);
    }
    _subBloc.add(LoadCatalogueEvent(type: _values['lbl_market']!));
  }

  _changedOption(ItemModel item, TextEditingController ctr, String key) {
    if (item.id != _values[key]) _setOption(ctr, key, id: item.id, name: item.name);
  }

  _onTextChanged(TextEditingController ctr, String value) {
    int count = 0;
    String tmp = value;
    for (int i = 0; i < tmp.length - 1; i++) {
      if (tmp.substring(i, i + 1) == '.') count++;
    }

    for (int i = count - 1; i > 0; i--) tmp = tmp.replaceFirst('.', '');

    double rs = Util.stringToDouble(tmp, locale: constants.localeVILang);
    if (rs > 9999999999999999) {
      ctr.text = value.substring(0, value.length - 1);
      ctr.selection = TextSelection.collapsed(offset: ctr.text.length);
    }
  }

  _focusListeners(TextEditingController ctr, FocusNode focus, {bool isNumberDefault = true}) {
    focus.addListener(() {
      if(!isNumberDefault) if(ctr.text.isEmpty) return;
      if (focus.hasFocus) {
        double tmp = Util.stringToDouble(ctr.text, locale: constants.localeVILang);
        if (tmp > 0) {
          ctr.text = tmp.toString();
          //if (_locale == Constants.localeVILang)
            ctr.text = ctr.text.replaceFirst('.0', '', ctr.text.length - 2);
        } else ctr.text = '';
      } else {
        int count = 0;
        String tmp = ctr.text;
        for (int i = 0; i < tmp.length - 1; i++) {
          if (tmp.substring(i, i + 1) == '.') count++;
        }

        for (int i = count - 1; i > 0; i--) tmp = tmp.replaceFirst('.', '');

        ctr.text = tmp;    
        ctr.text = Util.doubleToString(Util.stringToDouble(ctr.text,
            locale: constants.localeVILang), locale: constants.localeVILang);
      }
    });
  }

  _onClickPost() async {
    _myClearFocus();
    ProductPage page = widget as ProductPage;
    if (_images.isEmpty) {
      UtilUI.showCustomDialog(context, 'Cung cấp hình ảnh cho sản phẩm').whenComplete(() => selectImage(_imageTypes));
      return;
    }
    if (_ctrName.text.isEmpty) {
      UtilUI.showCustomDialog(context, MultiLanguage.get('msg_input_product_name'))
          .then((value) => _focusName.requestFocus());
      return;
    } else {
      final first = _ctrName.text.substring(0, 1).toUpperCase();
      _ctrName.text = first + _ctrName.text.substring(1, _ctrName.text.length);
    }
    if (_ctrProType.text.isEmpty) {
      UtilUI.showCustomDialog(context, 'Chọn danh mục chợ')
          .then((value) => _focusProType.requestFocus());
      return;
    }
    if (_ctrCatalogue.text.isEmpty) {
      UtilUI.showCustomDialog(context, 'Chọn danh mục sản phẩm')
          .then((value) => _focusCatalogue.requestFocus());
      return;
    }
    if (_ctrUnit.text.isEmpty) {
      UtilUI.showCustomDialog(context, 'Chọn đơn vị tính')
          .then((value) => _focusUnit.requestFocus());
      return;
    }
    // if (_ctrDescription.text.isEmpty) {
    //   UtilUI.showCustomDialog(context, MultiLanguage.get('msg_input_description'))
    //       .then((value) => _focusDescription.requestFocus());
    //   return;
    // }
    if (_ctrQuantity.text.isEmpty) _ctrQuantity.text = '0';
    if (_ctrRetailPrice.text.isEmpty) {
      UtilUI.showCustomDialog(context, MultiLanguage.get('msg_input_retail_price'))
          .then((value) => _focusRetailPrice.requestFocus());
      return;
    }
    if (_ctrWholesalePrice.text.isEmpty) {
      /*UtilUI.showCustomDialog(
              context, MultiLanguage.get(languageKey.msgInputWholesalePrice))
          .then((value) => _focusWholesalePrice.requestFocus());
      return;*/
      _ctrWholesalePrice.text = '0';
    }
    if (referrerListName().isNotEmpty) {
      if (_ctrCouponPerProduct.text.isEmpty || _ctrCouponPerProduct.text == '0') {
        UtilUI.showCustomDialog(context, 'Chọn % giảm giá trên một sản phẩm')
            .then((value) => _focusCouponPerProduct.requestFocus());
        return;
      }
      if (_ctrDiscountLevelPriceProduct.text.isEmpty || _ctrDiscountLevelPriceProduct.text == '0') {
        UtilUI.showCustomDialog(context, 'Chọn mức giảm tối đa trên 1 sản phẩm')
            .then((value) => _focusDiscountLevelPriceProduct.requestFocus());
        return;
      }
      if (_ctrIntructionPointProduct.text.isEmpty || _ctrIntructionPointProduct.text == '0') {
        UtilUI.showCustomDialog(context, 'Chọn điểm giới thiệu thành công trên 1 sản phẩm')
            .then((value) => _focusIntructionPointProduct.requestFocus());
        return;
      }
      if(!checkCurrentPointCreateProduct()) return;
    }
    if (await UtilUI().alertVerifyPhone(context)) return;
    if (page.isCreate) {
      bloc!.add(PostProductEvent(
          _images,
          ProductModel(
            title: _ctrName.text,
            product_code: _ctrId.text,
            description: _description,
            product_type: _values['lbl_market']!,
            product_catalogue_id: int.parse(_values[languageKey.lblCatalogue]!),
            product_unit_id: int.parse(_values[languageKey.lblUnit]!),
            quantity: Util.stringToDouble(_ctrQuantity.text, locale: constants.localeVILang),
            retail_price: Util.stringToDouble(_ctrRetailPrice.text, locale: constants.localeVILang),
            wholesale_price: Util.stringToDouble(_ctrWholesalePrice.text, locale: constants.localeVILang),
            optional_name: _ctrShop.text,
            hot_pick: hotPick,
            referraler_ids: referrerIds(),
            coupon_per_item: isHasReferrer() ? int.parse(_ctrCouponPerProduct.text) : 0,
            discount_level: isHasReferrer() ? Util.stringToDouble(_ctrDiscountLevelPriceProduct.text, locale: constants.localeVILang) : 0,
            intruction_point: isHasReferrer() ? int.parse(_ctrIntructionPointProduct.text) : 0,
          ),
          page.idBusiness));
    } else {
      _hasUpdateAdvancePoint = true;
      page.product!.title = _ctrName.text;
      page.product!.product_code = _ctrId.text;
      page.product!.description = _description;
      page.product!.optional_name = _ctrShop.text;
      page.product!.product_type = _values['lbl_market']!;
      page.product!.product_catalogue_id = int.parse(_values[languageKey.lblCatalogue]!);
      page.product!.product_unit_id = int.parse(_values[languageKey.lblUnit]!);
      page.product!.quantity = Util.stringToDouble(_ctrQuantity.text, locale: constants.localeVILang);
      page.product!.retail_price = Util.stringToDouble(_ctrRetailPrice.text, locale: constants.localeVILang);
      page.product!.wholesale_price = Util.stringToDouble(_ctrWholesalePrice.text, locale: constants.localeVILang);
      page.product!.hot_pick = hotPick;
      page.product!.referraler_ids = referrerIds();
      page.product!.coupon_per_item = !isHasBusiness() && _ctrCouponPerProduct.text.isNotEmpty ? int.parse(_ctrCouponPerProduct.text) : 0;
      page.product!.discount_level = !isHasBusiness() && _ctrDiscountLevelPriceProduct.text.isNotEmpty ? Util.stringToDouble(_ctrDiscountLevelPriceProduct.text, locale: constants.localeVILang) : 0;
      page.product!.intruction_point = !isHasBusiness() && _ctrIntructionPointProduct.text.isNotEmpty ? int.parse(_ctrIntructionPointProduct.text) : 0;
      bloc!.add(EditProductEvent(_images, page.product!, page.idBusiness, permission: page.permission));
    }
  }

  _handleResponseLoadCatalogue(LoadCatalogueState state) {
    if (isResponseNotError(state.response) && state.response.data.list != null && state.response.data.list.length > 0) {
      _catalogues.addAll(state.response.data.list);
      /*if (_ctrCatalogue.text.isEmpty) {
        _catalogues[0].selected = true;
        _changedOption(ItemModel(id: '${_catalogues[0].id}', name: _catalogues[0].name),
            _ctrCatalogue, languageKey.lblCatalogue);
      }*/
    }
  }

  _handleResponseLoadUnit(LoadUnitProductState state) {
    if (isResponseNotError(state.response) &&
        state.response.data.list != null &&
        state.response.data.list.length > 0) {
      _units = state.response.data.list;
      //if (_ctrUnit.text.isEmpty) _changedOption(_units![0], _ctrUnit, languageKey.lblUnit);
    } else _units = [];
  }

  _handleResponse(state) {
    if (isResponseNotError(state.response)) {
      _productId = state.response.data.id;
      _currentProductData = state.response.data;
      isHasReferrer() ? bloc!.add(GetAdvancePointsEvent(_productId)) : showDialogUpdateSuccess();
    }
  }

  _handleDownloadImages(List<File> files) {
    pass = false;
    if (files.isNotEmpty) {
      for (int i = 0; i < files.length; i++) {
        _images.add(FileByte(files[i].readAsBytesSync(), files[i].path));
      }
      bloc!.add(LoadImageProductEvent());
    }
  }

  _handleGetProfile(state){
    if (state.data.data is LoginModel){
      _currentPoint = state.data.data.points;
    }
  }

  _handleAdvancePoints(state){
    if (isResponseNotError(state.data)){
      updateCurrentAdvancePoint();
      setState(() {
        _currentPoint = state.data.data.current_point;
        _appliedPoint = state.data.data.applied_point;
        _minAdvancePoint = state.data.data.min_advance_point;
        updateHasAdvancePoint();
      });
      if(!state.isUpdate && _hasAdvancePoint == true){
        showDialogReferral();
      }else if(_hasUpdateAdvancePoint) {
        showDialogUpdateSuccess();
      }
    }
  }

  _handleAdvancePointsUpdate(state){
    if (isResponseNotError(state)) showDialogUpdateSuccess();
  }

  _checkHotPick(bool value) {
    hotPick = value;
    bloc!.add(CheckHotPickProductEvent());
  }

  void _showCatalogues({bool value = true}) {
    _myClearFocus();
    bloc!.add(ShowCataloguesEvent(value));
  }

  void _loadSubCatalogue(int id, int index) {
    final expanded = !_catalogues[index].expanded;
    if (expanded) _catalogues.forEach((element) => element.expanded = false);
    _catalogues[index].expanded = expanded;
    _subBloc.add(ExpandedCatalogueEvent());
    if (!_catalogues[index].hasSub) _subBloc.add(LoadSubCatalogueEvent(id, index));
  }

  void _handleLoadSubCatalogue(LoadSubCatalogueState state) {
    if (state.list.isNotEmpty) {
      final cat = _catalogues[state.index];
      if (cat.subList == null) cat.subList = state.list;
      else if (cat.subList!.isEmpty) cat.subList!.addAll(state.list);
      cat.hasSub = true;
    }
  }

  void _updateDescription(dynamic value) async {
    SharedPreferences.getInstance().then((prefs) => prefs.remove('hainong_url'));
    if (_description == value.toString()) return;
    _description = value.toString();
    bloc!.add(SetHeightEvent(-1));
  }

  void _selectedSub(int index) {
    _unselectedSub();
    _selectCats.putIfAbsent(_catalogues[index].id.toString() + _catalogues[index].name, () => ItemModel(id: _catalogues[index].id.toString(),
        name: _catalogues[index].name));
    _catalogues[index].selected = true;
    _subBloc.add(SelectedCatalogueEvent());
  }

  void _unselectedSub() {
    for(int i = _catalogues.length - 1; i > -1; i--) _unselectAll(_catalogues[i]);
    //_subBloc.add(SelectedCatalogueEvent());
  }

  void _unselectAll(CatalogueModel item) {
    _selectCats.remove(item.id.toString()+item.name);
    item.selected = false;
    if (item.hasSub && item.subList != null)
      for(int i = item.subList!.length - 1; i > -1; i--)
        _unselectAll(item.subList![i]);
  }

  Widget? prefixIconReferrer(InputFieldValues<String> inputFieldValues) {
    return inputFieldValues.tags.isNotEmpty
        ? SingleChildScrollView(
            controller: inputFieldValues.tagScrollController,
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.only(top: 8,bottom: 8,left: 8),
              child: Wrap(runSpacing: 4.0,spacing: 0,
                  children: inputFieldValues.tags.map((String tag) {
                    return Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all( Radius.circular(20.0)),
                        color: Color.fromARGB(255, 74, 137, 92),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 2.0),
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [ InkWell(child: Text('#$tag',style: const TextStyle(color: Colors.white)))]
                      ),
                    );
                  }).toList()),
            ),
          )
        : null;
  }

  String _textContentDialogPoint(int points){
    if(_hasAdvancePoint ?? false){
      return 'Bạn cần ứng [$points điểm] điểm để hoàn tất quy trình đăng sản phẩm. Số điểm này sẽ được chi trả dần cho người giới thiệu sản phẩm sau khi đơn hàng được hoàn thành. Bạn có thể rút lại số điểm đã ứng, tuy nhiên nếu không đủ điểm duy trì tính năng giới thiệu sẽ tạm ngưng.';
    } else{
      return 'Tính năng giới thiệu sản phẩm [${_ctrName.text}] sẽ tạm ngưng. Xác nhận rút toàn bộ điểm?';
    }
  }

  void updateHasAdvancePoint(){
    if(_currentPoint >= _minAdvancePoint){
      if(_minAdvancePoint > 0 ){
        _hasAdvancePoint = true;
        return;
      }
      if(_appliedPoint > 0){
        _hasAdvancePoint = false;
        return;
      }
    }
    _hasAdvancePoint = null;
  }

  void showDialogReferral(){
    if(!checkCurrentPointCreateProduct()) return;
    UtilUI.showCustomDialog(context, _textContentDialogPoint(_minAdvancePoint), isActionCancel: true, title: "Thông báo", lblOK: _hasAdvancePoint! ? 'Đồng ý' : 'Xác nhận').then((value) {
      if(value == true){
        bloc?.add(PostAdvancePointsEvent(_productId, _hasAdvancePoint! ? "advance_product_introduction" : "withdraw_point_product_introduction", _hasAdvancePoint! ? _minAdvancePoint.toString() : _appliedPoint.toString()));
      }else{
        if((widget as ProductPage).isCreate) UtilUI.goBack(context, _currentProductData);
      }
    });
  }

  void updateCurrentAdvancePoint(){
    final quality = Util.stringToDouble(_ctrQuantity.text, locale: constants.localeVILang);
    final point = Util.stringToDouble(_ctrIntructionPointProduct.text, locale: constants.localeVILang);
    _currentAdvancePoint = quality.toInt() * point.toInt();
  }

  void updateMinAdvancePoint(){
    updateCurrentAdvancePoint();
    if(_appliedPoint != 0){
      if(_currentAdvancePoint > _appliedPoint){
        _minAdvancePoint = _currentAdvancePoint - _appliedPoint;
        _hasAdvancePoint = true;
      }
    }else{
      _minAdvancePoint = _currentAdvancePoint;
      _hasAdvancePoint = true;
    }
  }

  bool isPoints() => _currentPoint > _minAdvancePoint;

  bool isShowAdvancePointsBottom() => !(widget as ProductPage).isCreate && _hasAdvancePoint != null;

  bool checkCurrentPointCreateProduct(){
    updateMinAdvancePoint();
    if(_currentPoint < _minAdvancePoint){
      showDialogDisableReferral();
      return false;
    }
    return true;
  }

  bool isHasReferrer() => !isHasBusiness() ? referrerListName().isNotEmpty : false;

  bool isHasBusiness() {
    final page = widget as ProductPage;
    return page.idBusiness > 0 || (page.product != null && page.product!.business_association_id > 0);
  }

  List<String> referrerListName() {
    List<String> nameList = [];
    final referrers = _selectReferrers.map((e) => e.name).toList();
    final friends = _selectFriends.map((e) => e.name).toList();
    nameList.addAll(referrers);
    nameList.addAll(friends);
    return nameList;
  }

  List<int> referrerIds() {
    List<int> nameList = [];
    final referrers = _selectReferrers.map((e) => e.id).toList();
    final friends = _selectFriends.map((e) => e.id).toList();
    nameList.addAll(referrers);
    nameList.addAll(friends);
    return nameList;
  }

  List<ReferrerModel> referrerList() {
    List<ReferrerModel> list = [];
    list.addAll(_selectFriends);
    list.addAll(_selectReferrers);
    return list;
  }

  void resetValuesReferral(){
    if(referrerIds().isEmpty){
      _selectReferrers.clear();
      _selectFriends.clear();
    }
  }

  void onHandlePressIconReferrer(InputFieldValues<String> inputFieldValues) {
      UtilUI.goToNextPage(
        context,
        ReferrerListPage(
        selectFriends: _selectFriends,
        selectReferrers: _selectReferrers,
        callBackSelectItems: (selectReferrers, selectFriends) {
          _selectFriends.clear();
          _selectReferrers.clear();
          _selectFriends.addAll(selectFriends);
          _selectReferrers.addAll(selectReferrers);
          resetValuesReferral();
          setState(() => inputFieldValues.tags = referrerListName());
      }));
  }

  void showDialogDisableReferral(){
     UtilUI.showCustomDialog(context, 'Điểm hiện tại của bạn [$_currentPoint] điểm, \nkhông đủ để giới thiệu sản phẩm', alignMessageText: TextAlign.center)
        .then((value) {
          _hasUpdateAdvancePoint = false;
          if(_productId != -1) bloc!.add(GetAdvancePointsEvent(_productId, isUpdate: true));
            _focusReferrarUser.requestFocus();
        });
  }

  void showDialogUpdateSuccess() => UtilUI.showCustomDialog(context, 'Bạn đã ${(widget as ProductPage).isCreate ? 'tạo' : 'cập nhập'} sản phẩm thành công', title: "Thành công").then((value) { UtilUI.goBack(context, _currentProductData); });
}
