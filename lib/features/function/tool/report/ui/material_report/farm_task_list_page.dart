import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/features/function/support/handbook/handbook_bloc.dart';
import 'package:hainong/features/function/tool/farm_management/ui/farm_management_detail_page.dart';
import 'package:hainong/common/ui/ui_farm.dart';
import 'package:hainong/features/function/tool/harvest_diary/harvest_diary_bloc.dart';
import 'package:hainong/features/function/tool/report/report_bloc.dart';

class FarmTaskListPage extends BasePage {
  final int id;
  final String name;
  FarmTaskListPage(this.id, this.name, {Key? key}) : super(pageState: _FarmTaskListPageState(), key: key);
}

class _FarmTaskListPageState extends BasePageState {
  final ScrollController _scroller = ScrollController();
  final List<dynamic> _list = [];
  int _page = 1;

  @override
  void dispose() {
    _scroller.removeListener(_listenScroller);
    _scroller.dispose();
    _list.clear();
    super.dispose();
  }

  @override
  void initState() {
    bloc = ReportBloc(isReport: false);
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadListState && isResponseNotError(state.response)) {
        final list = state.response.data;
        if (list.isNotEmpty) {
          _list.addAll(list);
          list.length == 20 ? _page++ : _page = 0;
        } else _page = 0;
      } else if (state is LoadFarmDtlState && isResponseNotError(state.resp)) {
        UtilUI.goToNextPage(context, FarmManageDtlPage(state.resp.data, _reset, lock: true));
      }
    });
    _loadMore();
    _scroller.addListener(_listenScroller);
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Scaffold(
      appBar: AppBar(elevation: 10, titleSpacing: 0, centerTitle: true,
          title: UtilUI.createLabel('Vật tư đưa vào kế hoạch')),
      backgroundColor: color,
      body: GestureDetector(
          onTapDown: (value) {clearFocus();},
          child: Stack(children: [
            createUI(),
            Loading(bloc)
          ])));

  @override
  Widget createUI() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: EdgeInsets.all(40.sp), child: LabelCustom((widget as FarmTaskListPage).name,
        align: TextAlign.left, size: 42.sp, color: const Color(0xFF1AAD80))),
    const FarmManageTitle([
      ['Lô thửa', 2],
      ['Kế hoạch', 2],
      ['Công việc', 2],
      ['SL', 2],
      ['ĐVT', 2]
    ]),
    Expanded(child: RefreshIndicator(child: BlocBuilder(bloc: bloc,
        buildWhen: (oldState, newState) => newState is LoadListState && _list.isNotEmpty,
        builder: (context, state) {
          return ListView.builder(padding: EdgeInsets.zero, controller: _scroller, itemCount: _list.length,
              itemBuilder: (context, index) => FarmManageItem([
                [_list[index]['culture_plot_title']??'', 2],
                [_list[index]['process_engineering_title']??'', 2],
                [_list[index]['title']??'', 2],
                [Util.doubleToString(Util.getValueFromJson(_list[index], 'material_quantity', .0).toDouble()), 2],
                [_list[index]['material_unit_name']??'', 2]
              ], index, action: _gotoDetail), physics: const AlwaysScrollableScrollPhysics());
        }), onRefresh: () async => _reset()))
  ]);

  void _loadMore() => bloc!.add(LoadListEvent(_page, (widget as FarmTaskListPage).id.toString()));

  void _listenScroller() {
    if (_page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) _loadMore();
  }

  void _reset() {
   setState(() => _list.clear());
    _page = 1;
    _loadMore();
  }

  void _gotoDetail(int index) => bloc!.add(LoadFarmDtlEvent(_list[index]['process_engineering_id']));
}