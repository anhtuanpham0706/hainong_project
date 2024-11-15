import 'dart:io';
import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/models/file_byte.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/features/function/support/handbook/handbook_bloc.dart';
import 'package:hainong/features/function/tool/farm_management/farm_management_bloc.dart';
import 'package:hainong/features/function/tool/farm_management/task_bloc.dart';
import 'package:hainong/features/home/bloc/home_event.dart';
import 'package:hainong/features/home/bloc/home_state.dart';
import 'package:hainong/features/post/bloc/post_item_bloc.dart';
import 'package:hainong/features/product/repository/product_repository.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';

class CreateHarvestTaskEvent extends BaseEvent {
  final HarvestTaskModel task;
  final String percent, workDate, cost, otherCost;
  final List<FileByte> images;
  CreateHarvestTaskEvent(this.task, this.percent, this.workDate, this.cost, this.otherCost, this.images);
}

class FinishHarvestEvent extends BaseEvent {}
class FinishHarvestState extends BaseState {
  final BaseResponse resp;
  FinishHarvestState(this.resp);
}

class SaveFileEvent extends BaseEvent {
  final File file;
  SaveFileEvent(this.file);
}
class SaveFileState extends BaseState {
  final bool value;
  SaveFileState(this.value);
}

class LoadTaskDtlEvent extends BaseEvent {
  final int pageHarvest, pagePlan, planId;
  LoadTaskDtlEvent(this.pageHarvest, this.pagePlan, this.planId);
}
class LoadTaskDtlState extends BaseState {
  final BaseResponse resp;
  final int pageHarvest, pagePlan;
  LoadTaskDtlState(this.resp, this.pageHarvest, this.pagePlan);
}

class HarvestTaskBloc extends BaseBloc {
  int id;
  HarvestTaskBloc(this.id, {BaseState init = const BaseState(),String typeInfo = ''}) :super(init: init,typeInfo: typeInfo) {
    on<ShowLoadingHomeEvent>((event, emit) => emit(BaseState(isShowLoading: event.isShow)));
    on<AddImageHomeEvent>((event, emit) => emit(AddImageHomeState()));
    on<AddDtlEvent>((event, emit) => emit(AddDtlState()));
    on<ChangeUnitEvent>((event, emit) => emit(ChangeUnitState()));
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
    on<LoadTaskDtlEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final List<List<dynamic>> list = [];
      final List<dynamic> harvests = [], plans = [];

      final respHarvest = event.pageHarvest == 0 ? BaseResponse() :
        await ApiClient().getAPI(Constants().apiVersion + 'harvest_managements/$id/harvest_diaries?page=${event.pageHarvest}&limit=10', HarvestTaskModels());
      final respPlan = event.pagePlan == 0 ? BaseResponse() :
        await ApiClient().getAPI(Constants().apiVersion + 'process_engineerings/${event.planId}/process_engineering_informations?page=${event.pagePlan}&limit=10', TaskModels());

      if (respHarvest.checkOK() && respHarvest.data != null && respHarvest.data.list.isNotEmpty) harvests.addAll(respHarvest.data.list);
      if (respPlan.checkOK() && respPlan.data != null && respPlan.data.list.isNotEmpty) plans.addAll(respPlan.data.list);

      int n = harvests.length > plans.length ? harvests.length : plans.length;
      for(int i = 0; i < n; i++) {
        final harvest = i < harvests.length ? harvests[i] : HarvestTaskModel();
        final plan = i < plans.length ? plans[i] : TaskModel();
        list.add([harvest, plan]);
      }

      emit(LoadTaskDtlState(BaseResponse(success: true, data: list),
          harvests.length == 10 ? event.pageHarvest + 1 : 0, plans.length == 10 ? event.pagePlan + 1 : 0));
    });
    on<CreateHarvestTaskEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final String taskId = event.task.id > 0 ? event.task.id.toString() : '';
      final Map<String, String> body = {
        'percent_finish': event.percent,
        'working_date': event.workDate,
        'cost': event.cost,
        'other_cost': event.otherCost,
      };

      HarvestTaskDtlModel detail;
      for(int i = event.task.jobs.length - 1; i > -1; i--) {
        detail = event.task.jobs[i];
        if (detail.id > 0 || detail.destroy == 0) body.addAll(detail.toJson(i));
      }
      final resp = await ApiClient().postAPI('/api/v2/harvest_managements/$id/harvest_diaries/$taskId',
          taskId.isEmpty ? 'POST' : 'PUT', HarvestTaskModel(), hasHeader: true, realFiles: event.images, body: body);
      emit(CreatePlanState(resp));
    });
    on<DeletePlanEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().postAPI('/api/v2/harvest_managements/$id/harvest_diaries/${event.id}', 'DELETE', BaseResponse(), hasHeader: true);
      emit(DeletePlanState(resp));
    });
    on<FinishHarvestEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().postAPI('/api/v2/harvest_managements/$id',
          'PUT', BaseResponse(), hasHeader: true, body: {'working_status':'completed'});
      emit(FinishHarvestState(resp));
    });
    on<SaveFileEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      try {
        Directory? folder;
        folder = Platform.isIOS ? await path.getApplicationDocumentsDirectory() :
          //await path.getExternalStorageDirectory();
          await DownloadsPathProvider.downloadsDirectory;

        if (folder == null) {
          emit(SaveFileState(false));
          return;
        }

        final array = event.file.path.split('/');
        String fullPath = folder.path + '/' + array[array.length - 1];
        final File temp = File.fromUri(Uri.parse(fullPath));
        if (temp.existsSync()) temp.deleteSync();
        final file = File(fullPath);
        file.writeAsBytesSync(event.file.readAsBytesSync());
        emit(SaveFileState(true));
      } catch (_) {
        emit(SaveFileState(false));
      }
    });
  }
}

class HarvestTaskModels {
  final List<HarvestTaskModel> list = [];
  HarvestTaskModels fromJson(json) {
    if (json.isNotEmpty) json.forEach((ele) => list.add(HarvestTaskModel().fromJson(ele)));
    return this;
  }
}

class HarvestTaskModel {
  int id = -1;
  double cost = .0, other_cost = .0, percent_finish = .0;
  String working_date = '';
  final List<String> images = [];
  final List<HarvestTaskDtlModel> jobs = [];
  HarvestTaskModel fromJson(Map<String, dynamic> json) {
    id = Util.getValueFromJson(json, 'id', -1);
    cost = Util.getValueFromJson(json, 'cost', .0);
    other_cost = Util.getValueFromJson(json, 'other_cost', .0);
    percent_finish = Util.getValueFromJson(json, 'percent_finish', .0);
    working_date = Util.getValueFromJson(json, 'working_date', '');
    if (Util.checkKeyFromJson(json, 'images')) json['images'].forEach((ele) => images.add(ele['name']));
    if (Util.checkKeyFromJson(json, 'harvest_jobs')) json['harvest_jobs'].forEach((ele) => jobs.add(HarvestTaskDtlModel().fromJson(ele)));
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

class HarvestTaskDtlModel {
  int id = -1, material_id = -1, material_unit_id = -1, destroy = 0;
  double material_quantity = .0, material_cost = .0;
  String title = '', material_name = '', material_unit_name = '', working_type = '';
  HarvestTaskDtlModel({
    this.id = -1, this.material_id = -1, this.material_unit_id = -1, this.destroy = 0,
    this.material_quantity = .0, this.material_cost = .0,
    this.title = '', this.material_name = '', this.material_unit_name = '', this.working_type = ''
  });

  HarvestTaskDtlModel fromJson(Map<String, dynamic> json) {
    id = Util.getValueFromJson(json, 'id', -1);
    material_id = Util.getValueFromJson(json, 'material_id', -1);
    material_unit_id = Util.getValueFromJson(json, 'material_unit_id', -1);
    material_quantity = double.parse(Util.getValueFromJson(json, 'material_amount', .0).toString());
    material_cost = Util.getValueFromJson(json, 'material_cost', .0);
    title = Util.getValueFromJson(json, 'title', '');
    material_name = Util.getValueFromJson(json, 'material_name', '');
    material_unit_name = Util.getValueFromJson(json, 'material_unit_name', '');
    working_type = Util.getValueFromJson(json, 'working_type', '');
    return this;
  }

  Map<String, String> toJson(int index) => {
    if (id > 0) 'harvest_jobs_attributes[$index][id]': id.toString(),
    if (material_id > 0) 'harvest_jobs_attributes[$index][material_id]': material_id.toString(),
    if (material_unit_id > 0) 'harvest_jobs_attributes[$index][material_unit_id]': material_unit_id.toString(),
    'harvest_jobs_attributes[$index][material_amount]': material_quantity.toString(),
    'harvest_jobs_attributes[$index][material_cost]': material_cost.toString(),
    'harvest_jobs_attributes[$index][title]': title,
    'harvest_jobs_attributes[$index][working_type]': working_type,
    'harvest_jobs_attributes[$index][_destroy]': destroy.toString()
  };
}