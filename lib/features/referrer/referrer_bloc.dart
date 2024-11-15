import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/features/referrer/referrer_event.dart';
import 'package:hainong/features/referrer/referrer_state.dart';
import 'package:hainong/features/referrer/repository/referrer_repository.dart';

class ReferrerBloc extends BaseBloc {
  final repository = ReferrerRepository();

  ReferrerBloc(ReferrerState init) : super(init: init) {
    on<LoadFriendListEvent>(_handleLoadFriendList);
    on<LoadReferrerEvent>(_handleLoadReferrer);
    on<ShowClearSearchEvent>((event, emit) => emit(ShowClearSearchState(event.value)));
    on<LoadReferrerHistoryListEvent>(_handleLoadReferrerHistoryList);
    on<LoadShopReferrerEvent>(_handleLoadReferrerShop);
    on<ChangeTabReferrerHistoryEvent>((event, emit) => emit(ChangeTabReferrerHistoryState(event.index, event.status)));
  }

  _handleLoadFriendList(event, emit) async {
    emit(ReferrerState(isShowLoading: true));
    final response = await repository.loadFriends(event.keyword, event.page.toString());
    emit(LoadFriendListState(response));
  }

  _handleLoadReferrer(event, emit) async {
    emit(ReferrerState(isShowLoading: true));
    final response = await repository.loadReferrer(event.phone);
    emit(LoadReferrerState(response));
  }

  _handleLoadReferrerHistoryList(event, emit) async {
    emit(ReferrerState(isShowLoading: true));
    final response = await repository.loadReferrerNewUser(event.type);
    response != null
      ? emit(GetReferrerHistoryState(response.response, response.totalPoint, response.type))
      : emit(const BaseState());
  }

  _handleLoadReferrerShop(event, emit) async {
    emit(ReferrerState(isShowLoading: true));
    final response = await repository.loadShop(event.id);
    emit(LoadShopReferrerState(event.userId, response, isCheckReferral: event.isCheckReferral));
  }
}
