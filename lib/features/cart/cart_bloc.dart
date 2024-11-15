import 'dart:convert';
import 'package:hainong/features/function/info_news/news/news_bloc.dart';
export 'package:hainong/features/function/info_news/news/news_bloc.dart';
import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/import_lib_system.dart';
import 'cart_model.dart';
import '../main/bloc/main_bloc.dart';
import '../profile/point_bloc.dart';

class ChangeQtyEvent extends BaseEvent {
  final CartModel shop;
  final CartDtlModel item;
  final bool? clearCoupon;
  ChangeQtyEvent(this.shop, this.item, {this.clearCoupon});
}
class ChangeQtyState extends BaseState {
  final bool? clearCoupon;
  ChangeQtyState({this.clearCoupon});
}

class CreateOrderEvent extends BaseEvent {
  final List<CartModel> cart;
  final String name, phone, email, address;
  final dynamic coupon;
  CreateOrderEvent(this.cart, this.name, this.phone, this.email, this.address, this.coupon);
}
class CreateOrderState extends BaseState {
  final List<CartModel> cart;
  CreateOrderState(this.cart);
}

class LoadOrderDtlEvent extends BaseEvent {
  final int id, idBusiness;
  final bool isMine;
  LoadOrderDtlEvent(this.id, this.isMine, {this.idBusiness = -1});
}
class LoadOrderDtlState extends BaseState {
  final BaseResponse resp;
  LoadOrderDtlState(this.resp);
}

class SetStatusOrderEvent extends BaseEvent {
  final int id, idBusiness;
  final String status;
  final bool isMine;
  SetStatusOrderEvent(this.id, this.status, this.isMine, {this.idBusiness = -1});
}
class SetStatusOrderState extends BaseState {
  final BaseResponse resp;
  final String status;
  SetStatusOrderState(this.resp, this.status);
}

class ChangeSizeEvent extends BaseEvent {
  final String? type;
  final double? width;
  ChangeSizeEvent({this.type, this.width});
}
class ChangeSizeState extends BaseState {
  final double? total, dis, pay;
  ChangeSizeState({this.total, this.dis, this.pay});
}

class CartBloc extends BaseBloc {
  double? wTotal, wDis, wPay;
  CartBloc({String type = 'cart'}) {
    if (type == 'cart' || type == 'detail') {
      wTotal = wDis = wPay = 0;
      on<ChangeSizeEvent>((event, emit) {
        switch(event.type) {
          case 'total': wTotal = event.width; break;
          case 'dis':
            wDis = event.width;
            if ((wTotal??.0) < (wDis??.0)) wDis = wTotal;
            break;
          case 'pay':
            wPay = event.width;
            if ((wTotal??.0) < (wPay??.0)) wPay = wTotal;
        }
        emit(ChangeSizeState(total: .0,
            dis: wTotal == 0 ? 0 : ((wTotal??.0) - (wDis??.0)),
            pay: wTotal == 0 ? 0 : ((wTotal??.0) - (wPay??.0))));
      });
    }

    if (type == 'cart') {
      on<ChangeQtyEvent>((event, emit) {
        if (event.shop.shop_id > 0) Util.addCart(event.shop, event.item, {}, false);
        emit(ChangeQtyState(clearCoupon: event.clearCoupon));
      });
      on<GetLocationEvent>((event, emit) async {
        final resp = await ApiClient().getAPI2(
            '${Constants().apiVersion}locations/address_full?lat=${event
                .lat}&lng=${event.lon}', hasHeader: false);
        if (resp.isNotEmpty) {
          dynamic json = jsonDecode(resp);
          if (Util.checkKeyFromJson(json, 'success') && json['success'] &&
              Util.checkKeyFromJson(json, 'data')) emit(GetLocationState(BaseResponse(success: true, data: json['data'])));
        }
      });
      on<CreateOrderEvent>((event, emit) async {
        emit(const BaseState(isShowLoading: true));
        String params = 'name=${event.name}&phone_number=${event.phone}&shipping_address=${event.address}&payment_type=Tiền mặt&shop_id=';
        if (event.email.isNotEmpty) params = 'email=' + event.email + '&' + params;
        String paramItems = '';
        for (var shop in event.cart) {
          paramItems = '';
          for (var item in shop.items) {
            if (item.quantity > 0) {
              paramItems += '&items[][unit_name]=${item.unit_name}&items[][product_id]=${item.product_id}'
                '&items[][quantity]=${item.quantity.toInt()}&items[][referral_code]='+item.referral_code;
            }
          }
          if (shop.coupon != null) paramItems += '&coupon_code=' + shop.coupon!;

          final resp = await ApiClient().postAPI(Constants().apiVersion + 'invoice_users?$params${shop.shop_id}$paramItems', 'POST', OrderModel());
          if (resp.checkOK()) {
            shop.id = resp.data.id;
            shop.items.clear();
          }
        }

        event.cart.removeWhere((value) => value.id > 0 || value.items.isEmpty || value.getTotal() == 0);
        final prefs = await SharedPreferences.getInstance();
        event.cart.isEmpty ? prefs.remove('carts') : prefs.setString('carts', jsonEncode(event.cart));

        emit(CreateOrderState(event.cart));
      });
      on<LoadOrderDtlEvent>((event, emit) async {
        emit(const BaseState(isShowLoading: true));
        final resp = await ApiClient().getData('coupons/' + event.id.toString(), getError: true);
        bool success = resp != null;
        emit(LoadOrderDtlState(BaseResponse(success: success, data: success ? resp : resp['error'])));
      });
      return;
    }
    if (type == 'list') {
      on<ChangeTabEvent>((event, emit) => emit(ChangeTabState()));
      on<ChangeStatusManageEvent>((event, emit) => emit(ChangeStatusManageState()));
      on<GetPointListEvent>((event, emit) async {
        emit(const BaseState(isShowLoading: true));
        String path = 'invoice_users${event.tab == 'client' ? '/shop' : ''}?';
        if (event.idBusiness > 0) path = 'business/business_associations/${event.idBusiness}/invoices?';
        final resp = await ApiClient().getAPI(Constants().apiVersion +
            '${path}page=${event.page}&limit=20&status=${event.status}', OrdersModel());
        emit(GetPointListState(resp));
      });
      return;
    }
    if (type == 'detail') {
      on<LoadOrderDtlEvent>((event, emit) async {
        emit(const BaseState(isShowLoading: true));
        String path = 'invoice_users/${event.isMine ? '' : 'shop/'}${event.id}';
        if (event.idBusiness > 0) path = 'business/business_associations/${event.idBusiness}/invoices/${event.id}';
        final resp = await ApiClient().getAPI(Constants().apiVersion + path, OrderModel());
        emit(LoadOrderDtlState(resp));
      });
      on<SetStatusOrderEvent>((event, emit) async {
        emit(const BaseState(isShowLoading: true));
        String path = 'invoice_users/' + (event.isMine ? '${event.id}' : 'shop/${event.id}?status=${event.status}');
        if (event.idBusiness > 0) path = 'business/business_associations/${event.idBusiness}/invoices/${event.id}?status=${event.status}';
        final resp = await ApiClient().postAPI(Constants().apiVersion + path, 'PUT', BaseResponse());
        emit(SetStatusOrderState(resp, event.status));
      });
    }
  }
}