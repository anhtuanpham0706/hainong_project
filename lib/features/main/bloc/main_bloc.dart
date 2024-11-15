import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/database_helper.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/common/util/util_ui.dart';
import 'package:hainong/features/function/module_model.dart';
import 'package:hainong/features/main/main_repository.dart';
import 'package:hainong/features/shop/ui/import_ui_shop.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main2/ui/search/models/home_search_model.dart';
import '../../main2/ui/search/models/home_search_params.dart';
import 'package:chat_call_core/presentation/chat/models/stream_response_model.dart';
import 'package:hainong/features/function/info_news/market_price/model/market_price_model.dart';
import 'package:chat_call_core/core/models/expert_model.dart';

abstract class MainState extends BaseState {
  final int index;
  final dynamic subPage;
  MainState({this.index = 2, this.subPage});
}

class ChangeIndexState extends MainState {
  ChangeIndexState({int index = 2, dynamic subPage})
      : super(index: index, subPage: subPage);
}

class LogoutMainState extends MainState {
  LogoutMainState({index = 2, subPage}) : super(index: index, subPage: subPage);
}

class CountNotificationMainState extends MainState {
  final BaseResponse response;
  final bool? loadList;
  CountNotificationMainState(this.response, int index, this.loadList) : super(index: index);
}

class CountCartMainState extends BaseState {
  final int value;
  CountCartMainState(this.value);
}

abstract class MainEvent extends BaseEvent {
  final int index;
  final dynamic subPage;
  MainEvent({this.index = 2, this.subPage});
}

class CountCartMainEvent extends BaseEvent {}

class ChangeIndexEvent extends MainEvent {
  ChangeIndexEvent({int index = 2, dynamic subPage})
      : super(index: index, subPage: subPage);
}

class LoadPestsMainEvent extends MainEvent {}

class CountNotificationMainEvent extends MainEvent {
  final bool? loadList;
  CountNotificationMainEvent({this.loadList});
}

class LogoutMainEvent extends MainEvent {}

class GetLocationEvent extends MainEvent {
  final String lat, lon;
  final bool isUpdate;
  GetLocationEvent(this.lat, this.lon, {this.isUpdate = false});
}

class GetLocationState extends MainState {
  final BaseResponse response;
  GetLocationState(this.response);
}

class MessageOpenEvent extends MainEvent {
  final RemoteMessage message;
  MessageOpenEvent(this.message);
}

class MessageOpenState extends MainState {
  final RemoteMessage message;
  MessageOpenState(this.message, int index) : super(index: index);
}

class MessageEvent extends MainEvent {
  final RemoteMessage message;
  MessageEvent(this.message);
}

class MessageState extends MainState {
  final RemoteMessage message;
  MessageState(this.message, int index) : super(index: index);
}

class HideTextFieldEvent extends MainEvent {
  final bool hideKeyboard;
  HideTextFieldEvent(this.hideKeyboard);
}

class HideTextFieldState extends MainState {
  final bool hideKeyboard;
  HideTextFieldState(this.hideKeyboard);
}

class ReloadSubCommentEvent extends BaseEvent {}

class ReloadSubCommentState extends BaseState {}

class ReloadListCommentEvent extends BaseEvent {}

class ReloadListCommentState extends BaseState {}

class LoadHeaderEvent extends MainEvent {}

class LoadHeaderState extends MainState {}

class GetHomeSearchMainEvent extends MainEvent {
  final HomeSearchParams params;
  GetHomeSearchMainEvent(this.params);
}

class HomeSearchMainState extends MainState {
  final List<HomeSearchModel> data;
  HomeSearchMainState(this.data);
}

class LoadingSearchEvent extends MainEvent {
  final bool isLoading;
  LoadingSearchEvent(this.isLoading);
}

class LoadingSearchState extends MainState {
  final bool isLoading;
  LoadingSearchState(this.isLoading);
}

class CallSuggestEvent extends MainEvent {
  final StreamResponseModel response;
  final bool? isSuggestCall;
  CallSuggestEvent(this.response, {this.isSuggestCall = true});
}

class CallSuggestState extends MainState {
  final StreamResponseModel response;
  final bool? isSuggestCall;
  CallSuggestState(this.response, {this.isSuggestCall = true});
}

class GetDetailMainEvent extends MainEvent {
  final String type, id;
  dynamic extend;
  GetDetailMainEvent(this.id, this.type, {this.extend});
}
class GetDetailMainState extends MainState {
  dynamic data, extend;
  final String type;
  GetDetailMainState(this.data, this.type, {this.extend});
}

class CheckProductReferralPointEvent extends MainEvent {
  final String id;
  final String referralCode;
  CheckProductReferralPointEvent(this.id, this.referralCode);
}
class CheckProductReferralPointState extends MainState {
  final String id, referralCode;
  final bool isReferral;
  CheckProductReferralPointState(this.isReferral, this.id, this.referralCode);
}

class ClosePopupEvent extends MainEvent {}
class ClosePopupState extends MainState {}

class ShowPopupAdsMainState extends MainState {
  final dynamic ads;
  ShowPopupAdsMainState(this.ads);
}

class MainBloc extends BaseBloc {
  final repository = MainRepository();

  MainBloc(ChangeIndexState init) : super(init: init) {
    on<GetModulesEvent>((event, emit) async {
      final modules = await DBHelperUtil().getModules();
      if (modules != null) emit(GetModulesState(modules));

      var info = await UtilUI.getDeviceInfo();
      final resp = await ApiClient().getAPI(Constants().apiVersion + 'app_modules?id=' + info['imei']!, ModuleModels());
      if (resp.checkOK()) emit(GetModulesState(resp.data));
    });
    on<LoadHeaderEvent>((event, emit) => emit(LoadHeaderState()));
    on<ClosePopupEvent>((event, emit) => emit(ClosePopupState()));
    on<ReloadListCommentEvent>((event, emit) => emit(ReloadListCommentState()));
    on<ReloadSubCommentEvent>((event, emit) => emit(ReloadSubCommentState()));
    on<HideTextFieldEvent>((event, emit) => emit(HideTextFieldState(event.hideKeyboard)));
    on<MessageOpenEvent>((event, emit) =>
        emit(MessageOpenState(event.message, (state as MainState).index)));
    on<MessageEvent>((event, emit) =>
        emit(MessageState(event.message, (state as MainState).index)));
    on<LoadPestsMainEvent>((event, emit) async {
      final ads = await _getAds();
      if (ads != null) emit(ShowPopupAdsMainState(ads));
      final response = await repository.getPests();
      if (response.checkOK() && response.data.list.length > 0) {
        final List<String> pests = [];
        response.data.list.forEach((ele) => pests.add(ele.name.toLowerCase()));
        final prefs = await SharedPreferences.getInstance();
        prefs.setStringList('pests', pests);
        pests.clear();
      }
      repository.lastActivity();
    });
    on<LogoutMainEvent>((event, emit) {
      UtilUI.logout();
      emit(LogoutMainState(
          index: (state as MainState).index,
          subPage: (state as MainState).subPage));
    });
    on<CountNotificationMainEvent>((event, emit) async {
      final response = await repository.countNotification();
      emit(CountNotificationMainState(response, (state as MainState).index, event.loadList));
    });
    on<GetLocationEvent>((event, emit) async {
      if (event.isUpdate) {
        ApiClient().postAPI(Constants().apiVersion + 'weather/user_location', 'POST', BaseResponse(), body: {'lat': event.lat, 'lng': event.lon});
        return;
      }
      final resp = await ApiClient().getAPI2('${Constants().apiVersion}locations/address_full?lat=${event.lat}&lng=${event.lon}', hasHeader: false);
      if (resp.isNotEmpty) {
        dynamic json = jsonDecode(resp);
        if (Util.checkKeyFromJson(json, 'success') && json['success'] && Util.checkKeyFromJson(json, 'data')) {
          json = json['data'];
          if (Util.checkKeyFromJson(json, 'province_name')) emit(GetLocationState(BaseResponse(success: true, data: json['province_name'])));
        }
      }
    });
    on<ChangeIndexEvent>((event, emit) => emit(ChangeIndexState(
        index: event.index > -1 ? event.index : (state as MainState).index,
        subPage: event.subPage)));
    on<GetHomeSearchMainEvent>((event, emit) async {
      emit(LoadingSearchState(true));
      final response = await repository.getSearchHome(event.params);
      if (response.checkOK()) {
        emit(HomeSearchMainState(response.data.list));
        emit(LoadingSearchState(false));
      }
    });
    on<LoadingSearchEvent>((event, emit) {
      emit(LoadingSearchState(event.isLoading));
    });
    on<CallSuggestEvent>((event, emit) {
      emit(CallSuggestState(event.response, isSuggestCall: event.isSuggestCall));
    });
    on<CountCartMainEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final cart = Util.getCarts(prefs);
      int count = 0;
      cart.forEach((key, value) {
        for (int i = value.items.length - 1; i > -1; i--) {
          count += value.items[i].quantity.toInt();
        }
      });
      emit(CountCartMainState(count));
    });
    on<CheckProductReferralPointEvent>((event, emit) async {
      final response = await repository.checkProductReferralPoint(event.id, event.referralCode);
      if (response.isNotEmpty) {
        Map<String, dynamic> json = jsonDecode(response);
        if (Util.checkKeyFromJson(json, 'success') && json['success']) {
          final isReferral = json['data'];
          emit(CheckProductReferralPointState(isReferral, event.id, event.referralCode));
          return;
        }
      }
      emit(CheckProductReferralPointState(false, event.id, ""));
    });
    on<GetDetailMainEvent>((event, emit) async {
      dynamic resp;
      switch(event.type) {
        case 'expert':
          resp = await repository.getExpertDetail(event.id);
          if (resp.isNotEmpty) {
            Map<String, dynamic> json = jsonDecode(resp);
            if (Util.checkKeyFromJson(json, 'success') && Util.checkKeyFromJson(json, 'data') && json['success']) {
              final expert = ExpertModel.fromJson(json['data']);
              if (expert.id != null) emit(GetDetailMainState(expert, event.type));
            }
          }
          break;
        case 'product':
          resp = await repository.getProductDetail(event.id);
          if (resp.checkOK()) emit(GetDetailMainState(resp!.data, event.type, extend: event.extend));
          break;
        case 'post':
          resp = await repository.getPostDetail(event.id);
          if (resp.checkOK()) emit(GetDetailMainState(resp!.data, event.type));
          break;
        case 'news':
          resp = await repository.getArticleDetail(event.id);
          if (resp.checkOK()) emit(GetDetailMainState(resp!.data, event.type, extend: event.extend));
          break;
        case 'market_price':
          resp = await repository.getMarketPriceDetail(event.id);
          if (resp.isNotEmpty) {
            dynamic json = jsonDecode(resp);
            if (Util.checkKeyFromJson(json, 'success') && json['success'] && Util.checkKeyFromJson(json, 'market_place')) {
              final mp = MarketPriceModel().fromJson(json['market_place']);
              if (Util.checkKeyFromJson(json, 'data') && json['data'].length > 0) mp.lastDetail.fromJson(json['data'][0]);
              emit(GetDetailMainState(mp, event.type));
            }
          }
          break;
        case 'mini_game':
          resp = await ApiClient().getAPI2(Constants().apiVersion + 'mini_events/${event.id}');
          if (resp.isNotEmpty) {
            Map<String, dynamic> json = jsonDecode(resp);
            if (Util.checkKeyFromJson(json, 'success') && Util.checkKeyFromJson(json, 'data') && json['success']) {
              final pref = await SharedPreferences.getInstance();
              final String phone = pref.getString("phone")??'', fullName = Uri.encodeFull(pref.getString("name")??''),
                  id = (pref.getInt("id")??'').toString();
              String _env = pref.getString("env") ?? '';
              if (_env.isNotEmpty) _env += '.';

              switch(json['data']['group_name']) {
                case 'millionaire':
                  json['data'].update('image', (value) => 'assets/images/v5/ic_game_trieuphu.png', ifAbsent: () => 'assets/images/v5/ic_game_trieuphu.png');
                  json['data'].update('help', (value) => 'https://help.hainong.vn/muc/14', ifAbsent: () => 'https://help.hainong.vn/muc/14');
                  json['data'].update('des', (value) => 'Thử tài kiến thức nông nghiệp', ifAbsent: () => 'Thử tài kiến thức nông nghiệp');
                  json['data'].update('url', (value) => 'https://trieuphu2nong.2nong.vn?phone=$phone&fullname=$fullName&secret=ca6NAuSXAURHLqrSKgpiYZNoSoyIXpI9cPYEER/YvmU=&app_id=cho2nong',
                      ifAbsent: () => 'https://trieuphu2nong.2nong.vn?phone=$phone&fullname=$fullName&secret=ca6NAuSXAURHLqrSKgpiYZNoSoyIXpI9cPYEER/YvmU=&app_id=cho2nong');
                  break;
                case 'lucky_wheel':
                  json['data'].update('image', (value) => 'assets/images/v5/ic_game_vongquay.png',
                      ifAbsent: () => 'assets/images/v5/ic_game_vongquay.png');
                  json['data'].update('help', (value) => 'https://help.hainong.vn/muc/13',
                      ifAbsent: () => 'https://help.hainong.vn/muc/13');
                  json['data'].update('des', (value) => 'Thử tài vòng quay may mắn', ifAbsent: () => 'Thử tài vòng quay may mắn');
                  json['data'].update('url', (value) => 'https://${_env}luckywheel.event.hainong.vn/user/'+id,
                      ifAbsent: () => 'https://${_env}luckywheel.event.hainong.vn/user/'+id);
                  break;
              }
              emit(GetDetailMainState(json['data'], event.type));
            }
          }
          break;
        case 'handbook_of_pest':
          resp = await repository.getPestHandbookDetail(event.id);
          if (resp.checkOK()) emit(GetDetailMainState(resp!.data, event.type));
          break;
        case 'technical_process':
          resp = await repository.getTechProcessDetail(event.id);
          if (resp.checkOK()) emit(GetDetailMainState(resp!.data, event.type));
          break;
        case 'knowledge_handbook':
          resp = await repository.getHandbookDetail(event.id);
          if (resp.checkOK()) emit(GetDetailMainState(resp!.data, event.type));
          break;
        default:
          if (event.type == 'all_missions' || event.type == 'current_joins' || event.type == 'user_missions') {
            resp = await ApiClient().getAPI2(Constants().apiVersion + 'mission/missions/${event.id}');
            if (resp.isNotEmpty) {
              Map<String, dynamic> json = jsonDecode(resp);
              if (Util.checkKeyFromJson(json, 'success') && Util.checkKeyFromJson(json, 'data')
                  && json['success']) emit(GetDetailMainState(json['data'], event.type, extend: event.extend??''));
            }
          }
      }
    });
  }

  FutureOr<dynamic> _getAds() async {
    dynamic first;
    final resp = await ApiClient().getAPI2(Constants().apiVersion + 'popup_advertisements');
    if (resp.isNotEmpty) {
      Map<String, dynamic> json = jsonDecode(resp);
      if (Util.checkKeyFromJson(json, 'success') && Util.checkKeyFromJson(json, 'data') && json['success']) {
        final db = DBHelper();
        await db.updateHelper('is_use', 1, tblName: 'ads5', values: {'is_use': 0});
        for(var item in json['data']) {
          final temp = await db.getJsonById('id', item['id'], 'ads5');
          final data = {
            "id": item['id'] ?? -1,
            "name": item['name'] ?? '',
            "description": item['description'] ?? '',
            "image": item['image'] ?? '',
            "show_position": item['show_position'] ?? '',
            "display_order": item['display_order'] ?? -1,
            "popup_type": item['popup_type'] ?? -1,
            "classable_type": item['classable_type'] ?? '',
            "classable_id": item['classable_id'] ?? -1,
            "is_use": 1,
            if (temp == null) "is_view": 0
          };
          if (temp == null) {
            first ??= data;
            await db.insertHelper(tblName: 'ads5', values: data);
          } else {
            if (temp['is_view'] == 0 && first == null) first = data;
            await db.updateHelper('id', data['id'], tblName: 'ads5', values: data);
          }
        }
        if (first != null) {
          db.updateHelper('id', first['id'], values: {'is_view': 1}, tblName: 'ads5');
        } else {
          dynamic list = await db.getAllJsonWithCond('ads5', cond: 'is_view = 1', limit: 1, orderBy: 'display_order');
          if (list != null && list.isNotEmpty) {
            first = list.first;
            await db.updateHelper('is_view', 1, values: {'is_view': 0}, tblName: 'ads5');
            db.updateHelper('id', first['id'], values: {'is_view': 1}, tblName: 'ads5');
          }
        }
        db.deleteHelper('is_use', 0, 'ads5');
      }
    }
    return first;
  }
}
