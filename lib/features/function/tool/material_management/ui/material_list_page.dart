import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import 'package:hainong/common/ui/ui_farm.dart';
import 'package:hainong/features/function/support/handbook/handbook_bloc.dart';
import '../material_bloc.dart';
import 'material_detail_page.dart';

class MaterialListPage extends BasePage {
  final bool isSelect;
  MaterialListPage({this.isSelect = false, Key? key}) : super(pageState: _MaterialListPageState(), key: key);
}

class _MaterialListPageState extends BasePageState {
  final TextEditingController _ctrSearch = TextEditingController(), _ctrType = TextEditingController();
  final FocusNode _focus = FocusNode();
  final ScrollController _scroller = ScrollController();
  final List<MaterialModel> _list = [];
  final ItemModel _type = ItemModel(id: '-1', name: 'Tất cả');
  final List<ItemModel> _types = [ItemModel(id: '-1', name: 'Tất cả')];
  int _page = 1;

  @override
  void dispose() {
    _ctrType.dispose();
    _ctrSearch.dispose();
    _focus.dispose();
    _scroller.removeListener(_listenScroller);
    _scroller.dispose();
    _list.clear();
    _types.clear();
    super.dispose();
  }

  @override
  void initState() {
    bloc = MaterialBloc();
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadListState && isResponseNotError(state.response)) {
        final list = state.response.data.list;
        if (list.isNotEmpty) {
          _list.addAll(list);
          list.length == 20 ? _page++ : _page = 0;
        } else _page = 0;
      } else if (state is LoadTypeState) {
        _types.addAll(state.list);
      }
    });
    _loadMore();
    bloc!.add(LoadTypeEvent());
    _scroller.addListener(_listenScroller);
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) =>
    Scaffold(appBar: AppBar(elevation: 10, titleSpacing: 0,
      title: UtilUI.createLabel('Kho phân thuốc vật tư'), centerTitle: true,
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
    Padding(padding: EdgeInsets.all(40.sp), child:
      UtilUI.createLabel('Lọc theo loại vật tư', textAlign: TextAlign.left,
        fontSize: 48.sp, fontWeight: FontWeight.w400, color: Colors.black)),
    Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child:
      TextFieldCustom(_ctrType, null, null, 'Chọn loại vật tư',
        size: 46.sp, color: const Color(0XFFF5F6F8), borderColor: const Color(0XFFF5F6F8),
        inputAction: TextInputAction.newline, onPressIcon: _selectType, readOnly: true,
        type: TextInputType.multiline, padding: EdgeInsets.all(30.sp), maxLine: 0,
        suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp))),
    Padding(padding: EdgeInsets.all(40.sp), child: UtilUI.createLabel('Danh sách phân thuốc vật tư', textAlign: TextAlign.left,
        fontSize: 48.sp, fontWeight: FontWeight.w400, color: Colors.black)),
    const FarmManageTitle([
      ['Tên vật tư', 3],
      ['Loại vật tư', 2],
      ['Tồn kho', 2],
      ['Đơn vị', 3]
    ]),
    Expanded(child: RefreshIndicator(child: BlocBuilder(bloc: bloc,
        buildWhen: (oldState, newState) => newState is LoadListState && _list.isNotEmpty,
        builder: (context, state) {
          final select = (widget as MaterialListPage).isSelect;
          return ListView.builder(padding: EdgeInsets.zero, controller: _scroller,
              physics: const AlwaysScrollableScrollPhysics(), itemCount: _list.length,
              itemBuilder: (context, index) => FarmManageItem([
                [_list[index].name, 3],
                [_list[index].material_type_name, 2],
                [Util.doubleToString(_list[index].origin), 2],
                [_list[index].material_unit_name, 3]
              ], index, action: _gotoDetail, funSelect: select ?
                  () => _gotoDetail(index, isSelect: true) : null));
        }), onRefresh: () async => _search())),
    Container(padding: EdgeInsets.all(40.sp), child: ButtonImageWidget(16.sp, () => _gotoDetail(-1),
        Container(padding: EdgeInsets.all(40.sp), child: Row(children: [
          Icon(Icons.add_circle_outline_outlined, color: Colors.white, size: 60.sp),
          const SizedBox(width: 5),
          LabelCustom('Thêm vật tư', color: Colors.white, size: 48.sp, weight: FontWeight.normal)
        ], mainAxisAlignment: MainAxisAlignment.center)), color: StyleCustom.primaryColor))
  ]);

  void _selectType() {
    clearFocus();
    UtilUI.showOptionDialog(context, 'Chọn loại vật tư', _types, _type.id).then((value) => _setType(value));
  }

  void _setType(ItemModel? value) {
    if (value != null && _type.id != value.id) {
      _type.setValue(value.id, value.name);
      _ctrType.text = value.name;
      _reset();
    }
  }

  void _loadMore() => bloc!.add(LoadMaterialsEvent(_page, int.parse(_type.id), _ctrSearch.text.trim()));

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
    UtilUI.goToNextPage(context, MaterialDtlPage(index < 0 ? MaterialModel() : _list[index], _search));
  }
}