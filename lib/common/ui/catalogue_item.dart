import 'package:hainong/common/ui/image_network_asset.dart';
import 'package:hainong/common/util/util_ui.dart';
import 'import_lib_base_ui.dart';
import 'package:hainong/common/style_custom.dart';
import 'package:hainong/features/post/ui/list_post_hash_tag_page.dart';

class CatalogueItem extends StatelessWidget {
  final dynamic item;
  final bool isActive, openPage;
  final Function funChangeIndex;
  final int index;
  final double? height, marginRight;

  const CatalogueItem(this.item, this.isActive, this.funChangeIndex, this.index,
      {this.openPage = true, this.height, this.marginRight, Key? key}):super(key:key);

  @override
  Widget build(BuildContext context) => Container(margin: EdgeInsets.only(right: marginRight??30.sp),
      height: height,
      decoration: BoxDecoration(color: isActive ? StyleCustom.buttonColor : Colors.white,
      borderRadius: BorderRadius.circular(15.sp),
          border: Border.all(color: StyleCustom.buttonColor, width: 0.5)),
      child: OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(
          color: Colors.transparent,
        )
      ),
      onPressed: () => _changeIndex(context),
      child: Row(children: [
        ImageNetworkAsset(width: 48.sp, height: 48.sp, fit: BoxFit.fill, scale: 0.5,
            path: item['image']??'', uiError: Icon(Icons.sell, size: 48.sp, color: const Color(0xFFCDCDCD))),
        SizedBox(width: 10.sp),
        Text(item['name']??'', style: TextStyle(color: StyleCustom.textColor2C, fontSize: 38.sp,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal))
      ])));

  void _changeIndex(BuildContext context) {
    funChangeIndex(index);
    if (openPage) UtilUI.goToNextPage(context, ListPostHashtagPage('#'+item['name']??'', allowGotoShop: true));
  }
}
