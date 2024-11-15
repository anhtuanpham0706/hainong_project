import 'dart:io';
import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/models/file_byte.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/features/function/info_news/news/news_bloc.dart' as news;
import 'package:hainong/features/function/support/handbook/handbook_bloc.dart';
import 'package:hainong/features/home/bloc/home_event.dart';
import 'package:hainong/features/home/bloc/home_state.dart';
import 'package:hainong/features/login/login_model.dart';
import 'package:hainong/features/post/bloc/post_item_bloc.dart';
import 'package:hainong/features/product/repository/product_repository.dart';
import 'package:hainong/features/profile/profile_bloc.dart';
import 'package:hainong/features/signup/sign_up_repository.dart';
import 'package:trackasia_gl/mapbox_gl.dart';
import '../farm_management/farm_management_bloc.dart';

class CreatePlotsEvent extends BaseEvent {
  final int id;
  final String name, tree, owner, address, content, location, acreage, expert, province, district;
  final List<FileByte> images;
  CreatePlotsEvent(this.id, this.name, this.tree, this.owner, this.address, this.content, this.location, this.acreage, this.expert, this.province, this.district, this.images);
}

class SavePolygonEvent extends BaseEvent {
  final int id;
  final Set<Circle> circles;
  SavePolygonEvent(this.id, this.circles);
}

class DrawMapEvent extends BaseEvent {}
class DrawMapState extends BaseState {}

class PlotsManagementBloc extends BaseBloc {
  PlotsManagementBloc({BaseState init = const BaseState(),String typeInfo = ''}) :super(init: init,typeInfo: typeInfo) {
    on<ShowLoadingHomeEvent>((event, emit) => emit(BaseState(isShowLoading: event.isShow)));
    on<AddImageHomeEvent>((event, emit) => emit(AddImageHomeState()));
    on<DrawMapEvent>((event, emit) => emit(DrawMapState()));
    on<DownloadFilesPostItemEvent>((event, emit) async {
      emit(PostItemState(isShowLoading: true));
      List<File> files = await Util.loadFilesFromNetwork(ProductRepository(), event.list);
      emit(DownloadFilesPostItemState(files));
    });
    on<LoadProvinceProfileEvent>((event, emit) async {
      final resp = await SignUpRepository().loadProvince();
      if (resp.checkOK() && resp.data.list.isNotEmpty) emit(LoadProvinceProfileState(resp.data.list));
    });
    on<LoadDistrictProfileEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await SignUpRepository().loadDistrict(event.provinceId);
      if (resp.checkOK() && resp.data.list.isNotEmpty) emit(LoadDistrictProfileState(resp.data.list));
      else emit(const BaseState());
    });
    on<LoadListEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      String path = 'culture_plots?';
      if (event.idAssigned != null) path = 'culture_plots/manages?officer_id=${event.idAssigned}&';
      final resp = await ApiClient().getAPI(Constants().apiVersion + path + 'page=${event.page}&limit=10&keyword=${event.keyword}', PlotsManageModels());
      emit(LoadListState(resp));
    });
    on<CreatePlotsEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final String id = event.id > 0 ? '/${event.id}' : '';
      final resp = await ApiClient().postAPI(Constants().apiVersion + 'culture_plots$id', event.id > 0 ? 'PUT' : 'POST', PlotsManageModel(),
          hasHeader: true, body: {
            'title': event.name,
            'acreage': event.acreage,
            'family_tree': event.tree,
            'office_phone': event.owner,
            'content': event.content,
            'address': event.address,
            if (event.expert.isNotEmpty && event.expert != '-1') 'expert_id': event.expert,
            if (event.province.isNotEmpty && event.province != '-1') 'province_id': event.province,
            if (event.district.isNotEmpty && event.district != '-1') 'district_id': event.district,
            //'latitude': '.0',
            //'longitude': '.0'
          }, realFiles: event.images);
      emit(CreatePlanState(resp));
    });
    on<DeletePlanEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().postAPI(Constants().apiVersion + 'culture_plots/${event.id}', 'DELETE', BaseResponse());
      emit(DeletePlanState(resp));
    });
    //on<LoadMapKeyEvent>((event, emit) async {
    //  final resp = await MapPageRepository().loadMapKey();
    //  if (resp.checkOK() && resp.data.list.isNotEmpty) emit(LoadMapKeyState(resp));
    //});
    on<SavePolygonEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final body = {'culture_plot_id': event.id.toString()};
      int i = 0;
      for(var circle in event.circles) {
        body.putIfAbsent('position[$i][lat]', () => circle.options.geometry!.latitude.toString());
        body.putIfAbsent('position[$i][long]', () => circle.options.geometry!.longitude.toString());
        i++;
      }
      dynamic resp = await ApiClient().postAPI(Constants().apiVersion + 'culture_plots/user_culture_plots', 'POST', BaseResponse(), body: body);
      if (resp.checkOK(passString: true)) {
        String lat = '', lng = '';
        if (event.circles.isNotEmpty) {
          lat = event.circles.first.options.geometry!.latitude.toString();
          lng = event.circles.first.options.geometry!.longitude.toString();
        }
        resp = await ApiClient().postAPI(Constants().apiVersion + 'culture_plots/${event.id}', 'PUT', PlotsManageModel(),
        body: {
          'latitude': lat,
          'longitude': lng
        });
        emit(CreatePlanState(resp));
      } else emit(CreatePlanState(resp));
    });
    on<news.LoadListManageEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().getAPI(Constants().apiVersion + 'culture_plots/officers?page=${event.page}&limit=20', LoginsModel());
      emit(news.LoadListManageState(resp));
    });
  }
}

class PlotsManageModels {
  final List<PlotsManageModel> list = [];
  PlotsManageModels fromJson(json) {
    if (json.isNotEmpty) json.forEach((ele) => list.add(PlotsManageModel().fromJson(ele)));
    return this;
  }
}

class PlotsManageModel {
  int id = -1, expert_id = -1, province_id = -1, district_id = -1, user_id = -1;
  double acreage = .0, latitude = .0, longitude = .0;
  String title = '', family_tree = '', office_name = '', expert_name = '', province_name = '', district_name = '', content = '', address = '';
  final List<String> images = [];
  final List<dynamic> polygons = [];
  PlotsManageModel fromJson(Map<String, dynamic> json) {
    id = Util.getValueFromJson(json, 'id', -1);
    user_id = Util.getValueFromJson(json, 'user_id', -1);
    expert_id = Util.getValueFromJson(json, 'expert_id', -1);
    expert_name = Util.getValueFromJson(json, 'expert_name', '');
    province_id = Util.getValueFromJson(json, 'province_id', -1);
    province_name = Util.getValueFromJson(json, 'province_name', '');
    district_id = Util.getValueFromJson(json, 'district_id', -1);
    district_name = Util.getValueFromJson(json, 'district_name', '');
    acreage = Util.getValueFromJson(json, 'acreage', .0);
    latitude = Util.getValueFromJson(json, 'latitude', .0);
    longitude = Util.getValueFromJson(json, 'longitude', .0);
    title = Util.getValueFromJson(json, 'title', '');
    family_tree = Util.getValueFromJson(json, 'family_tree', '');
    office_name = Util.getValueFromJson(json, 'office_phone', '');
    content = Util.getValueFromJson(json, 'content', '');
    address = Util.getValueFromJson(json, 'address', '');
    if (Util.checkKeyFromJson(json, 'images')) json['images'].forEach((ele) => images.add(ele['name']));
    if (Util.checkKeyFromJson(json, 'polygons')) json['polygons'].forEach((ele) => polygons.add(ele));
    return this;
  }

  void setValues(PlotsManageModel value) {
    id = value.id;
    user_id = value.user_id;
    expert_id = value.expert_id;
    expert_name = value.expert_name;
    province_id = value.province_id;
    province_name = value.province_name;
    district_id = value.district_id;
    district_name = value.district_name;
    acreage = value.acreage;
    latitude = value.latitude;
    longitude = value.longitude;
    title = value.title;
    family_tree = value.family_tree;
    office_name = value.office_name;
    content = value.content;
    address = value.address;
    images.clear();
    images.addAll(value.images);
    polygons.clear();
    polygons.addAll(value.polygons);
  }
}