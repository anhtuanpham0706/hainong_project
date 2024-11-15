import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/login/login_model.dart';
import '../features/function/module_model.dart';
import '../features/main/bloc/main_bloc.dart';
import 'api_client.dart';
import 'base_response.dart';
import 'constants.dart';
import 'database_helper.dart';

class BaseState {
  final bool isShowLoading;
  const BaseState({this.isShowLoading = false});
}

class GetModulesState extends MainState {
  final ModuleModels data;
  GetModulesState(this.data);
}

class CheckMemPackageState extends BaseState {
  dynamic resp;
  CheckMemPackageState(this.resp);
}

class GetProfileState extends BaseState {
  BaseResponse data;
  GetProfileState(this.data);
}

class GetBannerState extends BaseState {
  dynamic resp;
  GetBannerState(this.resp);
}

class GetInfoPopupState extends BaseState {
  dynamic resp;
  GetInfoPopupState(this.resp);
}

class ShowErrorState extends BaseState {
  dynamic resp;
  ShowErrorState(this.resp);
}

class LoadStatusMemberPackageState extends MainState {
  final bool isSign;
  LoadStatusMemberPackageState(this.isSign);
}

class BaseEvent {}

class LoadStatusMemberPackageEvent extends MainEvent{}

class LoadingEvent extends BaseEvent {
  final bool value;
  LoadingEvent(this.value);
}

class GetInfoPopupEvent extends BaseEvent {
  final String type;
  GetInfoPopupEvent(this.type);
}

class TrackEvent extends BaseEvent {
  final String method, path, function;
  TrackEvent(this.path, this.function, {this.method = 'onTap'});
}

class GetModulesEvent extends BaseEvent {}

class CheckMemPackageEvent extends BaseEvent {
  final String feature;
  CheckMemPackageEvent(this.feature);
}

class GetBannerEvent extends BaseEvent {
  final String position, location;
  GetBannerEvent(this.position, this.location);
}

class UpdateMemPackageEvent extends BaseEvent {
  final String feature;
  UpdateMemPackageEvent(this.feature);
}

class GetProfileEvent extends BaseEvent {}

class BaseBloc extends Bloc<BaseEvent, BaseState> {
  dynamic data;
  @override
  Future<void> close() async {
    data?.clear();
    super.close();
  }

  BaseBloc({BaseState init = const BaseState(), bool hasMemPackage = false, bool hasAds = false, String typeInfo = '', bool hasBanner = false, bool hasUpdateInfo = false}) : super(init) {
    on<LoadingEvent>((event, emit) => emit(BaseState(isShowLoading: event.value)));
    on<TrackEvent>((event, emit) {
      ApiClient().trackApp(event.path, event.function, method: event.method);
    });
    if (hasMemPackage) {
      on<CheckMemPackageEvent>((event, emit) async {
        emit(const BaseState(isShowLoading: true));
        final resp = await ApiClient().getData('membership_packages/membership_package_toggles/get_current_used_times?feature_key='+event.feature, getError: true);
        emit(CheckMemPackageState(resp));
      });
      on<UpdateMemPackageEvent>((event, emit) async {
        ApiClient().postAPI(Constants().apiVersion + 'membership_packages/membership_package_toggles/update_used_times?feature_key='+event.feature, 'PUT', BaseResponse());
      });
    }
    if (hasAds) {
      on<CheckMemPackageEvent>((event, emit) async {
        emit(const BaseState(isShowLoading: true));
        final resp = await ApiClient().getData('advertisements?show_position='+event.feature, hasHeader: false);
        emit(CheckMemPackageState(resp));
      });
    }
    if (hasBanner) {
      on<GetBannerEvent>((event, emit) async {
        final data = await _getBannerFromDB(event.position, event.location);
        if (data != null) emit(GetBannerState(data));

        final resp = await _getBannerFromApi(event.position, event.location);
        if (resp != null) emit(GetBannerState(resp));
      });
    }
    if(typeInfo.isNotEmpty){
      on<GetInfoPopupEvent>((event, emit) async {
        emit(const BaseState(isShowLoading: true));
        final resp = await ApiClient().getData('defination_lists/active_payload?app_type='+event.type,hasHeader: false);
        data = resp;
        emit(GetInfoPopupState(resp));
      });
      add(GetInfoPopupEvent(typeInfo));
    }
    if(hasUpdateInfo){
      on<GetProfileEvent>((event, emit) async {
        final response = await ApiClient().getAPI('${Constants().apiVersion}account/profile', LoginModel());
        if(response.checkOK()){
          SharedPreferences.getInstance().then((prefs) {
            prefs.setInt('points', response.data.points);
          });
          emit(GetProfileState(response));
        }
      });
      add(GetProfileEvent());
    }
  }

  FutureOr<dynamic> _getBannerFromDB(String pos, String loc) async {
    String cond = 'is_view = 0 AND show_position = "$pos"';
    if (loc.isNotEmpty) cond += ' AND location = "$loc"';
    dynamic list = await DBHelper().getAllJsonWithCond('banner', cond: cond, limit: 1, orderBy: 'order_ban');
    if (list != null && list.isNotEmpty) return list.first;
    return null;
  }

  FutureOr<dynamic> _getBannerFromApi(String pos, String loc) async {
    String temp = loc.isEmpty ? '' : '&location=' + loc;
    dynamic first;
    final json = await ApiClient().getData('banners?show_position=' + pos + temp, hasHeader: false);
    if (json != null) {
      final db = DBHelper();
      temp = 'show_position';
      if (loc.isNotEmpty) temp += ' = "$pos" AND location';
      await db.updateHelper(temp, loc.isEmpty ? pos : loc, tblName: 'banner', values: {'is_use': 0});
      for(var item in json) {
        final temp = await db.getJsonById('id', item['id'], 'banner');
        final data = {
          "id": item['id'] ?? -1,
          "name": item['name'] ?? '',
          "description": item['description'] ?? '',
          "image": item['image'] ?? '',
          "show_position": item['show_position'] ?? '',
          "order_ban": item['order'] ?? -1,
          "location": item['location'] ?? 'bottom',
          "classable_type": item['classable_type'] ?? '',
          "classable_id": item['classable_id'] ?? -1,
          "is_use": 1,
          if (temp == null) "is_view": 0
        };
        if (temp == null) {
          first ??= data;
          await db.insertHelper(tblName: 'banner', values: data);
        } else {
          if (temp['is_view'] == 0 && first == null) first = data;
          await db.updateHelper('id', data['id'], tblName: 'banner', values: data);
        }
      }

      if (first != null) {
        db.updateHelper('id', first['id'], values: {'is_view': 1}, tblName: 'banner');
      } else {
        temp = 'is_use = 1 AND is_view = 1 AND show_position = "$pos"';
        if (loc.isNotEmpty) temp += ' AND location = "$loc"';
        dynamic list = await db.getAllJsonWithCond('banner', cond: temp, limit: 1, orderBy: 'order_ban');
        if (list != null && list.isNotEmpty) {
          first = list.first;
          temp = 'is_use = 1 AND is_view = 1 AND show_position';
          if (loc.isNotEmpty) temp += ' = "$pos" AND location';
          await db.updateHelper(temp, loc.isEmpty ? pos : loc, values: {'is_view': 0}, tblName: 'banner');
          db.updateHelper('id', first['id'], values: {'is_view': 1}, tblName: 'banner');
        }
      }

      temp = 'is_use = 0 AND show_position';
      if (loc.isNotEmpty) temp += ' = "$pos" AND location';
      db.deleteHelper(temp, loc.isEmpty ? pos : loc, 'banner');
    }
    return first;
  }
}