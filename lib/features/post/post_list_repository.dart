import 'package:hainong/common/base_repository.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/features/shop/shop_model.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:html/dom.dart';
import 'model/post.dart';

class PostListRepository extends BaseRepository {
  Future<BaseResponse> loadFollowers(int page, int type, {int? limit}) {
    limit ??= Constants().limitPage;
    return apiClient.getAPI('${Constants().apiVersion}account/${type == 0 ? 'follow_users' : 'followings'}?page=$page&limit=$limit', ShopsModel());
  }

  Future<Document?> getWebsite(String url) => http.get(Uri.parse(url)).timeout(const Duration(seconds: 5)).then((response) {
      if (response.statusCode == 200) return parse(response.body);
      return null;
  }).catchError((error) => null).onError((error, stackTrace) => null);
  
  Future<BaseResponse> loadPostFollowers(int page, int type, {int? limit}){
    limit ??= Constants().limitPage;
    return apiClient.getAPI('${Constants().apiVersion}account/follow_posts?page=$page&limit=$limit', Posts());
  }

  Future<BaseResponse> unFollowPost(String clasSableType, String clasSableId){
    return apiClient.postAPI('${Constants().apiVersion}account/unfollow_item', 'POST', Post(),
        body: {'classable_type': clasSableType, 'classable_id': clasSableId});
  }

  Future<BaseResponse> setFollowPost(String clasSableType, String clasSableId) =>
      apiClient.postAPI('${Constants().apiVersion}account/follow_item', 'POST', Post(),
          body: {'classable_type': clasSableType, 'classable_id': clasSableId});
}
