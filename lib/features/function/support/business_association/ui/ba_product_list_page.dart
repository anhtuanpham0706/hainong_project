import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hainong/common/ui/box_dec_custom.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/features/function/support/mission/mission_bloc.dart';
import 'package:hainong/features/product/ui/product_item_horizontal_page.dart';
import 'package:hainong/features/product/ui/product_page.dart';
import '../ba_bloc.dart';

class BAProductListPage extends BasePage {
  BAProductListPage(int idBusiness, dynamic shop, {Key? key}) : super(pageState: _BAProductListPageState(idBusiness, shop), key: key);
}

class _BAProductListPageState extends BasePageState implements ProductItemHorizontalCallback {
  final TextEditingController _ctrSearch = TextEditingController();
  final ScrollController _scroller = ScrollController();
  final List _list = [];
  dynamic shop;
  int _page = 1, idBusiness;
  bool _lock = false;

  _BAProductListPageState(this.idBusiness, this.shop);

  @override
  addRemoveFavourite(bool value, int favouriteId, int productId) => _reset();

  @override
  void dispose() {
    _scroller.removeListener(_listenScroller);
    _scroller.dispose();
    _list.clear();
    _ctrSearch.dispose();
    super.dispose();
  }

  @override
  void initState() {
    bloc = BABloc('product_list');
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadListState) {
        if (isResponseNotError(state.response)) {
          final list = state.response.data.list;
          if (list.isNotEmpty) {
            _list.addAll(list);
            list.length == 20 ? _page++ : _page = 0;
          } else _page = 0;
        }
        _lock = false;
      } else if (state is DeleteEmpState && isResponseNotError(state.resp, passString: true)) {
        _reset();
      }
    });
    _loadMore();
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Stack(children: [
    GestureDetector(onTap: clearFocus, onHorizontalDragDown: (_) => clearFocus(), onVerticalDragDown: (_) => clearFocus(),
      child: Scaffold(backgroundColor: color,
        appBar: AppBar(elevation: 0, titleSpacing: 0, centerTitle: true,
          title: UtilUI.createLabel('Danh sách sản phẩm'),
          bottom: PreferredSize(preferredSize: Size(0.5.sw, 140.sp), child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.sp)
              ), padding: EdgeInsets.all(30.sp), margin: EdgeInsets.fromLTRB(40.sp, 0, 40.sp, 40.sp),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is ShowClearSearchState,
                    builder: (context, state) {
                      bool show = false;
                      if (state is ShowClearSearchState) show = state.value;
                      return show ? Padding(padding: EdgeInsets.only(right: 20.sp),
                          child: ButtonImageWidget(100, _clear, Icon(Icons.clear,
                              size: 48.sp, color: const Color(0xFF676767)))) : const SizedBox();
                    }),
                Expanded(child: TextField(controller: _ctrSearch,
                    onChanged: (value) {
                      if (value.length == 1) bloc!.add(ShowClearSearchEvent(true));
                      if (value.isEmpty) bloc!.add(ShowClearSearchEvent(false));
                    },
                    onSubmitted: (value) => _search(),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                        hintStyle: TextStyle(fontSize: 36.sp, color: const Color(0xFF959595)),
                        hintText: 'Tìm kiếm ...',
                        contentPadding: EdgeInsets.zero, isDense: true,
                        border: const UnderlineInputBorder(borderSide: BorderSide.none)
                    )
                )),
                ButtonImageWidget(100, _search, Icon(Icons.search, size: 48.sp, color: const Color(0xFF676767)))
              ])))
        ),
        floatingActionButton: FloatingActionButton.small(backgroundColor: StyleCustom.primaryColor,
          onPressed: () => UtilUI.goToNextPage(context, ProductPage(idBusiness: idBusiness), funCallback: (value) {
            if (value != null) _reset();
          }),
          child: Icon(Icons.add, color: Colors.white, size: 64.sp)),
        body: RefreshIndicator(child: BlocBuilder(bloc: bloc,
              buildWhen: (oldState, newState) => newState is LoadListState,
              builder: (context, state) => AlignedGridView.count(padding: EdgeInsets.all(20.sp), controller: _scroller,
                  crossAxisCount: 2, mainAxisSpacing: 20.sp, crossAxisSpacing: 20.sp,
                  physics: const AlwaysScrollableScrollPhysics(), itemCount: _list.length,
                  itemBuilder: (context, index) => Stack(children: [
                    ProductItemHorizontalPage(_list[index], shop, 0.5.sw, callback: this, idBusiness: idBusiness,
                        loginOrCreateCallback: () => UtilUI.showCustomDialog(context, MultiLanguage.get('msg_login_create_account'))),
                    Positioned(child: ButtonImageWidget(100, () => _remove(index), Container(padding: const EdgeInsets.all(8),
                        child: Icon(Icons.clear, color: Colors.white, size: 56.sp),
                        decoration: BoxDecCustom(radius: 100, bgColor: Colors.black45)), color: Colors.white60),
                      top: 40.sp, right: 40.sp)
                  ], alignment: Alignment.topRight)
              )), onRefresh: () async => _reset()))),
    Loading(bloc)
  ]);

  void _listenScroller() {
    if (_page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) _loadMore();
  }

  void _search() {
    clearFocus();
    _reset();
  }

  void _clear() {
    clearFocus();
    _ctrSearch.text = '';
    bloc!.add(ShowClearSearchEvent(false));
    _reset();
  }

  void _loadMore() {
    if (_lock) return;
    _lock = true;
    bloc!.add(LoadListEvent(_page, keyword: _ctrSearch.text, idBA: idBusiness));
  }

  void _reset() {
    setState(() {_list.clear();});
    _page = 1;
    _loadMore();
  }

  void _remove(int index) {
    clearFocus();
    UtilUI.showCustomDialog(context, 'Bạn có chắc muốn xoá sản phẩm này không?', isActionCancel: true).then((value) {
      if (value != null && value) bloc!.add(DeleteEmpEvent(idBusiness, _list[index].id));
    });
  }
}