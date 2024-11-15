import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'weather_list_province_model.dart';
import 'weather_model.dart';
import 'package:hainong/features/profile/profile_bloc.dart';
import 'package:hainong/features/signup/sign_up_repository.dart';

class LoadAudioWeatherEvent extends BaseEvent {
  final String lat;
  final String lon;
  final bool isRequest;
  LoadAudioWeatherEvent(this.lat,this.lon,{this.isRequest = false});
}
class LoadAudioWeatherState extends BaseState {
  final String data;
  final bool isRequest;
  LoadAudioWeatherState(this.data,this.isRequest);
}

class GetLatLonAddressEvent extends BaseEvent {
  final String address;
  GetLatLonAddressEvent(this.address);
}
class GetLatLonAddressState extends BaseState {
  final BaseResponse response;
  final String lat;
  final String lon;
  GetLatLonAddressState(this.response,this.lat,this.lon);
}

class LoadDetailWeatherEvent extends BaseEvent {
  final String lat;
  final String lon;
  final bool openModule, isSendLocation;
  LoadDetailWeatherEvent(this.lat,this.lon, {this.openModule = false, this.isSendLocation = false});
}
class LoadDetailWeatherState extends BaseState {
  final BaseResponse response;
  LoadDetailWeatherState(this.response);
}

class LoadListWeatherEvent extends BaseEvent {
  final int? page;
  LoadListWeatherEvent({this.page});
}
class LoadListWeatherState extends BaseState {
  final BaseResponse response;
  const LoadListWeatherState(this.response);
}

class LoadWeatherEvent extends BaseEvent {
  final String province_id;
  final String province_name;
  final bool isLogin;
  LoadWeatherEvent(this.province_id,this.province_name,{this.isLogin = true});
}
class LoadWeatherState extends BaseState {
  final BaseResponse response;
  LoadWeatherState(this.response);
}

class PlayAudioEvent extends BaseEvent {
  final bool value;
  PlayAudioEvent(this.value);
}
class PlayAudioState extends BaseState {
  final bool value;
  PlayAudioState(this.value);
}

class LoadingAudioEvent extends BaseEvent {
  final bool value;
  LoadingAudioEvent(this.value);
}
class LoadingAudioState extends BaseState {
  final bool value;
  LoadingAudioState(this.value);
}

class LoadNegativeWeatherStatusEvent extends BaseEvent{}

class ChangeNegativeWeatherStatusEvent extends BaseEvent {
  final int id;
  final String status;
  ChangeNegativeWeatherStatusEvent(this.id,this.status);
}

class LoadNegativeWeatherStatusState extends BaseState {
  dynamic response;
  LoadNegativeWeatherStatusState(this.response);
}
class ChangeNegativeWeatherStatusState extends BaseState {
  final BaseResponse response;
  final String status;
  ChangeNegativeWeatherStatusState(this.response,this.status);
}

class WeatherBloc extends BaseBloc {
  WeatherBloc({String type = ''}) {
    switch (type) {
      case 'setting':
        on<LoadListWeatherEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          final list = await ApiClient().getList('notice_schedules?', page: event.page!, limit: 20, isOnePage: true);
          emit(LoadListWeatherState(BaseResponse(success: list.isNotEmpty, data: list)));
        });
        on<LoadAudioWeatherEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          final resp = await ApiClient().postAPI2(Constants().apiVersion + 'notice_schedules/' + event.lat, method: 'PUT',
              body: {'status': event.isRequest ? 'sent' : 'unsent'});
          final data = await ApiClient().getDataFromString(resp, getError: true);
          final error = data['error']??'';
          emit(error.isEmpty ? GetLatLonAddressState(BaseResponse(success: true, data: data),
              event.lat, event.lon) : LoadAudioWeatherState(error, false));
        });
        break;
      default:
        on<LoadingAudioEvent>((event, emit) async {
          if (event.value) {
            emit(LoadingAudioState(true));
            await Future.delayed(const Duration(milliseconds: 10000));
          }
          emit(LoadingAudioState(false));
        });
        on<LoadWeatherEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          final response = await ApiClient().getAPI(Constants().apiVersion + 'weather?${event.isLogin ? 'id=${event.province_id}' : 'province_name=${event.province_name}'}',
              WeatherModel(), hasHeader: true);
          emit(LoadDetailWeatherState(response));
        });
        on<LoadListWeatherEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          final response = await ApiClient().getAPI(Constants().apiVersion + 'weather/weather_places', WeatherListModels(), hasHeader: false);
          emit(LoadListWeatherState(response));
        });
        on<GetLatLonAddressEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          final response = await ApiClient().getAPI(
              Constants().apiVersion + 'locations/latlong?address=${event.address}', WeatherListModel(), hasHeader: false);
          if (response.checkOK()) {
            emit(GetLatLonAddressState(response, response.data.lat, response.data.lng));
          } else {
            emit(GetLatLonAddressState(response, '', ''));
          }
        });
        on<LoadAudioWeatherEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          String temp = '';
          if (event.lat.isNotEmpty && event.lon.isNotEmpty) temp = '?lat=${event.lat}&lng=${event.lon}';
          final response = await ApiClient().getAPI(Constants().apiVersion + 'weather/details_audio_link$temp', BaseResponse(), hasHeader: true);
          emit(LoadAudioWeatherState(response.data != "null" && response.data != null ? response.data : '', event.isRequest));
        });
        on<LoadDetailWeatherEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          String temp = '';
          if (event.lat.isNotEmpty && event.lon.isNotEmpty) temp = '?lat=${event.lat}&lng=${event.lon}${event.openModule ? "&open_module=true" : ""}';
          final response = await ApiClient().getAPI(Constants().apiVersion + 'weather/details$temp', WeatherModel(), hasHeader: true);
          emit(LoadDetailWeatherState(response));

          if (event.isSendLocation) {
            ApiClient().postAPI(Constants().apiVersion + 'weather/user_location', 'POST', BaseResponse(), body: {'lat': event.lat, 'lng': event.lon});
          }
        });
        on<LoadProvinceProfileEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          final response = await SignUpRepository().loadProvince();
          emit(LoadProvinceProfileState(response));
        });
        on<PlayAudioEvent>((event, emit) => emit(PlayAudioState(event.value)));
        on<LoadNegativeWeatherStatusEvent>((event, emit) async {
          final resp = await ApiClient().getData('negative_weather_notices');
          if (resp != null) emit(LoadNegativeWeatherStatusState(resp));
        });
        on<ChangeNegativeWeatherStatusEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          final resp = await ApiClient().postJsonAPI(Constants().apiVersion + 'negative_weather_notices/${event.id}',BaseResponse(),{'status': event.status},method: 'PUT');
          if (resp.checkOK(passString: true)) emit(ChangeNegativeWeatherStatusState(resp, event.status));
        });
    }
  }
}