import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/features/comment/model/sub_comment_model.dart';
import 'package:hainong/features/referrer/model/referrer_model.dart';
import 'package:hainong/features/shop/shop_model.dart';

class ProductsModel {
  final List<ProductModel> list = [];

  ProductsModel fromJson(data) {
    if (data != null && data.isNotEmpty) data.forEach((v) => list.add(ProductModel().fromJson(v)));
    return this;
  }
}

class ProductModel {
  int id, business_association_id, product_catalogue_id, product_unit_id, rate, view_count, favourite_id, classable_id,
      intruction_point, coupon_per_item;
  double quantity, qty_buy, retail_price, wholesale_price, discount_level;
  bool pined, is_favourite, is_bought, hot_pick;
  String title, product_code, product_type, description, optional_name, catalogue_name, unit_name, qr_code, updated_at,
      classable_type;
  late ItemListModel images;
  late ShopModel shop;
  late SubCommentModel comment;
  late ReferrersModel referrerProducts;
  List<int>? referraler_ids;

  ProductModel({this.id = -1, this.business_association_id = -1, this.title = '', this.product_code = '',
      this.product_type = '', this.quantity = 0.0, this.qty_buy = 0.0, this.retail_price = 0.0, this.wholesale_price = 0.0,
      this.description = '', this.optional_name = '', this.product_catalogue_id = -1, this.catalogue_name = '',
      this.product_unit_id = -1, this.unit_name = '', this.qr_code = '', this.updated_at = '', this.pined = false,
      this.rate = 0, this.view_count = 0, this.is_favourite = false, this.favourite_id = -1, this.classable_type = '',
      this.classable_id = -1, this.hot_pick = false, this.is_bought = false, this.intruction_point = 0,
      this.discount_level = 0.0, this.coupon_per_item = 0, this.referraler_ids}) {
    images = ItemListModel();
    shop = ShopModel();
    comment = SubCommentModel();
    referrerProducts = ReferrersModel();
  }

  ProductModel fromJson(json) {
    try {
      id = Util.getValueFromJson(json, 'id', -1);

      final temp = Util.getValueFromJson(json, 'modify_response_for_business', false);
      if (temp) business_association_id = Util.getValueFromJson(json, 'business_association_id', -1);

      title = Util.getValueFromJson(json, 'title', '');

      product_code = Util.getValueFromJson(json, 'product_code', '');

      product_type = Util.getValueFromJson(json, 'product_type', '');

      quantity = Util.getValueFromJson(json, 'quantity', 0.0);

      qty_buy = Util.getValueFromJson(json, 'qty_buy', 0.0).toDouble();

      retail_price = Util.isNullFromJson(json, 'retail_price') ? double.parse(json['retail_price'].toString()) : 0.0;

      wholesale_price = Util.isNullFromJson(json, 'wholesale_price') ? double.parse(json['wholesale_price'].toString()) : 0.0;

      description = Util.getValueFromJson(json, 'description', '');

      optional_name = Util.getValueFromJson(json, 'optional_name', '');

      product_catalogue_id = Util.getValueFromJson(json, 'product_catalogue_id', -1);

      catalogue_name = Util.getValueFromJson(json, 'catalogue_name', '');

      product_unit_id = Util.getValueFromJson(json, 'product_unit_id', -1);

      unit_name = Util.getValueFromJson(json, 'unit_name', '');

      qr_code = Util.getValueFromJson(json, 'qr_code', '');

      updated_at = Util.getValueFromJson(json, 'updated_at', '');

      pined = Util.getValueFromJson(json, 'pined', false);

      rate = Util.getValueFromJson(json, 'rate', 0);

      view_count = Util.getValueFromJson(json, 'view_count', 0);

      if (Util.isNullFromJson(json, 'images')) images.fromJson(json['images']);

      if (Util.isNullFromJson(json, 'shop')) shop.fromJson(json['shop']);

      if (Util.isNullFromJson(json, 'comment')) comment.fromJson(json['comment']);

      is_favourite = Util.getValueFromJson(json, 'is_favourite', false);

      is_bought = Util.getValueFromJson(json, 'is_bought', false);

      hot_pick = Util.getValueFromJson(json, 'hot_pick', false);

      favourite_id = Util.getValueFromJson(json, 'favourite_id', -1);

      classable_type = Util.getValueFromJson(json, 'classable_type', '');

      classable_id = Util.getValueFromJson(json, 'classable_id', -1);

      intruction_point = Util.getValueFromJson(json, 'intruction_point', 0);

      discount_level = Util.isNullFromJson(json, 'discount_level') ? double.parse(json['discount_level'].toString()) : 0.0;

      coupon_per_item = Util.getValueFromJson(json, 'coupon_per_item', 0);

      referraler_ids = Util.isNullFromJson(json, 'referraler_ids') ? json['referraler_ids'] : [];

      if (Util.isNullFromJson(json, 'product_referralers')) referrerProducts.fromJson(json['product_referralers']);
    } catch (_) {}
    return this;
  }

  void copy(ProductModel value, {bool full = false}) {
    title = value.title;
    product_code = value.product_code;
    product_type = value.product_type;
    quantity = value.quantity;
    qty_buy = value.qty_buy;
    retail_price = value.retail_price;
    wholesale_price = value.wholesale_price;
    description = value.description;
    optional_name = value.optional_name;
    product_catalogue_id = value.product_catalogue_id;
    catalogue_name = value.catalogue_name;
    product_unit_id = value.product_unit_id;
    unit_name = value.unit_name;
    hot_pick = value.hot_pick;
    images.list.clear();
    images.list.addAll(value.images.list);
    if (full) {
      business_association_id = value.business_association_id;
      qr_code = value.qr_code;
      updated_at = value.updated_at;
      pined = value.pined;
      rate = value.rate;
      view_count = value.view_count;
      is_favourite = value.is_favourite;
      favourite_id = value.favourite_id;
      is_bought = value.is_bought;
      classable_type = value.classable_type;
      classable_id = value.classable_id;
      shop.copy(value.shop);
      comment.id = value.comment.id;
      comment.rate = value.comment.rate;
      referraler_ids = value.referraler_ids;
      intruction_point = value.intruction_point;
      discount_level = value.discount_level;
      coupon_per_item = value.coupon_per_item;
    }
  }

  copyReferrers(ProductModel value) {
    referrerProducts.list.clear();
    referrerProducts.list.addAll(value.referrerProducts.list);
  }
}
