import 'package:hainong/common/ui/empty_search.dart';
import 'package:hainong/common/ui/image_network_asset.dart';
import 'package:hainong/features/four_markets/four_markets_producer_page.dart';
import 'package:hainong/features/main/ui/header_main.dart';
import '../function/support/business_association/ui/ba_item.dart';
import '../main/bloc/main_bloc.dart';
import '../product/ui/import_ui_product.dart';

class FourMarketListPage extends BasePage {
  final ItemModel catalogue;
  final String type;
  final dynamic bas;
  final LoginOrCreateCallback? loginCallback;

  FourMarketListPage(this.catalogue, this.type, {Key? key, this.loginCallback, this.bas})
  : super(key: key, pageState: FourMarketListPageState());
}

class FourMarketListPageState extends BasePageState implements ProductItemHorizontalCallback {
  int _page = 1, _tabIndex = 0;
  bool _isLoading = false, _showCat = false, _changeCat = false;
  String _key = '';
  final int _maxTop = 4;
  final List _bas = [];
  final List<ProductModel> _list = [ProductModel(),ProductModel(),ProductModel(),ProductModel()];
  final ScrollController _scroller = ScrollController();
  final ShopModel _shop = ShopModel();
  final Map<String, String> _values = {};
  final List<CatalogueModel> _catalogues = [];
  final Map<String, ItemModel> _selectCats = {};
  final List<ItemModel> _provinces = [];
  final ScrollBloc _scrollBloc = ScrollBloc(ScrollState());
  final _ctrSearch = TextEditingController();
  final _focusSearch = FocusNode();

  @override
  addRemoveFavourite(bool value, int favouriteId, int productId) => _reloadHighlight();

  @override
  void dispose() {
    _scroller.dispose();
    _scrollBloc.close();
    _list.clear();
    _bas.clear();
    _values.clear();
    _catalogues.clear();
    _provinces.clear();
    _selectCats.clear();
    _ctrSearch.removeListener(_listenerSearch);
    _ctrSearch.dispose();
    _focusSearch.dispose();
    super.dispose();
  }

  @override
  void initState() {
    final page = widget as FourMarketListPage;
    _setOption(languageKey.lblCatalogue, id: page.catalogue.id, name: page.catalogue.name);
    _setOption(languageKey.lblProvince);
    _catalogues.add(CatalogueModel(id: -1, name: 'Tất cả'));
    _provinces.add(ItemModel(id: '-1', name: 'Tất cả'));
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

    if (page.bas == null) {
      bloc!.add(LoadCatalogueEvent(type: page.type));
      bloc!.add(LoadProvincesEvent());
      if (page.type == 'producer_market') bloc!.add(LoadBAsEvent(isBMarket: true));
    }

    if (page.catalogue.id.isNotEmpty) {
      _changeCat = true;
      _selectCats.putIfAbsent(page.catalogue.id + page.catalogue.name, () => ItemModel(id: page.catalogue.id, name: page.catalogue.name));
      bloc!.add(SelectedCatalogueEvent());
    }

    _setScroller();
    _ctrSearch.addListener(_listenerSearch);
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) =>
    GestureDetector(onTapDown: (value) => clearFocus(), child: Scaffold(
      appBar: HeaderAppBar(_ctrSearch, _focusSearch, _search, _clearSearch, _scrollBloc, buttonHelper()),
      body: Stack(children: [
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

            final page = widget as FourMarketListPage;
            final isBusiness = page.type == 'producer_market';
            return ListView.builder(physics: const AlwaysScrollableScrollPhysics(),
              controller: _scroller, padding: EdgeInsets.zero,
              itemCount: _list.length, itemBuilder: (context, index) {
                if (index >= _maxTop && index < _list.length) {
                  return _list[index].id > 0 ? ProductItemPage(_list[index], _shop, () {}, () {}, () {},
                    loginOrCreateCallback: () => _showLoginOrCreate(context: context),
                    reloadHighlight: _reloadHighlight, reloadList: _changeSearch) :
                  BlocBuilder(bloc: bloc, buildWhen: (oldBAS, newBAS) => newBAS is LoadBAsState,
                    builder: (context, stateBA) => SizedBox(child: EmptySearch(_key),
                      height: _bas.length < 3 ? 0.5.sh : 0.4.sh));
                }
                switch(index) {
                  case 0:
                    if (!isBusiness) return const SizedBox();
                    if (page.bas != null) {
                      return Column(children: [
                        BAItem(page.bas, fullInfo: true),
                        Divider(height: 20.sp, thickness: 20.sp, color: const Color(0xFFEFEFEF))
                      ]);
                    }
                    return Column(children: [
                      Padding(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        LabelCustom('Doanh nghiệp sản xuất', color: Colors.black, size: 42.sp, weight: FontWeight.normal),
                        GestureDetector(onTap: () => UtilUI.goToNextPage(context, FourMarketProducerPage(), funCallback: (value) => _search()),
                          child: LabelCustom('Xem tất cả 󠀼󠀼>', color: Colors.black38, size: 42.sp, weight: FontWeight.normal))
                      ]), padding: EdgeInsets.fromLTRB(40.sp, 40.sp, 40.sp, 0)),
                      BlocBuilder(bloc: bloc,
                        buildWhen: (oldBAS, newBAS) => newBAS is LoadBAsState,
                        builder: (context, stateBA) => GridView.count(physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 0.5.sw/0.25.sw, crossAxisCount: 2, shrinkWrap: true,
                          padding: EdgeInsets.all(40.sp), mainAxisSpacing: 40.sp, crossAxisSpacing: 40.sp,
                          children: List.generate(_bas.length, (indexBA) =>
                            ButtonImageWidget(0, () => UtilUI.goToNextPage(context,
                                FourMarketListPage(ItemModel(), page.type, bas: _bas[indexBA]), funCallback: (value) => _search()),
                              Stack(children: [
                                ClipRRect(borderRadius: BorderRadius.circular(10),
                                  child: ImageNetworkAsset(path: _bas[indexBA].image, width: 0.5.sw, height: 0.25.sw)),
                                if (_bas[indexBA].prestige == 1)
                                  Image.asset('assets/images/v8/ic_prestige_business.png', width: 80.sp, height: 80.sp)
                              ], alignment: Alignment.topRight))))),
                      Divider(height: 20.sp, thickness: 20.sp, color: const Color(0xFFEFEFEF))
                    ]);
                  case 1: return page.bas != null ? const SizedBox() :
                    Container(color: Colors.white, child:
                      FilterProduct(bloc as ProductListBloc, _selectCats,
                        _provinces, _values, _changeSearch, _showCatalogues));
                  case 2:
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
                              alignment: Alignment.center, child: Text(_selectCats.values.elementAt(indexCat).name,
                                style: TextStyle(fontWeight: notLast ? FontWeight.normal : FontWeight.bold,
                                fontSize: 40.sp, color: notLast ? const Color(0xFF767676) : Colors.black))),
                            notLast ? Icon(Icons.arrow_forward_ios, size: 40.sp, color: const Color(0xFFA1A1A1)) : const SizedBox()
                          ]);
                        }));
                  case 3: return isBusiness ? const SizedBox() :
                    Column(children: [
                      const Divider(height: 1, thickness: 1, color: Color(0xFFEFEFEF)),
                      Container(child: BlocBuilder(bloc: bloc,
                        buildWhen: (oldS, newS) => newS is LoadProductsState,
                        builder: (context, state) => Row(children: [
                          TabItem('Tất cả', 0, _tabIndex == 0, _changeTab, parseTitle: false, size: 60.sp,),
                          TabItem('Của tôi', 1, _tabIndex == 1, _changeTab, parseTitle: false, size: 60.sp,)
                        ])), color: Colors.white)
                    ]);
                }
                return const SizedBox();
              });
          }), onRefresh: () async => search(_key)),
        Loading(bloc)
      ])
    ));

  @override
  void search(String key) {
    clearFocus();
    _initSearch(key);
    _loadProducts();
  }

  void _search() => search(_ctrSearch.text);

  void _clearSearch() {
    _ctrSearch.text = '';
    search('');
  }

  void _changeTab(int index) {
    if (_tabIndex != index) {
      _tabIndex = index;
      search(_key);
    }
  }

  void _listenerSearch() => _scrollBloc.add(HideClearScrollEvent(_ctrSearch.text.isEmpty));

  void _showLoginOrCreate({context}) {
    final callback = (widget as FourMarketListPage).loginCallback;
    callback != null ? callback.showLoginOrCreate() :
      UtilUI.showCustomDialog(context, MultiLanguage.get(languageKey.msgLoginOrCreate));
  }

  void _setScroller() => _scroller.addListener(() {
    if (_scroller.position.atEdge && _scroller.position.pixels > 0) _nextPage();
  });

  void _getShop() => SharedPreferences.getInstance().then((prefs) {
        _shop.id = prefs.getInt(constants.shopId)??-1;
        _shop.name = prefs.getString(constants.shopName)??'';
        _shop.province_name = prefs.getString(constants.shopProvinceName)??'';
        _shop.district_name = prefs.getString(constants.shopDistrictName)??'';
        _shop.image = prefs.getString(constants.shopImage)??'';
        search('');
        BlocProvider.of<MainBloc>(context).add(CountCartMainEvent());
      });

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
    _list.removeRange(_maxTop, _list.length);
  }

  void _changeSearch() => search(_key);

  void _loadProducts() {
    _isLoading = true;
    final page = widget as FourMarketListPage;
    bloc!.add(LoadProductsEvent(_key, _values[languageKey.lblCatalogue]!,
      _values[languageKey.lblProvince]!, _page, '', isMine: _tabIndex == 1,
      type: page.type, businessId: page.bas != null ? page.bas.id : -1));
  }

  void _nextPage() {
    if (_page > 0 && !_isLoading) _loadProducts();
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
  }

  void _handleLoadCatalogue(LoadCatalogueState state) {
    if (isResponseNotError(state.response) && state.response.data.list != null &&
        state.response.data.list.length > 0) _catalogues.addAll(state.response.data.list);
  }

  void _handleLoadProvinces(LoadProvincesState state) {
    if (isResponseNotError(state.response) && state.response.data.list != null &&
        state.response.data.list.length > 0) _provinces.addAll(state.response.data.list);
  }

  void _reloadHighlight() => search(_key);

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
}
