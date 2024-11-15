import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/ui/avatar_circle_widget.dart';
import 'package:hainong/common/ui/button_image_circle_widget.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/ui/my_tooltip.dart';
import 'package:hainong/common/ui/shadow_decoration.dart';
import 'package:hainong/common/import_lib_system.dart';
import 'package:hainong/features/shop/shop_model.dart';
import 'product_detail_page.dart';
import '../bloc/product_list_bloc.dart';
import '../product_model.dart';

abstract class ProductItemPageCallback {
  removeFavourite();
}

class ProductItemPage extends StatelessWidget {
  final ProductModel item;
  final ShopModel _shop;
  final Function _edit, _delete, _pin;
  final Function? reloadHighlight, loginOrCreateCallback, reloadList;
  final bool isView, setShopId;
  final EdgeInsetsGeometry? margin;
  final ProductItemPageCallback? callback;
  final ProductListBloc _bloc = ProductListBloc(ProductListState());

  ProductItemPage(this.item, this._shop, this._edit, this._delete, this._pin,
      {this.isView = true, this.setShopId = false, this.callback, this.loginOrCreateCallback, this.reloadList,
      this.reloadHighlight, this.margin, Key? key}):super(key:key) {
    _bloc.stream.listen((state) {
      if (state is AddFavoriteState)
        _handleResponseAddFavorite(state);
      else if (state is RemoveFavoriteState)
        _handleResponseRemoveFavorite(state);
    });
  }

  @override
  Widget build(BuildContext context) {
    final LanguageKey languageKey = LanguageKey();
    return Container(
        decoration: ShadowDecoration(opacity: 0.15, bgColor: item.hot_pick && !isView ? Colors.greenAccent.withOpacity(0.08) : Colors.white),
        margin: margin??EdgeInsets.all(20.sp),
        child: OutlinedButton(
            style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Colors.transparent,
                ),
                padding: EdgeInsets.all(40.sp)),
            onPressed: () => _goToDetail(context),
            child: Row(children: [
              Stack(children: [
                AvatarCircleWidget(link: item.images.list.isNotEmpty ? item.images.list[0].name : '', size: 200.sp,
                    assetsImageReplace: 'assets/images/ic_default.png'),
                if (item.shop.prestige == 1) Image.asset('assets/images/v8/ic_prestige.png', width: 64.sp)
              ], alignment: Alignment.bottomRight),
              SizedBox(width: 40.sp),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    UtilUI.createLabel(item.title,
                        fontSize: 45.sp,
                        color: Colors.black87,
                        overflow: TextOverflow.ellipsis,line: 2),
                    Row(children: [
                      isView
                          ? Row(
                            children: [
                              Icon(Icons.location_on,size: 30.sp,color: Colors.black87,),
                              SizedBox(width: 10.sp,),
                              Text(item.shop.province_name + ' ',
                                  style: TextStyle(fontSize: 35.sp, color: Colors.black87)),
                            ],
                          )
                          : Container(),
                      Expanded(
                          child: Text(Util.getTimeAgo(item.updated_at),
                              style: TextStyle(
                                  fontSize: 30.sp, color: Colors.blueAccent)))
                    ]),
                    // Row(children: [
                    //       UtilUI.createLabel(MultiLanguage.get('lbl_qty')+':', color: Colors.black, fontSize: 35.sp, fontWeight: FontWeight.normal),
                    //       Padding(padding: EdgeInsets.symmetric(horizontal: 10.sp),
                    //           child: UtilUI.createLabel(Util.doubleToString(item.quantity,
                    //               locale: Constants().localeVILang), color: Colors.black, fontSize: 35.sp)),
                    //       UtilUI.createLabel(item.unit_name, color: Colors.black, fontSize: 35.sp, fontWeight: FontWeight.normal)
                    // ]),
                    Row(children: [
                      //Expanded(child: _createPriceUI(MultiLanguage.get(languageKey.lblWholesalePrice), item.wholesale_price)),
                      //Padding(padding: EdgeInsets.all(20.sp)),
                      Expanded(child: _createPriceUI(MultiLanguage.get(languageKey.lblRetailPrice), item.retail_price)),
                      isView
                          ? ButtonImageCircleWidget(
                              50.sp, () => _addRemoveFavorite(context),
                              child: _createFavorite())
                          : Container()
                    ])
                  ])),
              isView
                  ? Container()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          ButtonImageCircleWidget(60.sp, _edit,
                              child: Image.asset(
                                  'assets/images/ic_edit_outline.png',
                                  height: 60.sp,
                                  width: 60.sp,
                                  color: Colors.grey.shade500)),
                          SizedBox(height: 40.sp),
                          ButtonImageCircleWidget(60.sp, _delete,
                              child: Image.asset(
                                  'assets/images/ic_delete_outline.png',
                                  height: 60.sp,
                                  width: 60.sp,
                                  color: Colors.grey.shade500)),
                          SizedBox(height: 40.sp),
                          ButtonImageCircleWidget(60.sp, _pin,
                              child: Image.asset('assets/images/ic_pin.png',
                                  height: 60.sp,
                                  width: 60.sp,
                                  color: item.pined
                                      ? StyleCustom.primaryColor
                                      : StyleCustom.borderTextColor))
                        ])
            ])));
  }

  Widget _createPriceUI(String title, double price) {
    final unit = item.unit_name.isEmpty ? ' đ' : ' đ/${item.unit_name}';
    final temp = Util.doubleToString(price, locale: Constants().localeVILang) + unit;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(fontSize: 30.sp, color: Colors.black87)),
      price > 0 ? MyTooltip(temp,
          UtilUI.createLabel(temp, color: Colors.deepOrange, overflow: TextOverflow.ellipsis)) :
      UtilUI.createLabel(MultiLanguage.get(LanguageKey().lblAboutUs), color: Colors.deepOrange, overflow: TextOverflow.ellipsis)
    ]);
  }

  Widget _createFavorite() => BlocBuilder(
      bloc: _bloc,
      buildWhen: (state1, state2) =>
          state2 is AddFavoriteState || state2 is RemoveFavoriteState,
      builder: (context, state) => Image.asset(
          item.is_favourite
              ? 'assets/images/ic_love_fill.png'
              : 'assets/images/ic_love_outline.png',
          height: 60.sp,
          width: 60.sp));

  _goToDetail(BuildContext context) {
    if (isView) {
      int temp = _shop.id;
      if (setShopId) _shop.id = -1;
      Navigator.push(context, MaterialPageRoute(builder: (context) =>
          ProductDetailPage(item, _shop)
      )).then((value) => _getValueFromDetail(value)).whenComplete(() => _shop.id = temp);
      Util.trackActivities('products', path: 'List Product Favorite Screen -> Show Detail -> ${item.title}');
    }
  }

  _getValueFromDetail(value) {
    //if (value != null && value == 'delete' && reloadList != null) reloadList!();
    if (reloadHighlight != null) reloadHighlight!();
  }

  _addRemoveFavorite(BuildContext context) async {
    if (Constants().isLogin) {
      if (await UtilUI().alertVerifyPhone(context)) return;
      item.is_favourite ? {
        _bloc.add(RemoveFavoriteEvent(item.favourite_id, context)),
        Util.trackActivities('products', path: 'List Product Favorite Screen -> UnLike ${item.title}')
      }
      : _bloc.add(AddFavoriteEvent(item.classable_id, item.classable_type, context));
    } else if (loginOrCreateCallback != null) {
      loginOrCreateCallback!();
    } else {
      UtilUI.showCustomDialog(context, MultiLanguage.get(LanguageKey().msgLoginOrCreate));
    }
  }

  _handleResponseAddFavorite(AddFavoriteState state) {
    if (_handleResponse(state.context, state.response))
      _setFavorite(true, int.parse(state.response.data.id));
  }

  _handleResponseRemoveFavorite(RemoveFavoriteState state) {
    if (_handleResponse(state.context, state.response, passString: true)) _setFavorite(false, -1);
  }

  bool _handleResponse(BuildContext context, response, {bool passString = false}) {
    final BaseResponse tmp = response as BaseResponse;
    if (tmp.checkTimeout())
      UtilUI.showDialogTimeout(context);
    else if (tmp.checkOK(passString: passString))
      return true;
    else
      UtilUI.showCustomDialog(context, tmp.data).then((value) => print(value));
    return false;
  }

  _setFavorite(bool value, int id) {
    if (callback != null) callback?.removeFavourite();
    item.is_favourite = value;
    item.favourite_id = id;
    if (reloadHighlight != null) reloadHighlight!();
  }
}
