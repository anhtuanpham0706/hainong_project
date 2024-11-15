import 'dart:convert';
import 'dart:io';
import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/features/function/info_news/news/news_bloc.dart';
import 'package:hainong/features/home/bloc/home_event.dart';
import 'package:hainong/features/home/bloc/home_state.dart';
import 'package:hainong/features/post/bloc/post_item_bloc.dart';
import 'package:hainong/features/product/product_model.dart';
import 'package:hainong/features/product/repository/product_repository.dart';
import '../mission/mission_bloc.dart';
import 'ba_model.dart';

class LoadListEvent extends BaseEvent {
  final int page, idBA;
  final String keyword;
  LoadListEvent(this.page, {this.keyword = '', this.idBA = -1});
}
class LoadListState extends BaseState {
  final BaseResponse response;
  const LoadListState(this.response);
}

class EditEvent extends BaseEvent {
  final dynamic detail, files;
  EditEvent(this.detail, this.files);
}
class EditState extends BaseState {
  final BaseResponse response;
  const EditState(this.response);
}

class CheckNoticeEvent extends BaseEvent {
  final int value;
  CheckNoticeEvent(this.value);
}
class CheckNoticeState extends BaseState {
  final int value;
  CheckNoticeState(this.value);
}

class CheckPerEvent extends BaseEvent {
  final dynamic value;
  CheckPerEvent(this.value);
}
class CheckPerState extends BaseState {
  final dynamic value;
  CheckPerState(this.value);
}

class DeleteEmpEvent extends BaseEvent {
  final int business, employee;
  DeleteEmpEvent(this.business, this.employee);
}
class DeleteEmpState extends BaseState {
  final dynamic resp;
  DeleteEmpState(this.resp);
}

class BABloc extends BaseBloc {
  BABloc(String type) : super() {
    if (type == 'product_list' || type == 'employee') on<ShowClearSearchEvent>((event, emit) => emit(ShowClearSearchState(event.value)));

    switch (type) {
      case 'list':
        on<LoadListEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          final response = await ApiClient().getAPI(Constants().apiVersion + 'business/business_associations?page=${event.page}&limit=20', BAsModel());
          emit(LoadListState(response));
        });
        return;
      case 'product_list':
        on<LoadListEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          String param = '';
          if (event.keyword.isNotEmpty) param = '&keyword=' + event.keyword;
          if (event.idBA > 0) param += '&business_association_id=${event.idBA}';
          final response = await ApiClient().getAPI(Constants().apiVersion + 'business/products?page=${event.page}&limit=20' + param, ProductsModel());
          emit(LoadListState(response));
        });
        on<DeleteEmpEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          final resp = await ApiClient().postAPI(Constants().apiVersion + 'business/products/${event.employee}?business_association_id=${event.business}', 'DELETE', BaseResponse());
          emit(DeleteEmpState(resp));
        });
        return;
      case 'detail':
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
        on<SetHeightEvent>((event, emit) => emit(SetHeightState(event.height)));
        on<AddImageHomeEvent>((event, emit) => emit(AddImageHomeState()));
        on<DownloadFilesPostItemEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          List<File> files = await Util.loadFilesFromNetwork(ProductRepository(), event.list);
          emit(DownloadFilesPostItemState(files));
        });
        on<EditEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          final resp = await ApiClient().postAPI(Constants().apiVersion + 'business/business_associations/${event.detail.id}', 'PUT', BAModel(), body: {
                "name": event.detail.name,
                "phone": event.detail.phone,
                "email": event.detail.email,
                "address": event.detail.address,
                "website": event.detail.website,
                "content": event.detail.content,
                "province_id": event.detail.province,
                "district_id": event.detail.district
              }, realFiles: event.files);
          emit(EditState(resp));
        });
        return;
      case 'employee':
        on<LoadListEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          String param = '';
          if (event.keyword.isNotEmpty) param = '&keyword=' + event.keyword;
          final resp = await ApiClient().getAPI2(Constants().apiVersion + 'business/business_associations/${event.idBA}/employees?page=${event.page}&limit=20' + param);
          if (resp.isNotEmpty) {
            final json = jsonDecode(resp);
            Util.checkKeyFromJson(json, 'success') && Util.checkKeyFromJson(json, 'data') && json['success'] ?
              emit(LoadListState(BaseResponse(success: true, data: json['data']))) : emit(LoadListState(BaseResponse(data: json['data'].toString())));
          }
        });
        on<CheckNoticeEvent>((event, emit) => emit(CheckNoticeState(event.value)));
        on<CheckPerEvent>((event, emit) => emit(CheckPerState(event.value)));
        on<EditEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          String id = (event.detail['id']??'').toString();
          if (id.isNotEmpty) id = '/' + id;
          final resp = await ApiClient().postJsonAPI(Constants().apiVersion + 'business/business_associations/${event.files}'
            '/employees$id', BaseResponse(), {"business_association_users_attributes": event.detail, "phone": event.detail['phone']??''}, method: id.isEmpty ? 'POST' : 'PUT');
          emit(EditState(resp));
        });
        on<DeleteEmpEvent>((event, emit) async {
          emit(const BaseState(isShowLoading: true));
          final resp = await ApiClient().postAPI(Constants().apiVersion + 'business/business_associations/${event.business}/employees/${event.employee}', 'DELETE', BaseResponse());
          emit(DeleteEmpState(resp));
        });
        return;
    }
  }
}