import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/ui_farm.dart';
import 'farm_management_detail_page.dart';
import 'package:hainong/features/function/support/handbook/handbook_bloc.dart';
import '../farm_management_bloc.dart';

class FarmManageListPage extends BasePage {
  final bool isSelect;
  FarmManageListPage({this.isSelect = false, Key? key}) : super(pageState: _FarmManageListPageState(), key: key);
}

class _FarmManageListPageState extends BasePageState {
  final TextEditingController _ctrSearch = TextEditingController();
  final FocusNode _focus = FocusNode();
  final ScrollController _scroller = ScrollController();
  final List<FarmManageModel> _list = [];
  int _page = 1;

  @override
  void dispose() {
    _ctrSearch.dispose();
    _focus.dispose();
    _scroller.removeListener(_listenScroller);
    _scroller.dispose();
    _list.clear();
    super.dispose();
  }

  @override
  void initState() {
    bloc = FarmManagementBloc();
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadListState && isResponseNotError(state.response)) {
        final list = state.response.data.list;
        if (list.isNotEmpty) {
          _list.addAll(list);
          list.length == 20 ? _page++ : _page = 0;
        } else _page = 0;
      }
    });
    _loadMore();
    _scroller.addListener(_listenScroller);
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) =>
    Scaffold(appBar: AppBar(elevation: 10, titleSpacing: 0,
      title: UtilUI.createLabel('Kế hoạch canh tác'), centerTitle: true,
      bottom: PreferredSize(child: Container(width: 1.sw - 80.sp,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.sp)
          ), padding: EdgeInsets.all(30.sp), margin: EdgeInsets.only(bottom: 40.sp),
          child: Row(children: [
            ButtonImageWidget(40.sp, _search, Icon(Icons.search, size: 48.sp, color: const Color(0xFF676767))),
            SizedBox(child: TextField(controller: _ctrSearch, focusNode: _focus,
                onSubmitted: (value) => _search(),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 36.sp, color: const Color(0xFF959595)),
                    hintText: 'Tìm kiếm',
                    contentPadding: EdgeInsets.zero, isDense: true,
                    border: const UnderlineInputBorder(borderSide: BorderSide.none)
                )
            ), width: 1.sw - 256.sp),
            ButtonImageWidget(40.sp, _clear, Icon(Icons.clear, size: 48.sp, color: const Color(0xFF676767)))
          ], mainAxisAlignment: MainAxisAlignment.spaceBetween)), preferredSize: Size(1.sw, 140.sp))),
      backgroundColor: Colors.white,
      body: GestureDetector(
          onTapDown: (value) {clearFocus();},
          child: Stack(children: [
            createUI(),
            Loading(bloc)
          ])));

  @override
  Widget createUI() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: EdgeInsets.all(40.sp), child: UtilUI.createLabel('Danh sách kế hoạch canh tác', textAlign: TextAlign.left,
        fontSize: 48.sp, fontWeight: FontWeight.w400, color: Colors.black)),
    const FarmManageTitle([
      ['Tên kế hoạch', 4],
      ['Tên lô thửa', 3],
      ['Loại cây', 3]
    ]),
    Expanded(child: RefreshIndicator(child: BlocBuilder(bloc: bloc,
        buildWhen: (oldState, newState) => newState is LoadListState && _list.isNotEmpty,
        builder: (context, state) {
          final select = (widget as FarmManageListPage).isSelect;
          return ListView.builder(padding: EdgeInsets.zero, controller: _scroller,
              itemCount: _list.length, physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) => FarmManageItem([
                [_list[index].title, 4],
                [_list[index].culture_plot_title, 3],
                [_list[index].family_tree, 3]
              ], index, action: _gotoDetail, funSelect: select ?
                  () => _gotoDetail(index, isSelect: true) : null));
        }), onRefresh: () async => _search())),
    Container(padding: EdgeInsets.all(40.sp), child: ButtonImageWidget(16.sp, () => _gotoDetail(-1),
        Container(padding: EdgeInsets.all(40.sp), child: Row(children: [
          Icon(Icons.add_circle_outline_outlined, color: Colors.white, size: 60.sp),
          const SizedBox(width: 5),
          LabelCustom('Thêm kế hoạch canh tác', color: Colors.white, size: 48.sp, weight: FontWeight.normal)
        ], mainAxisAlignment: MainAxisAlignment.center)), color: StyleCustom.primaryColor))
  ]);

  void _loadMore() => bloc!.add(LoadListEvent(_page, _ctrSearch.text.trim()));

  void _listenScroller() {
    if (_page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) _loadMore();
  }

  void _reset() {
   setState(() => _list.clear());
    _page = 1;
    _loadMore();
  }

  void _search() {
    _focus.unfocus();
    _reset();
  }

  void _clear() {
    _ctrSearch.text = '';
    _reset();
  }

  void _gotoDetail(int index, {bool isSelect = false}) {
    if (isSelect && index > -1) {
      UtilUI.goBack(context, _list[index]);
      return;
    }
    UtilUI.goToNextPage(context, FarmManageDtlPage(index < 0 ? FarmManageModel() : _list[index], _search));
  }
}