import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/util/util.dart';

class AlbumsModel {
  final List<AlbumModel> list = [];

  AlbumsModel fromJson(json) {
    if (json.isNotEmpty) {
      json.forEach((ele) => list.add(AlbumModel(thumbnail: ItemModel()).fromJson(ele)));
    }
    return this;
  }
}

class AlbumModel {
  int id,user_id,shop_id;
  String name, created_at;
  ItemModel thumbnail;

  AlbumModel({this.id = -1, this.user_id = -1 ,this.name = '',this.shop_id = -1, this.created_at = '',required this.thumbnail});
  AlbumModel fromJson(Map<String, dynamic> json) {
    id = Util.getValueFromJson(json, 'id', -1);
    user_id = Util.getValueFromJson(json, 'user_id', -1);
    shop_id = Util.getValueFromJson(json, 'shop_id', -1);
    name = Util.getValueFromJson(json, 'name', '');
    created_at = Util.getValueFromJson(json, 'created_at', '');
    if(Util.checkKeyFromJson(json, "thumbnail")){
      thumbnail.fromJson(json['thumbnail']);
    }
    return this;
  }
}
