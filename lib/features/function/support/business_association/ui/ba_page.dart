import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/util/util_ui.dart';
import 'package:hainong/features/order_history/order_history_page.dart';
import 'ba_dtl_page.dart';
import 'ba_employee_list_page.dart';
import 'ba_product_list_page.dart';

class BAPage extends StatelessWidget {
  final dynamic item, shop;
  const BAPage(this.item, this.shop, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(elevation: 5, titleSpacing: 0, centerTitle: true, title: UtilUI.createLabel('Liên kết doanh nghiệp')),
    backgroundColor: Colors.white, body: Padding(child: Column(children: [
      _item(context, 'Thông tin doanh nghiệp', () => UtilUI.goToNextPage(context, BADetailPage(item))),
      _item(context, 'Danh sách nhân viên', () => UtilUI.goToNextPage(context, BAEmployeeListPage(item.id))),
      _item(context, 'Danh sách sản phẩm', () => UtilUI.goToNextPage(context, BAProductListPage(item.id, shop))),
      _item(context, 'Danh sách đơn hàng', () => UtilUI.goToNextPage(context, OrderHistoryPage(idBusiness: item.id)))
    ]), padding: EdgeInsets.all(40.sp))
  );

  Widget _item(BuildContext context, String title, Function action) =>
    ButtonImageWidget(0, action, Padding(child: Row(children: [
      Expanded(child: LabelCustom(title, color: const Color(0xFF282828), size: 48.sp)),
      Icon(Icons.navigate_next_sharp, size: 48.sp, color: const Color(0xFF1AAD80))
    ]), padding: EdgeInsets.all(40.sp)));
}