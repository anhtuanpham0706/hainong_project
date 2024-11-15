import 'package:hainong/common/base_bloc.dart';

abstract class ReferrerEvent extends BaseEvent {}

class LoadFriendListEvent extends ReferrerEvent {
  final String? keyword;
  final int page;
  LoadFriendListEvent(this.page, {this.keyword});
}

class LoadReferrerEvent extends ReferrerEvent {
  final String? phone;
  LoadReferrerEvent({this.phone});
}

class LoadReferrerHistoryListEvent extends ReferrerEvent {
  final String? keyword;
  final String type;
  LoadReferrerHistoryListEvent(this.type, {this.keyword});
}

class ReferrerHistoryEmptyEvent extends BaseEvent {
  final bool value;
  ReferrerHistoryEmptyEvent(this.value);
}

class ChangeTabReferrerHistoryEvent extends BaseEvent {
  final int index;
  final bool status;
  ChangeTabReferrerHistoryEvent(this.index, this.status);
}

class ShowClearSearchEvent extends BaseEvent {
  final bool value;
  ShowClearSearchEvent(this.value);
}

class LoadShopReferrerEvent extends BaseEvent {
  final String id;
  final bool isCheckReferral;
  final int userId;
  LoadShopReferrerEvent(this.userId, this.id, {this.isCheckReferral = false});
}
