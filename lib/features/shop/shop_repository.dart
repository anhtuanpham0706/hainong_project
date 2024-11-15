import 'package:hainong/common/base_repository.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/features/comment/model/follow_model.dart';
import 'package:hainong/features/login/login_model.dart';
import 'package:hainong/features/product/product_model.dart';
import 'package:hainong/features/shop/album_model.dart';

import 'friend_model.dart';

class ShopRepository extends BaseRepository {
  Future<BaseResponse> loadHighlightProducts(String shopId, String page, {int? limit}) {
    limit ??= Constants().limitPage;
    return apiClient.getAPI('${Constants().apiVersion}shops/highlight_products?shop_id=$shopId&page=$page&limit=$limit',
        ProductsModel(), hasHeader: false);
  }

  Future<BaseResponse> loadOtherProducts(int shopId, String page, int businessId, {int? limit}) {
    limit ??= Constants().limitPage;
    String param = 'current_products?';
    if (shopId > 0) {
      param = 'list_products?shop_id=$shopId&';
      if (businessId > 0) param += 'business_association_id=$businessId&';
    }
    return apiClient.getAPI('${Constants().apiVersion}products/${param}page=$page&limit=$limit', ProductsModel());
  }
  Future<BaseResponse> loadAlbumUser(int? user_id,String page, {int? limit}) {
    limit ??= Constants().limitPage;
    return apiClient.getAPI('${Constants().apiVersion}user_albums?shop_id=$user_id&page=$page&limit=$limit', AlbumsModel());
  }
  Future<BaseResponse> loadListImageAlbum(int id,String page, {int? limit}) {
    limit ??= Constants().limitPage;
    return apiClient.getAPI('${Constants().apiVersion}user_albums/$id/images?&page=$page&limit=$limit', ItemListModel());
  }
  Future<BaseResponse> deleteProduct(String productId) => apiClient.postAPI(
      '${Constants().apiVersion}products/$productId', 'DELETE', BaseResponse());

  Future<BaseResponse> pinProduct(String productId) =>
      apiClient.postAPI('${Constants().apiVersion}products/pin_product', 'PUT', ProductModel(), body: {'product_id': productId});
  Future<BaseResponse> removeImage(String album_id, String image_id) =>
      apiClient.postAPI('${Constants().apiVersion}user_albums/$album_id/images/$image_id', 'DELETE', BaseResponse());

  Future<BaseResponse> getUserFollow(String type, String id) =>
      apiClient.getAPI('${Constants().apiVersion}account/is_followed?classable_type=$type&classable_id=$id', FollowModel());

  Future<BaseResponse> setFollow(String type, String id) =>
      apiClient.postAPI('${Constants().apiVersion}account/follow_item', 'POST', FollowModel(),
          body: {'classable_type': type, 'classable_id': id});

  Future<BaseResponse> setUnFollow(String type, String id) =>
      apiClient.postAPI('${Constants().apiVersion}account/unfollow_item', 'POST', ItemModel(),
          body: {'classable_type': type, 'classable_id': id});

  Future<BaseResponse> uploadBackgroundImage(String path) {
    List<String> files = [];
    if (path.isNotEmpty) files.add(path);
    return apiClient.postAPI('${Constants().apiVersion}account/update_user', 'POST', LoginModel(),
        files: files, paramFile: 'background_image');
  }

  Future<BaseResponse> deleteBackgroundImage() => apiClient.postAPI(
      '${Constants().apiVersion}account/update_background_image', 'POST', LoginModel(), body: {'background_image':''});

  Future<BaseResponse> getPoint() => apiClient.getAPI('${Constants().apiVersion}account/profile', LoginModel());

  Future<BaseResponse> getFriendStatus(String userId) => apiClient.getAPI('${Constants().apiVersion}account/relationship_status?user_id=$userId', FriendModel());

  Future<BaseResponse> postAddFriend(String phone) => apiClient.postAPI('${Constants().apiVersion}friends?phone=$phone', 'POST', BaseResponse());

  Future<BaseResponse> postUnFriend(String friendId) => apiClient.postAPI('${Constants().apiVersion}friends/unfriend?friend_id=$friendId', 'POST', BaseResponse());
}
