import 'package:hainong/common/style_custom.dart';
import 'package:hainong/common/ui/avatar_circle_widget.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/ui/button_image_circle_widget.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/common/util/util_ui.dart';

class ReviewItem extends StatelessWidget {
  final dynamic item;
  final int index;
  final Function funLoadDetail;
  const ReviewItem(this.item, this.index, this.funLoadDetail, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => int.parse(item.id.toString()) < 1 ? const SizedBox() :
    ButtonImageCircleWidget(0, () => funLoadDetail(index), child: Container(child: Row(children: [
      AvatarCircleWidget(link: item.image, size: 120.sp, assetsImageReplace: 'assets/images/ic_default.png'),
      SizedBox(width: 40.sp),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        LabelCustom(item.title, color: Colors.black, size: 48.sp, weight: FontWeight.normal),
        SizedBox(height: 10.sp),
        Row(children: [
          Icon(Icons.av_timer, size: 40.sp, color: Colors.orange),
          Expanded(child: UtilUI.createLabel(' ${Util.getTimeAgo(item.created_at)}',
            color: StyleCustom.textColor6C, fontSize: 30.sp, fontWeight: FontWeight.normal))
        ])
      ]))
    ]), padding: EdgeInsets.all(40.sp), color: index % 2 == 0 ? Colors.white : const Color(0xFFFAFAFA)));
}
