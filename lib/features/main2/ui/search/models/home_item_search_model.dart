import 'home_item_search_user_model.dart';

class HomeItemSearchModel {
  int? id;
  String? short_search_homepage_title;
  String? object_type;
  String? search_image;
  String? province_name;
  String? district_name;
  double? retail_price;

  HomeItemSearchModel(
      {this.id, this.short_search_homepage_title, this.object_type});

  HomeItemSearchModel fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    object_type = json['object_type'] ?? '';
    search_image = json['search_image'] ?? '';
    province_name = json['province_name'] ?? '';
    district_name = json['district_name'] ?? '';
    retail_price = json['retail_price'] ?? 0;
    short_search_homepage_title = json['short_search_homepage_title'] ?? '';
    return this;
  }
}
