import 'package:hainong/common/util/util.dart';

class OrdersModel {
  final List<OrderModel> list = [];
  OrdersModel fromJson(json) {
    if (json.isNotEmpty) json.forEach((ele) => list.add(OrderModel().fromJson(ele)));
    return this;
  }
}

class OrderModel extends CartModel {
  double price_total = .0, price_not_reduced = .0, quantity = .0;
  String name = '', email = '', shipping_address = '', phone_number = '', status = '',
      sku = '', created_at = '', updated_at = '';
  double? max_discount;
  String? coupon_code;

  @override
  OrderModel fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    name = Util.getValueFromJson(json, 'name', '');
    email = Util.getValueFromJson(json, 'email', '');
    shipping_address = Util.getValueFromJson(json, 'shipping_address', '');
    phone_number = Util.getValueFromJson(json, 'phone_number', '');
    status = Util.getValueFromJson(json, 'status', '');
    sku = Util.getValueFromJson(json, 'sku', '');
    created_at = Util.getValueFromJson(json, 'created_at', '');
    updated_at = Util.getValueFromJson(json, 'updated_at', '');
    price_total = Util.getValueFromJson(json, 'price_total', .0);
    price_not_reduced = Util.getValueFromJson(json, 'price_not_reduced', .0);
    coupon_code = Util.getValueFromJson(json, 'coupon_code', null);
    max_discount = Util.getValueFromJson(json, 'max_discount', null);
    quantity = double.parse(Util.getValueFromJson(json, 'quantity', '0').toString());
    return this;
  }
}

class CartModel {
  int id = -1, shop_id = -1;
  String seller_name = '', seller_image = '';
  String? coupon;
  List<CartDtlModel> items = [];
  CartModel({this.shop_id = -1, this.seller_name = '', this.seller_image = ''});
  CartModel fromJson(Map<String, dynamic> json) {
    id = Util.getValueFromJson(json, 'id', -1);
    shop_id = Util.getValueFromJson(json, 'shop_id', -1);
    seller_name = Util.getValueFromJson(json, 'seller_name', '');
    String temp = Util.getValueFromJson(json, 'business_association_name', '');
    if (temp.isNotEmpty) seller_name = temp;
    seller_image = Util.getValueFromJson(json, 'seller_image', '');
    if (Util.checkKeyFromJson(json, 'invoice_items')) {
      final arrayJson = json['invoice_items'];
      arrayJson.forEach((ele) => items.add(CartDtlModel().fromJson(ele)));
    }
    return this;
  }

  Map<String, dynamic> toJson() => {
    'shop_id': shop_id,
    'seller_name': seller_name,
    'seller_image': seller_image,
    'invoice_items': items
  };

  double getTotal() {
    double total = 0;
    for(int i = items.length - 1; i > -1; i--) {
      total += items[i].quantity * items[i].price;
    }
    return total;
  }

  double getReduceTotal() {
    double total = 0;
    for(int i = items.length - 1; i > -1; i--) {
      if(items[i].referral_code.isNotEmpty && items[i].quantity != 0.0){
        total = total + (Util.reducePrice(items[i]) * items[i].quantity) ;
      }
    }
    return total;
  }

  double getPaymentTotal() {
    double total = 0, reduce = 0;
    for(int i = items.length - 1; i > -1; i--) {
      total += items[i].quantity * items[i].price;
      if(items[i].referral_code.isNotEmpty && items[i].quantity > 0) {
        reduce += Util.reducePrice(items[i]) * items[i].quantity;
      }
    }
    return total - reduce;
  }

  double getReducePrice(CartDtlModel item){
    double reducePrice = 0;
    for(int i = items.length - 1; i > -1; i--) {
      reducePrice += Util.reducePrice(items[i]);
    }
    return reducePrice;
  }

  double getQuantity() {
    double total = 0;
    for(int i = items.length - 1; i > -1; i--) {
      total += items[i].quantity;
    }
    return total;
  }
}

class CartDtlModel {
  int product_id = -1;
  double quantity = .0, price = .0, discount_level = .0;
  int coupon_per_item;
  String product_name = '', image = '', unit_name = '', referral_code = '';
  CartDtlModel({this.product_id = -1, this.quantity = .0, this.price = .0,
    this.product_name = '', this.image = '', this.unit_name = '', this.referral_code = '', this.discount_level = .0, this.coupon_per_item = 0});

  CartDtlModel fromJson(Map<String, dynamic> json) {
    product_id = Util.getValueFromJson(json, 'product_id', -1);
    quantity = Util.getValueFromJson(json, 'quantity', .0);
    price = double.parse(Util.getValueFromJson(json, 'price', .0).toString());
    coupon_per_item = Util.getValueFromJson(json, 'coupon_per_item', 0);
    discount_level = double.parse(Util.getValueFromJson(json, 'discount_level', .0).toString());
    product_name = Util.getValueFromJson(json, 'product_name', '');
    unit_name = Util.getValueFromJson(json, 'unit_name', '');
    referral_code = Util.getValueFromJson(json, 'referral_code', '');
    if (Util.checkKeyFromJson(json, 'product_images')) {
      final temp = json['product_images'];
      try {
        image = temp[0]['name'];
      } catch (_) {}
    } else if (Util.checkKeyFromJson(json, 'image')) {
      image = json['image'];
    }
    return this;
  }

  Map<String, dynamic> toJson() => {
    'product_id': product_id,
    'quantity': quantity,
    'price': price,
    'product_name': product_name,
    'image': image,
    'unit_name': unit_name,
    'referral_code': referral_code,
    'coupon_per_item': coupon_per_item,
    'discount_level': discount_level,
  };
}