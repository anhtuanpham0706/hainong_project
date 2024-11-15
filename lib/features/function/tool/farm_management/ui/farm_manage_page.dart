import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/features/function/tool/farm_management/ui/farm_management_list_page.dart';
import 'package:hainong/features/function/tool/harvest_diary/ui/harvest_diary_list_page.dart';
import 'package:hainong/features/function/tool/material_management/ui/material_list_page.dart';
import 'package:hainong/features/function/tool/plots_management/ui/plots_management_list_page.dart';
import 'package:hainong/features/function/tool/plots_management/ui/plots_manager_list_page.dart';
import 'package:hainong/features/function/tool/report/ui/report_page.dart';
import 'package:hainong/features/main2/ui/main2_item.dart';

class FarmManagePage extends StatelessWidget {
  const FarmManagePage({Key? key}):super(key:key);

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Scaffold(appBar: AppBar(elevation: 10,
      titleSpacing: 0, title: UtilUI.createLabel('Quản lý canh tác'), centerTitle: true),
      body: Container(decoration: BoxDecoration(
          image: DecorationImage(image: Image.asset('assets/images/v2/bg_main.png').image, fit: BoxFit.cover)),
        child: ListView(padding: EdgeInsets.fromLTRB(40.sp, 80.sp, 40.sp, 40.sp), children: [
          Main2Item('', 'material',
                  () => _gotoPage(context, MaterialListPage(), 'Material', 'Material Management')),
          Padding(padding: EdgeInsets.symmetric(vertical: 40.sp), child: Main2Item('', 'plots',
                  () => _gotoPage(context, PlotsManageListPage(), 'Plots', 'Plots Management'))),
          Main2Item('', 'manager',
                  () => _gotoPage(context, PlotsManagerListPage(), 'Manager List', 'Manager List')),
          Padding(padding: EdgeInsets.symmetric(vertical: 40.sp), child: Main2Item('', 'farm_plan',
                  () => _gotoPage(context, FarmManageListPage(), 'Farming Plan', 'Farming Plan'))),
          Main2Item('', 'harvest',
                  () => _gotoPage(context, HarvestDiaryListPage(), 'Harvest diary', 'Harvest diary')),
          Padding(padding: EdgeInsets.only(top: 40.sp), child: Main2Item('', 'sum_report',
                  () => _gotoPage(context, const ReportPage(), 'General Report', 'General Report')))
        ])
      ));

  void _gotoPage(BuildContext context, page, String button, String screen) {
    UtilUI.goToNextPage(context, page);
    Util.trackActivities('farming management', path: '"Farming Management" Screen -> Tap "$button" Button -> Open "$screen" Screen');
  }
}