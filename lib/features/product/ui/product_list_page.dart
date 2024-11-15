import 'package:hainong/common/ui/empty_search.dart';
import 'package:hainong/features/four_markets/four_markets_catalogue_page.dart';
import 'package:hainong/features/four_markets/four_markets_list_page.dart';
import 'package:hainong/features/function/ui/function_item.dart';
import 'import_ui_product.dart';

class ProductListPage extends BasePage {
  final ChangeUICallback? callback;
  final ScrollCallback? scrollCallback;
  final bool hideFilter, loadNext;
  final int initCatalogue;
  final String productId;
  final LoginOrCreateCallback? loginCallback;
  final Function? funHideList;

  ProductListPage({Key? key, this.loadNext = true, this.productId = '',
      this.callback, this.scrollCallback, this.hideFilter = false,
      this.initCatalogue = -1, this.loginCallback, this.funHideList})
  : super(key: key, pageState: ProductListPageState());
}

class ProductListPageState extends BasePageState implements ProductItemHorizontalCallback {
  int _page = 1, _tabIndex = 0;
  bool _isLoading = false, _changeUI = false, _allowScroll = false,
      _showCat = false, _changeCat = false;
  String _key = '';
  double _preScroll = 0.0;
  final int _maxTop = 7;
  final List<ProductModel> _list = [ProductModel(),ProductModel(),ProductModel(),
    ProductModel(),ProductModel(),ProductModel(),ProductModel()];
  final List _bas = [];
  final ScrollController _scroller = ScrollController();
  final ShopModel _shop = ShopModel();
  final Map<String, String> _values = {};
  final List<CatalogueModel> _catalogues = [];
  final Map<String, ItemModel> _selectCats = {};
  final List<ItemModel> _provinces = [];
  ProductListHorizontalPage? highlightPage;

  @override
  addRemoveFavourite(bool value, int favouriteId, int productId) {
    _reloadHighlight();
  }

  @override
  void dispose() {
    _scroller.dispose();
    _list.clear();
    _values.clear();
    _catalogues.clear();
    _provinces.clear();
    _selectCats.clear();
    super.dispose();
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((value) {
      if (value.containsKey(constants.hideToolbar) && value.getInt(constants.hideToolbar) == 1) _allowScroll = true;
    });
    _setOption(languageKey.lblCatalogue);
    _setOption(languageKey.lblProvince);
    _catalogues.add(CatalogueModel(id: (widget as ProductListPage).initCatalogue, name: 'Tất cả'));
    _provinces.add(ItemModel(id: '-1', name: 'Tất cả'));
    _setScroller();
    bloc = ProductListBloc(ProductListState());
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadProductsState) _handleLoadProducts(state);
      else if (state is LoadCatalogueState) _handleLoadCatalogue(state);
      else if (state is LoadProvincesState) _handleLoadProvinces(state);
      else if (state is LoadSubCatalogueState) _handleLoadSubCatalogue(state);
      else if (state is SelectedCatalogueState) _showCatalogues();
      else if (state is LoadBAsState) _bas.addAll(state.bas);
    });
    _getShop();
    bloc!.add(LoadCatalogueEvent());
    bloc!.add(LoadProvincesEvent());
    bloc!.add(LoadBAsEvent());
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    final page = widget as ProductListPage;
    return GestureDetector(onTapDown: (value) => clearFocus(),
      child: Stack(children: [
          RefreshIndicator(child: BlocBuilder(bloc: bloc,
            buildWhen: (state1, state2) => state2 is LoadProductsState || state2 is ShowCatalogueState,
            builder: (context, state) {
              bool showCatalogue = false;
              if (state is ShowCatalogueState) showCatalogue = state.value;
              if (showCatalogue) {
                return Column(children: [
                  FilterProduct(bloc as ProductListBloc, _selectCats, _provinces, _values, _changeSearch, _showCatalogues),
                  Expanded(child: ListView.builder(padding: EdgeInsets.zero,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _catalogues.length,
                      itemBuilder: (context, index) => ProductCatalogueItem(bloc as ProductListBloc, index,
                          _catalogues[index], _loadSubCatalogue, _selectedSub, _unselectedSub, _selectCats)))
                ]);
              }

              if (highlightPage == null || (highlightPage != null && !highlightPage!.pageState.mounted)) {
                highlightPage = ProductListHorizontalPage(_shop,
                    isHighlight: true, isNext: true, callback: this,
                    loginOrCreateCallback: () => _showLoginOrCreate(context: context));
              }

              return ListView.builder(physics: const AlwaysScrollableScrollPhysics(),
                controller: _scroller, padding: EdgeInsets.zero,
                itemCount: _list.length, itemBuilder: (context, index) {
                  if ((index >= _maxTop && index < _list.length) || page.hideFilter) {
                    return _list[index].id > 0 ? ProductItemPage(_list[index], _shop, () {}, () {}, () {},
                        loginOrCreateCallback: () => _showLoginOrCreate(context: context),
                        reloadHighlight: _reloadHighlight, reloadList: _changeSearch) :
                    Padding(padding: EdgeInsets.symmetric(vertical: 40.sp), child: EmptySearch(_key));
                  }
                  switch(index) {
                    case 0: return Column(children: [
                      Padding(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        LabelCustom('Chợ Hai Nông', color: Colors.black, size: 42.sp, weight: FontWeight.normal),
                        GestureDetector(onTap: () => UtilUI.goToNextPage(context, const FourMarketsCatPage(), funCallback: (value) => _reloadHighlight()),
                            child: LabelCustom('Tìm hiểu 󠀼󠀼>', color: Colors.black38, size: 42.sp, weight: FontWeight.normal))
                      ]), padding: EdgeInsets.all(40.sp)),
                      Padding(child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        FunctionItem('Chợ\nVật Tư', '', () => _gotoOtherMarket('agricultural_materials_market'), asset: 'assets/images/v8/ic_materials_market.png'),
                        FunctionItem('Chợ Sỉ\nNông Nghiệp', '', () => _gotoOtherMarket('agricultural_wholesale_market'), asset: 'assets/images/v8/ic_agri_market.png'),
                        FunctionItem('Chợ\nNông Sản', '', () => _gotoOtherMarket('farmers_markets'), asset: 'assets/images/v8/ic_farmers_market.png'),
                        FunctionItem('Chợ Nhà\nSản xuất', '', () => _gotoOtherMarket('producer_market'), asset: 'assets/images/v8/ic_producer_market.png')
                      ]), padding: EdgeInsets.fromLTRB(20.sp, 0, 20.sp, 40.sp)),
                      Divider(height: 20.sp, thickness: 20.sp, color: const Color(0xFFEFEFEF))
                    ]);
                    case 1: return page.hideFilter ? const SizedBox() : FilterProduct(bloc as ProductListBloc, _selectCats, _provinces, _values, _changeSearch, _showCatalogues);
                    case 2: return BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is LoadBAsState,
                        builder: (context, state) {
                          if (_bas.isEmpty) return const SizedBox();
                          final List<Widget> list = [];
                          for (int i = 0; i < _bas.length; i++) {
                            list.add(ButtonImageWidget(8.sp, () => UtilUI.goToNextPage(context, BAPage(_bas[i], _shop)),
                              Container(padding: EdgeInsets.all(20.sp), decoration: BoxDecCustom(bgColor: const Color(0xAFFFFFFF)),
                                child: LabelCustom(_bas[i].name, color: Colors.blue, size: 42.sp, weight: FontWeight.normal)
                            ), color: Colors.white));
                          }
                          return Container(color: const Color(0xFFEAEAEA), margin: EdgeInsets.only(bottom: 20.sp),
                            padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 40.sp),
                              child: Wrap(children: list, spacing: 20.sp, runSpacing: 20.sp));
                        });
                    case 3: return highlightPage??const SizedBox();
                    //case 4: return const Ads('market');
                    case 4: return SizedBox();
                    case 5:
                      if (_selectCats.isEmpty) return const SizedBox();
                      return Container(height: 180.sp, color: const Color(0xFFEAEAEA),
                        margin: EdgeInsets.symmetric(vertical: 20.sp),
                        padding: EdgeInsets.symmetric(vertical: 40.sp),
                        child: ListView.builder(itemCount: _selectCats.length,
                          scrollDirection: Axis.horizontal, padding: EdgeInsets.zero,
                          itemBuilder: (context, indexCat) {
                            bool notLast = indexCat != _selectCats.length - 1;
                            return Row(children: [
                              Container(padding: EdgeInsets.symmetric(horizontal: 40.sp),
                                alignment: Alignment.center, child: Text(
                                  _selectCats.values.elementAt(indexCat).name,
                                  style: TextStyle(fontWeight: notLast ? FontWeight.normal : FontWeight.bold,
                                    fontSize: 40.sp, color: notLast ? const Color(0xFF767676) : Colors.black))),
                              notLast ? Icon(Icons.arrow_forward_ios, size: 40.sp, color: const Color(0xFFA1A1A1)):const SizedBox()
                            ]);
                          }));
                    case 6: return Container(child: BlocBuilder(bloc: bloc,
                      buildWhen: (oldS, newS) => newS is LoadProductsState,
                      builder: (context, state) => Row(children: [
                        TabItem('Tất cả', 0, _tabIndex == 0, _changeTab, parseTitle: false,size: 60.sp,),
                        TabItem('Của tôi', 1, _tabIndex == 1, _changeTab, parseTitle: false,size: 60.sp,)
                      ])), color: Colors.white);
                  }
                  return const SizedBox();
                });
            }), onRefresh: () async {
              highlightPage!.reloadList();
              search(_key);
            }),
          Loading(bloc)
      ]));
  }

  @override
  void search(String key) {
    _initSearch(key);
    _loadProducts();
  }

  void _changeTab(int index) {
    if (_tabIndex != index) {
      _tabIndex = index;
      search(_key);
    }
  }

  void _showLoginOrCreate({context}) {
    final callback = (widget as ProductListPage).loginCallback;
    callback != null ? callback.showLoginOrCreate() :
      UtilUI.showCustomDialog(context, MultiLanguage.get(languageKey.msgLoginOrCreate));
  }

  void _setScroller() => _scroller.addListener(() {
    if (_scroller.position.atEdge && _scroller.position.pixels > 0) _nextPage();

    final page = widget as ProductListPage;
    if (page.callback != null && (page.hideFilter || _allowScroll) &&
      _scroller.position.pixels > 0 && _scroller.position.pixels < _scroller.position.maxScrollExtent) {
          double dy = _scroller.position.pixels - _preScroll;
          if (dy < -1 && _changeUI) _setCollapse(false);
          else if (dy > 1 && !_changeUI) _setCollapse(true);
          _preScroll = _scroller.position.pixels;
    }
  });

  void _getShop() => SharedPreferences.getInstance().then((prefs) {
        _shop.id = prefs.getInt(constants.shopId)??-1;
        _shop.name = prefs.getString(constants.shopName)??'';
        _shop.province_name = prefs.getString(constants.shopProvinceName)??'';
        _shop.district_name = prefs.getString(constants.shopDistrictName)??'';
        _shop.image = prefs.getString(constants.shopImage)??'';
        search('');
      });

  void _setCollapse(bool value) {
    _changeUI = value;
    (widget as ProductListPage).callback!.collapseHeader(value);
    (widget as ProductListPage).callback!.collapseFooter(value);
  }

  void _setOption(String key, {id = '', name = ''}) {
    _values.update(key, (value) => id, ifAbsent: () => id);
    _values.update(key + 'Name', (value) => name, ifAbsent: () => name);
    if (bloc != null) {
      bloc!.add(key == languageKey.lblCatalogue ? ChangeCatalogueEvent() : ChangeProvinceEvent());
      search(_key);
    }
  }

  void _initSearch(String keyword) {
    _key = keyword;
    _page = 1;
    _isLoading = false;
    if ((widget as ProductListPage).hideFilter) {
      _list.clear();
    } else { _list.removeRange(_maxTop, _list.length); }
  }

  void _changeSearch() => search(_key);

  void _loadProducts() {
    _isLoading = true;
    bloc!.add(LoadProductsEvent(_key, _values[languageKey.lblCatalogue]!,
        _values[languageKey.lblProvince]!, _page,
        (widget as ProductListPage).productId, isMine: _tabIndex == 1));
  }

  void _nextPage() {
    if (_page > 0 && !_isLoading && (widget as ProductListPage).loadNext) _loadProducts();
  }

  void _handleLoadProducts(LoadProductsState state) {
    if (isResponseNotError(state.response)) {
      final List<ProductModel> listTemp = state.response.data.list;
      if (listTemp.isNotEmpty) {
        _list.addAll(listTemp);
        _page = listTemp.length == constants.limitPage ? _page + 1 : 0;
      } else _page = 0;
    }
    if (_list.length == _maxTop) _list.add(ProductModel());
    _isLoading = false;
    final hide = (widget as ProductListPage).funHideList;
    if (hide != null && _list.isEmpty) hide();
  }

  void _handleLoadCatalogue(LoadCatalogueState state) {
    if (isResponseNotError(state.response) && state.response.data.list != null &&
        state.response.data.list.length > 0) _catalogues.addAll(state.response.data.list);
  }

  void _handleLoadProvinces(LoadProvincesState state) {
    if (isResponseNotError(state.response) && state.response.data.list != null &&
        state.response.data.list.length > 0) _provinces.addAll(state.response.data.list);
  }

  void _reloadHighlight() {
    highlightPage!.reloadList();
    search(_key);
  }

  void _showCatalogues() {
    _showCat = !_showCat;
    bloc!.add(ShowCatalogueEvent(_showCat));
    if (_showCat) _changeCat = false;
    else if (!_showCat && _changeCat) {
      final cat = _selectCats.values.last;
      _setOption(languageKey.lblCatalogue, id: cat.id, name: cat.name);
    } else search(_key);
  }

  void _loadSubCatalogue(int id, int index) {
    final expanded = !_catalogues[index].expanded;
    if (expanded) _catalogues.forEach((element) => element.expanded = false);
    _catalogues[index].expanded = expanded;
    Util.trackActivities('products', path: 'Products Screen -> Show product filter for ${_catalogues[index].name}');
    bloc!.add(ExpandedCatalogueEvent());
    if (!_catalogues[index].hasSub) bloc!.add(LoadSubCatalogueEvent(id, index));
  }

  void _handleLoadSubCatalogue(LoadSubCatalogueState state) {
    if (state.list.isNotEmpty) {
      final cat = _catalogues[state.index];
      if (cat.subList == null) cat.subList = state.list;
      else if (cat.subList!.isEmpty) cat.subList!.addAll(state.list);
      cat.hasSub = true;
    }
  }

  void _selectedSub(int index) {
    _unselectedSub();
    _selectCats.putIfAbsent(_catalogues[index].id.toString() + _catalogues[index].name, () => ItemModel(id: _catalogues[index].id.toString(),
        name: _catalogues[index].name));
    _catalogues[index].selected = true;
    bloc!.add(SelectedCatalogueEvent());
  }

  void _unselectedSub() {
    _changeCat = true;
    for(int i = _catalogues.length - 1; i > -1; i--) _unselectAll(_catalogues[i]);
  }

  void _unselectAll(CatalogueModel item) {
    _selectCats.remove(item.id.toString()+item.name);
    item.selected = false;
    if (item.hasSub && item.subList != null) for(int i = item.subList!.length - 1; i > -1; i--) _unselectAll(item.subList![i]);
  }

  void _gotoOtherMarket(String type) => UtilUI.goToNextPage(context, FourMarketListPage(ItemModel(), type), funCallback: (value) => _reloadHighlight());
}
