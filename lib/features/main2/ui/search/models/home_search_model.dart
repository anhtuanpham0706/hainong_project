import 'home_item_search_model.dart';

class HomeSearchModels {
  final List<HomeSearchModel> list = [];
  HomeSearchModels fromJson(json) {
    if (json.isNotEmpty) {
      json.forEach((ele) {
        list.add(HomeSearchModel().fromJson(ele));
      });
    }
    return this;
  }
}

class HomeSearchModel {
  String? wrap_title;
  List<HomeItemSearchModel>? data;

  HomeSearchModel({this.wrap_title, this.data});

  HomeSearchModel fromJson(Map<String, dynamic> json) {
    wrap_title = json['wrap_title'] ?? "";
    data = json['data']
            .map<HomeItemSearchModel>(
                (json) => HomeItemSearchModel().fromJson(json))
            .toList() ??
        [];
    return this;
  }
}
