import 'package:hainong/common/util/util.dart';

class TotalModel {
  int total_products, total_followers, total_like_posts, total_followings,total_follow_posts,total_shop_invoice;
  TotalModel({this.total_followers = 0, this.total_like_posts = 0, this.total_products = 0, this.total_followings = 0, this.total_follow_posts = 0, this.total_shop_invoice = 0});
  TotalModel fromJson(Map<String, dynamic> json) {
    total_products = Util.getValueFromJson(json, 'total_products', 0);
    total_followers = Util.getValueFromJson(json, 'total_followers', 0);
    total_like_posts = Util.getValueFromJson(json, 'total_like_posts', 0);
    total_followings = Util.getValueFromJson(json, 'total_followings', 0);
    total_follow_posts = Util.getValueFromJson(json, 'total_follow_posts', 0);
    total_shop_invoice = Util.getValueFromJson(json, 'total_shop_invoice', 0);
    return this;
  }
  TotalModel copy(TotalModel value) {
    total_products = value.total_products;
    total_followers = value.total_followers;
    total_like_posts = value.total_like_posts;
    total_followings = value.total_followings;
    total_follow_posts = value.total_follow_posts;
    total_shop_invoice = value.total_shop_invoice;
    return this;
  }
}