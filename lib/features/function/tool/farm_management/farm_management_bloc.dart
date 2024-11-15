import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/features/post/bloc/post_list_bloc.dart';
import 'package:hainong/features/function/support/handbook/handbook_bloc.dart';

class ChangeUnitEvent extends BaseEvent {}
class ChangeUnitState extends BaseState {}

class CreatePlanEvent extends BaseEvent {
  int id;
  String plots, qty, total, name, tree, start, end, unit, otherUnit;
  CreatePlanEvent(this.id, this.plots, this.qty, this.total, this.name, this.tree, this.start, this.end, this.unit, this.otherUnit);
}
class CreatePlanState extends BaseState {
  final BaseResponse resp;
  CreatePlanState(this.resp);
}

class DeletePlanEvent extends BaseEvent {
  int id;
  DeletePlanEvent(this.id);
}
class DeletePlanState extends BaseState {
  final BaseResponse resp;
  DeletePlanState(this.resp);
}

class FarmManagementBloc extends BaseBloc {
  FarmManagementBloc({BaseState init = const BaseState(),String typeInfo = ''}) :super(init: init,typeInfo: typeInfo) {
    on<ChangeTabEvent>((event, emit) => emit(ChangeTabState(event.index)));
    on<ChangeUnitEvent>((event, emit) => emit(ChangeUnitState()));
    on<LoadListEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().getAPI('/api/v2/process_engineerings?page=${event.page}&limit=20&keyword=${event.keyword}', FarmManageModels(), hasHeader: true);
      emit(LoadListState(resp));
    });
    on<CreatePlanEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final String id = event.id > 0 ? '/${event.id}' : '';
      final resp = await ApiClient().postAPI('/api/v2/process_engineerings$id', event.id > 0 ? 'PUT' : 'POST', FarmManageModel(),
        hasHeader: true, body: {
          'title': event.name,
          'culture_plot_id': event.plots,
          'family_tree': event.tree,
          'start_date': event.start,
          'end_date': event.end,
          if (event.qty.isNotEmpty) 'amount': event.qty,
          'unit': event.unit,
          if (event.total.isNotEmpty) 'revenue': event.total,
          'other_unit': event.otherUnit
        });
      emit(CreatePlanState(resp));
    });
    on<DeletePlanEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().postAPI('/api/v2/process_engineerings/${event.id}', 'DELETE', BaseResponse(), hasHeader: true);
      emit(DeletePlanState(resp));
    });
  }
}

class FarmManageModels {
  final List<FarmManageModel> list = [];
  FarmManageModels fromJson(json) {
    if (json.isNotEmpty) json.forEach((ele) => list.add(FarmManageModel().fromJson(ele)));
    return this;
  }
}

class FarmManageModel {
  int id = -1, culture_plot_id = -1;
  double amount = .0, revenue = .0;
  String title = '', family_tree = '', culture_plot_title = '', start_date = '', end_date = '', unit = '', other_unit = '';
  FarmManageModel fromJson(Map<String, dynamic> json) {
    id = Util.getValueFromJson(json, 'id', -1);
    culture_plot_id = Util.getValueFromJson(json, 'culture_plot_id', -1);
    amount = double.parse(Util.getValueFromJson(json, 'amount', .0).toString());
    revenue = Util.getValueFromJson(json, 'revenue', .0);
    title = Util.getValueFromJson(json, 'title', '');
    family_tree = Util.getValueFromJson(json, 'family_tree', '');
    culture_plot_title = Util.getValueFromJson(json, 'culture_plot_title', '');
    start_date = Util.getValueFromJson(json, 'start_date', '');
    end_date = Util.getValueFromJson(json, 'end_date', '');
    unit = Util.getValueFromJson(json, 'unit', '');
    other_unit = Util.getValueFromJson(json, 'other_unit', '');
    return this;
  }
}