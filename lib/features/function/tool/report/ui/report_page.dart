import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'expense_report_page.dart';
import 'farm_plots_report_page.dart';
import 'plots_report_page.dart';
import 'material_report/material_report_page.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({Key? key}):super(key:key);
  @override
  Widget build(BuildContext context, {Color color = Colors.white}) =>
    Scaffold(appBar: AppBar(elevation: 5, titleSpacing: 0,
      title: UtilUI.createLabel('Báo cáo tổng quát'), centerTitle: true),
      backgroundColor: Colors.white,
      body: Column(children: [
        SizedBox(height: 24.sp),
        _line('Báo cáo tổng hợp lô thửa đang quản lý', () => UtilUI.goToNextPage(context, PlotsReportPage())),
        _line('Báo cáo tổng hợp chi phí', () => UtilUI.goToNextPage(context, ExpenseReportPage())),
        _line('Báo cáo chi tiết canh tác lô', () => UtilUI.goToNextPage(context, FarmPlotsReportPage())),
        _line('Báo cáo nhập/ xuất lô/ tồn vật tư', () => UtilUI.goToNextPage(context, MaterialReportPage())),
      ]));

  Widget _line(String title, Function action) => ButtonImageWidget(0, action,
    Container(padding: EdgeInsets.fromLTRB(40.sp, 40.sp, 20.sp, 40.sp),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: LabelCustom(title, color: const Color(0xFF282828), size: 52.sp, weight: FontWeight.normal)),
        Icon(Icons.navigate_next, color: const Color(0xFFA4A4A4), size: 72.sp)
      ]), decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5), width: 0.5)))));
}