import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/features/login/login_model.dart';
import '../gift_catalog_model.dart';
import '../gift_history_model.dart';
import '../gift_model.dart';
import '../receive_point_model.dart';
import '../topup_data_model.dart';

abstract class GiftEvent extends BaseEvent {}

class LoadReceivePointEvent extends GiftEvent {}
class LoadGiftEvent extends GiftEvent{
  final int page;
  final int catalog_id;
  LoadGiftEvent(this.catalog_id,this.page);
}
class LoadListTopUpEvent extends GiftEvent{}
class LoadCatalogEvent extends GiftEvent {}
class LoadHistoryGiftEvent extends GiftEvent {
  final int page;
  LoadHistoryGiftEvent(this.page);
}
class ChangeMenuCatalogEvent extends GiftEvent {
  final int index;
  ChangeMenuCatalogEvent(this.index);
}
class GetInfoEvent extends GiftEvent {}
class ChangeGiftEvent extends GiftEvent {
  final int store_id;
  final String store_type;
  ChangeGiftEvent(this.store_id,this.store_type);
}
class ChangeTopUpEvent extends GiftEvent {
  final int package_id;
  ChangeTopUpEvent(this.package_id);
}
class ExpandedTopUpEvent extends GiftEvent {
  final bool expanded;
  ExpandedTopUpEvent(this.expanded);
}
class LoadReceivePointState extends BaseState {
  final BaseResponse response;
  LoadReceivePointState(this.response);
}
class GetInfoState extends BaseState {
  final BaseResponse response;
  GetInfoState(this.response);
}
class ExpandedTopUpState extends BaseState {
  final bool expanded;
  ExpandedTopUpState(this.expanded);
}
class ChangeMenuCatalogState extends BaseState {
  final int index;
  ChangeMenuCatalogState(this.index);
}
class LoadCatalogState extends BaseState {
  final BaseResponse response;
  LoadCatalogState(this.response);
}
class LoadListTopUpState extends BaseState {
  final BaseResponse response;
  LoadListTopUpState(this.response);
}
class ChangeGiftState extends BaseState {
  final BaseResponse response;
  ChangeGiftState(this.response);
}
class ChangeTopUpState extends BaseState {
  final BaseResponse response;
  ChangeTopUpState(this.response);
}
class LoadGiftState extends BaseState {
  final BaseResponse response;
  LoadGiftState(this.response);
}
class LoadHistoryGiftState extends BaseState {
  final BaseResponse response;
  LoadHistoryGiftState(this.response);
}

class GiftBloc extends BaseBloc {
  GiftBloc({BaseState init = const BaseState()}):super(init:init) {
    on<LoadGiftEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      String temp = event.catalog_id == -1
          ? ""
          : "store_gift_catalogue_id= ${event.catalog_id}";
      final response = await ApiClient().getAPI(
          '${Constants().apiVersion}gifts/store_gifts?${temp}&page=${event
              .page}&limit=20', GiftModels());
      emit(LoadGiftState(response));
    });
    on<LoadReceivePointEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final response = await ApiClient().getAPI(
          '${Constants().apiVersion}point_settings', ReceivePointsModel());
      emit(LoadReceivePointState(response));
    });
    on<LoadHistoryGiftEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final response = await ApiClient().getAPI(
          '${Constants().apiVersion}gifts/points_transactions?page=${event
              .page}&limit=15', GiftHistoryModels());
      emit(LoadHistoryGiftState(response));
    });
    on<LoadListTopUpEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final response = await ApiClient().getAPI(
          '${Constants().apiVersion}topup_data', TopUpModels());
      emit(LoadListTopUpState(response));
    });
    on<LoadCatalogEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final response = await ApiClient().getAPI(
          '${Constants().apiVersion}gifts/catalogues', GiftCatalogModels());
      emit(LoadCatalogState(response));
    });
    on<ChangeMenuCatalogEvent>((event, emit) {
      emit(ChangeMenuCatalogState(event.index));
    });
    on<ExpandedTopUpEvent>((event, emit) {
      emit(ExpandedTopUpState(!event.expanded));
    });
    on<GetInfoEvent>((event, emit) async {
      final response = await ApiClient().getAPI(
          '${Constants().apiVersion}account/profile', LoginModel());
      emit(GetInfoState(response));
    });
    on<ChangeGiftEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final response = await ApiClient().postAPI(
          '${Constants().apiVersion}gifts/exchange_points', "POST",
          BaseResponse(),
          body: {
            "store_id": event.store_id.toString(),
            "store_type": event.store_type
          }
      );
      emit(ChangeGiftState(response));
    });
    on<ChangeTopUpEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final response = await ApiClient().postAPI('${Constants().apiVersion}topup_data',"POST",BaseResponse(),
          body: {
            "package_id": event.package_id.toString(),
          }
      );
      emit(ChangeTopUpState(response));
    });
  }
}