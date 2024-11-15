import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/util/util_ui.dart';
import 'package:hainong/features/admin/bad_report/ui/bad_report_list_page.dart';
import 'review_contribute/market_price/review_page.dart';

class AdminPage extends StatelessWidget {
  final bool isAdmin;
  const AdminPage(this.isAdmin, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: UtilUI.createLabel('Quản lý ${isAdmin ? 'báo vi phạm và ' : ''}đóng góp'), centerTitle: true),
    backgroundColor: Colors.white,
    body: ListView(padding: EdgeInsets.zero, children: [
      _GroupItem('Vi phạm', {
        if (isAdmin) "Bài viết": () => _gotoBadReport(context, 0, 'Bài viết vi phạm'),
        "Bình luận bài viết": () => _gotoBadReport(context, 1, 'Bình luận bài viết vi phạm'),
        "Bình luận sản phẩm": () => _gotoBadReport(context, 2, 'Bình luận sản phẩm vi phạm'),
        "Bình luận tin nông nghiệp": () => _gotoBadReport(context, 3, 'Bình luận tin nông nghiệp vi phạm'),
        "Bình luận tin video": () => _gotoBadReport(context, 4, 'Bình luận tin video vi phạm')
      }),
      if (isAdmin) Divider(height: 20.sp, color: const Color(0xFFF5F5F5), thickness: 20.sp),
      if (isAdmin) _GroupItem('Đóng góp', {
        "Giá cả thị trường": () => _gotoReview(context, 0, 'Đóng góp giá cả thị trường'),
        "Quy trình kỹ thuật": () => _gotoReview(context, 1, 'Đóng góp quy trình kỹ thuật'),
        "Loại bệnh": () => _gotoReview(context, 2, 'Đóng góp loại bệnh'),
      })
    ])
  );

  void _gotoBadReport(BuildContext context, int index, String title) => UtilUI.goToNextPage(context, BadReportListPage(title, index));

  void _gotoReview(BuildContext context, int index, String title) => UtilUI.goToNextPage(context, ReviewPage(title, index));
}

class _GroupItem extends StatelessWidget {
  final String title;
  final Map<String, Function> list;
  const _GroupItem(this.title, this.list, {Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) => Padding(padding: EdgeInsets.symmetric(vertical: 40.sp), child: Column(children: [
    Padding(padding: EdgeInsets.only(left: 40.sp), child: LabelCustom(title, color: const Color(0xFF1AAD80), size: 58.sp, weight: FontWeight.w500)),
    ListView.builder(itemBuilder: (context, index) =>
        ButtonImageWidget(0, list.entries.elementAt(index).value, Padding(child: Row(children: [
          LabelCustom(list.entries.elementAt(index).key, size: 48.sp, color: Colors.blue, weight: FontWeight.normal),
          Icon(Icons.navigate_next, size: 64.sp, color: Colors.blue)
        ], mainAxisAlignment: MainAxisAlignment.spaceBetween), padding: EdgeInsets.all(40.sp))), padding: EdgeInsets.zero,
        itemCount: list.length, shrinkWrap: true, physics: const NeverScrollableScrollPhysics())
  ], crossAxisAlignment: CrossAxisAlignment.start));
}