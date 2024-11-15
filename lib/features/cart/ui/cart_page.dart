import 'dart:convert';
//import 'package:hainong/common/database_helper.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/measured_size.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import 'package:hainong/features/discount_code/dis_code_list_page.dart';
import 'package:hainong/features/function/tool/nutrition_map/nutrition_location_page.dart';
import 'package:hainong/features/login/login_page.dart';
import 'package:hainong/features/main/bloc/main_bloc.dart';
import 'package:hainong/features/order_history/order_history_page.dart';
import '../cart_model.dart';
import '../cart_bloc.dart';
import 'cart_item.dart';

class CartPage extends BasePage {
  CartPage({Key? key}) : super(pageState: _CartPageState(), key: key);
}

class _CartPageState extends BasePageState {
  final TextEditingController _ctrName = TextEditingController(),
    _ctrPhone = TextEditingController(), _ctrEmail = TextEditingController(),
    _ctrAddress = TextEditingController();
  final FocusNode _fcName = FocusNode(), _fcPhone = FocusNode(),
      _fcEmail = FocusNode(), _fcAddress = FocusNode();
  final Map<int, CartModel> _cart = {};
  final colorItem = const Color(0XFFF5F6F8);
  final require = LabelCustom(' (*)', color: Colors.red, size: 36.sp, weight: FontWeight.normal);
  bool _isEmpty = true;
  dynamic _coupon, _countCart, _totals;//, _countCoupon;

  @override
  void dispose() {
    _ctrName.dispose();
    _fcName.dispose();
    _ctrPhone.dispose();
    _fcPhone.dispose();
    _ctrEmail.dispose();
    _fcEmail.dispose();
    _ctrAddress.dispose();
    _fcAddress.dispose();
    _cart.clear();
    super.dispose();
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((value) {
      _cart.putIfAbsent(-1, () => CartModel());
      _cart.addAll(Util.getCarts(value));
      _getAll();
      setState(() {
        if (_cart.length > 1) _isEmpty = false;
      });
      _setInfo(value);
    });
    bloc = CartBloc();
    bloc!.stream.listen((state) {
      if (state is ChangeQtyState) {
        if (state.clearCoupon != null && _coupon != null) _clearCoupon();
        if (_getQuantity() == 0) {
          if (_coupon != null) _clearCoupon();
          setState(() => _isEmpty = true);
        }
        _getAll();
      } if (state is GetLocationState) {
        final json = state.response.data;
        if (Util.checkKeyFromJson(json, 'address_full')) {
          _ctrAddress.text = json['address_full'];
          _saveInfo();
        }
      } else if (state is CreateOrderState) _handleCreateOrder(state);
      else if (state is LoadOrderDtlState && isResponseNotError(state.resp)) _checkOrder(state.resp.data);
    });
    super.initState();
    _fcName.addListener(_listener);
    _fcPhone.addListener(_listener);
    _fcEmail.addListener(_listener);
    _fcAddress.addListener(_listener);
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Scaffold(appBar: AppBar(titleSpacing: 0,
      centerTitle: true, elevation: 2, title: UtilUI.createLabel('Giỏ hàng')), backgroundColor: color,
    body: GestureDetector(onTapDown: (_) => clearFocus(), child: Stack(children: [createUI(), Loading(bloc)])));

  @override
  Widget createUI() => Container(width: 1.sw, padding: EdgeInsets.all(40.sp), child: Column(children: [
      if (!_isEmpty) Expanded(child: ListView.builder(padding: EdgeInsets.zero,
        itemCount: _cart.length,
        itemBuilder: (context, index) {
          if (index > 0) return CartItem((bloc as CartBloc), _cart.values.elementAt(index));
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [_title('Họ tên'), require]),
            Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
                child: TextFieldCustom(_ctrName, _fcName, _fcPhone, 'Nhập họ tên',
                    size: 42.sp, color: colorItem, borderColor: colorItem,
                    padding: EdgeInsets.all(30.sp))),

            Row(children: [
              Expanded(child: Column(children: [
                Row(children: [_title('Số ĐT'), require]),
                Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
                    child: TextFieldCustom(_ctrPhone, _fcPhone, _fcEmail, 'Nhập số điện thoại',
                        size: 42.sp, color: colorItem, borderColor: colorItem,
                        type: TextInputType.phone, padding: EdgeInsets.all(30.sp))),
              ])),
              SizedBox(width: 20.sp),
              Expanded(child: Column(children: [
                _title('Email'),
                Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
                    child: TextFieldCustom(_ctrEmail, _fcEmail, _fcAddress, 'Nhập email',
                        size: 42.sp, color: colorItem, borderColor: colorItem,
                        type: TextInputType.emailAddress, padding: EdgeInsets.all(30.sp))),
              ], crossAxisAlignment: CrossAxisAlignment.start))
            ]),

            Row(children: [_title('Địa chỉ'), require]),
            Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp), child: Row(children: [
              Expanded(child: TextFieldCustom(_ctrAddress, _fcAddress, null, 'Nhập địa chỉ', size: 42.sp, color: colorItem,
                  borderColor: colorItem, maxLine: 0, padding: EdgeInsets.all(30.sp),
                  inputAction: TextInputAction.newline, type: TextInputType.multiline)),
              SizedBox(width: 32.sp),
              ButtonImageWidget(5, _openMap, Image.asset('assets/images/v5/ic_map_main2.png',
                  width: 128.sp, height: 128.sp, fit: BoxFit.scaleDown))
            ])),

            Row(children: [
              LabelCustom('Mã giảm giá: ', color: Colors.black, size: 42.sp, weight: FontWeight.w400),
              ButtonImageWidget(0, _openCouponList, Image.asset('assets/images/v8/ic_dis_code.png', color: Colors.black, height: 56.sp))
            ]),
            SizedBox(height: 40.sp)
          ]);
        }
      )),
      _totalPaymentWidget(),
      BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is ChangeQtyState,
        builder: (context, state) {
          if (_isEmpty) {
                return Column(children: [
                  Icon(Icons.shopping_cart_outlined, size: 200.sp, color: const Color(0xFFCDCDCD)),
                  LabelCustom('Giỏ hàng đang trống', size: 64.sp, color: const Color(0xFFCDCDCD), weight: FontWeight.normal)
                ]);
          }
          return ButtonImageWidget(16.sp, _createOrder, Container(padding: EdgeInsets.all(40.sp),
              width: 1.sw - 80.sp, child: LabelCustom('Tạo đơn hàng',
                  color: Colors.white, size: 48.sp, weight: FontWeight.normal,
                  align: TextAlign.center)), color: StyleCustom.primaryColor);
        }),
    ], mainAxisAlignment: MainAxisAlignment.center));

  Widget _title(String title) => LabelCustom(title, color: const Color(0xFF787878), size: 36.sp, weight: FontWeight.normal);

  Widget _totalPaymentWidget() => _isEmpty ? const SizedBox() :
    Padding(child: BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is ChangeQtyState,
      builder: (context, state) {
        return _totals != null ? Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            LabelCustom('Tổng tiền: ', color: Colors.black, size: 42.sp, weight: FontWeight.normal),
            MeasuredSize(child: LabelCustom(Util.doubleToString(_totals[0]) + ' đ', color: Colors.black87, size: 46.sp),
                onChange: (size) => bloc!.add(ChangeSizeEvent(type: 'total', width: size.width)))
          ]),
          if (_coupon != null) Padding(child: Row(mainAxisAlignment: MainAxisAlignment.end,
              children: [
                LabelCustom('Giảm giá: ', color: Colors.black, size: 42.sp, weight: FontWeight.normal),
                SpaceCartOrder(bloc, 'dis'),
                MeasuredSize(child: LabelCustom('-' + Util.doubleToString(_totals[1]) + ' đ', color: Colors.red, size: 46.sp),
                    onChange: (size) => bloc!.add(ChangeSizeEvent(type: 'dis', width: size.width)))
              ]), padding: EdgeInsets.only(top: 10.sp)),
          SizedBox(height: 10.sp),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            LabelCustom('Thanh toán: ', color: Colors.black, size: 42.sp, weight: FontWeight.normal),
            SpaceCartOrder(bloc, 'pay'),
            MeasuredSize(child: LabelCustom(Util.doubleToString(_totals[2]) + ' đ', color: Colors.red, size: 46.sp),
                onChange: (size) => bloc!.add(ChangeSizeEvent(type: 'pay', width: size.width)))
          ])
        ]) : const SizedBox();
      }), padding: EdgeInsets.symmetric(vertical: 40.sp));

  void _listener() {
    if (!_fcName.hasFocus || !_fcPhone.hasFocus ||
        !_fcEmail.hasFocus || !_fcAddress.hasFocus) _saveInfo();
  }

  void _saveInfo() => SharedPreferences.getInstance().then((prefs) {
    prefs.setString('cart_info', jsonEncode({
      "name": _ctrName.text,
      "phone": _ctrPhone.text,
      "email": _ctrEmail.text,
      "address": _ctrAddress.text
    }));
  });

  void _setInfo(SharedPreferences prefs) {
    final cartInfo = prefs.getString('cart_info')??'';
    if (cartInfo.isNotEmpty) {
      final json = jsonDecode(cartInfo);
      _ctrName.text = json['name'];
      _ctrPhone.text = json['phone'];
      _ctrEmail.text = json['email'];
      _ctrAddress.text = json['address'];
    } else {
      _ctrName.text = prefs.getString('name')??'';
      _ctrPhone.text = prefs.getString('phone')??'';
      _ctrEmail.text = prefs.getString('email')??'';

      _ctrAddress.text = prefs.getString('address')??'';
      String temp = '', temp2 = prefs.getString('district_name')??'';
      if (temp2.isNotEmpty) temp = ', ' + temp2;
      temp2 = prefs.getString('province_name')??'';
      if (temp2.isNotEmpty) temp += ', ' + temp2;
      _ctrAddress.text += temp;
    }

    /*if (_cart.length > 1) {
      DBHelper().getAllJsonWithCond('coupon').then((values) {
        if (values != null && values.isNotEmpty) _setCoupon(values.first);
      });
    }*/
  }

  void _setCoupon(value) {
    _coupon ??= {};
    _coupon.addAll(value);
    bloc!.add(ChangeQtyEvent(CartModel(), CartDtlModel()));
  }

  void _clearCoupon({bool hasSetState = false}) {
    _cart.forEach((key, value) => value.coupon = null);
    _coupon?.clear();
    _coupon = null;
    if (hasSetState) {
      _getAll();
      setState(() {});
    }
    //DBHelper().clearTable('coupon');
  }

  void _openMap() => UtilUI.goToNextPage(context, NutritionLocPage(), funCallback: (value) {
    if (value != null) bloc!.add(GetLocationEvent(value.latitude.toString(), value.longitude.toString()));
  });

  void _getAll() {
    if (_totals != null) {
      _totals.clear();
      _totals = null;
    }

    double total = 0, discount = 0, temp, tempDis, max;
    int count = 0;
    if (_coupon != null) count = (_coupon['quantity']??0x7FFFFFFFFFFFFFFF) - (_coupon['invoice_users_count']??0);

    for(int i = _cart.length - 1; i > 0; i--) {
      temp = _cart.values.elementAt(i).getPaymentTotal();
      total += temp;
      if (temp > 0) {
        if (count > 0 && _existsCoupon(_cart.keys.elementAt(i))) {
          tempDis = (_coupon['value'] ?? .0).toDouble();
          if (_coupon['coupon_type'] != 'money') {
            max = _coupon['max_value'] ?? .0;
            tempDis = temp * tempDis / 100;
            if (tempDis > max && max > 0) tempDis = max;
          }
          discount += tempDis;
          count --;
        }
      }
    };

    if (discount > total) discount = total;
    _totals = [total, discount, total - discount];
  }

  bool _existsCoupon(int key) {
    final CartModel cart = _cart[key]!;
    for(var ele in _coupon['shop_ids']) {
      if (cart.shop_id == ele) {
        cart.coupon = _coupon['coupon_code'];
        return true;
      }
    }
    return false;
  }

  double _getQuantity() {
    double total = 0;
    _cart.forEach((key, value) => total += value.getQuantity());
    return total;
  }

  void _checkOrder(data) {
    int count = data['invoice_users_count']??0, coupon = _coupon['invoice_users_count']??0;
    if (coupon == count) _createOrder(checkCoupon: false);
    else if (count == (_coupon['quantity']??0x7FFFFFFFFFFFFFFF)) {
      UtilUI.showCustomDialog(context, 'Số lượng mã giảm giá hiện tại đã hết.'
          '\nHãy chọn mã giảm giá khác để áp dụng vào đơn hàng.').whenComplete(() => _clearCoupon(hasSetState: true));
    } else if (coupon < count) {
      UtilUI.showCustomDialog(context, 'Số lượng mã giảm giá đang áp dụng có thay đổi (ít hơn so với hiện tại).'
          '\nHãy chọn lại mã giảm giá để áp dụng vào đơn hàng.').whenComplete(() => _clearCoupon(hasSetState: true));
    } else _createOrder(checkCoupon: false);
  }

  void _createOrder({bool checkCoupon = true}) {
    if (!constants.isLogin) {
      UtilUI.showCustomDialog(context, MultiLanguage.get(LanguageKey().msgLoginOrCreate)).whenComplete(() {
        UtilUI.logout();
        UtilUI.clearAllPages(context);
        UtilUI.goToPage(context, LoginPage(), null);
      });
      return;
    }

    if (_ctrName.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, 'Nhập họ tên').whenComplete(() => _fcName.requestFocus());
      return;
    }
    if (_ctrPhone.text.trim().length < 10) {
      UtilUI.showCustomDialog(context, 'Nhập số điện thoại đầy đủ').whenComplete(() => _fcPhone.requestFocus());
      return;
    }
    if (_ctrAddress.text.trim().length < 10) {
      UtilUI.showCustomDialog(context, 'Nhập địa chỉ đầy đủ').whenComplete(() => _fcAddress.requestFocus());
      return;
    }

    final List<CartModel> list = [];
    for (var shop in _cart.values) {
      if (shop.shop_id > 0 && shop.items.isNotEmpty && shop.getQuantity() > 0) list.add(shop);
    }
    _countCart = list.length;

    if (checkCoupon && _coupon != null && _coupon['quantity'] != null) {
      bloc!.add(LoadOrderDtlEvent(_coupon!['id'], false));
      return;
    }

    if (list.isNotEmpty) bloc!.add(CreateOrderEvent(list, _ctrName.text, _ctrPhone.text, _ctrEmail.text, _ctrAddress.text, _coupon));
  }

  void _handleCreateOrder(CreateOrderState state) {
    if (state.cart.isEmpty) {
      _clearCoupon();
      _isEmpty = true;
      setState(() {});
      BlocProvider.of<MainBloc>(context).add(CountCartMainEvent());
      UtilUI.showCustomDialog(context, 'Đặt hàng thành công',
          title: 'Thông báo').whenComplete(() {
        UtilUI.goBack(context, false);
        UtilUI.goToNextPage(context, OrderHistoryPage());
      });
    } else {
      String msg = 'Bạn chưa tạo xong đơn hàng cho shop:';
      //if (state.cart.isNotEmpty) {
      _cart.clear();
      _cart.putIfAbsent(-1, () => CartModel());
      for (int i = 0; i < state.cart.length; i++) {
        msg += '\n- ' + state.cart[i].seller_name;
        _cart.putIfAbsent(state.cart[i].shop_id, () => state.cart[i]);
      }
      if (_countCart != null && state.cart.length - 1 != _countCart) _clearCoupon(hasSetState: true);
      //}
      msg += '\nVui lòng thực hiện tạo đơn hàng lại cho shop trên';
      UtilUI.showCustomDialog(context, msg, alignMessageText: TextAlign.left);
      setState(() {});
    }
    _countCart = null;
  }

  void _openCouponList() {
    final List temp = [];
    final list = _cart.values;
    dynamic ele;
    for (int i = list.length - 1; i > 0; i--) {
      ele = list.elementAt(i);
      ele.coupon = null;
      temp.add([ele.shop_id, ele.getPaymentTotal()]);
    }
    UtilUI.goToNextPage(context, DisCodeListPage(hasSelect: true, shops: temp), funCallback: (value) => _setCoupon(value));
  }
}