import 'dart:convert';
import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/util/util.dart';
import '../../support/handbook/handbook_bloc.dart';
import '../farm_management/farm_management_bloc.dart';
import '../harvest_diary/harvest_diary_bloc.dart';

class ExpenseEvent extends BaseEvent {
  final bool isFirst;
  final String start, end;
  ExpenseEvent({this.isFirst = true, this.start = '', this.end = ''});
}

class Expense1State extends BaseState {
  final Map<String, dynamic> data;
  Expense1State(this.data);
}

class Expense2State extends BaseState {
  final Map<String, dynamic> data;
  Expense2State(this.data);
}

class PlotsEvent extends BaseEvent {}
class PlotsState extends BaseState {
  final Map<String, dynamic> data;
  PlotsState(this.data);
}

class MaterialEvent extends BaseEvent {
  final int page;
  final String start, end;
  MaterialEvent(this.page, {this.start = '', this.end = ''});
}
class MaterialReportState extends BaseState {
  final List data;
  MaterialReportState(this.data);
}

class PlotsDtlEvent extends BaseEvent {
  final String id;
  PlotsDtlEvent(this.id);
}
class PlotsDtlState extends BaseState {
  final Map<String, dynamic> plots;
  PlotsDtlState(this.plots);
}

class LoadHarvestsState extends BaseState {
  final BaseResponse resp;
  LoadHarvestsState(this.resp);
}

class LoadHarvestTasksEvent extends BaseEvent {
  final int page;
  final String id;
  LoadHarvestTasksEvent(this.id, {this.page = 0});
}
class LoadHarvestTasksState extends BaseState {
  final BaseResponse resp;
  LoadHarvestTasksState(this.resp);
}

class ReportBloc extends BaseBloc {
  ReportBloc({bool isReport = true, bool isFarm = true, BaseState init = const BaseState()}) :super(init: init) {
    if (isReport) {
      on<ExpenseEvent>((event, emit) async {
        emit(const BaseState(isShowLoading: true));
        String params = '';
        if (event.start.isNotEmpty) params = 'start_date=${event.start}&';
        if (event.end.isNotEmpty) params += 'end_date=${event.end}';
        final resp = await ApiClient().getAPI2(Constants().apiVersion + 'harvest_reports?$params');
        if (resp.isNotEmpty) {
          Map<String, dynamic> json = jsonDecode(resp);
          if (Util.checkKeyFromJson(json, 'success') && Util.checkKeyFromJson(json, 'data') && json['success']) {
            emit(event.isFirst ? Expense1State(json['data']) : Expense2State(json['data']));
          } else if (event.isFirst) {
            emit(ShowErrorState(json['data'] ?? ''));
          }
          return;
        }
        emit(const BaseState());
      });
      on<PlotsEvent>((event, emit) async {
        emit(const BaseState(isShowLoading: true));
        final resp = await ApiClient().getAPI2(Constants().apiVersion + 'harvest_reports/consolidation_plots');
        if (resp.isNotEmpty) {
          Map<String, dynamic> json = jsonDecode(resp);
          if (Util.checkKeyFromJson(json, 'success') && Util.checkKeyFromJson(json, 'data') && json['success']) {
            emit(PlotsState(json['data']));
          } else emit(ShowErrorState(json['data'] ?? ''));
          return;
        }
        emit(const BaseState());
      });
      on<MaterialEvent>((event, emit) async {
        emit(const BaseState(isShowLoading: true));
        String params = '';
        if (event.start.isNotEmpty) params = '&start_date=${event.start}';
        if (event.end.isNotEmpty) params += '&end_date=${event.end}';
        final resp = await ApiClient().getAPI2(Constants().apiVersion + 'harvest_reports/material_inventories?page=${event.page}&limit=20$params');
        if (resp.isNotEmpty) {
          Map<String, dynamic> json = jsonDecode(resp);
          if (Util.checkKeyFromJson(json, 'success') && Util.checkKeyFromJson(json, 'data') && json['success']) {
            emit(MaterialReportState(json['data'].toList()));
          } else emit(ShowErrorState(json['data']??''));
          return;
        }
        emit(const BaseState());
      });
      on<LoadListEvent>((event, emit) async {
        emit(const BaseState(isShowLoading: true));
        final resp = await ApiClient().getAPI(Constants().apiVersion + 'culture_plots?page=1&limit=500', ItemListModel(keyName: 'title'));
        emit(LoadListState(resp));
      });
      on<PlotsDtlEvent>((event, emit) async {
        emit(const BaseState(isShowLoading: true));
        final resp = await ApiClient().getAPI2(Constants().apiVersion + 'harvest_reports/farming_details?harvest_management_id=${event.id}');
        if (resp.isNotEmpty) {
          Map<String, dynamic> json = jsonDecode(resp);
          if (Util.checkKeyFromJson(json, 'success') && Util.checkKeyFromJson(json, 'data') && json['success']) {
            emit(PlotsDtlState(json['data']));
            return;
          }
        }
        emit(PlotsDtlState({}));
      });
      on<LoadHarvestTasksEvent>((event, emit) async {
        emit(const BaseState(isShowLoading: true));
        final resp = await ApiClient().getAPI(Constants().apiVersion + 'harvest_managements?page=1&limit=200&culture_plot_id=${event.id}', HarvestDiaryModels());
        emit(LoadHarvestsState(resp));
      });
      return;
    }
    if(isFarm) {
      on<LoadListEvent>((event, emit) async {
        emit(const BaseState(isShowLoading: true));
        final resp = await ApiClient().getAPI2(Constants().apiVersion + 'materials/${event.keyword}/process_engineering_jobs?page=${event.page}&limit=20');
        if (resp.isNotEmpty) {
          Map<String, dynamic> json = jsonDecode(resp);
          if (Util.checkKeyFromJson(json, 'success') && Util.checkKeyFromJson(json, 'data') && json['success']) {
            emit(LoadListState(BaseResponse(success: true, data: json['data'].toList())));
          } else emit(ShowErrorState(json['data'] ?? ''));
          return;
        }
        emit(const BaseState());
      });
      on<LoadFarmDtlEvent>((event, emit) async {
        emit(const BaseState(isShowLoading: true));
        final resp = await ApiClient().getAPI(Constants().apiVersion + 'process_engineerings/${event.id}', FarmManageModel());
        emit(LoadFarmDtlState(resp));
      });
      return;
    }

    on<LoadHarvestTasksEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().getAPI2(Constants().apiVersion + 'materials/${event.id}/harvest_jobs?page=${event.page}&limit=20');
      if (resp.isNotEmpty) {
        Map<String, dynamic> json = jsonDecode(resp);
        if (Util.checkKeyFromJson(json, 'success') && Util.checkKeyFromJson(json, 'data') && json['success']) {
          emit(LoadHarvestTasksState(BaseResponse(success: true, data: json['data'].toList())));
          return;
        }
      }
      emit(const BaseState());
    });
    on<LoadHarvestDtlEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().getAPI(Constants().apiVersion + 'harvest_managements/' + event.code, HarvestDiaryModel());
      emit(LoadHarvestDtlState(resp));
    });
  }
}
