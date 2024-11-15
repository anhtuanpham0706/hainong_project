import 'package:hainong/common/base_repository.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/models/file_byte.dart';
import 'package:hainong/features/post/model/post.dart';
import 'package:hainong/features/shop/shop_model.dart';

class HomeRepository extends BaseRepository {
  Future<List<dynamic>> loadHomeCatalogues() => apiClient.getList('posts/post_catalogues?');

  Future<BaseResponse> loadPosts(String key, int page, {int? limit,
    bool isMyPost = false, String hashTag = '', String shopId = ''}) {
    final Constants constants = Constants();
    limit ??= constants.limitPage;
    String keyword = key.isEmpty ? '' : '&keyword=$key';
    String path = constants.apiVersion + 'home/page?page=$page&limit=$limit$keyword';
    if (isMyPost) {
      path = constants.apiVersion + 'posts?page=$page&limit=$limit';
    } else if (hashTag.isNotEmpty) {
      path = constants.apiVersion + 'home/page?hash_tag=$hashTag&page=$page&limit=$limit';
    } else if (shopId.isNotEmpty) {
      path = constants.apiVersion + 'home/page?page=$page&limit=$limit&shop_id=$shopId'; }
    return apiClient.getAPI(path, Posts());
  }

  Future<BaseResponse> loadLikePosts(int page, {int? limit}) {
    final Constants constants = Constants();
    limit ??= constants.limitPage;
    return apiClient.getAPI(constants.apiVersion + 'account/like_posts?page=$page&limit=$limit', Posts());
  }

  Future<BaseResponse> loadHighlightPosts(int page, {int? limit}) {
    final Constants constants = Constants();
    limit ??= constants.limitPage;
    return apiClient.getAPI(constants.apiVersion + 'home/highlight_posts?page=$page&limit=$limit', Posts());
  }

  Future<List<dynamic>> loadCatalogue() => apiClient.getList('catalogues/post_catalogues?');

  Future<BaseResponse> loadPost(String id) => apiClient.getAPI('${Constants().apiVersion}posts/$id', Post());

  Future<BaseResponse> loadImageDetail(String id, String postId) => apiClient.getAPI('${Constants().apiVersion}posts/$postId/i/$id', ItemModel2());

  Future<BaseResponse> likePost(String classableId, String classableType) =>
      apiClient.postAPI('${Constants().apiVersion}account/like_item', 'POST', ItemModel2(),
          body: {"classable_id": classableId, "classable_type": classableType});

  Future<BaseResponse> unlikePost(String classableId, String classableType) =>
      apiClient.postAPI('${Constants().apiVersion}account/unlike', 'POST', BaseResponse(),
          body: {"classable_id": classableId, "classable_type": classableType});

  Future<BaseResponse> deletePost(String id) =>
      apiClient.postAPI('${Constants().apiVersion}posts/$id', 'DELETE', BaseResponse());

  Future<BaseResponse> deletePostPer(String id) =>
      apiClient.postAPI('${Constants().apiPerVer}posts/$id', 'DELETE', BaseResponse());

  Future<BaseResponse> warningPost(String id, String reason, {String imageId = ''}) {
    String temp = '/warning_post';
    if (imageId.isNotEmpty) temp = '/warning_image/' + imageId;
    return apiClient.postAPI('${Constants().apiVersion}posts/$id$temp', 'POST', imageId.isEmpty ? Post() : BaseResponse(), body: {"reason": reason});
  }

  Future<BaseResponse> createPost(List<String> files, List<String> hashTags,
      String title, String description, String id, {List<FileByte>? realFiles, String permission = '', String idAlbum = ''}) {
    String tmp = "[";
    for (int i = 0; i < hashTags.length; i++) tmp += "'${hashTags[i]}',";
    tmp += "]";
    return apiClient.postAPI(
        '${permission.isEmpty ? Constants().apiVersion : Constants().apiPerVer}posts/$id', id.isEmpty ? 'POST' : 'PUT', Post(),
        files: files,
        realFiles: realFiles,
        body: {
          "title": title,
          "description": description,
          "post_type": 'public',
          "hash_tag": tmp,
          if (idAlbum.isNotEmpty) "album_id": idAlbum
        });
  }

  Future<BaseResponse> sharePost(Post item, String des, List<String> hashTags) {
    String tmp = "[";
    for (int i = 0; i < hashTags.length; i++) tmp += "'${hashTags[i]}',";
    tmp += "]";
    return apiClient.postAPI('${Constants().apiVersion}account/create_share', 'POST', BaseResponse(),
        body: {
          "description": des,
          "classable_id": item.classable_id,
          "classable_type": item.classable_type,
          "share_type": 'config_share',
          "post_type": item.post_type,
          "hash_tag": tmp
        });
  }

  Future<BaseResponse> loadShop(String id) => apiClient.getAPI('${Constants().apiVersion}shops/$id', ShopModel());

  Future<BaseResponse> transferPoint(String point, String userId , {bool isUser = true}) =>
      apiClient.postAPI('${Constants().apiVersion}account/share_point', 'POST', BaseResponse(),
          body: {
            (isUser ? "receiver_id" : "phone"): userId, "points": point
          });
}
