import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import 'package:hainong/common/ui/ui_farm.dart';
import '../mission_bloc.dart';
import 'mission_mine_detail_page.dart';
import 'mission_detail_page.dart';

class MissionListPage extends BasePage {
  MissionListPage({bool isOwner = false, Key? key}) : super(pageState: _MissionListPageState(isOwner), key: key);
}

class _MissionListPageState extends BasePageState {
  final TextEditingController _ctrSearch = TextEditingController(), _ctrCat = TextEditingController();
  final ScrollController _scroller = ScrollController();
  final List _list = [];
  final List<ItemModel> _cats = [ItemModel(name: '...')];
  final ItemModel _cat = ItemModel(), _catTemp = ItemModel();
  int _page = 1;
  bool _missionEmpty = false, _missionEmptyTemp = false, _lock = false;

  final bool isOwner;
  _MissionListPageState(this.isOwner);

  @override
  void dispose() {
    _scroller.removeListener(_listenScroller);
    _scroller.dispose();
    _list.clear();
    _cats.clear();
    _ctrSearch.dispose();
    _ctrCat.dispose();
    super.dispose();
  }

  @override
  void initState() {
    bloc = MissionBloc('list');
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadMissionsState) {
        if (isResponseNotError(state.resp)) {
          final list = state.resp.data;
          if (list.isEmpty) _page = 0;
          else {
            _list.addAll(list);
            list.length == 20 ? _page++ : _page = 0;
          }
        }
        _lock = false;
      } else if (state is LoadCatalogueState) {
        _cats.addAll(state.resp);
      }
      _lock = false;
    });
    _loadMore();
    bloc!.add(LoadCatalogueEvent());
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Stack(children: [
    GestureDetector(onTap: clearFocus, onHorizontalDragDown: (_) => clearFocus(), onVerticalDragDown: (_) => clearFocus(),
      child: Scaffold(backgroundColor: color,
        appBar: AppBar(elevation: 0, titleSpacing: 0, centerTitle: true,
          title: UtilUI.createLabel('Danh sách nhiệm vụ${isOwner?' tự tạo':''}'),
          bottom: PreferredSize(preferredSize: Size(0.5.sw, 140.sp), child: Row(children: [
            Expanded(child: Container(
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
                ]))),

            Container(margin: EdgeInsets.only(right: 40.sp, bottom: 40.sp),
              child: ButtonImageWidget(5, _showFilter, Row(children: [
                Icon(Icons.filter_alt_outlined, color: Colors.white, size: 48.sp),
                LabelCustom('Lọc', color: Colors.white, size: 48.sp, weight: FontWeight.normal)
              ])))
          ]))
        ),
        floatingActionButton: isOwner ? FloatingActionButton.small(backgroundColor: StyleCustom.primaryColor,
          onPressed: () => UtilUI.goToNextPage(context, MissionMineDetailPage(null, reload: _reset)),
          child: Icon(Icons.add, color: Colors.white, size: 48.sp)) : null,
        body: Column(children: [
          const FarmManageTitle([['Nhiệm vụ', 4, TextAlign.center], ['Bắt đầu\nKết thúc', 3, TextAlign.center], ['Trạng thái', 3, TextAlign.center]]),
          Expanded(child: RefreshIndicator(child: BlocBuilder(bloc: bloc,
              buildWhen: (oldState, newState) => newState is LoadMissionsState,
              builder: (context, state) => ListView.builder(padding: EdgeInsets.zero, controller: _scroller,
                  physics: const AlwaysScrollableScrollPhysics(), itemCount: _list.length,
                  itemBuilder: (context, index) => FarmManageItem([
                      [_list[index]['title']??'', 4 ],
                      [Util.strDateToString(_list[index]['start_date']??'',
                          pattern: 'dd/MM/yyyy') + '\n' + Util.strDateToString(_list[index]['end_date']??'',
                          pattern: 'dd/MM/yyyy'), 3, TextAlign.center],
                      [_list[index]['work_status'] =='pending' ? 'Đang diễn ra': 'Hoàn thành', 3, TextAlign.center]
                    ], index, action: _gotoDetail)
                  )), onRefresh: () async => _reset()))
        ]))),
    Loading(bloc)
  ]);

  Widget _title(String title) => LabelCustom(title, color: const Color(0xFF787878), size: 36.sp, weight: FontWeight.normal);

  void _listenScroller() {
    if (_page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) _loadMore();
  }

  void _showFilter() => showDialog(context: context, builder: (context) {
    final color = const Color(0XFFF5F6F8);
    _catTemp.setValue(_cat.id, _cat.id.isEmpty ? '' : _cat.name);
    _ctrCat.text = _catTemp.name;
    _missionEmptyTemp = _missionEmpty;
    return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        titlePadding: EdgeInsets.zero, insetPadding: EdgeInsets.zero, contentPadding: EdgeInsets.all(40.sp),
        content: Container(color: Colors.white, width: 0.8.sw, constraints: BoxConstraints(maxHeight: 0.75.sh),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                ButtonImageWidget(0, _checkEmpty, BlocBuilder(bloc: bloc,
                  buildWhen: (oldS, newS) => newS is MissionEmptyState,
                  builder: (context, state) {
                      bool show = _missionEmptyTemp;
                      if (state is MissionEmptyState) show = state.value;
                      return Icon(show ? Icons.check_box : Icons.check_box_outline_blank, color: StyleCustom.primaryColor, size: 64.sp);
                  })),
                SizedBox(width: 20.sp),
                Expanded(child: LabelCustom('Nhiệm vụ trống (chưa có thành viên tham gia)',
                    size: 42.sp, weight: FontWeight.normal, color: Colors.black))
              ]),
              SizedBox(height: 40.sp),

              _title('Danh mục nhiệm vụ'),
              Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
                  child: TextFieldCustom(_ctrCat, null, null, 'Chọn danh mục nhiệm vụ',
                      size: 42.sp, color: color, borderColor: color, readOnly: true, maxLine: 0,
                      inputAction: TextInputAction.newline, onPressIcon: _selectCat,
                      type: TextInputType.multiline, padding: EdgeInsets.all(30.sp),
                      suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp))),

              Row(children: [
                Expanded(child: OutlinedButton(
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.transparent)),
                    onPressed: _setDefault,
                    child: Text('Thiết lập lại', style: TextStyle(fontSize: 48.sp)))),
                Expanded(child: OutlinedButton(onPressed: _applyFilter,
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.transparent),
                        backgroundColor: StyleCustom.primaryColor),
                    child: Text('Áp dụng', style: TextStyle(fontSize: 48.sp, color: Colors.white))))
              ])
            ], mainAxisSize: MainAxisSize.min))
    );
  });

  void _selectCat() {
    if (_cats.length < 2) return;
    UtilUI.showOptionDialog(context, 'Chọn danh mục NV', _cats, _catTemp.id).then((value) {
      if (value != null && _catTemp.id != value.id) {
        _catTemp.setValue(value.id, value.name);
        _ctrCat.text = value.id.isEmpty ? '' : value.name;
      }
    });
  }

  void _checkEmpty() {
    _missionEmptyTemp = !_missionEmptyTemp;
    bloc!.add(MissionEmptyEvent(_missionEmptyTemp));
  }

  void _setDefault() {
    _ctrCat.text = '';
    _catTemp.setValue('', '');
    _missionEmptyTemp = false;
    bloc!.add(MissionEmptyEvent(false));
  }

  void _applyFilter() {
    _missionEmpty = _missionEmptyTemp;
    _cat.setValue(_catTemp.id, _catTemp.id.isEmpty ? '' : _catTemp.name);
    _reset(hasBack: true);
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
    bloc!.add(LoadMissionsEvent(_page, _ctrSearch.text, _cat.id, _missionEmpty, isOwner: isOwner));
  }

  void _reset({bool hasBack = false}) {
    if (hasBack) UtilUI.goBack(context, false);
    _list.clear();
    _page = 1;
    _loadMore();
  }

  void _gotoDetail(int index) => UtilUI.goToNextPage(context, isOwner ? MissionMineDetailPage(_list[index], reload: _reset) : MissionDetailPage(_list[index], reload: _reset));
}