import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import '../report_bloc.dart';

class ExpenseReportPage extends BasePage {
  ExpenseReportPage({Key? key}) : super(pageState: _ExpenseReportPageState(), key: key);
}

class _ExpenseReportPageState extends BasePageState {
  final TextEditingController _ctrStart = TextEditingController(), _ctrEnd = TextEditingController();

  @override
  void dispose() {
    _ctrStart.dispose();
    _ctrEnd.dispose();
    super.dispose();
  }

  @override
  void initState() {
    bloc = ReportBloc();
    super.initState();
    bloc!.stream.listen((state) {
      if (state is ShowErrorState) UtilUI.showCustomDialog(context, state.resp);
    });
    bloc!.add(ExpenseEvent());
    bloc!.add(ExpenseEvent(isFirst: false));
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) =>
    Scaffold(appBar: AppBar(elevation: 5, titleSpacing: 0,
      title: UtilUI.createLabel('Báo cáo tổng hợp chi phí'), centerTitle: true),
      backgroundColor: Colors.white,
      body: Stack(children: [
        createUI(),
        Loading(bloc)
      ]));

  @override
  Widget createUI() => ListView(padding: EdgeInsets.zero, children: [
    Padding(child: BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is Expense1State,
      builder: (context, state) {
        Map<String, dynamic>? data;
        if (state is Expense1State) data = state.data;
        if (data == null) return const SizedBox();
        return Column(children: [
          _line('Tổng số lô kế hoạch', Util.getValueFromJson(data, 'total_plans_culture_plots', .0).toDouble(), color: const Color(0xFF282828), weight: FontWeight.w500),
          _line('Tổng số lô thực hiện', Util.getValueFromJson(data, 'total_culture_plots', .0).toDouble(), color: const Color(0xFF282828), weight: FontWeight.w500),
          _line('Tổng doanh thu kế hoạch', Util.getValueFromJson(data, 'plan_revenue', .0).toDouble()),
          _line('Tổng doanh thu đang thực hiện', Util.getValueFromJson(data, 'working_revenue', .0).toDouble()),
          _line('Tổng chi phí kế hoạch', Util.getValueFromJson(data, 'plan_cost', .0).toDouble()),
          _line('Tổng chi phí đang thực hiện', Util.getValueFromJson(data, 'working_cost', .0).toDouble()),
          _line('Thu nhập theo kế hoạch', Util.getValueFromJson(data, 'plan_income', .0).toDouble()),
          _line('Thu nhập thực tế', Util.getValueFromJson(data, 'working_income', .0).toDouble())
        ]);
      }), padding: EdgeInsets.only(top: 40.sp)),
    /*Divider(height: 32.sp, color: const Color(0xFFF4F4F4), thickness: 32.sp),
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
    Padding(child: BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is Expense2State,
        builder: (context, state) {
          Map<String, dynamic>? data;
          if (state is Expense2State) data = state.data;
          if (data == null) return const SizedBox();
          return Column(children: [
            _line('Tổng chi phí dự kiến', Util.getValueFromJson(data, 'plan_cost', .0).toDouble()),
            _line('Tổng chi phí đã thực hiện', Util.getValueFromJson(data, 'working_cost', .0).toDouble()),
            _line('Tổng doanh thu kế hoạch', Util.getValueFromJson(data, 'plan_revenue', .0).toDouble()),
            _line('Tổng doanh thu thực tế', Util.getValueFromJson(data, 'working_revenue', .0).toDouble()),
            _line('Thu nhập thực tế', Util.getValueFromJson(data, 'working_income', .0).toDouble())
          ]);
        }), padding: EdgeInsets.symmetric(horizontal: 40.sp))*/
  ]);

  Widget _line(String title, double value, {Color color = const Color(0xFF4A4A4A), FontWeight weight = FontWeight.normal}) =>
    Container(padding: EdgeInsets.all(40.sp),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5), width: 0.5))),
      child: Row(children: [
        Expanded(child: LabelCustom(title, color: color, size: 52.sp, weight: weight)),
        Expanded(child: LabelCustom(Util.doubleToString(value), color: const Color(0xFFFF030B), size: 52.sp, weight: weight, align: TextAlign.right))
    ], mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start));

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
          bloc!.add(ExpenseEvent(start: _ctrStart.text, end: _ctrEnd.text, isFirst: false));
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
          bloc!.add(ExpenseEvent(start: _ctrStart.text, end: _ctrEnd.text, isFirst: false));
        },
        currentTime: Util.stringToDateTime(temp, pattern: 'dd/MM/yyyy'),
        locale: LocaleType.vi);
  }
}