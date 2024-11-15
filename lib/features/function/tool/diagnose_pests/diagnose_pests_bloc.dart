import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/import_lib_system.dart';
import 'package:hainong/common/models/file_byte.dart';
import 'package:hainong/features/function/info_news/market_price/market_price_bloc.dart';
import 'package:hainong/features/function/info_news/weather/weather_bloc.dart';
import 'package:hainong/features/function/info_news/weather/weather_list_province_model.dart';
import 'package:hainong/features/main/bloc/main_bloc.dart';
import 'package:hainong/features/shop/ui/import_ui_shop.dart';
import 'package:hainong/features/home/home_repository.dart';
import '../suggestion_map/suggest_model.dart';
import 'diagnose_pests_repository.dart';
import 'model/plant_model.dart';

class DiagnosePestsState extends BaseState {
  const DiagnosePestsState({isShowLoading = false})
      : super(isShowLoading: isShowLoading);
}

//class SetLocationState extends DiagnosePestsState {}
class LoadListProvincesState extends DiagnosePestsState {
  final BaseResponse response;
  LoadListProvincesState(this.response);
}
class LoadListDistrictState extends DiagnosePestsState {
  final BaseResponse response;
  LoadListDistrictState(this.response);
}

class LoadProvincesState extends DiagnosePestsState {
  final Map<String, ItemModel> map;
  LoadProvincesState(this.map);
}
class ChangeProvinceState extends DiagnosePestsState {}
class UploadFileDiagnosePestsState extends DiagnosePestsState {
  final BaseResponse response;
  const UploadFileDiagnosePestsState(this.response);
}

class ShowImageDiagnosePestsState extends DiagnosePestsState {}

class CreatePostDiagnosePestsState extends DiagnosePestsState {
  final BaseResponse response;
  const CreatePostDiagnosePestsState(this.response);
}

class LoadCatalogueState extends DiagnosePestsState{
  final List<PlantModel> list;
  const LoadCatalogueState(this.list);
}

class ChangeCatalogueState extends DiagnosePestsState{}
class ChangePestState extends DiagnosePestsState{}

class LoadDiagnosticState extends DiagnosePestsState {
  final List<ItemModel> list;
  const LoadDiagnosticState(this.list);
}

class LoadDiagnosticHistoryState extends DiagnosePestsState {
  final BaseResponse response;
  const LoadDiagnosticHistoryState(this.response);
}

class ChangePointState extends DiagnosePestsState {
  final int point;
  ChangePointState(this.point);
}

class PostRatingState extends DiagnosePestsState {
  final BaseResponse response;
  PostRatingState(this.response);
}

class ShowPercentState extends DiagnosePestsState {
  final bool value;
  const ShowPercentState(this.value);
}

class LoadOptionState extends DiagnosePestsState {
  final String value;
  final dynamic popup;
  LoadOptionState(this.value, {this.popup});
}

class CheckPopupCameraState extends DiagnosePestsState {}

abstract class DiagnosePestsEvent extends BaseEvent {}

class UploadFileDiagnosePestsEvent extends DiagnosePestsEvent {
  final String catalogue, lat, lng;
  final List<FileByte> files;
  UploadFileDiagnosePestsEvent(this.files, this.catalogue, this.lat, this.lng);
}
//class SetLocationEvent extends DiagnosePestsEvent {}
class LoadListProvinceEvent extends DiagnosePestsEvent{}
class LoadProvincesEvent extends DiagnosePestsEvent{}
class LoadListDistrictEvent extends DiagnosePestsEvent{
  final String idProvince;
  LoadListDistrictEvent(this.idProvince);
}

class ShowImageDiagnosePestsEvent extends DiagnosePestsEvent {}

class CreatePostDiagnosePestsEvent extends DiagnosePestsEvent {
  final String title;
  final List<FileByte> files;
  CreatePostDiagnosePestsEvent(this.files, this.title);
}

class LoadCatalogueEvent extends DiagnosePestsEvent{}
class ChangeCatalogueEvent extends DiagnosePestsEvent{}
class ChangePestEvent extends DiagnosePestsEvent{}
class LoadDiagnosticEvent extends DiagnosePestsEvent{
  String idPlant;
  LoadDiagnosticEvent(this.idPlant);
}

class LoadListPlantEvent extends DiagnosePestsEvent{}

class LoadListPlantState extends DiagnosePestsState{
  List<ItemModel> list;

  LoadListPlantState(this.list);
}
class LoadDiagnosticHistoryEvent extends DiagnosePestsEvent{
  final int page;
  final String diagnosticId, plantId;
  LoadDiagnosticHistoryEvent(this.page,{required this.plantId, required this.diagnosticId});
}

class ChangePointEvent extends DiagnosePestsEvent {
  final int point;
  ChangePointEvent(this.point);
}

class PostRatingEvent extends DiagnosePestsEvent {
  final int rate;
  final String content, diagnosticId;
  final List? ids;
  PostRatingEvent(this.rate, this.content, this.ids, this.diagnosticId);
}

class ShowPercentEvent extends DiagnosePestsEvent {
  final bool value;
  ShowPercentEvent(this.value);
}

class LoadOptionEvent extends DiagnosePestsEvent {}
class CheckPopupCameraEvent extends DiagnosePestsEvent {
  final bool value, isSave;
  CheckPopupCameraEvent({this.value = true, this.isSave = false});
}

class SendFeedbackEvent extends DiagnosePestsEvent {
  final List ids;
  final String content;
  SendFeedbackEvent(this.content, this.ids);
}
class SendFeedbackState extends DiagnosePestsState {
  final BaseResponse resp;
  SendFeedbackState(this.resp);
}

class FillTerByPlantEvent extends DiagnosePestsEvent{
  FillTerByPlantEvent();
}

class FillTerByPlantState extends DiagnosePestsState{
  FillTerByPlantState();
}
class FillTerByPestEvent extends DiagnosePestsEvent{
  FillTerByPestEvent();
}

class FillTerByPestState extends DiagnosePestsState{
  FillTerByPestState();
}

class ChangeSliderPopupEvent extends DiagnosePestsEvent{
  int index;
  String nameSlide;
  ChangeSliderPopupEvent(this.index, this.nameSlide);
}

class ChangeSliderPopupState extends DiagnosePestsState{
  int index;
  String nameSlide;
  ChangeSliderPopupState(this.index, this.nameSlide);
}


class DiagnosePestsBloc extends BaseBloc {
  final repository = DiagnosePestsRepository();

  DiagnosePestsBloc(DiagnosePestsState init) : super(init: init) {
    on<LoadListProvinceEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().getAPI('${Constants().apiVersion}locations/list_provinces', ItemListModel(), hasHeader: false);
      emit(LoadListProvincesState(resp));
    });
    on<LoadListDistrictEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().getAPI('${Constants().apiVersion}locations/list_districts?province_id=${event.idProvince}', ItemListModel(), hasHeader: false);
      emit(LoadListDistrictState(resp));
    });
    on<SetLocationEvent>((event, emit) => emit(SetLocationState()));
    on<UploadFileDiagnosePestsEvent>((event, emit) async {
      emit(const ShowPercentState(true));
      final response = await repository.uploadFileDiagnostic(event.files, event.catalogue, event.lat, event.lng);
      emit(const ShowPercentState(false));
      emit(UploadFileDiagnosePestsState(response));
    });
    on<ShowImageDiagnosePestsEvent>((event, emit) => emit(ShowImageDiagnosePestsState()));
    on<LoadCatalogueEvent>((event, emit) async {
      final response = await repository.loadCatalogue();
      if (response.checkOK() && response.data.list.length > 0) {
        final newState = LoadCatalogueState(response.data.list);
        emit(newState);
      }
    });
    on<ChangeCatalogueEvent>((event, emit) => emit(ChangeCatalogueState()));
    on<ChangePestEvent>((event, emit) => emit(ChangePestState()));
    on<CheckPopupCameraEvent>((event, emit) async {
      emit(CheckPopupCameraState());
      if (event.isSave) {
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString('popup_camera', event.value ? 'hidden' : 'show');
        });
        ApiClient().postAPI2(Constants().apiVersion + 'popup_toggles', body: {
          'module_name':'traning_data',
          'popup_type':'camera',
          'popup_value':event.value?'show':'hidden'
        });
      }
    });
    on<LoadDiagnosticEvent>((event, emit) async {
      final resp = await repository.loadCatalogue(passUnknown: true);
      if (resp.checkOK()) {
        final List<PlantModel> plants = resp.data.list;
        final List<ItemModel> list = [];
        final PlantModel plant = plants.firstWhere((element) => element.id ==  event.idPlant, orElse: ()=> PlantModel());
          for(var item in plant.diagnostics) {
            // item.name += '\n(${plant.name})';
            list.add(item);
          }
        emit(LoadDiagnosticState(list));
      }
    });
    on<LoadListPlantEvent>((event, emit) async{
      emit(const DiagnosePestsState(isShowLoading: true));
      final resp = await repository.loadListPlant();
      if(resp.checkOK()){
        final List<ItemModel> list = resp.data.list;
        emit(LoadListPlantState(list));
      }
    });
    on<FillTerByPlantEvent>((event, emit) async{
      emit(FillTerByPlantState());
    });
    on<FillTerByPestEvent>((event, emit) async{
      emit(FillTerByPestState());
    });

    on<LoadDiagnosticHistoryEvent>((event, emit) async {
      emit(LoadDiagnosticHistoryState(await repository.loadDiagnosticHistory(event.page,event.plantId, event.diagnosticId)));
    });
    on<ChangePointEvent>((event, emit) => emit(ChangePointState(event.point)));
    on<PostRatingEvent>((event, emit) async {
      emit(const DiagnosePestsState(isShowLoading: true));
      final newState = PostRatingState(await repository.rating(event.rate,
          event.content, event.ids, event.diagnosticId));
      emit(newState);
    });
    on<ShowPercentEvent>((event, emit) => emit(ShowPercentState(event.value)));
    on<CreatePostDiagnosePestsEvent>((event, emit) async {
      emit(const DiagnosePestsState(isShowLoading: true));
      final response = await HomeRepository().createPost([], [], event.title, '', '', realFiles: event.files);
      emit(CreatePostDiagnosePestsState(response));
    });
    on<LoadOptionEvent>((event, emit) async {
      String guid = '', popup;
      dynamic response = await ApiClient().getAPI(Constants().apiVersion + 'base/option?key=guid_camera_ai', Options(), hasHeader: false);
      if (response.checkOK() && response.data.list.length > 0) guid = response.data.list[0].value;
      response = await ApiClient().getAPI2(Constants().apiVersion + 'popup_toggles?module_name=traning_data&popup_type=camera');
      if (response.isNotEmpty) {
        response = jsonDecode(response);
        if (Util.checkKeyFromJson(response, 'success') && response['success'] && Util.checkKeyFromJson(response, 'data') && response['data'].isNotEmpty) {
          popup = response['data'][0]['popup_value']??'show';
          emit(LoadOptionState(guid, popup: popup == 'show'));
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('popup_camera', popup);
          return;
        }
      }

      final prefs = await SharedPreferences.getInstance();
      popup = prefs.getString('popup_camera')??'show';
      emit(LoadOptionState(guid, popup: popup = 'show'));
    });
    //on<LoadImageDiagnostisPestEvent>((event, emit) => emit(LoadImageDiagnostisPestState()));
    on<CreateDiagnostisPestEvent>((event, emit) async {
      emit(const DiagnosePestsState(isShowLoading: true));

      String lat = '', lng = '';
      dynamic response = await ApiClient().getAPI('${Constants().apiVersion}locations/latlong?address=${event.address}', WeatherListModel(), hasHeader: false);
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

      response = await repository.createDiagnosticContribute(event.files, event.province_id,event.district_id,event.address,
          event.tree_name,event.pest_name,event.description,lat,lng);
      emit(CreateDiagnostisPestSuccessState(response));
    });
    on<SendFeedbackEvent>((event, emit) async {
      emit(const DiagnosePestsState(isShowLoading: true));
      final Map<String, String> body = {'feedback': event.content};
      for(int i = event.ids.length - 1; i > -1; i--) {
        body.putIfAbsent('training_data_ids[$i]', () => event.ids[i].toString());
      }
      final resp = await ApiClient().postAPI(Constants().apiVersion + 'training_data/feedback', 'PUT', BaseResponse(), body: body);
      emit(SendFeedbackState(resp));
    });
    on<GetLocationEvent>((event, emit) async {
      emit(const DiagnosePestsState(isShowLoading: true));
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
      response.checkOK() ? emit(GetLatLonAddressState(response, response.data.lat, response.data.lng)) : emit(const BaseState());
    });
    on<UpdateStatusEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final response = await ApiClient().postAPI(Constants().apiPerVer + 'training_contribution_data/${event.id}',
          'PUT', BaseResponse(), body: {"approve": event.status});
      emit(UpdateStatusState(response, event.status));
    });
    on<ChangeSliderPopupEvent>((event, emit) => emit(ChangeSliderPopupState(event.index, event.nameSlide)));
  }
}

class CreateDiagnostisPestSuccessState extends DiagnosePestsState {
  final dynamic resp;
  CreateDiagnostisPestSuccessState(this.resp);
}

//class LoadImageDiagnostisPestState extends DiagnosePestsState {}

class CreateDiagnostisPestEvent extends DiagnosePestsEvent {
  final List<FileByte> files;
  final String pest_name, description, tree_name, province_id,district_id,address;
  CreateDiagnostisPestEvent(this.province_id,this.district_id,this.address,this.tree_name,this.pest_name,this.description,this.files);
}

//class LoadImageDiagnostisPestEvent extends DiagnosePestsEvent {}
