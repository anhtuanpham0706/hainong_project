import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/features/function/info_news/market_price/model/market_price_model.dart';
import 'package:hainong/features/function/info_news/technical_process/technical_process_model.dart';
import 'package:hainong/features/post/bloc/post_list_bloc.dart';

class ReviewBloc extends BaseBloc {
  ReviewBloc() {
    on<LoadFollowersPostListEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      String temp = 'market_prices';
      dynamic data = MarketPricesModel();
      switch(event.type) {
        case 1: temp = 'technical_processes'; data = TechnicalProcessesModel(); break;
        case 2: temp = 'training_contribution_data'; data = TrainConsModel(); break;
      }
      final resp = await ApiClient().getAPI(Constants().apiPerVer + '$temp?page=${event.page}&limit=20', data);
      emit(LoadFollowersPostListState(resp));
    });
  }
}

class TrainConsModel {
 final List<TrainConModel> list = [];
 TrainConsModel fromJson(json) {
   if (json.isNotEmpty) json.forEach((ele) => list.add(TrainConModel().fromJson(ele)));
   return this;
 }
}

class TrainConModel {
  int id = -1;
  String title = '', image = '', created_at = '', tree_name = '', pest_name = '', address = '', province_name = '', district_name = '', description = '';
  TrainConModel fromJson(Map<String, dynamic> json) {
    id = Util.getValueFromJson(json, 'id', -1);
    title = Util.getValueFromJson(json, 'pest_name', '');
    tree_name = Util.getValueFromJson(json, 'tree_name', '');
    pest_name = Util.getValueFromJson(json, 'pest_name', '');
    province_name = Util.getValueFromJson(json, 'province_name', '');
    district_name = Util.getValueFromJson(json, 'district_name', '');
    address = Util.getValueFromJson(json, 'address', '');
    image = Util.getValueFromJson(json, 'image', '');
    created_at = Util.getValueFromJson(json, 'created_at', '');
    description = Util.getValueFromJson(json, 'description', '');
    return this;
  }
}