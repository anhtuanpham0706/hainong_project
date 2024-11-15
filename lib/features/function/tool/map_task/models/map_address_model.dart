import 'package:hainong/common/util/util.dart';

class MapAddressModel {
  String? address_full;
  String? district_name;
  String? province_name;
  int? districtId;
  int? provinceId;
  int? wardId;
  MapAddressModel({this.address_full = '', this.district_name = '', this.province_name = '', this.districtId = -1, this.provinceId = -1, this.wardId = -1});

  MapAddressModel fromJson(json, {String? keyName}) {
    provinceId = Util.getValueFromJson(json, keyName ?? 'province_id', -1);
    districtId = Util.getValueFromJson(json, keyName ?? 'district_id', -1);
    wardId = Util.getValueFromJson(json, keyName ?? 'ward_id', -1);
    address_full = Util.getValueFromJson(json, keyName ?? 'address_full', '');
    district_name = Util.getValueFromJson(json, keyName ?? 'district_name', '');
    province_name = Util.getValueFromJson(json, keyName ?? 'province_name', '');
    return this;
  }
}
