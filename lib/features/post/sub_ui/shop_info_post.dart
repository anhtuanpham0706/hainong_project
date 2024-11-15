import 'package:hainong/common/style_custom.dart';
import 'package:hainong/common/ui/avatar_circle_widget.dart';
import 'package:hainong/common/ui/button_image_circle_widget.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/common/util/util_ui.dart';
import 'import_lib_post_sub_ui.dart';

class ShopInfoPost extends StatelessWidget {
  final String createdAt, shopImage, shopName;
  final bool isHideOption;
  final Function funGotoShop, funSelectOption;
  final int viewed, connected;

  const ShopInfoPost(this.createdAt, this.shopImage, this.shopName,
      this.isHideOption, this.funGotoShop, this.funSelectOption, this.viewed, this.connected, {Key? key}):super(key:key);

  @override
  Widget build(BuildContext context) => Padding(
      padding: EdgeInsets.only(top: 40.sp, left: 40.sp, right: 40.sp),
      child: ButtonImageWidget(
          20.sp, () => funGotoShop(context),
          Row(children: [
            AvatarCircleWidget(link: shopImage, size: 150.sp),
            SizedBox(width: 20.sp),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UtilUI.createLabel(shopName,
                          color: StyleCustom.textColor2C, fontSize: 45.sp),
                      Padding(child: Row(children: [
                        Icon(Icons.av_timer, size: 40.sp, color: Colors.orange),
                        Expanded(
                            child: UtilUI.createLabel(' ${Util.getTimeAgo(createdAt)}',
                                color: StyleCustom.textColor6C,
                                fontSize: 30.sp,
                                fontWeight: FontWeight.normal))
                      ]), padding: EdgeInsets.symmetric(vertical: 16.sp)),
                      //Row(children: [
                        //if (viewed > 0) LabelCustom(Util.doubleToString(viewed.toDouble()) + ' Lượt xem   ', color: StyleCustom.textColor6C, size: 32.sp),
                        LabelCustom((viewed > 0 ? Util().formatNum2(viewed.toDouble() * 7, digit: 1) : '7') + ' Lượt xem   ', color: StyleCustom.textColor6C, size: 32.sp),
                        //if (connected > 0) LabelCustom(Util.doubleToString(connected.toDouble()) + ' Lượt tiếp cận', color: StyleCustom.textColor6C, size: 32.sp)
                      //])
                    ])),
            if (!isHideOption)
                ButtonImageCircleWidget(56.sp, () => funSelectOption(context),
                  child: const Icon(Icons.more_vert, color: StyleCustom.borderTextColor))
          ])));
}
