import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/ui_farm.dart';
import 'package:hainong/features/function/tool/harvest_diary/harvest_diary_bloc.dart';
import 'package:hainong/features/function/tool/harvest_diary/ui/harvest_diary_detail_page.dart';
import 'package:hainong/features/function/tool/report/report_bloc.dart';

class HarvestTaskListPage extends BasePage {
  final int id;
  final String name;
  HarvestTaskListPage(this.id, this.name, {Key? key}) : super(pageState: _HarvestTaskListPageState(), key: key);
}

class _HarvestTaskListPageState extends BasePageState {
  final Map<String, String> _works = {
    'making_land': 'Làm đất',
    'pruning': 'Cắt tỉa',
    'sowing_seeds': 'Gieo hạt',
    'fertilize': 'Bón phân',
    'spray': 'Tưới cây',
    'harvest': 'Thu hoạch',
    'other': 'Khác'
  };
  final ScrollController _scroller = ScrollController();
  final List<dynamic> _list = [];
  int _page = 1;

  @override
  void dispose() {
    _scroller.removeListener(_listenScroller);
    _scroller.dispose();
    _list.clear();
    _works.clear();
    super.dispose();
  }

  @override
  void initState() {
    bloc = ReportBloc(isReport: false, isFarm: false);
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadHarvestTasksState && isResponseNotError(state.resp)) {
        final list = state.resp.data;
        if (list.isNotEmpty) {
          _list.addAll(list);
          list.length == 20 ? _page++ : _page = 0;
        } else _page = 0;
      } else if (state is LoadHarvestDtlState && isResponseNotError(state.resp)) {
        state.resp.data.working_status = 'completed';
        UtilUI.goToNextPage(context, HarvestDiaryDtlPage(state.resp.data, _reset, lock: true));
      }
    });
    _loadMore();
    _scroller.addListener(_listenScroller);
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Scaffold(
      appBar: AppBar(elevation: 10, titleSpacing: 0, centerTitle: true,
          title: UtilUI.createLabel('Vật tư đã sử dụng')),
      backgroundColor: color,
      body: GestureDetector(
          onTapDown: (value) {clearFocus();},
          child: Stack(children: [
            createUI(),
            Loading(bloc)
          ])));

  @override
  Widget createUI() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: EdgeInsets.all(40.sp), child: LabelCustom((widget as HarvestTaskListPage).name,
        align: TextAlign.left, size: 42.sp, color: const Color(0xFF1AAD80))),
    const FarmManageTitle([
      ['Lô thửa', 2],
      ['Mùa vụ', 2],
      ['Công việc', 2],
      ['SL', 2],
      ['ĐVT', 2]
    ]),
    Expanded(child: RefreshIndicator(child: BlocBuilder(bloc: bloc,
        buildWhen: (oldState, newState) => newState is LoadHarvestTasksState && _list.isNotEmpty,
        builder: (context, state) {
          return ListView.builder(padding: EdgeInsets.zero, controller: _scroller, itemCount: _list.length,
              itemBuilder: (context, index) {
                String title = _list[index]['title']??'';
                if (title.isEmpty) title = _works[_list[index]['working_type']??'']??'';
                return FarmManageItem([
                  [_list[index]['culture_plot_title']??'', 2],
                  [_list[index]['harvest_management_title']??'', 2],
                  [title, 2],
                  [Util.doubleToString(Util.getValueFromJson(_list[index], 'material_amount', .0).toDouble()), 2],
                  [_list[index]['material_unit_name']??'', 2]
                ], index, action: _gotoDetail);
              }, physics: const AlwaysScrollableScrollPhysics());
        }), onRefresh: () async => _reset()))
  ]);

  void _loadMore() => bloc!.add(LoadHarvestTasksEvent((widget as HarvestTaskListPage).id.toString(), page: _page));

  void _listenScroller() {
    if (_page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) _loadMore();
  }

  void _reset() {
   setState(() => _list.clear());
    _page = 1;
    _loadMore();
  }

  void _gotoDetail(int index) => bloc!.add(LoadHarvestDtlEvent(_list[index]['harvest_management_id'].toString()));
}