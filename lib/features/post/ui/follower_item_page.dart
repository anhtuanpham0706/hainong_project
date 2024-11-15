import 'package:dotted_border/dotted_border.dart';
import 'package:hainong/features/shop/ui/shop_page.dart';
import 'package:hainong/common/ui/avatar_circle_widget.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/button_image_circle_widget.dart';
import 'package:hainong/features/post/bloc/post_item_bloc.dart';
import 'package:hainong/features/shop/shop_model.dart';

class FollowerItemPage extends StatelessWidget {
  final ShopModel shop;
  final int index, type;
  final bool hasLine;
  final PostItemBloc _bloc = PostItemBloc(PostItemState());

  FollowerItemPage(this.index, this.shop, this.type, this.hasLine, {Key? key}) : super(key: key) {
    _bloc.stream.listen((state) {
      if (state is LoadShopPostItemState) _handleLoadShop(state);
    });
  }

  Widget build(BuildContext context) => ButtonImageCircleWidget(40.sp, () => _loadShop(context),
      child: Container(color: Colors.white,
          padding: EdgeInsets.only(top: 60.sp),
          child: Column(children: [
            Container(color: Colors.white,
                padding: EdgeInsets.only(left: 40.sp, right: 40.sp),
                child: Row(children: [
              AvatarCircleWidget(link: shop.image, size: 150.sp),
              SizedBox(width: 40.sp),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UtilUI.createLabel(shop.name,
                            color: StyleCustom.textColor2C, fontSize: 45.sp),
                        SizedBox(height: 10.sp),
                        Row(children: [
                          Icon(Icons.av_timer, size: 40.sp, color: Colors.orange),
                          Expanded(
                              child: UtilUI.createLabel(' ${Util.getTimeAgo(type == 0 ? shop.followed_at : shop.following_at)}',
                                  color: StyleCustom.textColor6C,
                                  fontSize: 30.sp,
                                  fontWeight: FontWeight.normal))
                        ])
                      ]))
            ])),
            SizedBox(height: hasLine ? 60.sp : 0),
            hasLine ? DottedBorder(
                padding: EdgeInsets.zero,
                strokeWidth: 0.5,
                dashPattern: const [2, 4],
                borderType: BorderType.RRect,
                color: Colors.grey,
                child: Container(height: 0.5)) : SizedBox(height: 60.sp)
          ])));

  _loadShop(BuildContext context) => _bloc.add(LoadShopPostItemEvent(context, shop.shopable_id));

  _handleLoadShop(LoadShopPostItemState state) {
    if (state.response.checkTimeout())
      UtilUI.showDialogTimeout(state.context);
    else if (state.response.checkOK())
      _goToShop(state.response.data, state.context);
  }

  _goToShop(ShopModel shop, BuildContext context) {
    UtilUI.goToNextPage(
        context,
        ShopPage(
            shop: shop,
            isOwner: false,
            hasHeader: true,
            isView: true));
    Util.trackActivities('post', path: 'Follower List Screen -> Show Detail Profile');
  }
}
