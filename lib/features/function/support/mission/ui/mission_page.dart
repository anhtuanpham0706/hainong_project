import 'package:hainong/common/constants.dart';
import 'package:hainong/common/multi_language.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/common/util/util_ui.dart';
import 'mission_list_page.dart';
import 'mission_map_page.dart';
import 'mission_part_list_page.dart';

class MissionPage extends StatelessWidget {
  const MissionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Util.getPermission();
    return Scaffold(
        appBar: AppBar(elevation: 5, titleSpacing: 0, centerTitle: true, title:
        UtilUI.createLabel('Nhiệm vụ')), backgroundColor: Colors.white,
        body: Padding(child: Column(children: [
          _item(context, 'Danh sách nhiệm vụ', () => UtilUI.goToNextPage(context, MissionListPage())),
          _item(context, 'Danh sách nhiệm vụ tự tạo', () {
            Constants().isLogin ? UtilUI.goToNextPage(context, MissionListPage(isOwner: true)) :
              UtilUI.showCustomDialog(context, MultiLanguage.get('msg_login_create_account'));
          }),
          _item(context, 'Danh sách nhiệm vụ đang tham gia', () {
            Constants().isLogin ? UtilUI.goToNextPage(context, MissionPartListPage()) :
              UtilUI.showCustomDialog(context, MultiLanguage.get('msg_login_create_account'));
          }),
          _item(context, 'Bản đồ nhiệm vụ', () => UtilUI.goToNextPage(context, MissionMapPage()))
        ]), padding: EdgeInsets.all(40.sp))
    );
  }

  Widget _item(BuildContext context, String title, Function action) =>
    ButtonImageWidget(0, action, Padding(child: Row(children: [
      Expanded(child: LabelCustom(title, color: const Color(0xFF282828), size: 48.sp)),
      Icon(Icons.navigate_next_sharp, size: 48.sp, color: const Color(0xFF1AAD80))
    ]), padding: EdgeInsets.all(40.sp)));
}