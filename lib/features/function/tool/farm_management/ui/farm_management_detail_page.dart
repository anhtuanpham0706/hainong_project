import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/show_popup_html.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import 'package:hainong/features/function/support/handbook/handbook_bloc.dart';
import '../farm_management_bloc.dart';
import '../task_bloc.dart';
import 'package:hainong/common/ui/ui_farm.dart';
import 'task_detail_page.dart';
import '../../plots_management/ui/plots_management_list_page.dart';

class FarmManageDtlPage extends BasePage {
  final FarmManageModel detail;
  final Function funReload;
  final bool lock;
  FarmManageDtlPage(this.detail, this.funReload, {this.lock = false, Key? key}) : super(pageState: _FarmManageDtlPageState(), key: key);
}

class _FarmManageDtlPageState extends BasePageState {
  final TextEditingController _ctrName = TextEditingController(), _ctrPlot = TextEditingController(),
      _ctrTypeTree = TextEditingController(), _ctrStart = TextEditingController(),
      _ctrEnd = TextEditingController(), _ctrQty = TextEditingController(),
      _ctrUnit = TextEditingController(), _ctrOtherUnit = TextEditingController(), _ctrTotal = TextEditingController();
  final FocusNode _fcTotal = FocusNode(), _fcName = FocusNode(), _fcPlot = FocusNode(), _fcTypeTree = FocusNode(),
      _fcStart = FocusNode(), _fcEnd = FocusNode(), _fcQty = FocusNode(), _fcUnit = FocusNode(), _fcOtherUnit = FocusNode();
  final ItemModel _unit = ItemModel(id: 'other', name: 'Khác'), _plots = ItemModel();

  final ScrollController _scroller = ScrollController();
  final List<TaskModel> _list = [TaskModel()];
  TaskBloc? _taskBloc;
  int _page = 1;
  bool _lock = false, _isView = false;

  @override
  void dispose() {
    _list.clear();
    _taskBloc?.close();
    _scroller.removeListener(_listenScroller);
    _scroller.dispose();
    _ctrName.dispose();
    _fcName.dispose();
    _ctrPlot.dispose();
    _fcPlot.dispose();
    _ctrTypeTree.dispose();
    _fcTypeTree.dispose();
    _ctrStart.dispose();
    _fcStart.dispose();
    _ctrEnd.dispose();
    _fcEnd.dispose();
    _ctrQty.dispose();
    _fcQty.dispose();
    _ctrUnit.dispose();
    _fcUnit.dispose();
    _ctrOtherUnit.dispose();
    _fcOtherUnit.dispose();
    _ctrTotal.dispose();
    _fcTotal.dispose();
    super.dispose();
  }

  @override
  void initState() {
    final page = widget as FarmManageDtlPage;
    _isView = page.lock;
    bloc = FarmManagementBloc(typeInfo: 'process_engineering');
    _taskBloc = TaskBloc(page.detail.id);
    super.initState();
    bloc!.stream.listen((state) {
      if (state is CreatePlanState && isResponseNotError(state.resp)) {
        final page = widget as FarmManageDtlPage;
        page.funReload();
        if (page.detail.id < 0) {
          page.detail.id = state.resp.data.id;
          page.detail.title = state.resp.data.title;
          page.detail.start_date = state.resp.data.start_date;
          page.detail.end_date = state.resp.data.end_date;
          _scroller.animateTo(_scroller.position.maxScrollExtent, duration: const Duration(milliseconds: 2000), curve: Curves.ease);
          _taskBloc!.id = page.detail.id;
          UtilUI.showCustomDialog(context, 'Lưu thành công. Hãy tiếp tục thực hiện công việc', title: 'Thông báo');
        } else UtilUI.showCustomDialog(context, 'Lưu thành công', title: 'Thông báo');
      } else if (state is DeletePlanState && isResponseNotError(state.resp, passString: true)) {
        (widget as FarmManageDtlPage).funReload();
        UtilUI.goBack(context, true);
      }
    });
    _initData();

    _taskBloc!.stream.listen((state) {
      if (state is LoadListState) {
        if (isResponseNotError(state.response)) {
          final list = state.response.data.list;
          if (list.isNotEmpty) {
            _list.addAll(list);
            list.length == 20 ? _page++ : _page = 0;
          } else _page = 0;
        }
        _lock = false;
      }
    });
    if (_taskBloc!.id > 0) _loadMore();
    _scroller.addListener(_listenScroller);
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Scaffold(
      appBar: AppBar(elevation: 10, titleSpacing: 0, title: UtilUI.createLabel('Chi tiết kế hoạch canh tác'),
          centerTitle: true, actions: [
            IconButton(onPressed: clearFocus, icon: Icon(Icons.keyboard, color: Colors.white, size: 48.sp))
          ]),
      backgroundColor: color, body: Stack(children: [
          createUI(),
          Loading(bloc),
          Loading(_taskBloc)
        ]));

  @override
  Widget createUI() {
    final color = const Color(0XFFF5F6F8);
    final require = LabelCustom(' (*)', color: Colors.red, size: 36.sp, weight: FontWeight.normal);
    return Column(children: [
      Expanded(child: RefreshIndicator(child: BlocBuilder(bloc: _taskBloc,
        buildWhen: (oldState, newState) => newState is LoadListState,
        builder: (context, state) {
          return ListView.builder(padding: EdgeInsets.zero, controller: _scroller, itemCount: _list.length,
            physics: const AlwaysScrollableScrollPhysics(), itemBuilder: (context, index) {
              if (index > 0) {
                return FarmManageItem([
                  [Util.strDateToString(_list[index].working_date, pattern: 'dd/MM/yyyy'), 4], [_list[index].title, 6]
                ], index, action: _gotoDetail);
              }
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(padding: EdgeInsets.all(40.sp), child: Column(children: [
                  UtilUI.createLabel('Thông tin chung', fontSize: 52.sp, color: const Color(0xFF1AAD80)),
                  SizedBox(height: 40.sp),

                  Row(children: [_title('Tên kế hoạch'), require,ShowInfo(bloc, "title")]),
                  Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp), child: TextFieldCustom(_ctrName,
                      _fcName, _fcPlot, 'Nhập tên kế hoạch', size: 42.sp, color: color, readOnly: _isView,
                      borderColor: color, maxLine: 0, inputAction: TextInputAction.newline,
                      type: TextInputType.multiline, padding: EdgeInsets.all(30.sp))),

                  Row(children: [_title('Chọn lô thửa đã tạo'), require]),
                  Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
                      child: TextFieldCustom(_ctrPlot, _fcPlot, _fcTypeTree, 'Chọn lô thửa',
                          size: 42.sp, color: color, borderColor: color, readOnly: true,
                          onPressIcon: _selectPlots, maxLine: 0, inputAction: TextInputAction.newline,
                          type: TextInputType.multiline, padding: EdgeInsets.all(30.sp),
                          suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp))),

                  Row(children: [_title('Loại cây'),ShowInfo(bloc, "family_tree")],),
                  Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
                      child: TextFieldCustom(_ctrTypeTree, _fcTypeTree, _fcStart, 'Nhập loại cây',
                          size: 42.sp, color: color, borderColor: color, maxLine: 0, readOnly: _isView,
                          inputAction: TextInputAction.newline, type: TextInputType.multiline,
                          padding: EdgeInsets.all(30.sp))),

                  Row(children: [
                    Expanded(child: Column(children: [
                      Row(children: [_title('Ngày bắt đầu'),ShowInfo(bloc, "start_date")],),
                      SizedBox(height: 16.sp),
                      TextFieldCustom(_ctrStart, _fcStart, _fcEnd, 'dd/MM/yyyy', size: 42.sp,
                          color: color, borderColor: color, readOnly: true, onPressIcon: _selectDate,
                          suffix: Icon(Icons.calendar_today, color: Colors.grey, size: 48.sp))
                    ], crossAxisAlignment: CrossAxisAlignment.start)),
                    const SizedBox(width: 10),
                    Expanded(child: Column(children: [
                      Row(children: [_title('Ngày kết thúc dự kiến'),ShowInfo(bloc, "end_date")],),
                      SizedBox(height: 16.sp),
                      TextFieldCustom(_ctrEnd, _fcEnd, _fcQty, 'dd/MM/yyyy', size: 42.sp,
                          color: color, borderColor: color, readOnly: true,
                          onPressIcon: () => _selectDate(isStart: false),
                          suffix: Icon(Icons.calendar_today, color: Colors.grey, size: 48.sp))
                    ], crossAxisAlignment: CrossAxisAlignment.start))
                  ]),

                  Padding(padding: EdgeInsets.symmetric(vertical: 40.sp), child: Row(children: [
                    Expanded(child: Column(children: [
                      Row(children: [_title('Sản lượng dự tính'),ShowInfo(bloc, "amount")],),
                      SizedBox(height: 16.sp),
                      TextFieldCustom(_ctrQty, _fcQty, _fcUnit, 'Nhập', size: 42.sp, color: color, readOnly: _isView,
                          type: TextInputType.number, isOdd: false,
                          borderColor: color, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))])
                    ], crossAxisAlignment: CrossAxisAlignment.start)),
                    const SizedBox(width: 10),
                    Expanded(child: Column(children: [
                      _title('Đơn vị tính'),
                      SizedBox(height: 16.sp),
                      TextFieldCustom(_ctrUnit, _fcUnit, _fcTotal, '', size: 42.sp,
                          color: color, borderColor: color, readOnly: true,
                          onPressIcon: _selectUnit, suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp))
                    ], crossAxisAlignment: CrossAxisAlignment.start))
                  ])),

                  BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is ChangeUnitState,
                      builder: (context, state) => _unit.id == 'other' ? Column(children: [
                        _title('Đơn vị tính khác'),
                        Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp), child: TextFieldCustom(_ctrOtherUnit, _fcOtherUnit, _fcTotal,
                            'Nhập đơn vị tính khác', readOnly: _isView, size: 42.sp, color: color, borderColor: color))
                      ], crossAxisAlignment: CrossAxisAlignment.start) : const SizedBox()),

                  Row(children: [_title('Doanh thu dự kiến (VNĐ)'),ShowInfo(bloc, "revenue")],),
                  Padding(padding: EdgeInsets.only(top: 16.sp), child: TextFieldCustom(_ctrTotal, _fcTotal, null,
                      'Nhập doanh thu dự kiến', size: 42.sp, color: color, borderColor: color, readOnly: _isView,
                      type: TextInputType.number, isOdd: false,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))])),
                ], crossAxisAlignment: CrossAxisAlignment.start)),
                Divider(height: 32.sp, thickness: 32.sp, color: const Color(0xFFF4F4F4)),
                Row(children: [
                  Padding(padding: EdgeInsets.all(40.sp), child: UtilUI.createLabel('Danh sách công việc thực hiện',
                      fontSize: 52.sp, color: const Color(0xFF1AAD80))),
                  if ((widget as FarmManageDtlPage).detail.id > 0 && !_isView) ButtonImageWidget(100, () => _gotoDetail(-1), Icon(Icons.add_circle, color: const Color(0xFF1AAD80), size: 86.sp))
                ]),
                const FarmManageTitle([
                  ['Ngày thực hiện', 4],
                  ['Tên công việc', 6]
                ]),
              ]);
          });
         }), onRefresh: () async => _reset())),

      const Divider(height: 0.5, color: Colors.black12),
      if (!_isView) Padding(padding: EdgeInsets.all(40.sp), child: Row(children: [
        ButtonImageWidget(16.sp, _delete,
            Container(padding: EdgeInsets.all(40.sp), width: 0.5.sw - 60.sp, child: LabelCustom('Xoá',
                color: Colors.white, size: 48.sp, weight: FontWeight.normal, align: TextAlign.center)), color: Colors.black26),
        ButtonImageWidget(16.sp, _save,
            Container(padding: EdgeInsets.all(40.sp), width: 0.5.sw - 60.sp, child: LabelCustom('Lưu',
                color: Colors.white, size: 48.sp, weight: FontWeight.normal, align: TextAlign.center)), color: StyleCustom.primaryColor)
      ], mainAxisAlignment: MainAxisAlignment.spaceBetween)),
    ]);
  }

  Widget _title(String title) => LabelCustom(title, color: const Color(0xFF787878), size: 36.sp, weight: FontWeight.normal);

  void _initData() {
    final detail = (widget as FarmManageDtlPage).detail;
    if (detail.id > 0) {
      _ctrName.text = detail.title;
      _ctrTypeTree.text = detail.family_tree;
      _ctrOtherUnit.text = detail.other_unit;
      _ctrQty.text = Util.doubleToString(detail.amount);
      _ctrTotal.text = Util.doubleToString(detail.revenue);
      if (detail.start_date.isNotEmpty) _ctrStart.text = Util.strDateToString(detail.start_date, pattern: 'dd/MM/yyyy');
      if (detail.end_date.isNotEmpty) _ctrEnd.text = Util.strDateToString(detail.end_date, pattern: 'dd/MM/yyyy');
      if (detail.culture_plot_id > 0) {
        _ctrPlot.text = detail.culture_plot_title;
        _plots.id = detail.culture_plot_id.toString();
        _plots.name = detail.culture_plot_title;
      }
      if (detail.unit.isNotEmpty) {switch(detail.unit.toLowerCase()) {
        case 'other': _unit.setValue('other', 'Khác'); break;
        case 'kg': _unit.setValue('kg', 'Kg'); break;
        case 'bottle': _unit.setValue('bottle', 'Chai'); break;
        case 'bag': _unit.setValue('bag', 'Bao'); break;
        case 'tree': _unit.setValue('tree', 'Cây'); break;
        case 'ton': _unit.setValue('ton', 'Tấn'); break;
      }} else if (detail.other_unit.isNotEmpty) {
        _ctrOtherUnit.text = detail.other_unit;
      }
    }
    _setUnit(_unit, isFirst: true);
  }

  void _selectPlots() {
    if (_isView) return;
    clearFocus();
    UtilUI.goToNextPage(context, PlotsManageListPage(isSelect: true), funCallback: (value) => _setPlots(value));
  }

  void _setPlots(value) {
    if (value == null) return;
    if (_plots.id == value.id.toString()) return;
    _ctrPlot.text = value.title;
    _plots.id = value.id.toString();
    _plots.name = value.title;
    _ctrTypeTree.text = value.family_tree;
  }

  void _selectDate({bool isStart = true}) {
    if (_isView) return;
    clearFocus();
    String temp = isStart ? _ctrStart.text : _ctrEnd.text;
    if (temp.isEmpty) {
      final now = DateTime.now();
      temp = '${now.day}/${now.month}/${now.year}';
    }
    DatePicker.showDatePicker(context,
        minTime: DateTime.now().add(const Duration(days: -3650)),
        maxTime: DateTime.now().add(const Duration(days: 3650)),
        showTitleActions: true,
        onConfirm: (DateTime date) => _setDate(date, isStart),
        currentTime: Util.stringToDateTime(temp, pattern: 'dd/MM/yyyy'),
        locale: LocaleType.vi);
  }

  void _setDate(DateTime date, bool isStart) {
    if (isStart) {
      if (_ctrEnd.text.isNotEmpty) {
        DateTime end = Util.stringToDateTime(_ctrEnd.text, pattern: 'dd/MM/yyyy');
        if (date.compareTo(end) >= 0) return;
      }
    } else {
      if (_ctrStart.text.isNotEmpty) {
        DateTime start = Util.stringToDateTime(_ctrStart.text, pattern: 'dd/MM/yyyy');
        if (date.compareTo(start) <= 0) return;
      }
    }
    String temp = Util.dateToString(date, pattern: 'dd/MM/yyyy');
    isStart ? _ctrStart.text = temp : _ctrEnd.text = temp;
  }

  void _selectUnit() {
    if (_isView) return;
    clearFocus();
    final List<ItemModel> options = [
      ItemModel(id: 'other', name: 'Khác'),
      ItemModel(id: 'kg', name: 'Kg'),
      ItemModel(id: 'bottle', name: 'Chai'),
      ItemModel(id: 'bag', name: 'Bao'),
      ItemModel(id: 'tree', name: 'Cây'),
      ItemModel(id: 'ton', name: 'Tấn'),
    ];
    UtilUI.showOptionDialog(context, 'Chọn đơn vị tính', options, _ctrUnit.text).then((value) => _setUnit(value));
  }

  void _setUnit(ItemModel? value, {bool isFirst = false}) {
    if (value == null) return;
    if (!isFirst && _unit.id == value.id) return;
    _ctrUnit.text = value.name;
    _unit.id = value.id;
    _unit.name = value.name;
    bloc!.add(ChangeUnitEvent());
    if (value.id != 'other') _ctrOtherUnit.text = '';
  }

  void _save() {
    clearFocus();
    if (_ctrName.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, 'Nhập tên kế hoạch').whenComplete(() => _fcName.requestFocus());
      return;
    }
    if (_plots.id.isEmpty) {
      UtilUI.showCustomDialog(context, 'Chọn lô thửa').whenComplete(() => _fcPlot.requestFocus());
      return;
    }

    bloc!.add(CreatePlanEvent((widget as FarmManageDtlPage).detail.id, _plots.id,
        TextFieldCustom.stringToDouble(_ctrQty.text), TextFieldCustom.stringToDouble(_ctrTotal.text), _ctrName.text, _ctrTypeTree.text,
        _ctrStart.text, _ctrEnd.text, _unit.id, _ctrOtherUnit.text));
  }

  void _delete() {
    clearFocus();
    final detail = (widget as FarmManageDtlPage).detail;
    if (detail.id > 0) {
      UtilUI.showCustomDialog(context, 'Bạn có chắc muốn xoá kế hoạch canh tác này không?',
        isActionCancel: true).then((value) {
          if (value != null && value) bloc!.add(DeletePlanEvent(detail.id));
      });
    }
  }

  ///Jobs detail
  void _loadMore() {
    if (_taskBloc!.id < 0)  return;
    _taskBloc!.add(LoadListEvent(_page, ''));
  }

  void _listenScroller() {
    if (_page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) _loadMore();
  }

  void _reset() {
    if (_taskBloc!.id < 0 || _lock)  return;
    _lock = true;
    setState(() => _list.removeRange(1, _list.length));
    _page = 1;
    _loadMore();
  }

  void _gotoDetail(int index) {
    if (_taskBloc!.id < 0)  return;
    final page = widget as FarmManageDtlPage;
    UtilUI.goToNextPage(context, TaskDtlPage(page.detail.id, page.detail.start_date, page.detail.end_date, index < 0 ? TaskModel() : _list[index], _reset, lock: page.lock));
  }
  ///End: Jobs detail
}

class FarmTabItem extends StatelessWidget {
  final String title;
  final bool active;
  final Function action;
  const FarmTabItem(this.title, this.active, this.action, {Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) => ButtonImageWidget(200, action, Container(
    decoration: BoxDecoration(color: active ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(200)
    ), padding: EdgeInsets.symmetric(vertical: 20.sp, horizontal: 40.sp), child: LabelCustom(title, size: 36.sp, color: Color(active ? 0xFF1AAD80 : 0xFFFFFFFF),
      weight: active ? FontWeight.w500 : FontWeight.normal)));
}