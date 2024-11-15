import 'package:hainong/common/util/util.dart';

class MapDataModels {
  final List<MapDataModel> list = [];

  MapDataModels fromJson(json) {
    if (json != null && json.isNotEmpty) {
      json.forEach((v) => list.add(MapDataModel().fromJson(v)));
    }
    return this;
  }
}

class MapDataModel {
  int id, total_rated, total_user_comments, total_comment, classable_id;
  String name, address, province_name, district_name, status, start_date, end_date, updated_at, suggest, category_image;
  String opening_time, closing_time, opening_status, description, productivity, performance, classable_type, old_comment;
  String deep_link, full_address, category_name;
  double acreage, lat, lng, rate, percent, old_rate;
  bool has_commented,is_pet;
  List<String>? images;
  List<ImagePetModel>? images_pet;
  late List<Map<String, dynamic>> agency_working_hours;
  late List<String> categories;
  MapDataModel(
      {this.id = -1,
      this.name = '',
      this.address = '',
      this.acreage = 0,
      this.province_name = '',
      this.district_name = '',
      this.status = '',
      this.start_date = '',
      this.end_date = '',
      this.opening_time = '',
      this.closing_time = '',
      this.opening_status = '',
      this.description = '',
      this.performance = '',
      this.productivity = '',
      this.lat = 0.0,
      this.lng = 0.0,
      this.rate = 0.0,
      this.total_rated = 0,
      this.total_comment = 0,
      this.total_user_comments = 0,
      this.percent = 0.0,
      this.suggest = '',
      this.category_image = '',
      this.updated_at = '',
      this.images,
      this.classable_id = -1,
      this.classable_type = '',
      this.has_commented = false,
      this.old_rate = 0.0,
      this.old_comment = '',
      this.deep_link = '',
      this.full_address = '',
      this.category_name = '',
        this.is_pet = false
      }) {
    agency_working_hours = [];
    categories = [];
    images_pet = [];
  }

  MapDataModel fromJson(json, {String? keyName}) {
    try {
      id = Util.getValueFromJson(json, keyName ?? 'id', -1);
      classable_id = Util.getValueFromJson(json, keyName ?? 'classable_id', -1);
      classable_type = Util.getValueFromJson(json, keyName ?? 'classable_type', '');
      name = Util.getValueFromJson(json, keyName ?? 'name', '');
      category_name = Util.getValueFromJson(json, keyName ?? 'category_name', '');
      address = Util.getValueFromJson(json, keyName ?? 'address', '');
      acreage = Util.getValueFromJson(json, keyName ?? 'acreage', 0.0);
      province_name = Util.getValueFromJson(json, keyName ?? 'province_name', '');
      district_name = Util.getValueFromJson(json, keyName ?? 'district_name', '');
      status = Util.getValueFromJson(json, keyName ?? 'status', '');
      lat = Util.getValueFromJson(json, keyName ?? 'lat', 0.0);
      lng = Util.getValueFromJson(json, keyName ?? 'lng', 0.0);
      rate = Util.getValueFromJson(json, keyName ?? 'rate', 0.0);
      total_rated = Util.getValueFromJson(json, keyName ?? 'total_rated', 0);
      start_date = Util.getValueFromJson(json, keyName ?? 'start_date', '');
      end_date = Util.getValueFromJson(json, keyName ?? 'end_date', '');
      total_user_comments = Util.getValueFromJson(json, keyName ?? 'total_user_comments', 0);
      total_comment = Util.getValueFromJson(json, keyName ?? 'total_comment', 0);
      opening_time = Util.getValueFromJson(json, keyName ?? 'opening_time', '');
      opening_status = Util.getValueFromJson(json, keyName ?? 'opening_status', '');
      closing_time = Util.getValueFromJson(json, keyName ?? 'closing_time', '');
      description = Util.getValueFromJson(json, keyName ?? 'description', '');
      productivity = Util.getValueFromJson(json, keyName ?? 'productivity', '');
      performance = Util.getValueFromJson(json, keyName ?? 'performance', '');
      updated_at = Util.getValueFromJson(json, keyName ?? 'updated_at', '');
      suggest = Util.getValueFromJson(json, keyName ?? 'suggest', '');
      percent = Util.getValueFromJson(json, keyName ?? 'percent', 0.0);
      old_rate = Util.getValueFromJson(json, keyName ?? 'old_rate', 0.0);
      old_comment = Util.getValueFromJson(json, keyName ?? 'old_comment', '');
      deep_link = Util.getValueFromJson(json, keyName ?? 'deep_link', '');
      full_address = Util.getValueFromJson(json, keyName ?? 'full_address', '');
      category_image = Util.getValueFromJson(json, keyName ?? 'category_image', '');
      has_commented = Util.getValueFromJson(json, keyName ?? 'has_commented', false);
      // if (Util.checkKeyFromJson(json, 'images') && !is_pet) {
      //   images = [];
      //   json['images'].forEach((ele) {
      //     if (ele is String) {
      //       images?.add(ele);
      //     } else {
      //       images?.add(Util.getValueFromJson(ele, keyName ?? 'name', ''));
      //     }
      //   });
      // }
      if (Util.checkKeyFromJson(json, 'images')) {
        json['images'].forEach((ele) {
          images_pet?.add(ImagePetModel().fromJson(ele));
        });
      }
      if (Util.checkKeyFromJson(json, 'agency_working_hours')) {
        json['agency_working_hours'].forEach((ele) {
          agency_working_hours.add(ele);
        });
      }
      if (Util.checkKeyFromJson(json, 'categories')) {
        json['categories'].forEach((ele) {
          categories.add(ele['name']);
        });
      }
      return this;
    } catch (e) {
      return this;
    }
  }
}

class ImagePetModel {
  String user_id, name,user_name,note;
  bool selected;
  ImagePetModel({this.user_id = '', this.name = '',this.user_name =
    '',this.note = '',this.selected = false});

  ImagePetModel fromJson(json, {String? keyName}) {
    user_id = Util.getValueFromJson(json, 'user_id', -1).toString();
    name = Util.getValueFromJson(json, keyName??'name', '');
    user_name = Util.getValueFromJson(json, keyName??'user_name', '');
    note = Util.getValueFromJson(json, keyName??'note', '');
    return this;
  }

}
