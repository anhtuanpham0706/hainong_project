import 'package:hainong/common/ui/import_lib_ui.dart';
import '../bloc/product_list_bloc.dart';
import 'product_item_page.dart';
import 'package:hainong/features/shop/shop_model.dart';
import '../product_model.dart';

class ProductListFavouritePage extends BasePage {
  final bool isMain2;
  ProductListFavouritePage({this.isMain2 = false, Key? key}):super(key: key, pageState: _ProductListFavouritePageState());
}

class _ProductListFavouritePageState extends BasePageState implements ProductItemPageCallback {
  int _page = 1;
  final ScrollController _scroller = ScrollController();
  final ShopModel _shop = ShopModel();
  final List<ProductModel> _list = [];

  @override
  removeFavourite() {
    _page = 1;
    _list.clear();
    _nextPage();
  }

  @override
  void dispose() {
    _list.clear();
    super.dispose();
  }

  @override
  initState() {
    bloc = ProductListBloc(ProductListState());
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadProductsState) _handleResponseLoadProducts(state);
    });
    _scroller.addListener(() {
      if (_page > 0 && _scroller.position.maxScrollExtent ==
          _scroller.position.pixels) _nextPage();
    });
    _getShop();
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    final child = BlocBuilder(
        bloc: bloc,
        buildWhen: (state1, state2) => state2 is LoadProductsState,
        builder: (context, state) => ListView.builder(
            padding: EdgeInsets.only(left: 10.sp, right: 10.sp),
            controller: _scroller,
            itemCount: _list.length,
            itemBuilder: (context, index) => ProductItemPage(
                _list[index], _shop, () {}, () {}, () {}, callback: this)));
    return (widget as ProductListFavouritePage).isMain2 ? Scaffold(
      appBar: AppBar(title: UtilUI.createLabel(MultiLanguage.get('ttl_saved_products'), textAlign: TextAlign.center)),
      body: child
    ) : child;
  }

  _getShop() => SharedPreferences.getInstance().then((prefs) {
        _shop.id = prefs.getInt(constants.shopId)??-1;
        _shop.name = prefs.getString(constants.shopName)??'';
        _shop.province_name = prefs.getString(constants.shopProvinceName)??'';
        _shop.district_name = prefs.getString(constants.shopDistrictName)??'';
        _shop.image = prefs.getString(constants.shopImage)??'';
        _nextPage();
      });

  _nextPage() {
    if (_page > 0) {
      bloc!.add(LoadFavouriteProductsEvent(_page));
    }
  }

  _handleResponseLoadProducts(LoadProductsState state) {
    if (isResponseNotError(state.response)) {
      final List<ProductModel> listTemp = state.response.data.list;
      if (listTemp.isNotEmpty) listTemp.forEach((element) => _list.add(element));

      listTemp.length == constants.limitPage ? _page++ : _page = 0;
    }
  }
}
