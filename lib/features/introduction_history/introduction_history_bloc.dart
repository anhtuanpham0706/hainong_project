import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'introduction_history_model.dart';


class LoadListIntroHisEvent extends BaseEvent {
  final String status;
  final int page;
  LoadListIntroHisEvent(this.status,{this.page = 1});
}
class ChangeTabIntroHisEvent extends BaseEvent{}

class LoadListIntroHisState extends BaseState {
  BaseResponse response;
  LoadListIntroHisState(this.response);
}
class ChangeTabIntroHisState extends BaseState{}

class IntroductionHistoryBloc extends BaseBloc {
  IntroductionHistoryBloc() {
    on<ChangeTabIntroHisEvent>((event, emit) => emit(ChangeTabIntroHisState()));
    on<LoadListIntroHisEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final response = await ApiClient().getAPI(Constants().apiVersion + 'account/report_statistic_by_${event.status}?limit=20&page=${event.page}', IntroductionHistoryModel());
      emit(LoadListIntroHisState(response));
    });
  }
}