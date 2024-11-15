import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/features/function/info_news/news/news_model.dart';
import 'package:hainong/features/function/tool/diagnose_pests/model/plant_model.dart';

abstract class PestsHandbookEvent extends BaseEvent {}

class LoadListEvent extends PestsHandbookEvent {
  final int page;
  final String keyword, keyword2;
  LoadListEvent(this.keyword, this.page, this.keyword2);
}
class LoadListState extends BaseState {
  final BaseResponse response;
  const LoadListState(this.response);
}

class LoadCatalogueEvent extends PestsHandbookEvent{}
class LoadCatalogueState extends BaseState{
  final List<ItemModel2> list;
  LoadCatalogueState(this.list);
}

class ChangeCatalogueEvent extends PestsHandbookEvent{}
class ChangeCatalogueState extends BaseState{}

class PestsHandbookBloc extends BaseBloc {
  PestsHandbookBloc({BaseState init = const BaseState()}):super(init: init) {
    on<LoadListEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final String keyword = event.keyword.isEmpty ? '' : '&diagnostic_name=${event.keyword}';
      final String keyword2 = event.keyword2.isEmpty ? '' : '&keyword=${event.keyword2}';
      final path = '${Constants().apiVersion}diagnostic_infos?page=${event.page}&limit=${Constants().limitPage*2}$keyword$keyword2';
      final response = await ApiClient().getAPI(path, NewsModels(), hasHeader: false);
      emit(LoadListState(response));
    });
    on<LoadCatalogueEvent>((event, emit) async {
      final resp = await ApiClient().getAPI('${Constants().apiVersion}diagnostics/categories', PlantsModel(), hasHeader: false);
      if (resp.checkOK() && resp.data.list.isNotEmpty) {
        final List<PlantModel> plants = resp.data.list;
        final List<ItemModel2> list = [];
        for(var plant in plants) {
          for(var item in plant.diagnostics) {
            list.add(ItemModel2(id: item.id, name: item.name, shop_name: item.name + '\n(${plant.name})'));
          }
        }
        emit(LoadCatalogueState(list));
      }
    });
    on<ChangeCatalogueEvent>((event, emit) => emit(ChangeCatalogueState()));
  }
}