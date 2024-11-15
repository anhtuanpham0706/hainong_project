import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/features/post/bloc/post_list_bloc.dart';
import 'package:hainong/features/function/support/handbook/handbook_bloc.dart';
import '../farm_management/farm_management_bloc.dart';

class LoadHarvestDtlEvent extends BaseEvent {
  final String code;
  LoadHarvestDtlEvent(this.code);
}
class LoadHarvestDtlState extends BaseState {
  final BaseResponse resp;
  LoadHarvestDtlState(this.resp);
}

class LoadFarmDtlEvent extends BaseEvent {
  final int id;
  LoadFarmDtlEvent(this.id);
}
class LoadFarmDtlState extends BaseState {
  final BaseResponse resp;
  LoadFarmDtlState(this.resp);
}

class HarvestDiaryBloc extends BaseBloc {
  HarvestDiaryBloc({BaseState init = const BaseState(),String typeInfo = ''}) :super(init: init,typeInfo: typeInfo) {
    on<ChangeTabEvent>((event, emit) => emit(ChangeTabState(event.index)));
    on<ChangeUnitEvent>((event, emit) => emit(ChangeUnitState()));
    on<LoadListEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().getAPI(Constants().apiVersion + 'harvest_managements?page=${event.page}&limit=20&keyword=${event.keyword}', HarvestDiaryModels());
      emit(LoadListState(resp));
    });
    on<CreatePlanEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final String id = event.id > 0 ? '/${event.id}' : '';
      final resp = await ApiClient().postAPI(Constants().apiVersion + 'harvest_managements$id', event.id > 0 ? 'PUT' : 'POST', HarvestDiaryModel(),
        hasHeader: true, body: {
          'title': event.name,
          'culture_plot_id': event.plots,
          'family_tree': event.tree,
          'process_engineering_id': event.start,
          if (event.qty.isNotEmpty) 'amount': event.qty,
          'unit': event.unit,
          if (event.total.isNotEmpty) 'revenue': event.total,
          'other_unit': event.otherUnit,
          'working_status': event.end
        });
      emit(CreatePlanState(resp));
    });
    on<DeletePlanEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().postAPI(Constants().apiVersion + 'harvest_managements/${event.id}', 'DELETE', BaseResponse());
      emit(DeletePlanState(resp));
    });
    on<LoadHarvestDtlEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().getAPI(Constants().apiVersion + 'harvest_managements/scan?code=${event.code}', HarvestDiaryModel());
      emit(LoadHarvestDtlState(resp));
    });
    on<LoadFarmDtlEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().getAPI(Constants().apiVersion + 'process_engineerings/${event.id}', FarmManageModel());
      if (resp.checkOK()) emit(LoadFarmDtlState(resp));
      else emit(const BaseState());
    });
  }
}

class HarvestDiaryModels {
  final List<HarvestDiaryModel> list = [];
  HarvestDiaryModels fromJson(json) {
    if (json.isNotEmpty) json.forEach((ele) => list.add(HarvestDiaryModel().fromJson(ele)));
    return this;
  }
}

class HarvestDiaryModel {
  int id = -1, culture_plot_id = -1, process_engineering_id = -1;
  double amount = .0, revenue = .0;
  String title = '', qr_code = '', name = '', family_tree = '', culture_plot_title = '', unit = '', other_unit = '', working_status = 'working', process_engineering_title = '';
  HarvestDiaryModel fromJson(Map<String, dynamic> json) {
    id = Util.getValueFromJson(json, 'id', -1);
    culture_plot_id = Util.getValueFromJson(json, 'culture_plot_id', -1);
    process_engineering_id = Util.getValueFromJson(json, 'process_engineering_id', -1);
    amount = double.parse(Util.getValueFromJson(json, 'amount', .0).toString());
    revenue = Util.getValueFromJson(json, 'revenue', .0);
    qr_code = Util.getValueFromJson(json, 'qr_code', '');
    title = Util.getValueFromJson(json, 'title', '');
    name = title;
    family_tree = Util.getValueFromJson(json, 'family_tree', '');
    culture_plot_title = Util.getValueFromJson(json, 'culture_plot_title', '');
    unit = Util.getValueFromJson(json, 'unit', '');
    other_unit = Util.getValueFromJson(json, 'other_unit', '');
    working_status = Util.getValueFromJson(json, 'working_status', 'working');
    process_engineering_title = Util.getValueFromJson(json, 'process_engineering_title', '');
    return this;
  }
}