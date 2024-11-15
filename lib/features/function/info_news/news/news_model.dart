import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/util/util.dart';

class NewsModels {
  final List<NewsModel> list = [];
  NewsModels fromJson(json) {
    if (json.isNotEmpty) json.forEach((ele) => list.add(NewsModel().fromJson(ele)));
    return this;
  }
}

class NewsModel {
  int id, article_catalogue_id, viewed, total_comment, total_favourites;
  final List<ItemModel> tags = [];
  bool is_favourite;
  String title, content, image, article_catalogue_name, created_at, audio_link,
      classable_type, classable_type2, is_feature, status,favourite_id;
  NewsModel({this.id = -1, this.article_catalogue_id = -1, this.title = '',
    this.image = '', this.classable_type = '', this.classable_type2 = '',
    this.content = '', this.article_catalogue_name = '', this.created_at = '',
    this.audio_link = '', this.is_feature = '', this.status = '',
    this.is_favourite = false, this.favourite_id = '', this.viewed = 0,
    this.total_comment = 0, this.total_favourites = 0});
  NewsModel fromJson(Map<String, dynamic> json) {
    id = Util.getValueFromJson(json, 'id', -1);
    viewed = Util.getValueFromJson(json, 'viewed', 0);
    total_favourites = Util.getValueFromJson(json, 'total_favourites', 0);
    total_comment = Util.getValueFromJson(json, 'total_comment', 0);
    article_catalogue_id = Util.getValueFromJson(json, 'article_catalogue_id', -1);
    article_catalogue_name = Util.getValueFromJson(json, 'article_catalogue_name', '');
    is_feature = Util.getValueFromJson(json, 'is_feature', '0').toString();
    status = Util.getValueFromJson(json, 'status', '').toString();
    title = Util.getValueFromJson(json, 'title', '');
    content = Util.getValueFromJson(json, 'content', '');
    image = Util.getValueFromJson(json, 'image', '');
    created_at = Util.getValueFromJson(json, 'created_at', '');
    audio_link = Util.getValueFromJson(json, 'audio_link', '');
    is_favourite = Util.getValueFromJson(json, 'is_favourite', false);
    favourite_id = Util.getValueFromJson(json, 'favourite_id', -1).toString();
    classable_type2 = Util.getValueFromJson(json, 'classable_type', '');
    classable_type = classable_type2.toLowerCase();
    if (Util.checkKeyFromJson(json, 'tags')) json['tags'].forEach((ele) => tags.add(ItemModel(id: ele, name: ele)));
    return this;
  }
}