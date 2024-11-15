import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/util/util.dart';

class Posts {
  final List<Post> list = [];

  Posts fromJson(json) {
    if (json != null && json.isNotEmpty) json.forEach((v) => list.add(Post().fromJson(v)));
    return this;
  }
}

class Post {
  String id;
  String shop_id;
  String user_id;
  String shop_name;
  String shop_image;
  String classable_type;
  String classable_id;
  String post_type;
  String title;
  String short_title;
  String description;
  String created_at;
  String user_share_id;
  String shared_post_id;
  bool user_liked;
  int total_like;
  bool user_followed;
  bool user_comment;
  int total_comment;
  int total_connect;
  int viewed;
  bool user_shared;
  String province_name;
  String district_name;
  String user_level;
  String member_rate;
  dynamic images = ItemListModel2();

  Post(
      {this.id = '',
      this.shop_id = '',
      this.user_id = '',
      this.member_rate = '',
      this.user_level = '',
      this.shop_name = '',
      this.shop_image = '',
      this.classable_type = '',
      this.classable_id = '',
      this.post_type = '',
      this.title = '',
      this.short_title = '',
      this.description = '',
      this.created_at = '',
      this.user_share_id = '',
      this.shared_post_id = '',
      this.user_liked = false,
      this.user_followed = false,
      this.total_like = 0,
      this.user_comment = false,
      this.total_comment = 0,
      this.total_connect = 0,
      this.viewed = 0,
      this.user_shared = false,
      this.province_name = '',
      this.district_name = ''});

  Post copy(Post post) {
    title = post.title;
    short_title = post.short_title;
    description = post.description;
    user_share_id = post.user_share_id;
    shared_post_id = post.shared_post_id;
    user_liked = post.user_liked;
    user_followed = post.user_followed;
    total_like = post.total_like;
    user_comment = post.user_comment;
    total_comment = post.total_comment;
    total_connect = post.total_connect;
    viewed = post.viewed;
    user_shared = post.user_shared;
    user_id = post.user_id;
    user_level = post.user_level;
    member_rate = post.member_rate;
    return this;
  }

  Post copyAll(Post post) {
    id = post.id;
    user_id = post.user_id;
    shop_id = post.shop_id;
    shop_name = post.shop_name;
    member_rate = post.member_rate;
    user_level = post.user_level;
    shop_image = post.shop_image;
    classable_type = post.classable_type;
    classable_id = post.classable_id;
    post_type = post.post_type;
    title = post.title;
    short_title = post.short_title;
    description = post.description;
    created_at = post.created_at;
    user_share_id = post.user_share_id;
    shared_post_id = post.shared_post_id;
    user_liked = post.user_liked;
    user_followed = post.user_followed;
    total_like = post.total_like;
    user_comment = post.user_comment;
    total_comment = post.total_comment;
    total_connect = post.total_connect;
    viewed = post.viewed;
    user_shared = post.user_shared;
    province_name = post.province_name;
    district_name = post.district_name;
    images.list.clear();
    final list = post.images.list;
    for (int i = list.length - 1; i > -1 ; i--) images.list.add(list[i]);
    //images.list.addAll(post.images.list);
    return this;
  }

  Post fromJson(json) {
    try {
      id = Util.isNullFromJson(json, 'id') ? json['id'].toString():'';

      user_id = Util.isNullFromJson(json, 'id') ? json['user_id'].toString():'';

      title = Util.isNullFromJson(json, 'title') ? json['title']:'';

      short_title = Util.isNullFromJson(json, 'short_title') ? json['short_title']:'';

      classable_id = Util.isNullFromJson(json, 'classable_id') ? json['classable_id'].toString():'';

      classable_type = Util.isNullFromJson(json, 'classable_type') ? json['classable_type']:'';

      post_type = Util.isNullFromJson(json, 'post_type') ? json['post_type']:'';

      description = Util.isNullFromJson(json, 'description') ? json['description']:'';

      created_at = Util.isNullFromJson(json, 'created_at') ? json['created_at']:'';

      user_share_id = Util.isNullFromJson(json, 'user_share_id') ? json['user_share_id'].toString():'';

      shared_post_id = Util.isNullFromJson(json, 'shared_post_id') ? json['shared_post_id'].toString():'';

      if (Util.isNullFromJson(json, 'images')) images.fromJson(json['images']);

      user_liked = Util.isNullFromJson(json, 'user_liked') ? json['user_liked']:false;

      user_followed = Util.isNullFromJson(json, 'user_followed') ? json['user_followed']:false;

      user_comment = Util.isNullFromJson(json, 'user_comment') ? json['user_comment']:false;

      user_shared = Util.isNullFromJson(json, 'user_shared') ? json['user_shared']:false;

      total_like = Util.isNullFromJson(json, 'total_like') ? json['total_like']:0;

      total_comment = Util.isNullFromJson(json, 'total_comment') ? json['total_comment'] : 0;

      total_connect = Util.isNullFromJson(json, 'total_connect') ? json['total_connect'] : 0;

      viewed = Util.isNullFromJson(json, 'viewed') ? json['viewed'] : 0;

      shop_id = Util.isNullFromJson(json, 'shop_id') ? json['shop_id'].toString():'';

      shop_name = Util.isNullFromJson(json, 'shop_name') ? json['shop_name']:'';

      shop_image = Util.isNullFromJson(json, 'shop_image') ? json['shop_image']:'';

      province_name = Util.isNullFromJson(json, 'province_name') ? json['province_name']:'';

      district_name = Util.isNullFromJson(json, 'district_name') ? json['district_name']:'';

      member_rate = Util.isNullFromJson(json, 'member_rate') ? json['member_rate']:'';

      user_level = Util.isNullFromJson(json, 'user_level') ? json['user_level']:'';
    } catch (e) {
      return Post();
    }
    return this;
  }
}
