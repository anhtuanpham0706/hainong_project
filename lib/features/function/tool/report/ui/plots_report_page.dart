import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import '../report_bloc.dart';

class PlotsReportPage extends BasePage {
  PlotsReportPage({Key? key}) : super(pageState: _PlotsReportPageState(), key: key);
}

class _PlotsReportPageState extends BasePageState {

  @override
  void initState() {
    bloc = ReportBloc();
    super.initState();
    bloc!.stream.listen((state) {
      if (state is ShowErrorState) UtilUI.showCustomDialog(context, state.resp);
    });
    bloc!.add(PlotsEvent());
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) =>
    Scaffold(appBar: AppBar(elevation: 5, titleSpacing: 0,
      title: UtilUI.createLabel('Báo cáo tổng hợp lô thửa'), centerTitle: true),
      backgroundColor: Colors.white,
      body: Padding(child: BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is PlotsState,
          builder: (context, state) {
            Map<String, dynamic>? data;
            if (state is PlotsState) data = state.data;
            if (data == null) return const SizedBox();
            return Column(children: [
              _line('Tổng số danh mục vật tư đang quản lý', Util.getValueFromJson(data, 'total_material', .0).toDouble()),
              _line('Tổng số lô đang quản lý', Util.getValueFromJson(data, 'total_culture_plots', .0).toDouble()),
              _line('Tổng số kế hoạch canh tác', Util.getValueFromJson(data, 'total_process_engineerings', .0).toDouble()),
              _line('Tổng số mùa vụ đã kết thúc', Util.getValueFromJson(data, 'completed_harvests', .0).toDouble()),
              _line('Tổng số mùa vụ đang tiến hành', Util.getValueFromJson(data, 'working_harvests', .0).toDouble())
            ]);
          }), padding: EdgeInsets.only(top: 40.sp)));

  Widget _line(String title, double value) =>
    Container(padding: EdgeInsets.all(40.sp),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5), width: 0.5))),
      child: Row(children: [
        Expanded(child: LabelCustom(title, color: const Color(0xFF282828), size: 52.sp, weight: FontWeight.normal)),
        SizedBox(width: 20.sp),
        LabelCustom(Util.doubleToString(value), color: const Color(0xFF181818), size: 52.sp, weight: FontWeight.normal)
    ], mainAxisAlignment: MainAxisAlignment.spaceBetween));
}