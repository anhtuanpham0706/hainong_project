import 'dart:io';
import 'package:hainong/features/function/info_news/market_price/market_price_bloc.dart';
import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/models/file_byte.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'technical_process_model.dart';

abstract class TechnicalProcessEvent extends BaseEvent {}

class LoadListEvent extends TechnicalProcessEvent {
  final int page;
  final String keyword, technical_id;
  LoadListEvent(this.page,this.keyword,this.technical_id);
}
class LoadListState extends BaseState {
  final BaseResponse response;
  const LoadListState(this.response,);
}

class AddImageEvent extends TechnicalProcessEvent {}
class AddImageState extends BaseState {}

class AddHashTagHomeState extends BaseState {
  final List<ItemModel>? filters;
  final String? key;
  AddHashTagHomeState({this.filters, this.key});
}

class LoadCatalogueEvent extends TechnicalProcessEvent{
  final String idSub, keyName, keyword;
  final bool isParent;
  final bool isSubProcess;
  final bool isMainSelect;
  final bool clearList;
  final bool loadPrevious;
  final int index;
  LoadCatalogueEvent({this.idSub = '', this.isParent = true, this.keyName = 'name', this.isSubProcess =false,
    this.keyword = '', this.clearList = true, this.loadPrevious = false, this.index  = -1, this.isMainSelect =false});
}
class LoadCatalogueState extends BaseState{
  final List response;
  final String idSub;
  final bool isSubProcess;
  final bool isMainSelect;
  final bool clearList;
  final bool loadPrevious;
  final int index;

  LoadCatalogueState(this.response, this.idSub, {this.isSubProcess = false, this.clearList = true, this.loadPrevious = false, this.index = -1, this.isMainSelect = false});
}

class EmptySearchEvent extends BaseEvent{}
class EmptySearchState extends BaseState{}


class ChangeIndexMainBaseEvent extends BaseEvent{}
class ChangeIndexMainBaseState extends BaseState{}



class CreateContributeTPEvent extends TechnicalProcessEvent {
  String title;
  String content;
  String typeProcess;
  // List<ItemModel> tag;
  File image;

  CreateContributeTPEvent(this.title, this.content, this.typeProcess, this.image);
}
class CreateContributeTPState extends BaseState{
  BaseResponse response;
  CreateContributeTPState(this.response);
}

class ChangeIndexEvent extends BaseEvent{
  int index;
  ChangeIndexEvent(this.index);
}
class ChangeIndexState extends BaseState{
  int index;

  ChangeIndexState(this.index);
}

class TechnicalProcessBloc extends BaseBloc {
  TechnicalProcessBloc({BaseState init = const BaseState()}):super(init:init) {
    on<LoadListEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final String keyword = event.keyword.isEmpty ? '' : '&keyword=${event.keyword}';
      final String category_id = '&technical_process_catalogue_id=${event.technical_id}';
      final response = await ApiClient().getAPI('${Constants().apiVersion}technical_processes?page=${event.page}&'
          'limit=20$keyword$category_id', TechnicalProcessesModel());
      emit(LoadListState(response));
    });
    on<LoadCatalogueEvent>((event, emit) async {
      if(event.isSubProcess) emit(const BaseState(isShowLoading: true));
      String parent = event.isParent ? '?parent_id=is_parent' : '';
      String keyword = event.keyword.isNotEmpty? '&keyword=${event.keyword}':'';
      String temp = event.idSub.isEmpty ? 'catalogues$parent&' : event.isSubProcess?'child_catalogues/${event.idSub}?': 'list_child_catalogues?parent_id=${event.idSub== 'all' ? '': event.idSub}$keyword&';
      final response = await ApiClient().getList('technical_processes/$temp',);
      emit(LoadCatalogueState(response, event.idSub,isSubProcess: event.isSubProcess, clearList: event.clearList,
          loadPrevious: event.loadPrevious, index: event.index, isMainSelect: event.isMainSelect));
    });
    on<AddImageEvent>((event, emit) => emit(AddImageState()));
    on<CreateContributeTPEvent>((event, emit) async{
      emit(const BaseState(isShowLoading: true));
        FileByte file = FileByte(event.image.readAsBytesSync(), event.image.path);
        // String tags = '';
        // event.tag.forEach((ele) => tags += '${ele.id},');
        final response = await ApiClient().postAPI('${Constants().apiVersion}technical_processes','POST', TechnicalProcessesModel(), body: {
          "title": event.title,
          "content": event.content,
          "technical_process_catalogue_id": event.typeProcess,
          // "hash_tag": tags,
        },realFiles: [file]);
        emit(CreateContributeTPState(response));
    });
    on<UpdateStatusEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final response = event.status == '1' ? await ApiClient().postAPI(Constants().apiPerVer + 'technical_processes/${event.id}',
          'PUT', BaseResponse(), body: {"status": event.status}) :
      await ApiClient().postAPI(Constants().apiPerVer + 'technical_processes/${event.id}', 'DELETE', BaseResponse());
      emit(UpdateStatusState(response, event.status));
    });
    on<ChangeIndexEvent>((event, emit) => emit(ChangeIndexState(event.index)));
    on<EmptySearchEvent>((event, emit) => emit(EmptySearchState()));

  }
}