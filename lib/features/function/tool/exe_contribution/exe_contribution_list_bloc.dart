import 'dart:async';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';

import 'package:hainong/features/function/support/handbook/handbook_bloc.dart';
export 'package:hainong/features/function/support/handbook/handbook_bloc.dart';

class ExeContributionListBloc extends BaseBloc {
  final ScrollController scroller = ScrollController();
  final List list = [];
  int _page = 1, tab = 0;

  @override
  Future<void> close() async {
    scroller.removeListener(_listenScroll);
    scroller.dispose();
    list.clear();
    super.close();
  }

  ExeContributionListBloc() {
    on<ChangeExpandEvent>((event, emit) => emit(ChangeExpandState()));
    on<LoadListEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      String path;
      switch(tab) {
        case 1: path = 'contribution_missions/user_tasks?status=happenning&'; break;
        case 2: path = 'contribution_missions/user_tasks?status=expired&'; break;
        default: path = 'contribution_missions?';
      }
      final data = await ApiClient().getList(path, page: _page, limit: 20, isOnePage: true);
      _handleLoadList(data);
      emit(LoadListState(BaseResponse()));
    });
    loadList(reload: false);
    scroller.addListener(_listenScroll);
  }

  Future<void> loadList({bool reload = true}) async {
    if (reload) {
      _page = 1;
      list.clear();
    }
    add(LoadListEvent(0, ''));
  }

  void _listenScroll() {
    if (_page > 0 && scroller.position.maxScrollExtent == scroller.position.pixels) loadList(reload: false);
  }

  void _handleLoadList(dynamic data) {
    if (data.isNotEmpty) {
      list.addAll(data);
      data.length == 20 ? _page++ : _page = 0;
    } else _page = 0;
  }

  void changeTab(int index, Function setState) {
    if (tab != index) {
      list.clear();
      tab = index;
      _page = 1;
      setState();
      add(LoadListEvent(0, ''));
    }
  }
}