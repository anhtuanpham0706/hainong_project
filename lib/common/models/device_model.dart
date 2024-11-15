import 'package:hainong/common/util/util.dart';

class DeviceModel {
  int id = -1;
  String device_token = '';
  String device_id = '';
  String device_type = '';
  String name = '';
  String os_version = '';
  String app_version = '';

  DeviceModel fromJson(Map<String, dynamic> json) {
    id = Util.isNullFromJson(json, 'id') ? json['id']:-1;
    device_token = Util.isNullFromJson(json, 'device_token') ? json['device_token']:'';
    device_id = Util.isNullFromJson(json, 'device_id') ? json['device_id']:'';
    device_type = Util.isNullFromJson(json, 'device_type') ? json['device_type']:'';
    name = Util.isNullFromJson(json, 'name') ? json['name']:'';
    os_version = Util.isNullFromJson(json, 'os_version') ? json['os_version']:'';
    app_version = Util.isNullFromJson(json, 'app_version') ? json['app_version']:'';
    return this;
  }
}