import 'dart:io';
import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/models/file_byte.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/features/function/support/handbook/handbook_bloc.dart';
import 'package:hainong/features/function/tool/harvest_diary/harvest_diary_bloc.dart';
import 'package:hainong/features/product/repository/product_repository.dart';
import 'package:hainong/features/home/bloc/home_event.dart';
import 'package:hainong/features/home/bloc/home_state.dart';
import 'package:hainong/features/post/bloc/post_item_bloc.dart';
import '../farm_management/farm_management_bloc.dart';
import '../farm_management/task_bloc.dart';

class LoadMaterialsEvent extends BaseEvent {
  final int page, type;
  final String keyword;
  LoadMaterialsEvent(this.page, this.type, this.keyword);
}

class LoadTypeEvent extends BaseEvent {}
class LoadTypeState extends BaseState {
  final List<ItemModel> list;
  LoadTypeState(this.list);
}

class CreateMaterialEvent extends BaseEvent {
  final int id;
  final List<FileByte> images;
  final String name, code, type, unit, price, volume, date;
  CreateMaterialEvent(this.id, this.name, this.code, this.type, this.unit, this.price, this.volume, this.date, this.images);
}
class CreateMaterialState extends BaseState {
  final BaseResponse resp;
  CreateMaterialState(this.resp);
}

class MaterialBloc extends BaseBloc {
  MaterialBloc({BaseState init = const BaseState(),String typeInfo = ''}) :super(init: init,typeInfo: typeInfo) {
    on<ShowLoadingHomeEvent>((event, emit) => emit(BaseState(isShowLoading: event.isShow)));
    on<AddImageHomeEvent>((event, emit) => emit(AddImageHomeState()));
    on<DownloadFilesPostItemEvent>((event, emit) async {
      emit(PostItemState(isShowLoading: true));
      List<File> files = await Util.loadFilesFromNetwork(ProductRepository(), event.list);
      emit(DownloadFilesPostItemState(files));
    });
    on<LoadUnitEvent>((event, emit) async {
      final resp = await ApiClient().getAPI('/api/v2/materials/material_units?limit=500&page=1', ItemListModel());
      if (resp.checkOK() && resp.data.list.isNotEmpty) emit(LoadUnitState(resp.data.list));
    });
    on<LoadTypeEvent>((event, emit) async {
      final resp = await ApiClient().getAPI('/api/v2/materials/material_types?limit=500&page=1', ItemListModel());
      if (resp.checkOK() && resp.data.list.isNotEmpty) emit(LoadTypeState(resp.data.list));
    });
    on<LoadMaterialsEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final type = event.type > 0 ? '&material_type_id=${event.type}' : '';
      final keyword = event.keyword.isEmpty ? '' : '&keyword=${event.keyword}';
      final resp = await ApiClient().getAPI('/api/v2/materials?page=${event.page}&'
          'limit=20$type$keyword', MaterialModels(), hasHeader: true);
      emit(LoadListState(resp));
    });
    on<CreateMaterialEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final String id = event.id > 0 ? '/${event.id}' : '';
      final resp = await ApiClient().postAPI('/api/v2/materials$id', event.id > 0 ? 'PUT' : 'POST', MaterialModel(),
        hasHeader: true, body: {
          'name': event.name,
          'code': event.code,
          'material_type_id': event.type,
          'material_unit_id': event.unit,
          'volume': event.volume,
          'warehouse_date': event.date,
          'price': event.price,
          'total_price': (double.parse(event.volume) * double.parse(event.price)).toString()
        }, realFiles: event.images);
      emit(CreatePlanState(resp));
    });
    on<DeletePlanEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().postAPI('/api/v2/materials/${event.id}', 'DELETE', BaseResponse(), hasHeader: true);
      emit(DeletePlanState(resp));
    });
    on<LoadFarmDtlEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().getAPI('/api/v2/materials/${event.id}', MaterialModel());
      emit(LoadFarmDtlState(resp));
    });
  }
}

class MaterialModels {
  final List<MaterialModel> list = [];
  MaterialModels fromJson(json) {
    if (json.isNotEmpty) json.forEach((ele) => list.add(MaterialModel().fromJson(ele)));
    return this;
  }
}

class MaterialModel {
  int id = -1, material_type_id = -1, material_unit_id = -1;
  double volume = .0, origin = .0, price = .0;
  String name = '', code = '', material_type_name = '', material_unit_name = '', warehouse_date = '';
  final List<String> images = [];
  MaterialModel({this.id = -1, this.name = '', this.volume = .0, this.price = .0, this.material_unit_id = -1, this.material_unit_name = ''});

  MaterialModel fromJson(Map<String, dynamic> json) {
    id = Util.getValueFromJson(json, 'id', -1);
    material_type_id = Util.getValueFromJson(json, 'material_type_id', -1);
    material_unit_id = Util.getValueFromJson(json, 'material_unit_id', -1);
    origin = Util.getValueFromJson(json, 'origin', .0);
    volume = Util.getValueFromJson(json, 'volume', .0);
    price = Util.getValueFromJson(json, 'price', .0);
    name = Util.getValueFromJson(json, 'name', '');
    code = Util.getValueFromJson(json, 'code', '');
    warehouse_date = Util.getValueFromJson(json, 'warehouse_date', '');
    material_type_name = Util.getValueFromJson(json, 'material_type_name', '');
    material_unit_name = Util.getValueFromJson(json, 'material_unit_name', '');
    if (Util.checkKeyFromJson(json, 'images')) json['images'].forEach((ele) => images.add(ele['name']));
    return this;
  }

  void copy(MaterialModel value) {
    id = value.id;
    material_type_id = value.material_type_id;
    material_unit_id = value.material_unit_id;
    origin = value.origin;
    volume = value.volume;
    price = value.price;
    name = value.name;
    code = value.code;
    warehouse_date = value.warehouse_date;
    material_type_name = value.material_type_name;
    material_unit_name = value.material_unit_name;
    if (value.images.isNotEmpty) {
      images.clear();
      images.addAll(value.images);
    }
  }

  void setValue(int id, String name, int materialId, String materialName, int unitId, String unitName, double volume, double price) {
    id = id;
    material_unit_id = unitId;
    material_type_id = materialId;
    volume = volume;
    price = price;
    name = name;
    material_unit_name = unitName;
    material_type_name = materialName;
    warehouse_date = warehouse_date;
  }
}