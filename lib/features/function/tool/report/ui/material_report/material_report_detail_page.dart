import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/features/function/tool/report/ui/material_report/farm_task_list_page.dart';

import 'harvest_task_list_page.dart';

class MaterialReportDtlPage extends StatelessWidget {
  final dynamic detail;
  const MaterialReportDtlPage(this.detail, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    final String date = Util.getValueFromJson(detail, 'warehouse_date', '');
    final double plan = Util.getValueFromJson(detail, 'used_in_plant', .0).toDouble();
    final double real = Util.getValueFromJson(detail, 'used_in_harvest', .0).toDouble();
    return Scaffold(appBar: AppBar(elevation: 10, titleSpacing: 0, centerTitle: true,
      title: UtilUI.createLabel('Chi tiết nhập xuất tồn kho vật tư')),
      backgroundColor: Colors.white, body: ListView(padding: EdgeInsets.all(40.sp), children: [
        _item('Tên vật tư', 'name', ''),
        _item('Loại vật tư', 'material_type_name', ''),
        _item('Ngày nhập kho', '', date.isEmpty ? '' : Util.strDateToString(date, pattern: 'dd/MM/yyyy')),
        Row(children: [
          Expanded(child: _item('Tổng số nhập kho', '', Util.doubleToString(Util.getValueFromJson(detail, 'total_import', .0).toDouble()))),
          Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 20.sp),
              child: _item('Tồn kho', '', Util.doubleToString(Util.getValueFromJson(detail, 'inventory', .0).toDouble())))),
          Expanded(child: _item('Đơn vị tính', 'material_unit_name', ''))
        ], crossAxisAlignment: CrossAxisAlignment.start),

        plan > 0 ? Row(children: [
          Expanded(child: _item('Tổng số đưa vào kế hoạch', '', Util.doubleToString(plan))),
          SizedBox(width: 20.sp),
          Expanded(child: ButtonImageWidget(0, () => UtilUI.goToNextPage(context, FarmTaskListPage(detail['id'], detail['name'])),
              const LabelCustom('Xem kế hoạch canh tác', color: Color(0xFF1AAD80), align: TextAlign.center)))
        ]) : const SizedBox(),

        real > 0 ? Row(children: [
          Expanded(child: _item('Tổng số đã sử dụng', '', Util.doubleToString(real))),
          SizedBox(width: 20.sp),
          Expanded(child: ButtonImageWidget(0, () => UtilUI.goToNextPage(context, HarvestTaskListPage(detail['id'], detail['name'])),
              const LabelCustom('Xem quản lý canh tác', color: Color(0xFF1AAD80), align: TextAlign.center)))
        ]) : const SizedBox()
    ]));
  }

  Widget _item(String title, String keyName, String value) => Column(children: [
    LabelCustom(title, color: const Color(0xFF787878), size: 36.sp, weight: FontWeight.normal),
    Container(margin: EdgeInsets.only(top: 16.sp, bottom: 40.sp), padding: EdgeInsets.all(30.sp), width: 1.sw,
        decoration: BoxDecoration(color: const Color(0XFFF5F6F8), borderRadius: BorderRadius.circular(5)),
        child: LabelCustom(keyName.isEmpty ? value : Util.getValueFromJson(detail, keyName, ''), color: Colors.black, weight: FontWeight.normal))
  ], crossAxisAlignment: CrossAxisAlignment.start);
}