import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/models/item_list_model.dart';
import '../diagnose_pests/model/plant_model.dart';
import 'mappage_repository.dart';

abstract class MapPageEvent extends BaseEvent {}

//class LoadMapKeyEvent extends MapPageEvent{}
//class LoadSuggestionsEvent extends MapPageEvent{}
class LoadDiagnosticsEvent extends MapPageEvent{}
class LoadDiagnostics2Event extends MapPageEvent{}
class LoadProvincesEvent extends MapPageEvent{}
class ChangeProvinceEvent extends MapPageEvent{}
class ChangeDiagnosticEvent extends MapPageEvent{}
class ReloadProvinceEvent extends MapPageEvent{}
class ChangePageEvent extends MapPageEvent{}
class LoadMarkerEvent extends MapPageEvent{}
class LoadListDistrictEvent extends  MapPageEvent{
  final String idProvince;
  LoadListDistrictEvent(this.idProvince);
}
class LoadListProvinceEvent extends  MapPageEvent{}


class MapState extends BaseState {}

class LoadMapKeyState extends MapState {
  final BaseResponse response;
  LoadMapKeyState(this.response);
}

//class LoadMapSuggestionsState extends MapState {
//  final BaseResponse response;
//  LoadMapSuggestionsState(this.response);
//}

class LoadDiagnosticsState extends MapState {
  final Map<String, ItemModel> map;
  LoadDiagnosticsState(this.map);
}
class LoadDiagnostics2State extends MapState {
  final Map<String, ItemModel> map;
  LoadDiagnostics2State(this.map);
}
class LoadProvincesState extends MapState {
  final Map<String, ItemModel> map;
  LoadProvincesState(this.map);
}
class ChangeProvinceState extends MapState {}
class ChangeDiagnosticState extends MapState {}
class ReloadProvinceState extends MapState {}
class ChangePageState extends MapState {}
class LoadMarkerState extends MapState {}

class MapPageBloc extends BaseBloc {
  MapPageBloc(MapState init) : super(init: init) {
    //on<LoadMapKeyEvent>((event, emit) async {
    //  emit(LoadMapKeyState(await MapPageRepository().loadMapKey()));
    //});

    //on<LoadSuggestionsEvent>((event, emit) async {
    //  emit(LoadMapSuggestionsState(await MapPageRepository().loadSuggestions()));
    //});
    on<LoadDiagnosticsEvent>((event, emit) async {
      final resp = await MapPageRepository().loadDiagnostics();
      if (resp.checkOK() && resp.data.list.isNotEmpty) {
        emit(LoadDiagnosticsState(_listToMap(resp.data.list)));
      }
    });
    on<LoadDiagnostics2Event>((event, emit) async {
      final resp = await MapPageRepository().loadDiagnostics2();
      if (resp.checkOK() && resp.data.list.isNotEmpty) {
        final List<PlantModel> plants = resp.data.list;
        final Map<String, ItemModel> list = {};
        for(var plant in plants) {
          for(var item in plant.diagnostics) {
            item.name += ' (${plant.name})';
            list.putIfAbsent(item.id, () => item);
          }
        }
        emit(LoadDiagnostics2State(list));
      }
    });
    on<LoadProvincesEvent>((event, emit) async {
      final resp = await MapPageRepository().loadProvinces();
      if (resp.checkOK() && resp.data.list.isNotEmpty) {
        emit(LoadProvincesState(_listToMap(resp.data.list)));
      }
    });
    on<ChangeProvinceEvent>((event, emit) => emit(ChangeProvinceState()));
    on<ChangeDiagnosticEvent>((event, emit) => emit(ChangeDiagnosticState()));
    on<ReloadProvinceEvent>((event, emit) => emit(ReloadProvinceState()));
    on<ChangePageEvent>((event, emit) => emit(ChangePageState()));
    on<LoadMarkerEvent>((event, emit) => emit(LoadMarkerState()));
  }

  Map<String, ItemModel> _listToMap(List<ItemModel> list, {bool isId = true}) {
    final Map<String, ItemModel> map = {};
    for (var ele in list) {
      map.putIfAbsent(ele.id, () => ele);
    }
    return map;
  }
}
