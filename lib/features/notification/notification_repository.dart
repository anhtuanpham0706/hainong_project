import 'package:hainong/common/base_repository.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/features/comment/model/comment_model.dart';
import '../cart/cart_model.dart';
import '../function/tool/farm_management/farm_management_bloc.dart';
import '../function/tool/material_management/material_bloc.dart';
import '../function/tool/plots_management/plots_management_bloc.dart';
import 'notification_model.dart';
import 'package:hainong/features/post/model/post.dart';
import 'package:hainong/features/shop/shop_model.dart';

class NotificationRepository extends BaseRepository {
  Future<BaseResponse> loadNotifications(int page, {limit}) {
    limit ??= Constants().limitPage;
    return apiClient.getAPI(Constants().apiVersion + 'notifications?page=$page&limit=$limit', NotificationsModel());
  }

  Future<BaseResponse> seenNotification(int id) => apiClient.postAPI(Constants().apiVersion + 'notifications/seen/$id', 'PUT', NotificationModel());
  Future<BaseResponse> deleteNotification(int id) => apiClient.postAPI(Constants().apiVersion + 'notifications/$id', 'DELETE', BaseResponse());

  Future<BaseResponse> deleteAllNotification() => apiClient.postAPI(Constants().apiVersion + 'notifications/destroy_all', 'DELETE', BaseResponse());
  Future<BaseResponse> readAllNotification() => apiClient.postAPI(Constants().apiVersion + 'notifications/seen_all', 'PUT', BaseResponse());

  Future<BaseResponse> loadFarm(int id) => apiClient.getAPI(Constants().apiVersion + 'process_engineerings/$id', FarmManageModel());
  Future<BaseResponse> loadMaterial(int id) => apiClient.getAPI(Constants().apiVersion + 'materials/$id', MaterialModel());
  Future<BaseResponse> loadPlot(int id) => apiClient.getAPI(Constants().apiVersion + 'culture_plots/$id', PlotsManageModel());
  Future<BaseResponse> loadPost(int id) => apiClient.getAPI(Constants().apiVersion + 'posts/$id', Post());
  Future<BaseResponse> loadOrder(int id) => apiClient.getAPI(Constants().apiVersion + 'invoice_users/shop/$id', OrderModel());
  Future<BaseResponse> loadShop(int id) => apiClient.getAPI(Constants().apiVersion + 'shops/$id', ShopModel());
  Future<BaseResponse> loadComment(int id) => apiClient.getAPI(Constants().apiVersion + 'comments/$id', CommentModel());
  Future<String> loadMarketPrice(int id) => apiClient.getAPI2(Constants().apiVersion + 'market_prices/$id');
}
