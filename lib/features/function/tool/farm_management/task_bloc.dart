import 'dart:io';
import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/models/file_byte.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/features/function/support/handbook/handbook_bloc.dart';
import 'package:hainong/features/home/bloc/home_event.dart';
import 'package:hainong/features/home/bloc/home_state.dart';
import 'package:hainong/features/post/bloc/post_item_bloc.dart';
import 'package:hainong/features/product/repository/product_repository.dart';
import 'farm_management_bloc.dart';

class AddDtlEvent extends BaseEvent {}
class AddDtlState extends BaseState {}

class LoadUnitEvent extends BaseEvent {}
class LoadUnitState extends BaseState {
  final List<ItemModel> list;
  LoadUnitState(this.list);
}

class SelectDtlEvent extends BaseEvent {}
class SelectDtlState extends BaseState {}

class CreateTaskEvent extends BaseEvent {
  final TaskModel task;
  final String title, workDate, cost, otherCost;
  final List<FileByte> images;
  CreateTaskEvent(this.task, this.title, this.workDate, this.cost, this.otherCost, this.images);
}

class TaskBloc extends BaseBloc {
  int id;
  TaskBloc(this.id, {BaseState init = const BaseState()}) :super(init: init) {
    on<ShowLoadingHomeEvent>((event, emit) => emit(BaseState(isShowLoading: event.isShow)));
    on<AddImageHomeEvent>((event, emit) => emit(AddImageHomeState()));
    on<AddDtlEvent>((event, emit) => emit(AddDtlState()));
    on<SelectDtlEvent>((event, emit) => emit(SelectDtlState()));
    on<DownloadFilesPostItemEvent>((event, emit) async {
      emit(PostItemState(isShowLoading: true));
      List<File> files = await Util.loadFilesFromNetwork(ProductRepository(), event.list);
      emit(DownloadFilesPostItemState(files));
    });
    on<LoadUnitEvent>((event, emit) async {
      final resp = await ApiClient().getAPI('/api/v2/materials/material_units?limit=500&page=1', ItemListModel());
      if (resp.checkOK() && resp.data.list.isNotEmpty) emit(LoadUnitState(resp.data.list));
    });
    on<LoadListEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().getAPI('/api/v2/process_engineerings/$id/process_engineering_informations?'
          'page=${event.page}&limit=20&keyword=${event.keyword}', TaskModels(), hasHeader: true);
      emit(LoadListState(resp));
    });
    on<CreateTaskEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final String taskId = event.task.id > 0 ? event.task.id.toString() : '';
      final Map<String, String> body = {
        'title': event.title,
        'working_date': event.workDate,
        'cost': event.cost,
        'other_cost': event.otherCost,
      };

      TaskDtlModel detail;
      for(int i = event.task.jobs.length - 1; i > -1; i--) {
        detail = event.task.jobs[i];
        if (detail.id > 0 || detail.destroy == 0) body.addAll(detail.toJson(i));
      }
      final resp = await ApiClient().postAPI('/api/v2/process_engineerings/$id/process_engineering_informations/$taskId',
          taskId.isEmpty ? 'POST' : 'PUT', TaskModel(), hasHeader: true, realFiles: event.images, body: body);
      emit(CreatePlanState(resp));
    });
    on<DeletePlanEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().postAPI('/api/v2/process_engineerings/$id/process_engineering_informations/${event.id}', 'DELETE', BaseResponse(), hasHeader: true);
      emit(DeletePlanState(resp));
    });
  }
}

class TaskModels {
  final List<TaskModel> list = [];
  TaskModels fromJson(json) {
    if (json.isNotEmpty) json.forEach((ele) => list.add(TaskModel().fromJson(ele)));
    return this;
  }
}

class TaskModel {
  int id = -1;
  double cost = .0, other_cost = .0;
  String title = '', working_date = '';
  final List<String> images = [];
  final List<TaskDtlModel> jobs = [];
  TaskModel fromJson(Map<String, dynamic> json) {
    id = Util.getValueFromJson(json, 'id', -1);
    cost = Util.getValueFromJson(json, 'cost', .0);
    other_cost = Util.getValueFromJson(json, 'other_cost', .0);
    title = Util.getValueFromJson(json, 'title', '');
    working_date = Util.getValueFromJson(json, 'working_date', '');
    if (Util.checkKeyFromJson(json, 'images')) json['images'].forEach((ele) => images.add(ele['name']));
    if (Util.checkKeyFromJson(json, 'process_engineering_jobs')) json['process_engineering_jobs'].forEach((ele) => jobs.add(TaskDtlModel().fromJson(ele)));
    return this;
  }

  double getTotal() {
    double total = .0;
    for (var ele in jobs) {
      if (ele.destroy == 0) total += (ele.material_quantity*ele.material_cost);
    }
    return total;
  }

  void clearJobs() {
    for (int i = jobs.length - 1; i > -1; i--) {
      if (jobs[i].id < 0) jobs.removeAt(i);
    }
  }
}

class TaskDtlModel {
  int id = -1, material_id = -1, material_unit_id = -1, destroy = 0;
  double material_quantity = .0, material_cost = .0;
  String title = '', material_name = '', material_unit_name = '';
  TaskDtlModel({
    this.id = -1, this.material_id = -1, this.material_unit_id = -1,
    this.material_quantity = .0, this.material_cost = .0,
    this.title = '', this.material_name = '', this.material_unit_name = ''
  });

  TaskDtlModel fromJson(Map<String, dynamic> json) {
    id = Util.getValueFromJson(json, 'id', -1);
    material_id = Util.getValueFromJson(json, 'material_id', -1);
    material_unit_id = Util.getValueFromJson(json, 'material_unit_id', -1);
    material_quantity = double.parse(Util.getValueFromJson(json, 'material_quantity', .0).toString());
    material_cost = Util.getValueFromJson(json, 'material_cost', .0);
    title = Util.getValueFromJson(json, 'title', '');
    material_name = Util.getValueFromJson(json, 'material_name', '');
    material_unit_name = Util.getValueFromJson(json, 'material_unit_name', '');
    return this;
  }

  Map<String, String> toJson(int index) => {
    if (id > 0) 'process_engineering_jobs_attributes[$index][id]': id.toString(),
    if (material_id > 0) 'process_engineering_jobs_attributes[$index][material_id]': material_id.toString(),
    if (material_unit_id > 0) 'process_engineering_jobs_attributes[$index][material_unit_id]': material_unit_id.toString(),
    'process_engineering_jobs_attributes[$index][material_quantity]': material_quantity.toString(),
    'process_engineering_jobs_attributes[$index][material_cost]': material_cost.toString(),
    'process_engineering_jobs_attributes[$index][title]': title,
    'process_engineering_jobs_attributes[$index][_destroy]': destroy.toString()
  };
}