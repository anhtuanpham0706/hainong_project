import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/features/function/info_news/weather/weather_bloc.dart';
import 'package:hainong/features/function/info_news/weather/weather_list_province_model.dart';
import 'package:hainong/features/function/support/handbook/handbook_bloc.dart';
import 'package:hainong/features/main/bloc/main_bloc.dart';
import 'package:hainong/features/profile/profile_bloc.dart';
import 'package:hainong/features/signup/sign_up_repository.dart';
import 'package:trackasia_gl/mapbox_gl.dart';
import '../suggestion_map/mappage_block.dart';
import '../suggestion_map/mappage_repository.dart';

class LoadMarkersEvent extends BaseEvent {
  final TrackasiaMapController map;
  final Function funOnTouch;
  final String pro, dis, from, to, type;
  LoadMarkersEvent(this.map, this.funOnTouch, this.pro, this.dis, this.from, this.to, this.type);
}

class LoadListNameEvent extends BaseEvent {}
class LoadListNameState extends BaseState {
  final List<List<ItemModel>> list;
  LoadListNameState(this.list);
}

class SendContributeEvent extends BaseEvent {
  final String harvest, desHar, tree, desTree, nutrition, salinity, pH, province, district, address, lat, lng, n, p, k, s, ca, organic;
  SendContributeEvent(this.harvest, this.desHar, this.tree, this.desTree, this.nutrition, this.salinity, this.pH,
      this.province, this.district, this.address, this.lat, this.lng, this.n, this.p, this.k, this.s, this.ca, this.organic);
}

class NutritionMapBloc extends BaseBloc {
  NutritionMapBloc() {
    //on<LoadMapKeyEvent>((event, emit) async {
    //  final resp = await MapPageRepository().loadMapKey();
    //  if (resp.checkOK() && resp.data.list.isNotEmpty) emit(LoadMapKeyState(resp));
    //});
    on<LoadListNameEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().getAPI2(Constants().apiVersion + 'info_diseases/collection_option', hasHeader: false);
      if (resp.isNotEmpty) {
        try {
          dynamic json = jsonDecode(resp);
          if (Util.checkKeyFromJson(json, 'success') && (json['success']??false) && Util.checkKeyFromJson(json, 'data')) {
            json = json['data'];
            final List<List<ItemModel>> list = [];
            list.add(_getList('harvest', json));
            list.add(_getList('plant_name', json));
            list.add(_getList('nutrition', json));
            emit(LoadListNameState(list));
          }
        } catch (_) {
          emit(const BaseState());
        }
      } else emit(const BaseState());
    });
    on<LoadProvinceProfileEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await SignUpRepository().loadProvince();
      resp.checkOK() && resp.data.list.isNotEmpty ? emit(LoadProvinceProfileState(resp)) : emit(const BaseState());
    });
    on<LoadDistrictProfileEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await SignUpRepository().loadDistrict(event.provinceId);
      resp.checkOK() && resp.data.list.isNotEmpty ? emit(LoadDistrictProfileState(resp)) : emit(const BaseState());
    });
    on<GetLocationEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().getAPI2('${Constants().apiVersion}locations/address_full?lat=${event.lat}&lng=${event.lon}', hasHeader: false);
      if (resp.isNotEmpty) {
        dynamic json = jsonDecode(resp);
        Util.checkKeyFromJson(json, 'success') && json['success'] && Util.checkKeyFromJson(json, 'data') ?
          emit(GetLocationState(BaseResponse(success: true, data: json['data']))) : emit(const BaseState());
      } else emit(const BaseState());
    });
    on<GetLatLonAddressEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final response = await ApiClient().getAPI('${Constants().apiVersion}locations/latlong?address=${event.address}',
          WeatherListModel(), hasHeader: false);
      response.checkOK() ? emit(GetLatLonAddressState(response, response.data.lat, response.data.lng)) : emit(GetLatLonAddressState(response, '', ''));
    });
    on<LoadMarkersEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      String params = '';
      if (event.pro.isNotEmpty) params = 'province_id=${event.pro}&';
      if (event.dis.isNotEmpty) params += 'district_id=${event.dis}&';
      if (event.from.isNotEmpty) params += 'start_date=${event.from}&';
      if (event.to.isNotEmpty) params += 'end_date=${event.to}&';
      //if (event.type.isNotEmpty) params += 'type_map=${event.type}';
      final resp = await ApiClient().getAPI2(Constants().apiVersion + 'info_diseases/map_data?$params', hasHeader: false);
      if (resp.isNotEmpty) {
        final temp = BaseResponse();
        try {
          final json = jsonDecode(resp);
          final data = json;
          temp.success = true;
          temp.data = data;
        } catch (e) {
          temp.data = e.toString();
        }
        emit(LoadListState(temp));
      } else emit(const BaseState());
    });
    on<SendContributeEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      String lat = event.lat, lng = event.lng;
      dynamic response;
      if (lat.isEmpty || lng.isEmpty) {
        response = await ApiClient().getAPI('${Constants().apiVersion}locations/latlong?address=${event.address}', WeatherListModel(), hasHeader: false);
        if (response.checkOK()) {
          lat = response.data.lat;
          lng = response.data.lng;
        } else {
          try {
            final loc = await Geolocator.getCurrentPosition();
            lat = loc.latitude.toString();
            lng = loc.longitude.toString();
          } catch(_) {}
        }
      }

      response = await ApiClient().postAPI(Constants().apiVersion + 'info_diseases', 'POST', BaseResponse(), body: {
        'harvest': event.harvest,
        'harvest_description': event.desHar,
        'plant_name': event.tree,
        'plant_description': event.desTree,
        if (event.nutrition.isNotEmpty) 'nutrition': event.nutrition,
        if (event.salinity.isNotEmpty) 'salinity': event.salinity,
        if (event.pH.isNotEmpty) 'pH': event.pH,
        if (event.n.isNotEmpty) 'nutrition_n': event.n,
        if (event.p.isNotEmpty) 'nutrition_p': event.p,
        if (event.k.isNotEmpty) 'nutrition_k': event.k,
        if (event.s.isNotEmpty) 'nutrition_s': event.s,
        if (event.ca.isNotEmpty) 'nutrition_ca': event.ca,
        if (event.organic.isNotEmpty) 'nutrition_organic': event.organic,
        if (event.province.isNotEmpty) 'province_id': event.province,
        if (event.district.isNotEmpty) 'district_id': event.district,
        'address': event.address,
        'lat': lat,
        'lng': lng
      });
      emit(CreateQuestionState(response));
    });
  }

  List<ItemModel> _getList(String key, json) {
    if (Util.checkKeyFromJson(json, key)) {
      final data = json[key];
      final List<ItemModel> subList = [];
      for(int i = data.length - 1; i > -1; i--) {
        subList.add(ItemModel(id: data[i], name: data[i]));
      }
      return subList;
    }
    return [];
  }
}
