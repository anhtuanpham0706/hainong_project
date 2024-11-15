import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/tab_item.dart';
import 'package:hainong/common/ui/ui_farm.dart';
import 'history_point_model.dart';
import '../point_bloc.dart';

class HistoryPointPage extends BasePage {
  HistoryPointPage({Key? key}):super(key: key, pageState: _HistoryPointPageState());
}

class _HistoryPointPageState extends BasePageState {
  int _page = 1;
  String _status = 'receive';
  final HistoryPointModel _historyPoint = HistoryPointModel();
  final ScrollController _scroller = ScrollController();

  @override
  void dispose() {
    _historyPoint.modified_list.clear();
    _scroller.removeListener(_listener);
    _scroller.dispose();
    super.dispose();
  }

  @override
  initState() {
    bloc = PointBloc();
    super.initState();
    bloc!.stream.listen((state) {
      if (state is GetHistoryPointState) {
        _handleResponseLoadPoints(state);
      } else if (state is UpdateStatusState && isResponseNotError(state.response, passString: true)) _reload();
    });
    _loadMore();
    _scroller.addListener(_listener);
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Stack(
      children: [
        Scaffold(appBar: AppBar(elevation: 5, centerTitle: true,
            title: UtilUI.createLabel(MultiLanguage.get('lbl_point_diary'))),
            backgroundColor: color,
            body: Column(children: [
              BlocBuilder(bloc: bloc,
                  buildWhen: (state1, state2) => state2 is ChangeTabState,
                  builder: (context, state) => Row(children: [
                    TabItem('lbl_receive', 'receive', _status == 'receive', _changeTab),
                    TabItem('lbl_send', 'send', _status == 'send', _changeTab),
                    // TabItem('lbl_point_rejected', 'rejected', _status == 'rejected', _changeTab)
                  ])),
              BlocBuilder(
                  bloc: bloc,
                  buildWhen: (state3, state4) => state4 is ChangeTabState || state4 is GetHistoryPointState,
                  builder: (context, state) {
                    return  Column(
                      children: [
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Row(
                                children: [
                                  Text('Hiện có: ', style: TextStyle(fontSize: 42.sp, color: Colors.black87, fontWeight: FontWeight.w500)),
                                  Flexible(child: Text(Util.doubleToString(_historyPoint.current_points.toDouble()) + " điểm", style: TextStyle(fontSize: 42.sp, color: Colors.black, fontWeight: FontWeight.w800))),
                                ],
                              )),
                              SizedBox(width: 20.sp),
                              Expanded(child: Row(
                                children: [
                                  Text(_status == "receive" ? "Tổng nhận: " : "Tổng tặng: ", style: TextStyle(fontSize: 42.sp, color: Colors.black87, fontWeight: FontWeight.w500)),
                                  Flexible(child: Text(Util.doubleToString(_historyPoint.total_points.toDouble()) + " điểm", style: TextStyle(fontSize: 42.sp, color: _status == "receive" ? const Color(0xFF1AAD80) : Colors.red, fontWeight: FontWeight.w500))),
                                ], mainAxisAlignment: MainAxisAlignment.end
                              ))
                            ],
                          ),
                          margin: EdgeInsets.fromLTRB(20.sp, 40.sp, 20.sp, 40.sp),
                        ),
                        FarmManageTitle( [[_status == "receive" ? "Người tặng" : "Người nhận", 3],  ['Lý do', 3, TextAlign.center], ['Ngày cập nhật', 3, TextAlign.center],['Điểm', 2,TextAlign.center],],
                            size: 38.sp,
                            padding: 20.sp),
                      ],
                    );
                  }),
              Expanded(child: BlocBuilder(bloc: bloc,
                buildWhen: (oldS, newS) => newS is GetHistoryPointState, builder: (context, state) =>
                    ListView.builder(padding: EdgeInsets.zero,
                        itemCount: _historyPoint.modified_list.length,
                        controller: _scroller,
                        itemBuilder: (context, index) => _item(index),
                        physics: const AlwaysScrollableScrollPhysics()))
              )
            ])),
        Loading(bloc)
      ]
  );


  Widget _item(int index) {
    return FarmManageItem([
      [_historyPoint.modified_list[index].person_name.toString(), 3],
      [_historyPoint.modified_list[index].action_change, 3, TextAlign.left],
      [Util.dateToString(Util.stringToDateTime(_historyPoint.modified_list[index].created_at),
          locale: constants.localeVI, pattern: 'dd/MM/yyyy'), 3, TextAlign.center],
      [(_status == "receive" ? "+" : "-") + Util.doubleToString(_historyPoint.modified_list[index].points.toDouble()), 2,TextAlign.center, _status == "receive" ? Colors.green : Colors.red],
    ], index, colorRow: (index % 2 != 0) ? Colors.transparent : const Color(0xFFF8F8F8), padding: 20.sp,size: 38.sp,);
  }

  void _listener() {
    if (_page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) _loadMore();
  }

  void _loadMore() => bloc!.add(GetHistoryPointEvent(_page, _status));

  void _handleResponseLoadPoints(GetHistoryPointState state) {
    if (isResponseNotError(state.response)) {
      _historyPoint.copy(state.response.data);
      final List<PointModel> listTemp = state.response.data.modified_list;
      if (listTemp.isNotEmpty) {
        listTemp.length == 20?_page++:_page = 0;
      } else {
        _page = 0;
      }
    }
  }

  void _changeTab(String status) {
    if (_status != status) {
      _status = status;
      bloc!.add(ChangeTabEvent());
      _reload();
    }
  }

  Future<void> _reload() async {
    _historyPoint.modified_list.clear();
    _page = 1;
    _loadMore();
  }
}
