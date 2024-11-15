import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/button_image_circle_widget.dart';
import 'package:hainong/common/ui/shadow_decoration.dart';
import 'package:hainong/common/ui/task_bar_widget.dart';
import 'package:hainong/features/product/bloc/product_list_bloc.dart';
import 'package:hainong/features/product/product_model.dart';
import 'package:hainong/features/shop/shop_model.dart';

import 'empty_search.dart';

class BaseProductListPage extends BasePage {
  final String catalogueId;
  final String productId;
  final ShopModel shop;
  final bool hasExceptCatalogue;

  const BaseProductListPage(this.shop, {this.catalogueId = '-1', this.hasExceptCatalogue = false,
    this.productId = '', pageState, Key? key}):super(pageState: pageState, key:key);
}

class BaseProductListPageState extends BasePageState {
  int _page = 0;
  bool _isNext = false, _isLoading = false, _isFirst = true;
  final List<ProductModel> list = [];
  final ScrollController scroller = ScrollController();
  final TextEditingController _ctrKey = TextEditingController();
  String title, _keyword = '';

  BaseProductListPageState(this.title);

  @override
  void dispose() {
    list.clear();
    super.dispose();
  }

  @override
  initState() {
    bloc = ProductListBloc(ProductListState());
    _setScroller();
    super.initState();
    bloc?.stream.listen((state) {
      if (state is LoadProductsState) _handleResponseLoadProducts(state);
    });
  }

  @override
  Widget createUI() {
    if (_page == 0) _search();
    return Scaffold(
        appBar: TaskBarWidget(title, shadowColor: Colors.transparent, elevation: 0).createUI(),
        body: Column(children: [
          Container(
              padding: EdgeInsets.only(left: 40.sp, right: 40.sp, bottom: 40.sp),
              decoration: ShadowDecoration(bgColor: StyleCustom.primaryColor, opacity: 1),
              child: Stack(alignment: Alignment.centerLeft, children: [
                _createSearch(),
                Row(children: [
                  Container(padding: EdgeInsets.only(left: 20.sp, right: 20.sp),
                      child: ButtonImageCircleWidget(40.sp, _search,
                          child: Image.asset('assets/images/ic_search.png',
                              height: 50.sp, width: 50.sp))),
                  _ctrKey.text.isNotEmpty ? Container(padding: EdgeInsets.only(left: 20.sp, right: 20.sp),
                      child: ButtonImageCircleWidget(40.sp, _clear,
                          child: Icon(Icons.close, size: 50.sp, color: Colors.white))) : const SizedBox()
                ], mainAxisAlignment: MainAxisAlignment.spaceBetween)
              ])),
          Expanded(child: BlocBuilder(bloc: bloc,
              buildWhen: (state1, state2) => state2 is LoadProductsState,
              builder: (context, state) => list.isEmpty && !_isFirst && !_isLoading ?
                EmptySearch(_keyword) : createList(context)))
        ]));
  }

  Widget createList(context) => const SizedBox();

  Widget _createSearch() {
    return TextField(
        style: TextStyle(color: Colors.white, fontSize: 35.sp),
        onSubmitted: (value) => _search(),
        onChanged: (value) {
          if (value.isEmpty || value.length == 1) setState((){});
        },
        textInputAction: TextInputAction.done,
        controller: _ctrKey,
        cursorColor: Colors.white,
        decoration: InputDecoration(
            hintStyle: const TextStyle(color: Colors.white),
            isDense: true,
            filled: true,
            fillColor: Colors.black12,
            contentPadding: EdgeInsets.only(
                top: 22.sp, left: 80.sp, right: 110.sp, bottom: 22.sp),
            hintText: MultiLanguage.get('lbl_search'),
            border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(100.sp))));
  }

  showLoginOrCreate(context) =>
    UtilUI.showCustomDialog(context, MultiLanguage.get(LanguageKey().msgLoginOrCreate));

  _setScroller() => scroller.addListener(() {
    if (scroller.position.atEdge && scroller.position.pixels > 0) _nextPage();
  });

  _search() {
    _page = 1;
    list.clear();
    clearFocus();
    _loadProducts();
  }

  _clear() {
    _ctrKey.text = '';
    setState((){});
    _search();
  }

  _loadProducts() {
    _isLoading = true;
    final page = widget as BaseProductListPage;
    bloc?.add(LoadProductsEvent(_ctrKey.text, page.catalogueId, '', _page,
        page.productId, hasExceptCatalogue: page.hasExceptCatalogue));
  }

  _nextPage() {
    if (_isNext && !_isLoading) {
      _page++;
      _loadProducts();
    }
  }

  _handleResponseLoadProducts(LoadProductsState state) {
    _isFirst = false;
    _keyword = _ctrKey.text;
    if (isResponseNotError(state.response)) {
      final List<ProductModel> listTemp = state.response.data.list;
      if (listTemp.isNotEmpty) list.addAll(listTemp);
      _isNext = listTemp.length == constants.limitPage;
    }
    _isLoading = false;
  }
}
