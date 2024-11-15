import 'dart:async';
import 'package:flutter/services.dart';
import 'package:hainong/common/import_lib_system.dart';
import 'package:hainong/common/ui/avatar_circle_widget.dart';
import 'package:hainong/common/ui/box_dec_custom.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/image_network_asset.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/features/main/bloc/main_bloc.dart';
import 'package:hainong/features/product/product_model.dart';
import 'package:hainong/features/product/ui/product_detail_page.dart';
import '../cart_model.dart';
import '../cart_bloc.dart';
import 'cart_page.dart';

class CartItem extends StatefulWidget {
  final CartModel item;
  final CartBloc bloc;
  final bool lock;
  const CartItem(this.bloc, this.item, {this.lock = false, Key? key}) :super(key: key);
  @override
  _CartItemState createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  bool _show = true, _hideAll = false;
  late StreamSubscription _stream;

  @override
  void dispose() {
    _stream.cancel();
    super.dispose();
  }

  @override
  void initState() {
    _stream = widget.bloc.stream.listen((state) {
      if (state is ChangeQtyState) {
        if (widget.item.getQuantity() == 0) {
          setState(() {
            _hideAll = true;
          });
        }
        BlocProvider.of<MainBloc>(context).add(CountCartMainEvent());
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_hideAll) return const SizedBox();
    return Container(decoration: BoxDecCustom(radius: 10),
      child: Column(children: [
        Container(child: Row(children: [
          /*Expanded(child: ButtonImageWidget(10, () {
            UtilUI.goToNextPage(context, ShopPage(isOwner: false, hasHeader: true, isView: true,
                shop: ShopModel(id: widget.item.shop_id, name: widget.item.seller_name, image: widget.item.seller_image)));
          }, Row(children: [*/
            AvatarCircleWidget(link: widget.item.seller_image, size: 100.sp),
            SizedBox(width: 20.sp),
            Expanded(child: LabelCustom('Shop: ' + widget.item.seller_name, color: Colors.black, size: 48.sp)),
          //]))),
          SizedBox(width: 20.sp),
          ButtonImageWidget(100, () => setState(() {_show = !_show;}),
              Icon(_show ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 64.sp, color: StyleCustom.primaryColor))
        ]), decoration: _show ? const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5))
        ) : null, padding: EdgeInsets.all(40.sp)),
        if (_show) ListView.separated(physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(40.sp, 40.sp, 40.sp, 0),
            shrinkWrap: true, itemCount: widget.item.items.length,
            separatorBuilder: (context, index) => SizedBox(height: 40.sp),
            itemBuilder: (context, index) => _ItemDtl(widget.bloc, widget.item.items[index], widget.item, widget.lock)),
        Divider(height: 80.sp, color: Colors.grey),
        BlocBuilder(bloc: widget.bloc, buildWhen: (oldS, newS) => newS is ChangeQtyState && widget.item.coupon != null,
          builder: (context, state) => widget.item.coupon != null ?
          Padding(child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            LabelCustom('Mã giảm giá: ', color: Colors.black, size: 46.sp, weight: FontWeight.normal),
            LabelCustom(widget.item.coupon!, color: Colors.red, size: 46.sp, weight: FontWeight.normal)
          ]), padding: EdgeInsets.only(bottom: 20.sp, right: 40.sp)) : const SizedBox()),
        Padding(child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          LabelCustom('Tổng: ', color: Colors.black, size: 42.sp, weight: FontWeight.normal),
          BlocBuilder(bloc: widget.bloc, buildWhen: (oldS, newS) => newS is ChangeQtyState,
            builder: (context, state) => LabelCustom(Util.doubleToString(widget.item.getPaymentTotal()) + ' đ',
                color: Colors.red, size: 46.sp))
        ]), padding: EdgeInsets.only(bottom: 40.sp, right: 40.sp))
      ]), margin: EdgeInsets.only(bottom: 40.sp));
  }
}

class _ItemDtl extends StatefulWidget {
  final CartDtlModel item;
  final CartBloc bloc;
  final CartModel shop;
  final bool lock;
  const _ItemDtl(this.bloc, this.item, this.shop, this.lock, {Key? key}) :super(key: key);
  @override
  _ItemDtlState createState() => _ItemDtlState();
}

class _ItemDtlState extends State<_ItemDtl> {
  final TextEditingController ctr = TextEditingController();
  final FocusNode fc = FocusNode();
  late StreamSubscription _stream;

  @override
  void dispose() {
    _stream.cancel();
    ctr.dispose();
    fc.removeListener(_listener);
    fc.dispose();
    super.dispose();
  }

  @override
  void initState() {
    ctr.text = widget.item.quantity.toInt().toString();
    _stream = widget.bloc.stream.listen((state) {
      if (state is ChangeQtyState && widget.item.quantity == 0) setState(() {});
    });
    super.initState();
    fc.addListener(_listener);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item.quantity == 0) return const SizedBox();
    final temp = ButtonImageWidget(5, _gotoProDetail, Row(crossAxisAlignment: CrossAxisAlignment.start,children: [
      ClipRRect(borderRadius: BorderRadius.circular(5), child: ImageNetworkAsset(path: widget.item.image, width: 120.sp, height: 120.sp, scale: 0.5)),
      SizedBox(width: 20.sp),
      Expanded(child: Column(children: [
        Padding(padding: EdgeInsets.only(right: 60.sp),
            child: LabelCustom(widget.item.product_name, color: Colors.black, size: 48.sp, weight: FontWeight.normal)),
        SizedBox(height: 20.sp),
        widget.lock ? Row(children: [
            LabelCustom('x' + Util.doubleToString(widget.item.quantity), color: Colors.black, size: 46.sp, weight: FontWeight.normal),
            if (widget.item.unit_name.isNotEmpty) Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 20.sp),
                child: LabelCustom(widget.item.unit_name, color: Colors.black, size: 46.sp, weight: FontWeight.normal))),
            if (widget.item.referral_code.isEmpty) LabelCustom(Util.doubleToString(widget.item.price * widget.item.quantity) + ' đ', color: Colors.red, size: 46.sp)
            else Flexible(child: Wrap(children: [
              LabelCustom(Util.doubleToString(widget.item.price) + ' đ', color: const Color(0xFFA4A4A4), decoration: TextDecoration.lineThrough, size: 46.sp),
              SizedBox(width: 20.sp,),
              LabelCustom(Util.doubleToString(calculateReducePrice(widget.item)) + ' đ', color: Colors.red, size: 46.sp),
            ]))
          ], mainAxisAlignment: MainAxisAlignment.spaceBetween)
        : Column(children: [
            Wrap(children:
                widget.item.referral_code.isEmpty ? [
                  LabelCustom(Util.doubleToString(widget.item.price) + ' đ', color: Colors.red, size: 46.sp),
                ] : [
                  LabelCustom(Util.doubleToString(widget.item.price) + ' đ', color: const Color(0xFFA4A4A4), decoration: TextDecoration.lineThrough, size: 46.sp),
                  SizedBox(width: 20.sp),
                  LabelCustom(Util.doubleToString(calculateReducePrice(widget.item)) + ' đ', color: Colors.red, size: 46.sp),
                ]
            ),
            SizedBox(height: 20.sp),
            Row(children: [
              SizedBox(width: 0.25.sw, child: TextField(textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.black, fontSize: 40.sp),
                  maxLines: 1, controller: ctr, focusNode: fc,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                      filled: true, isDense: true,
                      contentPadding: EdgeInsets.all(20.sp),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5), borderSide:
                      const BorderSide(color: StyleCustom.borderTextColor, width: 0.5)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5), borderSide:
                      const BorderSide(color: StyleCustom.primaryColor, width: 0.5))
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'\d*'))
                  ])),
              if (widget.item.unit_name.isNotEmpty) Flexible(child: Padding(padding: EdgeInsets.only(left: 20.sp),
                child: LabelCustom(widget.item.unit_name, color: Colors.black, size: 46.sp, weight: FontWeight.normal)))
            ], mainAxisAlignment: MainAxisAlignment.end)
          ], mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start)
      ], crossAxisAlignment: CrossAxisAlignment.start))
    ]));
    return widget.lock ? temp : Stack(children: [
      temp,
      ButtonImageWidget(100, _delete, Container(padding: EdgeInsets.all(10.sp), margin: EdgeInsets.all(6.sp),
        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(100)),
        child: Icon(Icons.clear, size: 36.sp, color: Colors.white)))
    ], alignment: Alignment.topRight);
  }

  void _listener() {
    if (!fc.hasFocus) {
      double temp = 0;
      try {
        temp = double.parse(ctr.text);
      } catch (_) {}
      if (temp == 0) {
        temp = 1;
        ctr.text = '1';
      }
      widget.item.quantity = temp;
      _addQty();
    }
  }

  void _delete() {
    widget.item.quantity = 0;
    _addQty();
  }

  double calculateReducePrice(CartDtlModel item) => item.price - Util.reducePrice(item);

  void _addQty() => widget.bloc.add(ChangeQtyEvent(widget.shop, widget.item, clearCoupon: true));

  void _gotoProDetail() async {
    if (!widget.lock) return;
    final pro = ProductModel(id: widget.item.product_id);
    UtilUI.goToNextPage(context, ProductDetailPage(pro, await Util.getShop()));
  }
}

class CartNumber extends StatelessWidget {
  const CartNumber({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Padding(child:
    ButtonImageWidget(100, () => UtilUI.goToNextPage(context, CartPage()),
      BlocBuilder(bloc: BlocProvider.of<MainBloc>(context),
        buildWhen: (oldS, newS) => newS is CountCartMainState,
        builder: (context, state) {
            final temp = Icon(Icons.shopping_cart, color: Colors.white, size: 56.sp);
            int count = 0;
            if (state is CountCartMainState) count = state.value;
            return count > 0 ? Stack(children: [
              temp,
              Container(width: 50.sp, height: 50.sp, margin: EdgeInsets.only(bottom: 40.sp, left: 40.sp),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.red,
                      borderRadius: BorderRadius.circular(100)),
                  child: Text(count < 100 ? count.toString() : '99+',
                      style: TextStyle(color: Colors.white, fontSize: 20.sp)))
            ], alignment: Alignment.center) : temp;
        })), padding: EdgeInsets.symmetric(horizontal: 40.sp));
}