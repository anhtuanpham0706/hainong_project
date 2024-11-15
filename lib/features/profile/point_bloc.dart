import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/features/profile/ui/history_point_model.dart';

class PointsModel {
  final List<PointModel> list = [];
  PointsModel fromJson(json) {
    if (json.isNotEmpty) json.forEach((ele) => list.add(PointModel().fromJson(ele)));
    return this;
  }
}

class PointModel {
  int id, points;
  String sender_name, sender_avatar, created_at, updated_at;
  String person_name,action_change;
  PointModel({this.id = -1, this.points = 0, this.sender_name = '', this.sender_avatar = '', this.created_at = '', this.updated_at = '',this.action_change = '',this.person_name = ''});
  PointModel fromJson(Map<String, dynamic> json) {
    id = Util.getValueFromJson(json, 'id', -1);
    points = Util.getValueFromJson(json, 'points', 0);
    sender_name = Util.getValueFromJson(json, 'sender_name', '');
    sender_avatar = Util.getValueFromJson(json, 'sender_avarta', '');
    created_at = Util.getValueFromJson(json, 'created_at', '');
    updated_at = Util.getValueFromJson(json, 'updated_at', '');
    person_name = Util.getValueFromJson(json, 'person_name', '');
    action_change = Util.getValueFromJson(json, 'action_change', '');
    return this;
  }
}

class ChangeTabEvent extends BaseEvent {}
class ChangeTabState extends BaseState {}

class GetPointListEvent extends BaseEvent {
  final int page, idBusiness;
  final String status, tab;
  GetPointListEvent(this.page, this.status, {this.tab = '', this.idBusiness = -1});
}
class GetPointListState extends BaseState {
  final BaseResponse response;
  GetPointListState(this.response);
}
class GetHistoryPointEvent extends BaseEvent {
  final int page;
  final String status;
  GetHistoryPointEvent(this.page,this.status);
}

class GetHistoryPointState extends BaseState {
  final BaseResponse response;
  GetHistoryPointState(this.response);
}


class UpdateStatusEvent extends BaseEvent {
  final int id;
  final String status;
  UpdateStatusEvent(this.id, this.status);
}
class UpdateStatusState extends BaseState {
  final BaseResponse response;
  UpdateStatusState(this.response);
}

class PointBloc extends BaseBloc {
  PointBloc() {
    on<ChangeTabEvent>((event, emit) => emit(ChangeTabState()));
    on<GetPointListEvent>((event, emit) async {
      final resp = await ApiClient().getAPI('${Constants().apiVersion}account/received_points?'
        'page=${event.page}&limit=${Constants().limitPage}&status=${event.status}', PointsModel());
      emit(GetPointListState(resp));
    });
    on<GetHistoryPointEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().getAPI('${Constants().apiVersion}point_histories/point_${event.status == 'receive' ? "received": "given"}?'
          'page=${event.page}&limit=20', HistoryPointModel());
      emit(GetHistoryPointState(resp));
    });
    on<UpdateStatusEvent>((event, emit) async {
      final resp = await ApiClient().postAPI('${Constants().apiVersion}account/accept_point/${event.id}',
          'PUT', BaseResponse(), body: {'status': event.status});
      emit(UpdateStatusState(resp));
    });
  }
}