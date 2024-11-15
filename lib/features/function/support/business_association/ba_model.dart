import 'package:hainong/common/util/util.dart';

class BAsModel {
  final List<BAModel> list = [];
  BAsModel fromJson(json) {
    if (json.isNotEmpty) json.forEach((ele) => list.add(BAModel().fromJson(ele)));
    return this;
  }
}

class BAModel {
  String name, content, image, website, phone, email, address, province, district, proName, disName;
  int prestige, id;
  bool is_owner;
  BAModel({this.name = '', this.image = '', this.content = '', this.website = '',
    this.phone = '', this.email = '', this.address = '', this.proName = '', this.disName = '',
    this.province = '-1', this.district = '-1', this.id = -1, this.is_owner = false, this.prestige = 0});
  BAModel fromJson(Map<String, dynamic> json) {
    name = Util.getValueFromJson(json, 'name', '');
    content = Util.getValueFromJson(json, 'content', '');
    website = Util.getValueFromJson(json, 'website', '');
    image = Util.getValueFromJson(json, 'image', '');
    email = Util.getValueFromJson(json, 'email', '');
    phone = Util.getValueFromJson(json, 'phone', '');
    address = Util.getValueFromJson(json, 'address', '');
    prestige = Util.getValueFromJson(json, 'prestige', 0);
    //rate = Util.getValueFromJson(json, 'rate', -1);
    province = Util.getValueFromJson(json, 'province_id', '-1').toString();
    district = Util.getValueFromJson(json, 'district_id', '-1').toString();
    proName = Util.getValueFromJson(json, 'province_name', '');
    disName = Util.getValueFromJson(json, 'district_name', '');
    id = Util.getValueFromJson(json, 'id', -1);
    is_owner = Util.getValueFromJson(json, 'is_owner', false);
    return this;
  }

  void setValue(BAModel value) {
    name = value.name;
    prestige = value.prestige;
    content = value.content;
    website = value.website;
    image = value.image;
    email = value.email;
    phone = value.phone;
    address = value.address;
    province = value.province;
    district = value.district;
    proName = value.proName;
    disName = value.disName;
    is_owner = true;
  }
}