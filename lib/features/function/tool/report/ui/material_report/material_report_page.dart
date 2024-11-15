import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import 'package:hainong/common/ui/ui_farm.dart';
import '../../report_bloc.dart';
import 'material_report_detail_page.dart';

class MaterialReportPage extends BasePage {
  MaterialReportPage({Key? key}) : super(pageState: _MaterialReportPageState(), key: key);
}

class _MaterialReportPageState extends BasePageState {
  final TextEditingController _ctrStart = TextEditingController(), _ctrEnd = TextEditingController();
  final ScrollController _scroller = ScrollController();
  final List _list = [];
  int _page = 1;

  @override
  void dispose() {
    _ctrStart.dispose();
    _ctrEnd.dispose();
    _scroller.removeListener(_listener);
    _scroller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    bloc = ReportBloc();
    super.initState();
    bloc!.stream.listen((state) {
      if (state is ShowErrorState) UtilUI.showCustomDialog(context, state.resp);
    });
    _loadData();
    _scroller.addListener(_listener);
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) =>
    Scaffold(appBar: AppBar(elevation: 5, titleSpacing: 0,
      title: UtilUI.createLabel('Báo cáo nhập xuất tồn kho vật tư'), centerTitle: true),
      backgroundColor: Colors.white,
      body: Stack(children: [
        SizedBox(width: 1.5.sw, child: createUI()),
        Loading(bloc)
      ]));

  @override
  Widget createUI() => Column(children: [
    Padding(child: Row(children: [
      Expanded(child: Column(children: [
        LabelCustom('Ngày bắt đầu', size: 36.sp, color: const Color(0xFF787878), weight: FontWeight.normal),
        SizedBox(height: 20.sp),
        TextFieldCustom(_ctrStart, null, null, 'dd/MM/yyyy',
            size: 42.sp, color: const Color(0XFFF5F6F8), borderColor: const Color(0XFFF5F6F8), readOnly: true,
            onPressIcon: _selectStartDate, suffix: Icon(Icons.calendar_today, color: Colors.grey, size: 48.sp))
      ], crossAxisAlignment: CrossAxisAlignment.start)),
      SizedBox(width: 20.sp),
      Expanded(child: Column(children: [
        LabelCustom('Ngày kết thúc', size: 36.sp, color: const Color(0xFF787878), weight: FontWeight.normal),
        SizedBox(height: 20.sp),
        TextFieldCustom(_ctrEnd, null, null, 'dd/MM/yyyy',
            size: 42.sp, color: const Color(0XFFF5F6F8), borderColor: const Color(0XFFF5F6F8), readOnly: true,
            onPressIcon: _selectEndDate, suffix: Icon(Icons.calendar_today, color: Colors.grey, size: 48.sp))
      ], crossAxisAlignment: CrossAxisAlignment.start))
    ]), padding: EdgeInsets.all(40.sp)),
    const FarmManageTitle([
      ['Tên VT', 2],
      ['Đơn vị', 2],
      ['Nhập', 2],
      ['Sử dụng', 2],
      ['Tồn', 2]
    ]),
    Expanded(child: BlocConsumer(bloc: bloc, buildWhen: (oldS, newS) => newS is MaterialReportState,
        listener: (context, state) {
          if (state is MaterialReportState) {
            if (state.data.isEmpty) {
              _page = 0;
            } else {
              _list.addAll(state.data);
              state.data.length == 20 ? _page++ : _page = 0;
            }
          }
        },
        builder: (context, state) {
          if (_list.isEmpty) return const SizedBox();
          return ListView.builder(padding: EdgeInsets.zero, itemCount: _list.length, controller: _scroller,
              itemBuilder: (context, index) => FarmManageItem([
                [Util.getValueFromJson(_list[index], 'name', ''), 2],
                [Util.getValueFromJson(_list[index], 'material_unit_name', ''), 2],
                [Util.doubleToString(Util.getValueFromJson(_list[index], 'total_import', .0).toDouble()), 2],
                [Util.doubleToString(Util.getValueFromJson(_list[index], 'total_ouput', .0).toDouble()), 2],
                [Util.doubleToString(Util.getValueFromJson(_list[index], 'inventory', .0).toDouble()), 2]
              ], index, action: _gotoDetail), physics: const AlwaysScrollableScrollPhysics());
        }))
  ]);

  void _listener() {
    if (_page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) _loadData();
  }

  void _selectStartDate() {
    String temp = _ctrStart.text;
    if (temp.isEmpty) {
      final now = DateTime.now();
      temp = '${now.day}/${now.month}/${now.year}';
    }

    DateTime max = DateTime.now();
    if (_ctrEnd.text.isNotEmpty) max = Util.stringToDateTime(_ctrEnd.text, pattern: 'dd/MM/yyyy');

    DatePicker.showDatePicker(context,
        minTime: max.add(const Duration(days: -3650)),
        maxTime: max,
        showTitleActions: true,
        onConfirm: (DateTime date) {
          _ctrStart.text = Util.dateToString(date, pattern: 'dd/MM/yyyy');
          _loadData(reload: true);
        },
        currentTime: Util.stringToDateTime(temp, pattern: 'dd/MM/yyyy'),
        locale: LocaleType.vi);
  }

  void _selectEndDate() {
    String temp = _ctrEnd.text;
    if (temp.isEmpty) {
      final now = DateTime.now();
      temp = '${now.day}/${now.month}/${now.year}';
    }

    DateTime min = DateTime.now().add(const Duration(days: -3650));
    if (_ctrStart.text.isNotEmpty) min = Util.stringToDateTime(_ctrStart.text, pattern: 'dd/MM/yyyy');

    DatePicker.showDatePicker(context,
        minTime: min,
        maxTime: DateTime.now().add(const Duration(days: 3650)),
        showTitleActions: true,
        onConfirm: (DateTime date) {
          _ctrEnd.text = Util.dateToString(date, pattern: 'dd/MM/yyyy');
          _loadData(reload: true);
        },
        currentTime: Util.stringToDateTime(temp, pattern: 'dd/MM/yyyy'),
        locale: LocaleType.vi);
  }

  void _loadData({bool reload = false}) {
    if (reload) {
      _list.clear();
      _page = 1;
    }
    bloc!.add(MaterialEvent(_page, start: _ctrStart.text, end: _ctrEnd.text));
  }

  void _gotoDetail(int index) => UtilUI.goToNextPage(context, MaterialReportDtlPage(_list[index]));
}