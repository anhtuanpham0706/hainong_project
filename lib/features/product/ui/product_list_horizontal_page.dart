import 'package:hainong/common/ui/import_lib_ui.dart';
import '../bloc/product_list_horizontal_bloc.dart';
import 'product_item_horizontal_page.dart';
import 'package:hainong/features/shop/shop_model.dart';
import '../product_model.dart';

class ProductListHorizontalPage extends BasePage {
  final String productId;
  final ShopModel shop;
  final bool isHighlight, isNext, hasExceptCatalogue;
  final Function? loginOrCreateCallback, funHideList, funReloadParent;
  final ProductItemHorizontalCallback? callback;

  ProductListHorizontalPage(this.shop, {Key? key, this.productId = '', this.isHighlight = false,
    this.funHideList, this.isNext = false, this.loginOrCreateCallback, this.callback,
    this.hasExceptCatalogue = false, this.funReloadParent})
      : super(key: key, pageState: ProductListHorizontalPageState());

  reloadList() {
    final state = pageState as ProductListHorizontalPageState;
    state.reloadList();
  }
}

class ProductListHorizontalPageState extends BasePageState implements ProductItemHorizontalCallback {
  final List<ProductModel> _list = [];
  final ScrollController _scroller = ScrollController();
  int _page = 1;

  @override
  bool get wantKeepAlive => true;

  @override
  addRemoveFavourite(bool value, int favouriteId, int productId) {
    final page = widget as ProductListHorizontalPage;
    page.callback?.addRemoveFavourite(value, favouriteId, productId);
  }

  @override
  void dispose() {
    _list.clear();
    _scroller.dispose();
    super.dispose();
  }

  @override
  initState() {
    alive = true;
    bloc = ProListHorBloc(ProListHorState());
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadProductsHorState) _handleResponseLoadProducts(state);
    });
    _scroller.addListener(() {
      if (_page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) _loadProducts(false);
    });
    _loadProducts(true);
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    super.build(context);
    return SizedBox(height: 0.36.sh, width: 1.sw, child: BlocBuilder(bloc: bloc,
      buildWhen: (state1, state2) => state2 is LoadProductsHorState,
      builder: (context, state) {
        final page = widget as ProductListHorizontalPage;
        return ListView.builder(scrollDirection: Axis.horizontal, controller: _scroller,
          itemCount: _list.length, itemBuilder: (context, index) =>
            ProductItemHorizontalPage(_list[index], page.shop, 0.4.sw,
              loginOrCreateCallback: showLoginOrCreate, callback: this));
      }));
  }

  showLoginOrCreate() {
    final page = widget as ProductListHorizontalPage;
    if (page.loginOrCreateCallback == null) {
      UtilUI.showCustomDialog(context, MultiLanguage.get(languageKey.msgLoginOrCreate));
    } else page.loginOrCreateCallback!();
  }

  _loadProducts(bool isFirst) {
    ProductListHorizontalPage pageUI = widget as ProductListHorizontalPage;
    if (pageUI.isNext || isFirst)
      bloc!.add(LoadProductsHorEvent('', '', '', _page, pageUI.productId,
          isHighlight: pageUI.isHighlight, hasExceptCatalogue: pageUI.hasExceptCatalogue));
  }

  _handleResponseLoadProducts(LoadProductsHorState state) {
    if (isResponseNotError(state.response)) {
      final List<ProductModel> listTemp = state.response.data.list;
      if (listTemp.isNotEmpty) {
        _list.addAll(listTemp);
        listTemp.length == 5 ? _page++ : _page = 0;
      } else _page = 0;
    }
    final hide = (widget as ProductListHorizontalPage).funHideList;
    if (hide != null && _list.isEmpty) hide();
  }

  reloadList() {
    _page = 1;
    _list.clear();
    _loadProducts(true);
  }
}
