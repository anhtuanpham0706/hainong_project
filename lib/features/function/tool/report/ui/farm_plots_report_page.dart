import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import 'package:hainong/features/function/support/handbook/handbook_bloc.dart';
import 'package:hainong/common/ui/ui_farm.dart';
import 'package:hainong/features/function/tool/harvest_diary/harvest_diary_bloc.dart';
import 'package:hainong/features/function/tool/harvest_diary/ui/harvest_diary_detail_page.dart';
import '../report_bloc.dart';

class FarmPlotsReportPage extends BasePage {
  FarmPlotsReportPage({Key? key}) : super(pageState: _FarmPlotsReportPageState(), key: key);
}

class _FarmPlotsReportPageState extends BasePageState {
  final TextEditingController _ctrPlots = TextEditingController(), _ctrHarvest = TextEditingController();
  final List<HarvestDiaryModel> _harvests = [];
  String _harvest = '', _plot = '';
  final List<ItemModel> _listPlots = [];
  final Map<String, dynamic> _plots = {};
  final Map<String, String> _units = {
    'kg': 'Kg',
    'bottle': 'Chai',
    'bag': 'Bao',
    'tree': 'Cây',
    'ton': 'Tấn',
    'other': 'Khác'
  };

  HarvestDiaryBloc? _harvestBloc;
  final ScrollController _scroller = ScrollController();
  final List<HarvestDiaryModel> _list = [HarvestDiaryModel()];
  int _page = 1;

  @override
  void dispose() {
    _ctrPlots.dispose();
    _ctrHarvest.dispose();
    _listPlots.clear();
    _plots.clear();
    _harvests.clear();
    _units.clear();

    _harvestBloc?.close();
    _scroller.removeListener(_listenScroller);
    _scroller.dispose();
    _list.clear();
    super.dispose();
  }

  @override
  void initState() {
    bloc = ReportBloc();
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadHarvestsState && isResponseNotError(state.resp, showError: false) && state.resp.data.list.isNotEmpty) {
        _harvests.addAll(state.resp.data.list);
      } else if (state is LoadListState && isResponseNotError(state.response, showError: false) && state.response.data.list.isNotEmpty) {
        _listPlots.addAll(state.response.data.list);
      } else if (state is PlotsDtlState && state.plots.isNotEmpty) {
        _plots.addAll(state.plots);
      }
    });
    bloc!.add(LoadListEvent(1, ''));

    _harvestBloc = HarvestDiaryBloc();
    _harvestBloc!.stream.listen((state) {
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
    Scaffold(appBar: AppBar(elevation: 5, titleSpacing: 0,
      title: UtilUI.createLabel('Báo cáo chi tiết canh tác lô'), centerTitle: true),
      backgroundColor: Colors.white,
      body: Stack(children: [
        createUI(),
        Loading(bloc),
        Loading(_harvestBloc)
      ]));

  @override
  Widget createUI() => Column(children: [
      Padding(child: Row(children: [
        Expanded(child: Column(children: [
          LabelCustom('Chọn lô thửa', color: Colors.black, size: 36.sp),
          SizedBox(height: 20.sp),
          TextFieldCustom(_ctrPlots, null, null, 'Chọn lô thửa',
                  size: 42.sp, color: const Color(0XFFF5F6F8), borderColor: const Color(0XFFF5F6F8), readOnly: true,
                  onPressIcon: _selectPlots, maxLine: 0, inputAction: TextInputAction.newline,
                  type: TextInputType.multiline, padding: EdgeInsets.all(30.sp),
                  suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp))
        ], crossAxisAlignment: CrossAxisAlignment.start)),
        SizedBox(width: 20.sp),
        Expanded(child: Column(children: [
          LabelCustom('Chọn mùa canh tác', color: Colors.black, size: 36.sp),
          SizedBox(height: 20.sp),
          TextFieldCustom(_ctrHarvest, null, null, 'Chọn mùa canh tác',
              size: 42.sp, color: const Color(0XFFF5F6F8), borderColor: const Color(0XFFF5F6F8), readOnly: true,
              onPressIcon: _selectHarvest, maxLine: 0, inputAction: TextInputAction.newline,
              type: TextInputType.multiline, padding: EdgeInsets.all(30.sp),
              suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp))
        ], crossAxisAlignment: CrossAxisAlignment.start))
      ]), padding: EdgeInsets.all(40.sp)),

      Expanded(child: BlocBuilder(bloc: _harvestBloc,
          buildWhen: (oldState, newState) => newState is LoadListState,
          builder: (context, state) => ListView.builder(padding: EdgeInsets.zero, controller: _scroller,
              itemCount: _list.length, physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                if (index > 0) {
                  return FarmManageItem([
                    [_list[index].title, 4],
                    [_list[index].culture_plot_title, 3],
                    [_list[index].family_tree, 3]
                  ], index, action: _gotoDetail);
                }

                return Column(children: [
                  BlocBuilder(bloc: bloc, builder: (context, state) {
                    if (_plots.isEmpty) return const SizedBox();
                    String unitPlan = Util.getValueFromJson(_plots, 'plan_unit', '');
                    String unitWork = Util.getValueFromJson(_plots, 'working_unit', '');
                    if (unitPlan.isNotEmpty) {
                      unitPlan = ' (${_units.containsKey(unitPlan) ? _units[unitPlan] : unitPlan})';
                    }
                    if (unitWork.isNotEmpty) {
                      unitWork = ' (${_units.containsKey(unitWork) ? _units[unitWork] : unitWork})';
                    }
                    return Container(padding: EdgeInsets.all(40.sp), color: const Color(0xFFF1FCF9),
                        margin: EdgeInsets.fromLTRB(40.sp, 0, 40.sp, 40.sp),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          LabelCustom('Thông tin chung', color: const Color(0xFF1AAD80), size: 42.sp),
                          _line('Tên lô thửa', Util.getValueFromJson(_plots, 'title', '')),
                          _line('Diện tích (m2)', Util.doubleToString(Util.getValueFromJson(_plots, 'acreage', .0).toDouble(), digit: 3)),
                          _line('Loại cây', Util.getValueFromJson(_plots, 'family_tree', '')),
                          _line('Tiến độ thực hiện (%)', Util.doubleToString(Util.getValueFromJson(_plots, 'percent_working', .0).toDouble(), digit: 2)),
                          _line('Chi phí kế hoạch', Util.doubleToString(Util.getValueFromJson(_plots, 'plan_cost', .0).toDouble()), color: const Color(0xFFD60000)),
                          _line('Chi phí thực hiện', Util.doubleToString(Util.getValueFromJson(_plots, 'working_cost', .0).toDouble()), color: const Color(0xFFD60000)),
                          _line('Doanh thu kế hoạch', Util.doubleToString(Util.getValueFromJson(_plots, 'plan_revenue', .0).toDouble()), color: const Color(0xFFD60000)),
                          _line('Doanh thu thực tế', Util.doubleToString(Util.getValueFromJson(_plots, 'working_revenue', .0).toDouble()), color: const Color(0xFFD60000)),
                          _line('Sản lượng kế hoạch$unitPlan', Util.doubleToString(Util.getValueFromJson(_plots, 'plan_quantity', .0).toDouble(), digit: 3)),
                          _line('Sản lượng thực tế$unitWork', Util.doubleToString(Util.getValueFromJson(_plots, 'working_quantity', .0).toDouble(), digit: 3))
                        ]));
                  }, buildWhen: (oldS, newS) => newS is PlotsDtlState || newS is LoadHarvestsState),

                  Container(padding: EdgeInsets.fromLTRB(40.sp, 0, 40.sp, 40.sp), alignment: Alignment.centerLeft,
                      child: UtilUI.createLabel('Danh sách mùa vụ', fontSize: 52.sp, color: const Color(0xFF1AAD80))),
                  const FarmManageTitle([
                    ['Tên mùa vụ', 4],
                    ['Tên lô thửa', 3],
                    ['Vùng canh tác', 3]
                  ])
                ]);
              })))
    ]);

  Widget _line(String title, String value, {Color color = const Color(0xFF2C2C2C)}) =>
    Padding(padding: EdgeInsets.only(top: 48.sp), child: Row(children: [
      Expanded(child: LabelCustom(title, color: const Color(0xFF4A4A4A), size: 42.sp, weight: FontWeight.normal)),
      LabelCustom(value, color: color, size: 42.sp, weight: FontWeight.normal)
    ], mainAxisAlignment: MainAxisAlignment.spaceBetween));

  void _selectPlots() {
    if (_listPlots.isNotEmpty) {UtilUI.showOptionDialog(context, 'Chọn lô thửa', _listPlots,
        _plots.containsKey('id') ? _plots['id'].toString() : '').then((value) => _setPlots(value));}
  }

  void _setPlots(value) {
    if (value == null || _plot == value.id) return;
    _plots.clear();
    _ctrPlots.text = value.name;
    _plot = value.id;

    _harvests.clear();
    _ctrHarvest.text = '';
    _harvest = '';

    bloc!.add((LoadHarvestTasksEvent(_plot)));
  }

  void _selectHarvest() {
    if (_harvests.isNotEmpty) {UtilUI.showOptionDialog(context, 'Chọn mùa vụ', _harvests, '').then((value) => _setHarvest(value));}
  }

  void _setHarvest(value) {
    if (value == null || _harvest == value.id.toString()) return;
    _plots.clear();
    _ctrHarvest.text = value.name;
    _harvest = value.id.toString();
    bloc!.add(PlotsDtlEvent(_harvest));
  }

  /// Harvest diary list
  void _loadMore() => _harvestBloc!.add(LoadListEvent(_page, ''));

  void _listenScroller() {
    if (_page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) _loadMore();
  }

  void _gotoDetail(int index) {
    _list[index].working_status = 'completed';
    UtilUI.goToNextPage(context, HarvestDiaryDtlPage(_list[index], (){}, lock: true));
  }
  /// End: Harvest diary list
}