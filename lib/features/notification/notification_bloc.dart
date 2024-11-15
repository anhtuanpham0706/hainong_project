import 'dart:convert';
import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/features/function/info_news/market_price/model/market_price_model.dart';
import 'package:hainong/features/product/product_model.dart';
import '../admin/review_contribute/review_bloc.dart';
import 'notification_repository.dart';

class NotificationState extends BaseState {
  NotificationState({isShowLoading = false}):super(isShowLoading: isShowLoading);
}
class LoadNotificationsState extends NotificationState {
  final BaseResponse response;
  LoadNotificationsState(this.response);
}
class DeleteAllNotificationsState extends NotificationState {
  final BaseResponse response;
  DeleteAllNotificationsState(this.response);
}
class ReadAllNotificationState extends NotificationState {
  final BaseResponse response;
  ReadAllNotificationState(this.response);
}

class SeenNotificationState extends NotificationState {
  final BaseResponse response;
  SeenNotificationState(this.response);
}
class DeleteNotificationState extends NotificationState {
  final BaseResponse response;
  DeleteNotificationState(this.response);
}

class LoadPostState extends NotificationState {
  final BaseResponse response;
  final String type;
  LoadPostState(this.response, {this.type = ''});
}
class LoadCommentState extends NotificationState {
  final BaseResponse response;
  LoadCommentState(this.response);
}
class LoadImageDtlState extends NotificationState {
  final BaseResponse response;
  final int id;
  LoadImageDtlState(this.response, this.id);
}

class NotificationEvent extends BaseEvent {}
class LoadNotificationsEvent extends NotificationEvent {
  final int page;
  LoadNotificationsEvent(this.page);
}
class DeleteAllNotificationsEvent extends NotificationEvent {}
class ReadAllNotificationEvent extends NotificationEvent {}

class SeenNotificationEvent extends NotificationEvent {
  final int id;
  SeenNotificationEvent(this.id);
}
class DeleteNotificationEvent extends NotificationEvent {
  final int id;
  DeleteNotificationEvent(this.id);
}

class LoadPostEvent extends NotificationEvent {
  final int id;
  final String type;
  LoadPostEvent(this.id, {this.type = ''});
}
class LoadCommentEvent extends NotificationEvent {
  final int id;
  LoadCommentEvent(this.id);
}
class LoadImageDtlEvent extends NotificationEvent {
  final String id;
  final int postId;
  LoadImageDtlEvent(this.id, this.postId);
}

class LoadDetailEvent extends NotificationEvent {
  final int id;
  final String type;
  final dynamic ext;
  LoadDetailEvent(this.id, this.type, {this.ext});
}
class LoadDetailState extends NotificationState {
  final BaseResponse resp;
  final String type;
  final dynamic ext;
  LoadDetailState(this.resp, this.type, this.ext);
}

class NotificationBloc extends BaseBloc {
  final NotificationRepository repository = NotificationRepository();
  NotificationBloc({bool isList = false}) {
    if (isList) {
      on<LoadNotificationsEvent>((event, emit) async {
        emit(NotificationState(isShowLoading: true));
        final response = await repository.loadNotifications(event.page);
        emit(LoadNotificationsState(response));
      });
      on<ReadAllNotificationEvent>((event, emit) async {
        emit(NotificationState(isShowLoading: true));
        final response = await repository.readAllNotification();
        emit(ReadAllNotificationState(response));
      });
      on<DeleteAllNotificationsEvent>((event, emit) async {
        emit(NotificationState(isShowLoading: true));
        final response = await repository.deleteAllNotification();
        emit(response.checkOK(passString: true) ? DeleteAllNotificationsState(response) : NotificationState());
      });
      return;
    }

    on<SeenNotificationEvent>((event, emit) async {
      emit(NotificationState(isShowLoading: true));
      final response = await repository.seenNotification(event.id);
      emit(SeenNotificationState(response));
    });
    on<DeleteNotificationEvent>((event, emit) async {
      emit(NotificationState(isShowLoading: true));
      final response = await repository.deleteNotification(event.id);
      emit(DeleteNotificationState(response));
    });
    on<LoadDetailEvent>((event, emit) async {
      emit(NotificationState(isShowLoading: true));
      dynamic resp, success;
      switch(event.type) {
        case 'image':
          resp = await repository.loadPost(event.id);
          if (resp.checkOK()) {
            int i = 0, n = resp.data.images.list.length;
            for(; i < n; i++) {
              if (event.ext == resp.data.images.list[i].id) break;
            }
            emit(LoadDetailState(resp, event.type, i));
          } else emit(NotificationState());
          return;
        case 'marketplace':
          resp = await repository.loadMarketPrice(event.id);
          if (resp.isNotEmpty) {
            try {
              final json = jsonDecode(resp);
              if (Util.checkKeyFromJson(json, 'market_place') && json['success']) {
                final market = MarketPriceModel().fromJson(json['market_place']);
                try {
                  if (Util.checkKeyFromJson(json, 'data') && json['data'].isNotEmpty) {
                    market.lastDetail.fromJson(json['data'][0]);
                  }
                } catch (_) {}
                emit(LoadDetailState(BaseResponse(success: true, data: market), event.type, event.ext));
                return;
              }
            }
            catch (_) {}
          }
          emit(NotificationState());
          return;
        case 'post':
          resp = await repository.loadPost(event.id);
          break;
        case 'shop':
          resp = await repository.loadShop(event.id);
          break;
        case 'comment':
          resp = await repository.loadComment(event.id);
          break;
        case 'invoiceuser':
          resp = await repository.loadOrder(event.id);
          break;
        case 'plot':
          resp = await repository.loadPlot(event.id);
          break;
        case 'material':
          resp = await repository.loadMaterial(event.id);
          break;
        case 'process_engineering_information':
          resp = await repository.loadFarm(event.id);
          break;
        case 'product_introduction':
          resp = await ApiClient().getAPI(Constants().apiVersion + 'products/${event.id}', ProductModel());
          break;
        case 'mission_detail':
          resp = await ApiClient().getData('mission/missions/${event.id}', getError: true);
          success = !resp.containsKey('error');
          resp = BaseResponse(success: success, data: success ? resp : resp['error']);
          break;
        case 'membership_packages':
          resp = await ApiClient().getData('membership_packages/membership_packages/${event.id}', getError: true);
          success = !resp.containsKey('error');
          resp = BaseResponse(success: success, data: success ? resp : resp['error']);
          break;
        case 'contributionmission':
          resp = await ApiClient().getData('contribution_missions/${event.id}', getError: true);
          success = !resp.containsKey('error');
          resp = BaseResponse(success: success, data: success ? resp : resp['error']);
          break;
        case 'new_coupon':
          resp = await ApiClient().getData('coupons/${event.id}', getError: true);
          success = !resp.containsKey('error');
          resp = BaseResponse(success: success, data: success ? resp : resp['error']);
          break;
        case 'training_data':
          resp = await ApiClient().getAPI(Constants().apiVersion + 'diagnostics/training_data_detail/${event.id}', TrainConModel());
          break;
      }
      emit(LoadDetailState(resp, event.type, event.ext));
    });
  }
}
