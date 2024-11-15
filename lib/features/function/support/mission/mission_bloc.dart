import 'dart:convert';
import 'dart:io';
import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/util/util.dart';
import 'package:trackasia_gl/mapbox_gl.dart';
import 'ui/mission_review_item.dart';
import 'ui/mission_map_page.dart';
import 'package:hainong/features/home/bloc/home_event.dart';
import 'package:hainong/features/home/bloc/home_state.dart';
import 'package:hainong/features/post/bloc/post_item_bloc.dart';
import 'package:hainong/features/product/repository/product_repository.dart';

class LoadCatalogueEvent extends BaseEvent {}
class LoadCatalogueState extends BaseState {
  final dynamic resp;
  LoadCatalogueState(this.resp);
}

class LoadMissionsEvent extends BaseEvent {
  final int page;
  final String keyword, catId;
  final bool missionEmpty, isOwner;
  final dynamic data;
  LoadMissionsEvent(this.page, this.keyword, this.catId, this.missionEmpty, {this.isOwner = false, this.data});
}
class LoadMissionsState extends BaseState {
  final dynamic resp, counts;
  LoadMissionsState(this.resp, {this.counts});
}

class LoadMembersEvent extends BaseEvent {
  final int id;
  LoadMembersEvent(this.id);
}
class LoadMembersState extends BaseState {
  final dynamic resp;
  LoadMembersState(this.resp);
}

class LoadReviewsEvent extends BaseEvent {
  final int id, page, idDetail;
  LoadReviewsEvent(this.id, {this.page = 0, this.idDetail = -1});
}
class LoadReviewsState extends BaseState {
  final dynamic resp;
  LoadReviewsState(this.resp);
}

class JoinMissionEvent extends BaseEvent {
  final int idParent, idSub;
  JoinMissionEvent(this.idParent, this.idSub);
}
class JoinMissionState extends BaseState {
  final dynamic resp;
  JoinMissionState(this.resp);
}

class LeaveMissionEvent extends BaseEvent {
  final int idParent, idSub, idMem;
  LeaveMissionEvent(this.idParent, this.idSub, this.idMem);
}
class LeaveMissionState extends BaseState {
  final dynamic resp;
  LeaveMissionState(this.resp);
}

class LoadProvinceEvent extends BaseEvent {}
class LoadProvinceState extends BaseState {
  final dynamic list;
  LoadProvinceState(this.list);
}

class LoadDistrictEvent extends BaseEvent {
  final String idProvince;
  LoadDistrictEvent(this.idProvince);
}
class LoadDistrictState extends BaseState {
  final dynamic list;
  LoadDistrictState(this.list);
}

class GetAddressEvent extends BaseEvent {
  final dynamic latLng;
  GetAddressEvent(this.latLng);
}
class GetAddressState extends BaseState {
  final dynamic address;
  GetAddressState(this.address);
}

class GetLocationEvent extends BaseEvent {
  final dynamic address;
  GetLocationEvent(this.address);
}
class GetLocationState extends BaseState {
  final dynamic latLng;
  GetLocationState(this.latLng);
}

class ReviewMissionEvent extends BaseEvent {
  final int idParent, idSub, idMem;
  final String status;
  final List? list;
  ReviewMissionEvent(this.idParent, this.idSub, this.idMem, this.status, {this.list});
}
class ReviewMissionState extends BaseState {
  final dynamic resp;
  final String status;
  ReviewMissionState(this.resp, this.status);
}

class SetLeaderEvent extends BaseEvent {
  final int idParent, idSub, idMem, index;
  SetLeaderEvent(this.idParent, this.idSub, this.idMem, this.index);
}
class SetLeaderState extends BaseState {
  final dynamic resp;
  final int index;
  SetLeaderState(this.resp, this.index);
}

class SaveMissionEvent extends BaseEvent {
  final int id, idParent;
  final String name, cat, start, end, des, province, district, address, status, joinNumber, point, acreage;
  final dynamic images;
  SaveMissionEvent(this.id, this.name, this.cat, this.start, this.end, this.des, this.province, this.district, this.address,
      {this.idParent = -1, this.status = '', this.acreage = '', this.joinNumber = '', this.point = '', this.images});
}
class SaveMissionState extends BaseState {
  final dynamic resp;
  final String status;
  SaveMissionState(this.resp, this.status);
}

class LoadMarkersEvent extends BaseEvent {
  final dynamic map, funTouchMarker;
  String province, district, name;
  LoadMarkersEvent(this.map, this.funTouchMarker, this.province, this.district, this.name);
}
class LoadMarkersState extends BaseState {
  final dynamic resp;
  LoadMarkersState(this.resp);
}

class ShowClearSearchEvent extends BaseEvent {
  final bool value;
  ShowClearSearchEvent(this.value);
}
class ShowClearSearchState extends BaseState {
  final bool value;
  ShowClearSearchState(this.value);
}

class MissionEmptyEvent extends BaseEvent {
  final bool value;
  MissionEmptyEvent(this.value);
}
class MissionEmptyState extends BaseState {
  final bool value;
  MissionEmptyState(this.value);
}

class MissionBloc extends BaseBloc {
  MissionBloc(String type ,{BaseState init = const BaseState(),String typeInfo = ''}) :super(init: init,typeInfo: typeInfo) {
    if (type == 'list' || type == 'par_list' || type == 'mine_detail' || type == 'mine_sub_detail') {
      on<LoadCatalogueEvent>((event, emit) async {
        emit(const BaseState(isShowLoading: true));
        final resp = await ApiClient().getAPI(Constants().apiVersion + 'mission/missions/mission_catalogues', ItemListModel());
        if (resp.checkOK() && resp.data.list.isNotEmpty) emit(LoadCatalogueState(resp.data.list));
      });
      if (type == 'list' || type == 'par_list') {
        on<MissionEmptyEvent>((event, emit) => emit(MissionEmptyState(event.value)));
        on<ShowClearSearchEvent>((event, emit) => emit(ShowClearSearchState(event.value)));
      }
    }

    if (type == 'mine_detail' || type == 'mine_sub_detail' || type == 'map') {
      on<LoadProvinceEvent>((event, emit) async {
        emit(const BaseState(isShowLoading: true));
        final resp = await ApiClient().getAPI(Constants().apiVersion + 'locations/list_provinces', ItemListModel(), hasHeader: false);
        emit(resp.checkOK() && resp.data.list.isNotEmpty ? LoadProvinceState(resp.data.list) : const BaseState());
      });
      on<LoadDistrictEvent>((event, emit) async {
        emit(const BaseState(isShowLoading: true));
        final resp = await ApiClient().getAPI(Constants().apiVersion + 'locations/list_districts?province_id=' + event.idProvince, ItemListModel(), hasHeader: false);
        emit(resp.checkOK() && resp.data.list.isNotEmpty ? LoadDistrictState(resp.data.list) : const BaseState());
      });
      if (type != 'map') {
        on<GetAddressEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          final resp = await ApiClient().getAPI2(Constants().apiVersion + 'locations/address_full?lat=${event.latLng.latitude}&lng=${event.latLng.longitude}', hasHeader: false, timeout: 5);
          if (resp.isNotEmpty) {
            dynamic json = jsonDecode(resp);
            Util.checkKeyFromJson(json, 'success') && json['success'] && Util.checkKeyFromJson(json, 'data') ?
            emit(GetAddressState(json['data'])) : emit(const BaseState());
          } else emit(const BaseState());
        });
        on<GetLocationEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          final resp = await ApiClient().getAPI2(Constants().apiVersion + 'locations/latlong?address=' + event.address, hasHeader: false, timeout: 5);
          if (resp.isNotEmpty) {
            dynamic json = jsonDecode(resp);
            Util.checkKeyFromJson(json, 'success') && json['success'] && Util.checkKeyFromJson(json, 'data') ?
            emit(GetLocationState(json['data'])) : emit(const BaseState());
          } else emit(const BaseState());
        });
      }
    }

    switch(type) {
      case 'list':
        on<LoadMissionsEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          String param = '';
          if (event.keyword.isNotEmpty) param = '&keyword='+event.keyword;
          if (event.catId.isNotEmpty) param += '&catalogue_id='+event.catId;
          if (event.missionEmpty) param += '&missing_user=true';
          if (event.isOwner) param += '&user_id=${Constants().userId}';
          final resp = await ApiClient().getAPI2(Constants().apiVersion + 'mission/missions?page=${event.page}&limit=20$param');
          if (resp.isNotEmpty) {
            Map<String, dynamic> json = jsonDecode(resp);
            Util.checkKeyFromJson(json, 'success') && Util.checkKeyFromJson(json, 'data') && json['success'] ?
            emit(LoadMissionsState(BaseResponse(success: true, data: json['data'].toList()))) :
            emit(LoadMissionsState(BaseResponse(data: json['data'].toString())));
            return;
          }
          emit(const BaseState());
        });
        return;
      case 'par_list':
        on<LoadMissionsEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          String param = '';
          if (event.keyword.isNotEmpty) param = '&keyword='+event.keyword;
          if (event.catId.isNotEmpty) param += '&catalogue_id='+event.catId;
          final resp = await ApiClient().getAPI2(Constants().apiVersion + 'mission/missions/joined_users?page=${event.page}&limit=20$param');
          if (resp.isNotEmpty) {
            Map<String, dynamic> json = jsonDecode(resp);
            Util.checkKeyFromJson(json, 'success') && Util.checkKeyFromJson(json, 'data') && json['success'] ?
            emit(LoadMissionsState(BaseResponse(success: true, data: json['data'].toList()))) :
            emit(LoadMissionsState(BaseResponse(data: json['data'].toString())));
            return;
          }
          emit(const BaseState());
        });
        on<ReviewMissionEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          dynamic parent, detail;
          dynamic resp = await ApiClient().getAPI2(Constants().apiVersion + 'mission/missions/${event.idParent}');
          if (resp.isNotEmpty) {
            Map<String, dynamic> json = jsonDecode(resp);
            if (Util.checkKeyFromJson(json, 'success') && Util.checkKeyFromJson(json, 'data') && json['success']) {
              parent = json['data'];
            }

            resp = await ApiClient().getAPI2(Constants().apiVersion + 'mission/missions/${event.idParent}/mission_details/${event.idSub}');
            if (resp.isNotEmpty) {
              Map<String, dynamic> json = jsonDecode(resp);
              Util.checkKeyFromJson(json, 'success') && Util.checkKeyFromJson(json, 'data') && json['success'] ?
                detail = json['data'] : emit(const BaseState());
              if (parent != null && detail != null) emit(ReviewMissionState([parent, detail], ''));
            } else emit(const BaseState());
          } else emit(const BaseState());
        });
        return;
      case 'detail':
        on<LoadMissionsEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          final resp = await ApiClient().getAPI2(Constants().apiVersion + 'mission/missions/${event.catId}/mission_details?page=${event.page}&limit=20');
          if (resp.isNotEmpty) {
            Map<String, dynamic> json = jsonDecode(resp);
            Util.checkKeyFromJson(json, 'success') && Util.checkKeyFromJson(json, 'data') && json['success'] ?
            emit(LoadMissionsState(BaseResponse(success: true, data: json['data'].toList()))) :
            emit(LoadMissionsState(BaseResponse(data: json['data'].toString())));
            return;
          }
          emit(const BaseState());
        });
        return;
      case 'sub':
        on<JoinMissionEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          final resp = await ApiClient().postAPI(Constants().apiVersion + 'mission/missions/${event.idParent}'
              '/mission_details/${event.idSub}/mission_employees/apply_mission', 'POST', BaseResponse(), body: {'info':'Tham gia'});
          emit(JoinMissionState(resp));
        });
        on<LeaveMissionEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          final resp = await ApiClient().postAPI(Constants().apiVersion + 'mission/missions/${event.idParent}'
              '/mission_details/${event.idSub}/mission_employees/${event.idMem}', 'DELETE', BaseResponse(), body: {'out_type':'employee'});
          emit(LeaveMissionState(resp));
        });
        on<SaveMissionEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          final resp = await ApiClient().postAPI(Constants().apiVersion + 'mission/missions/${event.idParent}/mission_details/${event.id}',
              'PUT', BaseResponse(),
              body: { 'work_status': 'completed' });
          emit(SaveMissionState(resp, event.status));
        });
        return;
      case 'mine_detail':
        on<LoadMissionsEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          final List list = await _getList('mission/missions/${event.catId}/mission_details?');
          if (list.isNotEmpty) {
            double total = .0, points = .0;
            if (event.missionEmpty) {
              for (int i = list.length - 1; i > -1; i--) {
                total += (list[i]['number_joins']??.0).toDouble();
                points += (list[i]['point']??.0).toDouble();
              }
            }
            emit(LoadMissionsState(list, counts: event.missionEmpty ? [total, points] : null));
          } else emit(const BaseState());
        });
        on<LoadMembersEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          final List list = await _getList('mission/missions/${event.id}/joined_users?status=accepted&');
          list.isNotEmpty ? emit(LoadMembersState(list)) : emit(const BaseState());
        });
        on<LoadReviewsEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          final List list = await _getList('mission/missions/${event.id}/joined_users?status=waiting&');
          list.isNotEmpty ? emit(LoadReviewsState(list)) : emit(const BaseState());
        });
        on<ReviewMissionEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          final resp = await ApiClient().postAPI(Constants().apiVersion + 'mission/missions/${event.idParent}/mission_details/'
              '${event.idSub}/mission_employees/${event.idMem}/author_confirm', 'POST', BaseResponse(), body: {'status':event.status});
          emit(ReviewMissionState(resp, event.status));
        });
        on<SetLeaderEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          final resp = await ApiClient().postAPI(Constants().apiVersion + 'mission/missions/${event.idParent}/mission_details/'
              '${event.idSub}/mission_employees/${event.idMem}/update_regency', 'POST', BaseResponse(), body: {'regency':'leader'});
          emit(SetLeaderState(resp, event.index));
        });
        on<SaveMissionEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          final String id = event.id > 0 ? '/${event.id}' : '';
          final resp = await ApiClient().postAPI(Constants().apiVersion + 'mission/missions$id',
              event.id > 0 ? (event.status != 'delete' ? 'PUT' : 'DELETE') : 'POST', BaseResponse(),
              body: event.status.isEmpty ? {
                'title': event.name,
                'mission_catalogue_id': event.cat,
                'content': event.des,
                'start_date': event.start,
                'end_date': event.end,
                'province_id': event.province,
                'district_id': event.district,
                'address': event.address,
              } : { if (event.status == 'completed') 'work_status': event.status });
          emit(SaveMissionState(resp, event.status));
        });
        return;
      case 'mine_sub_detail':
        on<AddImageHomeEvent>((event, emit) => emit(AddImageHomeState()));
        on<DownloadFilesPostItemEvent>((event, emit) async {
          emit(PostItemState(isShowLoading: true));
          List<File> files = await Util.loadFilesFromNetwork(ProductRepository(), event.list);
          emit(DownloadFilesPostItemState(files));
        });
        on<SaveMissionEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          final String id = event.id > 0 ? '/${event.id}' : '';
          final resp = await ApiClient().postAPI(Constants().apiVersion + 'mission/missions/${event.idParent}/mission_details$id',
              event.id > 0 ? 'PUT' : 'POST', BaseResponse(),
              body: event.status.isEmpty ? {
                'title': event.name,
                if (event.cat.isNotEmpty) 'mission_catalogue_id': event.cat,
                'content': event.des,
                'start_date': event.start,
                'end_date': event.end,
                'province_id': event.province,
                'district_id': event.district,
                'address': event.address,
                'number_joins': event.joinNumber,
                'acreage': Util.stringToDouble(event.acreage, locale: Constants().localeVILang).toString(),
                'point': event.point
              } : { 'work_status': 'completed' }, realFiles: event.images);
          emit(SaveMissionState(resp, event.status));
        });
        return;
      case 'review':
        on<LoadReviewsEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          final List list = await _getList('mission/missions/${event.id}/joined_users?mission_detail_id=${event.idDetail}&');
          list.isNotEmpty ? emit(LoadReviewsState(list)) : emit(const BaseState());
        });
        on<ReviewMissionEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          final Map<String, String> body = {};
          int i = 0;
          for(var item in event.list!) {
            final page = (item['pageState'] as MissionReviewItem);
            if ((page.item['status']??'') == 'accepted') {
              String per = page.isLeader ? page.pageState.ctrPer1.text : page.pageState.ctrPer2.text;
              if (per.isEmpty) {
                emit(ReviewMissionState(page.isLeader ? page.pageState.fcPer1 : page.pageState.fcPer2, 'Nhập phần trăm đánh giá đầy đủ'));
                return;
              }

              body.putIfAbsent('information[$i][mission_detail_user_id]', () => page.item['id'].toString());
              body.putIfAbsent('information[$i][rate]', () => page.pageState.ctrPer1.text);
              body.putIfAbsent('information[$i][owner_percent_rate]', () => page.pageState.ctrPer2.text);
              i++;
            }
          }
          final resp = await ApiClient().postAPI(Constants().apiVersion + 'mission/missions/${event.idParent}/'
              'mission_details/${event.idSub}/mission_employees/update_rate', 'PUT', BaseResponse(), body: body);
          emit(ReviewMissionState(resp, ''));
        });
        return;
      case 'map':
        on<GetLocationEvent>((event, emit) => emit(GetLocationState(true)));
        on<LoadMarkersEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          String param = '';
          if (event.name.isNotEmpty) param = 'keyword=' + event.name;
          if (event.province.isNotEmpty) param += '&province_id=' + event.province;
          if (event.district.isNotEmpty) param += '&district_id=' + event.district;
          final list = await _getList('mission/missions/map?$param&');
          if (list.isNotEmpty) {
            final List<Marker> markers = [];
            for(int i = list.length - 1; i > -1; i--) {
              final point = await event.map.toScreenLocation(LatLng(list[i]['latitude'], list[i]['longitude']));
              markers.add(Marker(list[i], point, event.funTouchMarker));
            }
            emit(LoadMarkersState(markers));
            return;
          }
          emit(const BaseState());
        });
        on<LoadMissionsEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          final resp = await ApiClient().getAPI2(Constants().apiVersion + 'mission/missions/${event.keyword}');
          if (resp.isNotEmpty) {
            Map<String, dynamic> json = jsonDecode(resp);
            Util.checkKeyFromJson(json, 'success') && Util.checkKeyFromJson(json, 'data') && json['success'] ?
              emit(LoadMissionsState(BaseResponse(success: true, data: json['data']), counts: event.data)) :
              emit(LoadMissionsState(BaseResponse(data: json['data'].toString())));
          } else emit(const BaseState());
        });
        return;
    }
  }

  Future<List> _getList(String path) async {
    dynamic resp;
    List temp;
    final List list = [];
    Map<String, dynamic> json;
    int page = 1;
    while (page > 0) {
      resp = await ApiClient().getAPI2(Constants().apiVersion + path + 'page=$page&limit=50');
      if (resp.isNotEmpty) {
        json = jsonDecode(resp);
        if (Util.checkKeyFromJson(json, 'success') && Util.checkKeyFromJson(json, 'data') && json['success']) {
          temp = json['data'].toList();
          temp.isNotEmpty ? list.addAll(temp) : page = 0;
          temp.length == 50 ? page++ : page = 0;
        }
      } else page = 0;
    }
    return list;
  }
}