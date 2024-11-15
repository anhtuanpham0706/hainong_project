import 'dart:io';
import 'package:hainong/features/function/tool/suggestion_map/suggest_model.dart';
import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/features/home/bloc/home_event.dart';
import 'package:hainong/features/home/bloc/home_state.dart';
import 'package:hainong/features/post/bloc/post_item_bloc.dart';
import 'package:hainong/features/post/bloc/post_list_bloc.dart';
import 'package:hainong/features/post/model/post.dart';
import 'package:hainong/features/product/repository/product_repository.dart';
import '../technical_process/technical_process_model.dart';
import 'news_model.dart';

abstract class NewsEvent extends BaseEvent {}

class LoadListEvent extends NewsEvent {
  final int page;
  final bool isVideo;
  final String tag;
  LoadListEvent(this.page, this.isVideo, {this.tag = ''});
}
class LoadListState extends BaseState {
  final BaseResponse response;
  LoadListState(this.response);
}

class LoadListWithCatEvent extends NewsEvent {
  final int page, id;
  final bool isVideo;
  LoadListWithCatEvent(this.page, this.id, this.isVideo);
}
class LoadListWithCatState extends BaseState {
  final BaseResponse response;
  LoadListWithCatState(this.response);
}

class PlayAudioEvent extends NewsEvent {
  final bool value;
  PlayAudioEvent(this.value);
}
class PlayAudioState extends BaseState {
  final bool value;
  PlayAudioState(this.value);
}

class AutoSwitchEvent extends NewsEvent {
  final bool value;
  AutoSwitchEvent(this.value);
}
class AutoSwitchState extends BaseState {
  final bool value;
  AutoSwitchState(this.value);
}

class SetHeightEvent extends BaseEvent {
  final double height;
  final dynamic ext;
  SetHeightEvent(this.height, {this.ext});
}
class SetHeightState extends BaseState {
  final double height;
  final dynamic ext;
  SetHeightState(this.height, {this.ext});
}

class LoadListManageEvent extends BaseEvent {
  final int page, type;
  LoadListManageEvent(this.page, this.type);
}
class LoadListLikeNewsEvent extends BaseEvent {
  final int page, type;
  LoadListLikeNewsEvent(this.page, this.type);
}
class LoadListManageState extends BaseState {
  final BaseResponse response;
  LoadListManageState(this.response);
}
class LoadListLikeNewsState extends BaseState {
  final BaseResponse response;
  LoadListLikeNewsState(this.response);
}

class ChangeStatusManageEvent extends BaseEvent {}
class ChangeStatusManageState extends BaseState {}

class LoadCatManageEvent extends BaseEvent {
  final String type;
  LoadCatManageEvent(this.type);
}
class LoadCatManageState extends BaseState {
  final List<ItemModel> list;
  LoadCatManageState(this.list);
}

class ChangeTagManageEvent extends BaseEvent {}
class ChangeTagManageState extends BaseState {}

class CUDNewsManageEvent extends BaseEvent {
  final int id;
  final String title, content, type, status, cat, feature, image;
  final List<ItemModel> tags;
  CUDNewsManageEvent(this.id, this.title, this.content, this.tags, this.type,
      this.status, this.cat, this.feature, this.image);
}
class CUDNewsManageState extends BaseState {
  final BaseResponse response;
  CUDNewsManageState(this.response);
}

class DeleteNewsEvent extends BaseEvent {
  final int id;
  final String type;
  DeleteNewsEvent(this.id, this.type);
}
class DeleteNewsState extends BaseState {
  final BaseResponse response;
  DeleteNewsState(this.response);
}
class AddFavoriteEvent extends NewsEvent {
  final String classableType;
  final int classableId;
  AddFavoriteEvent(this.classableId, this.classableType);
}

class RemoveFavoriteEvent extends NewsEvent {
  final String favoriteId;
  RemoveFavoriteEvent(this.favoriteId);
}
class AddFavoriteState extends BaseState {
  final BaseResponse response;
  AddFavoriteState(this.response);
}

class RemoveFavoriteState extends BaseState {
  final BaseResponse response;
  RemoveFavoriteState(this.response);
}

class CreatePostEvent extends HomeEvent {
  final String title;
  CreatePostEvent(this.title);
}
class CreatePostState extends BaseState {
  final BaseResponse response;
  CreatePostState(this.response);
}

class LoadTechProDtlEvent extends HomeEvent {
  final String id;
  final bool isNews;
  LoadTechProDtlEvent(this.id, {this.isNews = false});
}
class LoadTechProDtlState extends BaseState {
  final BaseResponse response;
  LoadTechProDtlState(this.response);
}

class CheckProcessPostAutoInNewsEvent extends BaseEvent{
}

class CheckProcessPostAutoInNewsState extends BaseState{
  bool? isActive;
  CheckProcessPostAutoInNewsState({this.isActive});
}

class NewsBloc extends BaseBloc {
  NewsBloc({bool isNews = false, int id = -1, BaseState init = const BaseState()}):super(init:init) {
    if (isNews && id > 0) ApiClient().getAPI(Constants().apiVersion + 'articles/$id', NewsModel());

    on<LoadTechProDtlEvent>((event, emit) async {
      final response = await ApiClient().getAPI(Constants().apiVersion + (event.isNews ? 'articles/' : 'technical_processes/') + event.id, event.isNews ? NewsModel() : TechnicalProcessModel());
      if (response.checkOK()) emit(LoadTechProDtlState(response));
    });
    on<CreatePostEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final response = await ApiClient().postAPI(
          Constants().apiVersion + 'posts', 'POST', Post(),
          body: {
            "title": event.title, "post_type": 'public', "description": "", "hash_tag": "[]"
          });
      emit(CreatePostState(response));
    });
    on<DeleteNewsEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().postAPI('${Constants().apiConVer}'
          '${event.type}s/${event.id}', 'DELETE', BaseResponse());
      emit(DeleteNewsState(resp));
    });
    on<CUDNewsManageEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().postAPI('${Constants().apiConVer}'
          'resources/quick_create_upload', 'POST', BaseResponse(), files: [event.image], paramFile: 'file');
      if (resp.checkOK(passString: true)) {
        String tags = '';
        event.tags.forEach((ele) => tags += '${ele.id},');
        final ext = event.id > 0 ? '/${event.id}' : '';
        final response = await ApiClient().postAPI('${Constants().apiConVer}'
            '${event.type}s$ext', ext.isEmpty ? 'POST' : 'PUT', NewsModel(),
            body: {
              'title': event.title,
              'content': event.content,
              'status': event.status,
              'is_feature': event.feature,
              'article_catalogue_id': event.cat,
              'tags': tags,
              'image': resp.data
            });
        emit(CUDNewsManageState(response));
        return;
      }
      emit(CUDNewsManageState(resp));
    });
    on<DownloadFilesPostItemEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      List<File> files = await Util.loadFilesFromNetwork(ProductRepository(), event.list);
      emit(DownloadFilesPostItemState(files));
    });
    on<LoadCatManageEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final response = await ApiClient().getAPI('${Constants().apiVersion}catalogues/${event.type}_catalogues?page=1&limit=100', ItemListModel());
      if (response.checkOK() && response.data.list.isNotEmpty) emit(LoadCatManageState(response.data.list));
    });
    on<LoadListManageEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final response = await ApiClient().getAPI('${Constants().apiConVer}${event.type==0?'articles':'videos'}?page=${event.page}&limit=20', NewsModels());
      emit(LoadListManageState(response));
    });
    on<LoadListLikeNewsEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final response = await ApiClient().getAPI('${Constants().apiVersion}articles/favorite_articles?article_type=${event.type==1?'Video':'Article'}&page=${event.page}&limit=20', NewsModels());
      emit(LoadListLikeNewsState(response));
    });
    on<LoadListEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      String params = event.tag.isEmpty ? '' : '&hash_tag=' + event.tag;
      params += '&article_type=' + (event.isVideo ? 'Video':'Article');
      final response = await ApiClient().getAPI(Constants().apiVersion +
          'articles?page=${event.page}&limit=20' + params, NewsModels());
      emit(LoadListState(response));
    });
    on<LoadListWithCatEvent>((event, emit) async {
      final response = await ApiClient().getAPI('${Constants().apiVersion}articles/${event.id}/relation_articles?page=${event.page}&'
          'limit=${Constants().limitPage}&article_type=${event.isVideo?'Video':'Article'}', NewsModels());
      emit(LoadListWithCatState(response));
    });
    on<AddFavoriteEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final response = await ApiClient().postAPI('${Constants().apiVersion}account/create_favourite', 'POST', ItemModel(),
          body: {
            "classable_type": event.classableType=='article'?'Article':'Video',
            "classable_id": event.classableId.toString()
          });
      emit(AddFavoriteState(response));
    });
    on<RemoveFavoriteEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final response = await ApiClient().postAPI(
          '${Constants().apiVersion}account/favourite/${event.favoriteId}', 'DELETE', BaseResponse());
      emit(RemoveFavoriteState(response));
    });
    on<PlayAudioEvent>((event, emit) => emit(PlayAudioState(event.value)));
    on<SetHeightEvent>((event, emit) => emit(SetHeightState(event.height)));
    on<AutoSwitchEvent>((event, emit) => emit(AutoSwitchState(event.value)));
    on<ChangeTabEvent>((event, emit) => emit(ChangeTabState(event.index)));
    on<ChangeStatusManageEvent>((event, emit) => emit(ChangeStatusManageState()));
    on<AddImageHomeEvent>((event, emit) => emit(AddImageHomeState()));
    on<ChangeTagManageEvent>((event, emit) => emit(ChangeTagManageState()));
    on<CheckProcessPostAutoInNewsEvent>((event, emit) async{
      emit(const BaseState(isShowLoading: true));
      bool? status;
      final response  = await ApiClient().getAPI(Constants().apiVersion + 'base/option?key=process_post_auto', Options(), hasHeader: false);
      if (response.checkOK() && response.data.list.length > 0) status = response.data.list[0].value == 'true';
      emit(CheckProcessPostAutoInNewsState(isActive: status));
    });
  }
}