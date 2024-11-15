import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/util/util.dart';

class ReferrersModel {
  final List<ReferrerModel> list = [];

  ReferrersModel fromJson(data) {
    try {
      if (data != null && data.isNotEmpty) {
        data.forEach((v) {
          list.add(ReferrerModel().fromJson(v));
        });
      }
      return this;
    } catch (e) {
      return this;
    }
  }
}

class ReferrerModel {
  int id;
  String email;
  String name;
  String address;
  String phone;
  String image;
  String slug;
  int status;
  int points;
  int shop_id;

  ReferrerModel({
    this.id = -1,
    this.email = '',
    this.name = '',
    this.address = '',
    this.phone = '',
    this.image = '',
    this.slug = '',
    this.status = 1,
    this.points = 0,
    this.shop_id = -1,
  });

  ReferrerModel fromJson(json) {
    id = Util.isNullFromJson(json, 'id')
        ? json['id']
        : Util.isNullFromJson(json, 'referraler_id')
            ? json['referraler_id']
            : -1;
    email = Util.isNullFromJson(json, 'email') ? json['email'] : '';
    name = Util.isNullFromJson(json, 'name') ? json['name'] : '';
    address = Util.isNullFromJson(json, 'address') ? json['address'] : '';
    phone = (Util.isNullFromJson(json, 'phone') ? json['phone'] : '');
    image = (Util.isNullFromJson(json, 'image') ? json['image'] : '');
    slug = (Util.isNullFromJson(json, 'slug') ? json['slug'] : '');
    status = (Util.isNullFromJson(json, 'status') ? json['status'] : 1);
    points = (Util.isNullFromJson(json, 'points') ? json['points'] : 0);
    shop_id = (Util.isNullFromJson(json, 'shop_id') ? json['shop_id'] : -1);
    return this;
  }

  void copy(ReferrerModel value) {
    email = value.email;
    name = value.name;
    address = value.address;
    phone = value.phone;
    image = value.image;
    slug = value.slug;
    status = value.status;
    points = value.points;
    shop_id = value.shop_id;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReferrerModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ReferrerHistoryResponse {
  dynamic response;
  int? totalPoint;
  String type;
  ReferrerHistoryResponse({this.response, this.totalPoint, this.type = ""});
}
