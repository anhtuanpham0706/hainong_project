import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';

class ReferrerState extends BaseState {
  ReferrerState({isShowLoading = false}) : super(isShowLoading: isShowLoading);
}

class LoadFriendListState extends ReferrerState {
  final BaseResponse response;
  LoadFriendListState(this.response);
}

class LoadReferrerState extends ReferrerState {
  final BaseResponse response;
  LoadReferrerState(this.response);
}

class LoadReferrerHistoryListState extends ReferrerState {
  final BaseResponse response;
  LoadReferrerHistoryListState(this.response);
}

class ReferrerHistoryEmptyState extends BaseState {
  final bool value;
  ReferrerHistoryEmptyState(this.value);
}

class ShowClearSearchState extends BaseState {
  final bool value;
  ShowClearSearchState(this.value);
}

// class LoadReferrerHistoryState extends BaseState {
//   final dynamic resp, counts;
//   LoadReferrerHistoryState(this.resp, {this.counts});
// }

class GetReferrerHistoryState extends BaseState {
  dynamic data;
  final int? totalPoint;
  final String? type;
  GetReferrerHistoryState(this.data, this.totalPoint, this.type);
}

class LoadShopReferrerState extends BaseState {
  final BaseResponse response;
  final bool isCheckReferral;
  final int userId;
  LoadShopReferrerState(this.userId, this.response, {this.isCheckReferral = false});
}

class ChangeTabReferrerHistoryState extends BaseState {
  final int index;
  final bool status;
  ChangeTabReferrerHistoryState(this.index, this.status);
}
