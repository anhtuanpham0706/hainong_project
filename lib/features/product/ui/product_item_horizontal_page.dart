import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/ui/image_network_asset.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/button_image_circle_widget.dart';
import 'package:hainong/common/ui/divider_widget.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/my_tooltip.dart';
import 'package:hainong/common/ui/shadow_decoration.dart';
import 'package:hainong/features/login/login_page.dart';
import 'package:hainong/features/product/ui/product_page.dart';
import '../bloc/product_list_horizontal_bloc.dart';
import 'product_detail_page.dart';
import 'package:hainong/features/shop/shop_model.dart';
import '../product_model.dart';

abstract class ProductItemHorizontalCallback {
  addRemoveFavourite(bool value, int favouriteId, int productId);
}

class ProductItemHorizontalPage extends StatelessWidget {
  final ProductModel _item;
  final ShopModel _shop;
  final double width;
  final Function? loginOrCreateCallback;
  final ProListHorBloc _bloc = ProListHorBloc(ProListHorState());
  final int idBusiness;
  final ProductItemHorizontalCallback? callback;

  ProductItemHorizontalPage(this._item, this._shop, this.width,
      {Key? key, this.loginOrCreateCallback, this.callback, this.idBusiness = -1}) : super(key: key) {
    _bloc.stream.listen((state) {
      if (state is AddFavoriteState) _handleResponseAddFavorite(state);
      else if (state is RemoveFavoriteState) _handleResponseRemoveFavorite(state);
    });
  }

  @override
  Widget build(BuildContext context) {
    final temp = Container(width: width, height: 0.36.sh, decoration: ShadowDecoration(opacity: 0.15),
        margin: EdgeInsets.all(20.sp), child: OutlinedButton(
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.transparent), padding: EdgeInsets.zero),
            onPressed: () => _goToDetail(context),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _item.images.list.isEmpty || _item.images.list[0].name.isEmpty ? UtilUI.imageDefault(width: width) :
              ImageNetworkAsset(path: _item.images.list[0].name, scale: 1, cache: true, rateCache: 2, width: width)),
              if (_item.shop.prestige == 10) Padding(padding: EdgeInsets.only(right: 10.sp, bottom: 10.sp),
                  child: Image.asset('assets/images/v8/ic_prestige.png', width: 64.sp)),
              Padding(padding: EdgeInsets.all(20.sp), child: LabelCustom(_item.title, size: 45.sp, color: Colors.black87, overflow: TextOverflow.ellipsis)),
              Container(padding: EdgeInsets.only(top: 10.sp, left: 20.sp, right: 20.sp), child: Row(children: [
                Expanded(child: Text(Util.getTimeAgo(_item.updated_at), style: TextStyle(fontSize: 30.sp, color: Colors.blueAccent))),
                idBusiness > 0 ? const SizedBox() : ButtonImageCircleWidget(50.sp, () => _addRemoveFavorite(context), child: _createFavorite())
              ])),
              Container(padding: EdgeInsets.symmetric(horizontal: 20.sp), child: Row(children: [
                Icon(Icons.location_on,size: 30.sp,color: Colors.black87,),
                SizedBox(width: 10.sp,),
                Expanded(child: LabelCustom(_item.shop.province_name, size: 35.sp, color: Colors.black87, overflow: TextOverflow.ellipsis))
              ])),
              // Container(padding: EdgeInsets.symmetric(horizontal: 20.sp),
              //   alignment: Alignment.centerLeft,
              //   child: Wrap(children: [
              //       UtilUI.createLabel('SL:', color: Colors.black, fontSize: 35.sp, fontWeight: FontWeight.normal),
              //     Padding(padding: EdgeInsets.symmetric(horizontal: 10.sp),
              //           child: UtilUI.createLabel(Util.doubleToString(_item.quantity,
              //               locale: Constants().localeVILang), color: Colors.black, fontSize: 35.sp)),
              //       UtilUI.createLabel(_item.unit_name, color: Colors.black, fontSize: 35.sp, fontWeight: FontWeight.normal)
              // ])),
              DividerWidget(margin: EdgeInsets.only(top: 20.sp)),
              /*Row(children: [
                Expanded(child: _createPriceUI(MultiLanguage.get(languageKey.lblWholesalePrice),
                        _item.wholesale_price, const Border(right: BorderSide(color: Colors.black12, width: 0.5)))),
                Expanded(child: _createPriceUI(MultiLanguage.get(languageKey.lblRetailPrice), _item.retail_price, null))
              ])*/
              _createPriceUI(MultiLanguage.get(LanguageKey().lblRetailPrice), _item.retail_price, null)
            ])));
    if (_item.shop.prestige == 0) return temp;
    return Stack(children: [
      temp,
      Padding(padding: EdgeInsets.only(left: 30.sp, top: 30.sp),
          child: Image.asset('assets/images/v8/ic_prestige.png', width: 64.sp))
    ]);
  }

  Widget _createPriceUI(String title, double price, Border? border) {
    final unit = _item.unit_name.isEmpty ? ' đ' : ' đ/${_item.unit_name}';
    final temp = Util.doubleToString(price, locale: Constants().localeVILang) + unit;
    return Container(
        decoration: BoxDecoration(border: border), padding: EdgeInsets.all(20.sp),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 30.sp, color: Colors.black87)),
          price > 0 ? MyTooltip(temp, UtilUI.createLabel(temp, color: Colors.deepOrange, overflow: TextOverflow.ellipsis)) :
          UtilUI.createLabel(MultiLanguage.get(LanguageKey().lblAboutUs), color: Colors.deepOrange, overflow: TextOverflow.ellipsis)
        ]));
  }

  Widget _createFavorite() => BlocBuilder(
      bloc: _bloc,
      buildWhen: (state1, state2) =>
          state2 is AddFavoriteState || state2 is RemoveFavoriteState,
      builder: (context, state) => Image.asset(
          _item.is_favourite ? 'assets/images/ic_love_fill.png' : 'assets/images/ic_love_outline.png',
          height: 50.sp, width: 50.sp));

  _goToDetail(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) =>
        idBusiness > 0 ? ProductPage(product: _item, isCreate: false, idBusiness: idBusiness) : ProductDetailPage(_item, _shop))).then((value) => _getValueFromDetail(value));
    Util.trackActivities('products', path: 'List Product Favorite Screen -> Show Detail -> ${_item.title}');
  }

  _getValueFromDetail(value) => callback?.addRemoveFavourite(true, -1, -1);

  _addRemoveFavorite(BuildContext context) async {
    if (Constants().isLogin) {
      if (await UtilUI().alertVerifyPhone(context)) return;
      if (_item.is_favourite)
        _bloc.add(RemoveFavoriteEvent(_item.favourite_id, context));
      else
        _bloc.add(AddFavoriteEvent(_item.classable_id, _item.classable_type, context));
    } else if (loginOrCreateCallback != null) loginOrCreateCallback!();
    else {
      UtilUI.showCustomDialog(context, MultiLanguage.get(LanguageKey().msgLoginOrCreate));
    }
  }

  _handleResponseAddFavorite(AddFavoriteState state) {
    if (_handleResponse(state.context, state.response)) _setFavorite(true, int.parse(state.response.data.id));
  }

  _handleResponseRemoveFavorite(RemoveFavoriteState state) {
    if (_handleResponse(state.context, state.response, passString: true)) _setFavorite(false, -1);
  }

  bool _handleResponse(BuildContext context, response, {bool passString = false}) {
    final BaseResponse tmp = response as BaseResponse;
    if (tmp.checkTimeout())
      _timeout(context);
    else if (tmp.checkOK(passString: passString))
      return true;
    else
      UtilUI.showCustomDialog(context, tmp.data).then((value) => print(value));
    return false;
  }

  _setFavorite(bool value, int id) {
    _item.is_favourite = value;
    _item.favourite_id = id;
    if (callback != null) callback!.addRemoveFavourite(value, id, _item.id);
  }

  _timeout(BuildContext context) {
    UtilUI.showCustomDialog(context, MultiLanguage.get(LanguageKey().msgAnotherLogin))
        .then((value) => Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => LoginPage())));
  }
}
