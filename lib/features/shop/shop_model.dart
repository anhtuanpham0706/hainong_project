import 'package:hainong/common/util/util.dart';

class ShopsModel {
  final List<ShopModel> list = [];
  ShopsModel fromJson(data) {
    if (data.isNotEmpty) data.forEach((ele) => list.add(ShopModel().fromJson(ele)));
    return this;
  }
}

class ShopModel {
  int id, user_id, hidden_phone, hidden_email, hide_toolbar, shop_star, classable_id, shopable_id, prestige;
  String name, email, phone, address, province_id, province_name, district_id,
      district_name, website, facebook, description, image, background_image,
      classable_type, followed_at, following_at, member_rate, user_level;
  bool is_followed;

  ShopModel({
    this.id = -1,
    this.user_id = -1,
    this.prestige = 0,
    this.hidden_phone = 0,
    this.hidden_email = 0,
    this.hide_toolbar = 0,
    this.member_rate = '',
    this.user_level = '',
    this.name = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.province_id = '',
    this.province_name = '',
    this.district_id = '',
    this.district_name = '',
    this.website = '',
    this.facebook = '',
    this.description = '',
    this.shop_star = 0,
    this.image = '',
    this.background_image = '',
    this.classable_id = -1,
    this.classable_type = '',
    this.followed_at = '',
    this.following_at = '',
    this.is_followed = false,
    this.shopable_id = -1
  });

  ShopModel copy(ShopModel value) {
    id = value.id;
    prestige = value.prestige;
    user_id = value.user_id;
    hidden_phone = value.hidden_phone;
    hidden_email = value.hidden_email;
    hide_toolbar = value.hide_toolbar;
    member_rate = value.member_rate;
    user_level = value.user_level;
    name = value.name;
    email = value.email;
    phone = value.phone;
    address = value.address;
    province_id = value.province_id;
    province_name = value.province_name;
    district_id = value.district_id;
    district_name = value.district_name;
    website = value.website;
    facebook = value.facebook;
    description = value.description;
    shop_star = value.shop_star;
    image = value.image;
    background_image = value.background_image;
    classable_id = value.classable_id;
    classable_type = value.classable_type;
    followed_at = value.followed_at;
    following_at = value.following_at;
    is_followed = value.is_followed;
    shopable_id = value.shopable_id;
    return this;
  }

  ShopModel fromJson(Map<String, dynamic> json) {
    try {
      id = Util.isNullFromJson(json, 'id') ? json['id'] : -1;

      prestige = Util.isNullFromJson(json, 'prestige') ? json['prestige'] : 0;

      user_id = Util.isNullFromJson(json, 'user_id') ? json['user_id'] : -1;

      hidden_phone = Util.isNullFromJson(json, 'hidden_phone') ? json['hidden_phone'] : 0;

      hidden_email = Util.isNullFromJson(json, 'hidden_email') ? json['hidden_email'] : 0;

      hide_toolbar = Util.isNullFromJson(json, 'hide_toolbar') ? json['hide_toolbar'] : 0;

      name = Util.isNullFromJson(json, 'name') ? json['name']:'';

      email = Util.isNullFromJson(json, 'email') ? json['email']:'';

      phone = Util.isNullFromJson(json, 'phone') ? json['phone']:'';

      address = Util.isNullFromJson(json, 'address') ? json['address']:'';

      province_id = Util.isNullFromJson(json, 'province_id') ? json['province_id'].toString():'';

      province_name = Util.isNullFromJson(json, 'province_name') ? json['province_name']:'';

      district_id = Util.isNullFromJson(json, 'district_id') ? json['district_id'].toString():'';

      district_name = Util.isNullFromJson(json, 'district_name') ? json['district_name']:'';

      website = Util.isNullFromJson(json, 'website') ? json['website']:'';

      facebook = Util.isNullFromJson(json, 'facebook') ? json['facebook']:'';

      description = Util.isNullFromJson(json, 'description') ? json['description']:'';

      shop_star = Util.isNullFromJson(json, 'shop_star') ? json['shop_star']:0;

      classable_id = Util.isNullFromJson(json, 'classable_id') ? json['classable_id']:-1;

      classable_type = Util.isNullFromJson(json, 'classable_type') ? json['classable_type']:'';

      image = Util.isNullFromJson(json, 'image') ? json['image']:'';

      background_image = Util.isNullFromJson(json, 'background_image') ? json['background_image']:'';

      followed_at = Util.isNullFromJson(json, 'followed_at') ? json['followed_at']:'';

      following_at = Util.isNullFromJson(json, 'following_at') ? json['following_at']:'';

      is_followed = Util.isNullFromJson(json, 'is_followed') ? json['is_followed']:false;

      shopable_id = Util.isNullFromJson(json, 'shopable_id') ? json['shopable_id']:-1;

      if (Util.isNullFromJson(json, 'user')) {
        final user = json['user'];
        member_rate = Util.isNullFromJson(user, 'member_rate') ? user['member_rate'] : '';
        user_level = Util.isNullFromJson(user, 'user_level') ? user['user_level'] : '';
      }
    } catch (e) {
      return ShopModel();
    }
    return this;
  }
}
