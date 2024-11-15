import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/import_lib_system.dart';
import 'package:hainong/features/function/tool/suggestion_map/suggest_model.dart';
import 'package:hainong/features/post/model/post.dart';
import '../news/news_bloc.dart';
import 'model/market_price_chart_model.dart';
import 'model/market_price_history_model.dart';
import 'model/market_price_model.dart';
import 'package:hainong/features/signup/sign_up_repository.dart';

class LoadHistoryListEvent extends BaseEvent {
  final int id;
  final bool isReload;
  LoadHistoryListEvent(this.id, this.isReload);
}
class ExpandedChartPriceEvent extends BaseEvent{
  final bool expanded;
  ExpandedChartPriceEvent(this.expanded);
}
class LoadHistoryListState extends BaseState {
  final BaseResponse resp;
  final bool isReload;
  LoadHistoryListState(this.resp, this.isReload);
}

class LoadListEvent extends BaseEvent {
  final String keyword, time, location, type;
  LoadListEvent(this.keyword, this.time, this.location, this.type);
}
class ExpandedChartPriceState extends BaseState {
  final bool expanded;
  ExpandedChartPriceState(this.expanded);
}

class LoadListState extends BaseState {
  final BaseResponse resp;
  LoadListState(this.resp);
}

class ChangeTabEvent extends BaseEvent {
  final int index;
  ChangeTabEvent(this.index);
}
class ChangeTabState extends BaseState {
  final int index;
  ChangeTabState(this.index);
}

class LoadProvinceEvent extends BaseEvent {
  final bool showLocation;
  LoadProvinceEvent({this.showLocation = false});
}
class LoadProvinceState extends BaseState {
  final BaseResponse resp;
  final bool showLocation;
  LoadProvinceState(this.resp, this.showLocation);
}

class LoadDistrictEvent extends BaseEvent{
  final bool showLocation;
  final String idProvince;
  LoadDistrictEvent({this.showLocation = false,required this.idProvince,});
}

class LoadDistrictState extends BaseState{
  final BaseResponse response;
  final bool showLocation;
  LoadDistrictState(this.response, this.showLocation);
}

class LoadChartsEvent extends BaseEvent {
  final int id;
  final String time;
  LoadChartsEvent({this.id = -1, this.time = '7'});
}
class LoadChartsState extends BaseState {
  final List? data;
  LoadChartsState(this.data);
}

class SetLocationEvent extends BaseEvent {}
class SetLocationState extends BaseState {}

class SetGoodTypeEvent extends BaseEvent{}
class SetGoodTypeState extends BaseState{}

class SetDateEvent extends BaseEvent {}
class SetDateState extends BaseState {}

class ComparePriceEvent extends BaseEvent{}

class ResetSearchEvent extends BaseEvent {}
class ResetSearchState extends BaseState {}

class ChangeInterestEvent extends BaseEvent {
  final int id;
  final int? index;
  final bool value;
  ChangeInterestEvent(this.id, this.value, {this.index});
}
class ChangeInterestState extends BaseState {
  final BaseResponse resp;
  final int? index;
  ChangeInterestState(this.resp, {this.index});
}

class ReportEvent extends BaseEvent {
  final int MarketPriceId;
  final String content;
  final int PriceId;
  ReportEvent(this.MarketPriceId,this.PriceId, this.content);
}
class ReportState extends BaseState {
  final BaseResponse resp;
  ReportState(this.resp);
}

class CreateReportPriceEvent extends BaseEvent{
  final MkPHistoryModel mkPHistoryModel;
  CreateReportPriceEvent(this.mkPHistoryModel);
}

class CreateReportPriceState extends BaseState{
  BaseResponse baseResponse;
  CreateReportPriceState(this.baseResponse);
}

class UpdateStatusEvent extends BaseEvent{
  final String id, status;
  UpdateStatusEvent(this.id, this.status);
}
class UpdateStatusState extends BaseState{
  BaseResponse resp;
  final String status;
  UpdateStatusState(this.resp, this.status);
}

class CheckProcessPostInMarketEvent extends BaseEvent{
}

class CheckProcessPostInMarketState extends BaseState{
  bool? isActive;
  CheckProcessPostInMarketState({required this.isActive});
}

class MarketPriceBloc extends BaseBloc {
  int page = 1;
  MarketPriceBloc() {
    on<ChangeTabEvent>((event, emit) => emit(ChangeTabState(event.index)));
    on<SetLocationEvent>((event, emit) => emit(SetLocationState()));
    on<SetDateEvent>((event, emit) => emit(SetDateState()));
    on<ResetSearchEvent>((event, emit) => emit(ResetSearchState()));
    on<ExpandedChartPriceEvent>((event, emit) => emit(ExpandedChartPriceState(!event.expanded)));
    on<LoadProvinceEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await SignUpRepository().loadProvince();
      emit(resp.checkOK() && resp.data.list.isNotEmpty ? LoadProvinceState(resp, event.showLocation) : const BaseState());
    });
    on<LoadDistrictEvent>((event, state) async{
      emit(const BaseState(isShowLoading: true));
      final resp = await SignUpRepository().loadDistrict(event.idProvince);
      emit(resp.checkOK() && resp.data.list.isNotEmpty ? LoadDistrictState(resp, event.showLocation) : const BaseState());
    });
    on<LoadListEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      late BaseResponse resp;
      String temp = '';
      if (event.type.isNotEmpty && event.type != 'all') temp += '&agricultural_type=${event.type}';
      if (event.keyword.isNotEmpty) temp += '&keyword=${event.keyword}';
      if (event.location.isNotEmpty) temp += '&province_id=${event.location}';
      if (event.time.isNotEmpty) temp += '&date=${event.time}';
      resp = await ApiClient().getAPI(Constants().apiVersion + (event.type.isEmpty ? 'account/like_market_prices' : 'market_prices')
          + '?page=$page&limit=${Constants().limitPage}$temp', MarketPricesModel());
      emit(LoadListState(resp));
      resp.checkOK() && resp.data.list.length == Constants().limitPage ? page++ : page = 0;
    });
    on<LoadHistoryListEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().getAPI('${Constants().apiVersion}market_prices'
            '/${event.id}?page=$page&limit=${Constants().limitPage}', MkPHistoriesModel());
      emit(LoadHistoryListState(resp,event.isReload));
      resp.checkOK() && resp.data.list.length == Constants().limitPage ? page++ : page = 0;
    });
    on<LoadChartsEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      String param = '';
      if (event.id > 0) {
        param = '&ids[]=${event.id}';
      } else if (!Constants().isLogin) {
        emit(LoadChartsState(null));
        return;
      }
      final now = DateTime.now();
      final date = '&start_date=${Util.dateToString(now.add(Duration(days: -int.parse(event.time))), pattern: 'dd/MM/yyyy')}&end_date=' + Util.dateToString(now, pattern: 'dd/MM/yyyy');
      final resp = await ApiClient().getAPI('${Constants().apiVersion}market_prices/chart'
          '?page=1&limit=5$param$date', MarketPriceChartsModel(), hasHeader: param.isEmpty && Constants().isLogin);
      if (resp.checkOK()) {
        final data = (resp.data as MarketPriceChartsModel).result;
        double max = .0;
        if (event.id > 0) {
          if (data.isNotEmpty) {
            for (var detail in data[0].details.list) {
              if (detail.price > max) max = detail.price;
            }
            if (max > 0) data[0].details.list[0].max_price = max;
          }
          emit(LoadChartsState(resp.data.result));
        } else if (resp.data.result.isNotEmpty) {
          final List<Map<String, dynamic>> list = [];
          data.sort((a, b) {
            if (a.details.list.isEmpty || b.details.list.isEmpty) return 0;
            return a.details.list[0].created_at.compareTo(b.details.list[0].created_at);
          });
          for (var item in data) {
            for (var detail in item.details.list) {
              if (detail.price > max) max = detail.price;
              list.add({
                'date': Util.strDateToString(detail.created_at, pattern: 'dd/MM/yyyy HH:mm'),
                'name': item.title,
                'points': detail.price,
                'created': detail.created_at
              });
            }
          }
          if (max > 0) data[0].details.list[0].max_price = max;
          list.sort((a, b) => a['created'].toString().compareTo(b['created'].toString()));
          emit(LoadChartsState([resp.data, list]));
        } else emit(LoadChartsState(null));
      } else emit(LoadChartsState(null));
    });
    on<ChangeInterestEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      String temp = event.value ? 'unlike' : 'like_item';
      final resp = await ApiClient().postAPI('${Constants().apiVersion}account/$temp', 'POST', BaseResponse(), body: {
        'classable_id':event.id.toString(),
        'classable_type':'MarketPlace'
      });
      emit(ChangeInterestState(resp, index: event.index));
    });
    on<ReportEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().postAPI('${Constants().apiVersion}market_prices/user_report', 'POST', BaseResponse(), body: {
        'market_price_id':event.MarketPriceId.toString(),
        'price_id':event.PriceId.toString(),
        'content':event.content
      });
      emit(ReportState(resp));
    });
    on<SetGoodTypeEvent>((event, emit) => emit(SetGoodTypeState()));
    on<CreateReportPriceEvent>((event, emit) async{
      emit(const BaseState(isShowLoading: true));
      final response = await ApiClient().postAPI('${Constants().apiVersion}market_prices', 'POST', BaseResponse(),
          body:{
            "title" : event.mkPHistoryModel.title,
            "price" : event.mkPHistoryModel.price.toString(),
            "agricultural_type" : event.mkPHistoryModel.agricultural_type == MultiLanguage.get('lbl_agricultural')? 'agricultural' : 'fertilizer' ,
            "province_id" : event.mkPHistoryModel.provinceId.toString(),
            "district_id" : event.mkPHistoryModel.districtId.toString(),
            "unit" : event.mkPHistoryModel.unit,
            "market_place_id": event.mkPHistoryModel.market_place_id.toString(),
            "optional": '',
            "upload_image":'',
            //"min_price": event.mkPHistoryModel.min_price.toString(),
            //"max_price": event.mkPHistoryModel.max_price.toString(),
            "date": DateTime.now().toString(),
            }
      );
      emit(CreateReportPriceState(response));
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
    on<UpdateStatusEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final response = event.status == '1' ? await ApiClient().postAPI(Constants().apiPerVer + 'market_prices/update_price/${event.id}',
          'PUT', BaseResponse(), body: {"status": event.status}) :
        await ApiClient().postAPI(Constants().apiPerVer + 'market_prices/destroy_price/${event.id}', 'DELETE', BaseResponse());
      emit(UpdateStatusState(response, event.status));
    });
    on<CheckProcessPostInMarketEvent>((event, emit) async{
      emit(const BaseState(isShowLoading: true));
      bool? status;
      final response  = await ApiClient().getAPI(Constants().apiVersion + 'base/option?key=process_post_auto', Options(), hasHeader: false);
      if (response.checkOK() && response.data.list.length > 0) status = response.data.list[0].value == 'true';
      emit(CheckProcessPostInMarketState(isActive: status));
    });
  }
}