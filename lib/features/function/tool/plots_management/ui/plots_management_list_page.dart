import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/features/function/support/handbook/handbook_bloc.dart';
import 'package:hainong/features/home/ui/import_ui_home.dart';
import '../plots_management_bloc.dart';
import 'plots_detail_page.dart';

class PlotsManageListPage extends BasePage {
  final bool isSelect;
  final int? idAssigned;
  PlotsManageListPage({this.isSelect = false, this.idAssigned, Key? key}) : super(pageState: _PlotsManageListPageState(), key: key);
}

class _PlotsManageListPageState extends BasePageState {
  final TextEditingController _ctrSearch = TextEditingController();
  final FocusNode _focus = FocusNode();
  final ScrollController _scroller = ScrollController();
  final List<dynamic> _list = [];
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
    bloc = PlotsManagementBloc();
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadListState && isResponseNotError(state.response)) {
        final list = state.response.data.list;
        if (list.isNotEmpty) {
          _list.addAll(list);
          list.length == 10 ? _page++ : _page = 0;
        } else _page = 0;
      }
    });
    _loadMore();
    _scroller.addListener(_listenScroller);
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) =>
    Scaffold(appBar: AppBar(elevation: 5, titleSpacing: 0,
      title: UtilUI.createLabel((widget as PlotsManageListPage).isSelect ? 'Chọn lô thửa' : 'Quản lý lô thửa'), centerTitle: true,
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
      backgroundColor: const Color(0xFFECF1F1),
      body: GestureDetector(
          onTapDown: (value) {clearFocus();},
          child: Stack(children: [
            createUI(),
            Loading(bloc)
          ])));

  @override
  Widget createUI() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: EdgeInsets.fromLTRB(40.sp, 40.sp, 40.sp, 0), child: UtilUI.createLabel('Danh sách lô thửa',
        textAlign: TextAlign.left, fontSize: 48.sp, color: const Color(0xFF1AAD80), fontWeight: FontWeight.normal)),
    Expanded(child: RefreshIndicator(child: BlocBuilder(bloc: bloc,
        buildWhen: (oldState, newState) => newState is LoadListState && _list.isNotEmpty,
        builder: (context, state) => ListView.separated(padding: EdgeInsets.all(40.sp), controller: _scroller,
            separatorBuilder: (context, index) => SizedBox(height: 20.sp),
            itemCount: _list.length, itemBuilder: (context, index) {
              final select = (widget as PlotsManageListPage).isSelect;
              return _PlotsItem(_list[index], index, _gotoDetail, funSelect: select ?
                  () => _gotoDetail(index, isSelect: true) : null);
            },
            physics: const AlwaysScrollableScrollPhysics())),
        onRefresh: () async => _search())),
    Container(padding: EdgeInsets.all(40.sp), child: ButtonImageWidget(16.sp, () => _gotoDetail(-1),
        Container(padding: EdgeInsets.all(40.sp), child: Row(children: [
          Icon(Icons.add_circle_outline_outlined, color: Colors.white, size: 60.sp),
          const SizedBox(width: 5),
          LabelCustom('Thêm lô thửa', color: Colors.white, size: 48.sp, weight: FontWeight.normal)
        ], mainAxisAlignment: MainAxisAlignment.center)), color: StyleCustom.primaryColor))
  ]);

  void _loadMore() => bloc!.add(LoadListEvent(_page, _ctrSearch.text.trim(), idAssigned: (widget as PlotsManageListPage).idAssigned));

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
    UtilUI.goToNextPage(context, PlotsDtlPage(index < 0 ? PlotsManageModel() : _list[index], _search));
  }
}

class _PlotsItem extends StatelessWidget {
  final PlotsManageModel item;
  final int index;
  final Function action;
  final Function? funSelect;
  const _PlotsItem(this.item, this.index, this.action, {this.funSelect, Key? key}):super(key:key);
  
  @override
  Widget build(BuildContext context) {
    final temp = ButtonImageWidget(16.sp, () => action(index), Column(children: [
      Padding(padding: EdgeInsets.symmetric(vertical: 20.sp),
          child: LabelCustom('Tên thửa: ' + item.title, color: Colors.black, size: 42.sp, weight: FontWeight.normal)),
      ClipRRect(child: FadeInImage.assetNetwork(placeholder: 'assets/images/ic_default.png',
          imageErrorBuilder: (_,__,___) => Image.asset('assets/images/ic_default.png', width: 1.sw, height: 342.sp, fit: BoxFit.fitWidth),
          image: item.images.isEmpty ? '' : Util.getRealPath(item.images[0]),
          width: 1.sw, height: 342.sp, fit: BoxFit.fill, imageScale: 0.5), borderRadius: BorderRadius.vertical(top: Radius.circular(32.sp))),
      Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.sp))),
          padding: EdgeInsets.all(40.sp),
          child: Row(children: [
            _item('Diện tích (m2)', Util.doubleToString(item.acreage, digit: 3), 3),
            _item('Loại cây', item.family_tree, 3),
            _item('Người quản lý', item.office_name, 4)
          ], crossAxisAlignment: CrossAxisAlignment.start)
      )
    ], crossAxisAlignment: CrossAxisAlignment.start));
    return funSelect == null ? temp : Row(children: [
      Expanded(child: temp),
      SizedBox(width: 20.sp),
      Column(children: [
        ButtonImageWidget(50, funSelect!,
            Icon(Icons.radio_button_unchecked, color: StyleCustom.primaryColor, size: 96.sp)),
        SizedBox(height: 10.sp),
        LabelCustom('Chọn', weight: FontWeight.normal, size: 36.sp, color: const Color(0xFF414141))
      ])
    ]);
  }

  Widget _item(String title, String name, int flex) => Expanded(child: Column(children: [
    LabelCustom(title, size: 36.sp, color: const Color(0xFF616161), weight: FontWeight.normal),
    SizedBox(height: 16.sp),
    LabelCustom(name, size: 42.sp, color: const Color(0xFF303030))
  ]), flex: flex);
}