import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/features/function/info_news/news/news_model.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/features/home/ui/import_ui_home.dart';
import 'pests_handbook_item.dart';
import '../pests_handbook_bloc.dart';

class PestsHandbookListPage extends BasePage {
  final String keyword;
  PestsHandbookListPage(this.keyword, {Key? key}):super(key: key, pageState: _PestsHandbookListPageState());
}

class _PestsHandbookListPageState extends BasePageState {
  final TextEditingController _ctrSearch = TextEditingController();
  final ScrollController _scroller = ScrollController();
  final List<NewsModel> _list = [];
  final List<ItemModel2> _cats = [];
  int _page = 1, _index = -1;
  String _catName = '';

  @override
  void dispose() {
    _list.clear();
    _scroller.removeListener(_listenerScroll);
    _scroller.dispose();
    _ctrSearch.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _catName = (widget as PestsHandbookListPage).keyword;
    bloc = PestsHandbookBloc();
    super.initState();
    if (_catName.isNotEmpty) _loadMore();
    bloc!.add(LoadCatalogueEvent());
    _scroller.addListener(_listenerScroll);
  }

  @override
  Widget createUI() => Scaffold(appBar: AppBar(elevation: 0, titleSpacing: 0, title: UtilUI.createLabel(
      MultiLanguage.get('lbl_pests_handbook')), centerTitle: true,
      bottom: PreferredSize(child: Container(width: 1.sw - 80.sp,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.sp)
          ), padding: EdgeInsets.all(30.sp), margin: EdgeInsets.only(bottom: 40.sp),
          child: Row(children: [
            ButtonImageWidget(40.sp, _search, Icon(Icons.search, size: 48.sp, color: const Color(0xFF676767))),
            SizedBox(child: TextField(controller: _ctrSearch,
                onSubmitted: (value) => _search(),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 36.sp, color: const Color(0xFF959595)),
                    hintText: 'Nhập từ khóa hoặc nội dung cần tìm',
                    contentPadding: EdgeInsets.zero, isDense: true,
                    border: const UnderlineInputBorder(borderSide: BorderSide.none)
                )
            ), width: 1.sw - 256.sp),
            ButtonImageWidget(40.sp, _clear, Icon(Icons.clear, size: 48.sp, color: const Color(0xFF676767)))
          ], mainAxisAlignment: MainAxisAlignment.spaceBetween)), preferredSize: Size(1.sw, 140.sp))),
      backgroundColor: Colors.white,
      body: Column(children: [
        BlocConsumer(bloc: bloc,
            listener: (context, state) {
              if (state is LoadCatalogueState) {
                _cats.addAll(state.list);
                if (_catName.isEmpty) {
                  _setCatalogue(0, isLoadList: true);
                } else {
                  for(int i = _cats.length - 1; i > -1; i--) {
                    if (_cats[i].name == _catName) {
                      _setCatalogue(i);
                      return;
                    }
                  }
                }
              }
            },
            buildWhen: (state1, state2) => state2 is LoadCatalogueState || state2 is ChangeCatalogueState,
            builder: (context, state) {
              if (_cats.isEmpty) return const SizedBox();
              final List<Widget> children = [];
              for (int i = 0; i < _cats.length; i++) {
                children.add(
                    ButtonImageWidget(0, () => _setCatalogue(i, isLoadList: true), Container(child: Column(children: [
                    Text(_cats[i].shop_name, style: TextStyle(color: _cats[i].name == _catName ? StyleCustom.primaryColor :
                      const Color(0xFF878787), fontSize: 42.sp), textAlign: TextAlign.center),
                    if (_cats[i].name == _catName) Container(color: _cats[i].name == _catName ? StyleCustom.primaryColor :
                    const Color(0xFF878787), width: 20.0 * (_cats[i].name.split(' ').length), height: 2, margin: EdgeInsets.only(top: 5.sp))
                  ]), padding: EdgeInsets.all(40.sp)))
                );
              }
              return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: children));
            }),
        Expanded(child: BlocConsumer(bloc: bloc,
            listener: (context, state) {
              if (state is LoadListState && isResponseNotError(state.response)) _handleLoadList(state.response.data);
            },
            buildWhen: (state1, state2) => state2 is LoadListState,
            builder: (context, state) => ListView.builder(controller: _scroller, itemCount: _list.length,
                itemBuilder: (context, index) => PestsHandbookItem(constants, _list[index]))))
      ], mainAxisSize: MainAxisSize.min)
  );

  void _reset() {
    _list.clear();
    _page = 1;
    _loadMore();
  }

  void _search() {
    clearFocus();
    if (_ctrSearch.text.trim().isEmpty) return;
    _reset();
  }

  void _clear() {
    if (_ctrSearch.text.trim().isEmpty) return;
    _ctrSearch.text = '';
    _reset();
  }

  void _setCatalogue(int index, {bool isLoadList = false}) {
    if (_index != index) {
      _index = index;
      _catName = _cats[index].name;
      bloc!.add(ChangeCatalogueEvent());
      if (isLoadList) _reset();
    }
  }

  void _listenerScroll() {
    if (_page > 0 && _scroller.position.pixels == _scroller.position.maxScrollExtent) _loadMore();
  }

  void _loadMore() => bloc!.add(LoadListEvent(_catName, _page, _ctrSearch.text.trim()));

  void _handleLoadList(NewsModels data) {
    if (data.list.isNotEmpty) {
      _list.addAll(data.list);
      data.list.length == constants.limitPage*2 ? _page++ : _page = 0;
    } else _page = 0;
  }
}