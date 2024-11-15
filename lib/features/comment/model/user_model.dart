import 'package:hainong/common/util/util.dart';

class UserModel {
  int id;
  String name, image, shop_id;

  UserModel({
    this.id = -1,
    this.name = '',
    this.image = '',
    this.shop_id = ''
  });

  UserModel fromJson(Map<String, dynamic> json) {
    try {
      id = Util.isNullFromJson(json, 'id') ? json['id'] : -1;
      name = Util.isNullFromJson(json, 'name') ? json['name']:'';
      image = Util.isNullFromJson(json, 'image') ? json['image']:'';
      shop_id = Util.isNullFromJson(json, 'shop_id') ? json['shop_id'].toString():'';
    } catch(e) {
      return UserModel();
    }
    return this;
  }

  void copy(UserModel value) {
    id = value.id;
    name = value.name;
    image = value.image;
    shop_id = value.shop_id;
  }
}
