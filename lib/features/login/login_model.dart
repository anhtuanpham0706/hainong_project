import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/features/home/ui/import_ui_home.dart';
import 'package:hainong/features/shop/shop_model.dart';

class LoginsModel {
  final List<LoginModel> list = [];
  LoginsModel fromJson(json) {
    if (json.isNotEmpty) json.forEach((ele) => list.add(LoginModel().fromJson(ele)));
    return this;
  }
}

class LoginModel {
  int id;
  int hidden_phone;
  int hidden_email;
  int hide_toolbar;
  int auto_play_video;
  int points;
  double acreage;
  String name;
  String birthdate;
  String gender;
  String email;
  String website;
  String phone;
  String address;
  String token_user;
  String token2_user;
  String province_id;
  String province_name;
  String district_id;
  String district_name;
  String user_type;
  ItemListModel? has_tash_list, tree_list;
  String image;
  String background_image;
  String member_rate;
  String user_level;
  String manager_type;
  ShopModel? shop;
  Map<String, dynamic>? contribute_role;
  String partner_token;
  String partner_type;
  String role_type;
  String current_referral_code;
  String referral_link;

  LoginModel({this.id = -1,
        this.hidden_phone = 0,
        this.hidden_email = 0,
        this.hide_toolbar = 0,
        this.auto_play_video = 1,
        this.points = 0,
        this.acreage = .0,
        this.name = '',
        this.birthdate = '',
        this.gender = '',
        this.email = '',
        this.website = '',
        this.phone = '',
        this.address = '',
        this.token_user = '',
        this.token2_user = '',
        this.province_id = '',
        this.province_name = '',
        this.district_id = '',
        this.district_name = '',
        this.user_type = '',
        this.image = '',
        this.background_image = '',
        this.member_rate = '',
        this.user_level = '',
        this.manager_type = 'member',
        this.has_tash_list,
        this.tree_list,
        this.shop,
        this.partner_token = '',
        this.partner_type= '',
        this.role_type = '',
        this.current_referral_code = '',
        this.referral_link = '',
        }) {
    has_tash_list = ItemListModel();
    tree_list = ItemListModel();
    shop = ShopModel();
  }

  LoginModel fromJson(Map<String, dynamic> json) {
    try {
      id = Util.isNullFromJson(json, 'id') ? json['id'] : -1;

      acreage = Util.isNullFromJson(json, 'acreage') ? json['acreage'] : .0;

      hidden_phone = Util.isNullFromJson(json, 'hidden_phone') ? json['hidden_phone'] : 0;

      hidden_email = Util.isNullFromJson(json, 'hidden_email') ? json['hidden_email'] : 0;

      hide_toolbar = Util.isNullFromJson(json, 'hide_toolbar') ? json['hide_toolbar'] : 0;

      auto_play_video = Util.isNullFromJson(json, 'auto_play_video') ? json['auto_play_video'] : 1;

      points = Util.isNullFromJson(json, 'points') ? json['points'] : 0;

      birthdate = Util.isNullFromJson(json, 'birthdate') ? json['birthdate'] : '';

      gender = Util.isNullFromJson(json, 'gender') ? json['gender'] : '';

      name = Util.isNullFromJson(json, 'name') ? json['name'] : '';

      website = Util.isNullFromJson(json, 'website') ? json['website'] : '';

      email = Util.isNullFromJson(json, 'email') ? json['email'] : '';

      phone = Util.isNullFromJson(json, 'phone') ? json['phone'] : '';

      address = Util.isNullFromJson(json, 'address') ? json['address'] : '';

      token_user = Util.isNullFromJson(json, 'token_user') ? json['token_user'] : '';
      
      token2_user = Util.isNullFromJson(json, 'token2_user') ? json['token2_user'] : '';

      province_id = Util.isNullFromJson(json, 'province_id')
          ? json['province_id'].toString()
          : '';

      province_name = Util.isNullFromJson(json, 'province_name')
          ? json['province_name']
          : '';

      district_id = Util.isNullFromJson(json, 'district_id')
          ? json['district_id'].toString()
          : '';

      district_name = Util.isNullFromJson(json, 'district_name')
          ? json['district_name']
          : '';

      user_type = Util.isNullFromJson(json, 'user_type') ? json['user_type'] : '';

      image = Util.isNullFromJson(json, 'image') ? json['image'] : '';

      background_image = Util.isNullFromJson(json, 'background_image') ? json['background_image'] : '';

      member_rate = Util.isNullFromJson(json, 'member_rate') ? json['member_rate'] : '';

      user_level = Util.isNullFromJson(json, 'user_level') ? json['user_level'] : '';

      manager_type = Util.isNullFromJson(json, 'manager_type') ? json['manager_type'].toString().toLowerCase() : 'member';

      if (Util.isNullFromJson(json, 'shop')) shop!.fromJson(json['shop']);

      if (Util.isNullFromJson(json, 'has_tash_list')) has_tash_list!.fromJson(json['has_tash_list']);

      if (Util.isNullFromJson(json, 'family_tree')) {
        json['family_tree'].forEach((ele) {
          tree_list!.list.add(ItemModel(id: ele, name: ele));
        });
      }

      if (Util.isNullFromJson(json, 'contribute_role')) contribute_role = json['contribute_role'];

      partner_token = Util.isNullFromJson(json, 'partner_token') ? json['partner_token'] : '';
      partner_type = Util.isNullFromJson(json, 'partner_type') ? json['partner_type'] : '';
      role_type = Util.isNullFromJson(json, 'role_type') ? json['role_type'] : '';
      current_referral_code = Util.isNullFromJson(json, 'current_referral_code') ? json['current_referral_code'] : '';
      referral_link = Util.isNullFromJson(json, 'referral_link') ? json['referral_link'] : '';
    } catch (e) {
      return LoginModel();
    }
    return this;
  }
}
