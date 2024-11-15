import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import 'package:hainong/common/ui/ui_farm.dart';
import 'mission_sub_detail_page.dart';
import '../mission_bloc.dart';

class MissionPartListPage extends BasePage {
  MissionPartListPage({Key? key}) : super(pageState: _MissionPartListPageState(), key: key);
}

class _MissionPartListPageState extends BasePageState {
  final TextEditingController _ctrSearch = TextEditingController(), _ctrCat = TextEditingController();
  final ScrollController _scroller = ScrollController();
  final List _list = [];
  final List<ItemModel> _cats = [ItemModel(name: '...')];
  final ItemModel _cat = ItemModel(), _catTemp = ItemModel();
  int _page = 1;
  bool _lock = false;

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
    bloc = MissionBloc('par_list');
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
      } else if (state is ReviewMissionState) {
        UtilUI.goToNextPage(context, MissionSubDetailPage(state.resp[0], state.resp[1], reload: _reset, showParent: true));
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
                title: UtilUI.createLabel('Danh sách nhiệm vụ đang tham gia'),
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
            body: Column(children: [
              const FarmManageTitle([['NV con', 3], ['NV tổng', 3], ['Số người', 2, TextAlign.center], ['Trạng thái', 2, TextAlign.center]]),
              Expanded(child: RefreshIndicator(child: BlocBuilder(bloc: bloc,
                  buildWhen: (oldState, newState) => newState is LoadMissionsState,
                  builder: (context, state) => ListView.builder(padding: EdgeInsets.zero, controller: _scroller,
                      physics: const AlwaysScrollableScrollPhysics(), itemCount: _list.length,
                      itemBuilder: (context, index) {
                        double join = .0, total = .0;
                        join = (_list[index]['agree_joins']??.0).toDouble();
                        total = (_list[index]['total_joined']??.0).toDouble();
                        String status = (_list[index]['work_status']??'pending') == 'pending' ? '' : 'Đã hoàn thành';
                        if (status.isEmpty) {
                          status = _list[index]['status']??'';
                          if (status.isNotEmpty) {
                            status = MultiLanguage.get('opt_' + (_list[index]['status']??''));
                          }
                        }
                        return FarmManageItem([
                          [_list[index]['mission_detail_title']??'', 3],
                          [_list[index]['mission_title']??'', 3],
                          [Util.doubleToString(total)+'/'+Util.doubleToString(join), 2, TextAlign.center],
                          [status, 2, TextAlign.center]
                        ], index, action: _gotoDetail);
                      })), onRefresh: () async => _search))
            ]))),
    Loading(bloc)
  ]);

  void _listenScroller() {
    if (_page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) _loadMore();
  }

  void _showFilter() => showDialog(context: context, builder: (context) {
    final color = const Color(0XFFF5F6F8);
    _catTemp.setValue(_cat.id, _cat.id.isEmpty ? '' : _cat.name);
    _ctrCat.text = _catTemp.name;
    return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        titlePadding: EdgeInsets.zero, insetPadding: EdgeInsets.zero, contentPadding: EdgeInsets.all(40.sp),
        content: Container(color: Colors.white, width: 0.8.sw, constraints: BoxConstraints(maxHeight: 0.75.sh),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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

  Widget _title(String title) => LabelCustom(title, color: const Color(0xFF787878), size: 36.sp, weight: FontWeight.normal);

  void _selectCat() {
    if (_cats.length < 2) return;
    UtilUI.showOptionDialog(context, 'Chọn danh mục NV', _cats, _catTemp.id).then((value) {
      if (value != null && _catTemp.id != value.id) {
        _catTemp.setValue(value.id, value.name);
        _ctrCat.text = value.id.isEmpty ? '' : value.name;
      }
    });
  }

  void _setDefault() {
    _ctrCat.text = '';
    _catTemp.setValue('', '');
  }

  void _applyFilter() {
    _cat.setValue(_catTemp.id, _catTemp.id.isEmpty ? '' : _catTemp.name);
    _reset(0, hasBack: true);
  }

  void _search() {
    clearFocus();
    _reset(0);
  }

  void _clear() {
    clearFocus();
    _ctrSearch.text = '';
    bloc!.add(ShowClearSearchEvent(false));
    _reset(0);
  }

  void _loadMore() {
    if (_lock) return;
    _lock = true;
    bloc!.add(LoadMissionsEvent(_page, _ctrSearch.text, _cat.id, false));
  }

  void _reset(int count, {bool hasBack = false}) {
    if (hasBack) UtilUI.goBack(context, false);
    _list.clear();
    _page = 1;
    _loadMore();
  }

  void _gotoDetail(int index) => bloc!.add(ReviewMissionEvent(_list[index]['mission_id']??-1, _list[index]['mission_detail_id']??-1, -1, ''));
}