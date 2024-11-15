import 'dart:async';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import '../function/support/handbook/handbook_bloc.dart';
export '../function/support/handbook/handbook_bloc.dart';

class MemPackageUsingListBloc extends BaseBloc {
  final ScrollController scroller = ScrollController();
  final List list = [];
  dynamic myMemPackage;
  int _page = 1;

  MemPackageUsingListBloc() {
    on<LoadListEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final data = await ApiClient().getList('membership_packages/membership_packages?', page: _page, limit: 20);
      _handleLoadList(data);
      emit(LoadListState(BaseResponse()));
    });
    loadList(reload: false);
    loadMyMemPackage();
    scroller.addListener(_listenScroll);
  }

  @override
  Future<void> close() async {
    scroller.removeListener(_listenScroll);
    scroller.dispose();
    list.clear();
    super.close();
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

  void loadMyMemPackage() async {
    myMemPackage = await ApiClient().getData('membership_packages/membership_packages/current_package');
  }
}