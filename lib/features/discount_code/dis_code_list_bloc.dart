import 'dart:async';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import '../function/support/mission/mission_bloc.dart';
export '../function/support/mission/mission_bloc.dart';

class DisCodeListBloc extends BaseBloc {
  final TextEditingController ctrSearch = TextEditingController();
  final ScrollController scroller = ScrollController();
  final List list = [];
  final List? shops;
  int? _loading;
  int _page = 1, currentSelect = -1, tabIndex = 0;

  DisCodeListBloc({this.currentSelect = -1, bool isDetail = false, this.shops}) {
    if (isDetail) {
      on<LoadMissionsEvent>((event, emit) async {
        emit(const BaseState(isShowLoading: true));
        final data = await ApiClient().getList('coupons/$currentSelect/invoice_users_applied?', page: _page, limit: 20, isOnePage: true);
        _handleLoadList(data);
        emit(LoadMissionsState(null));
      });
    } else {
      // clear search
      on<ShowClearSearchEvent>((event, emit) => emit(ShowClearSearchState(event.value)));

      // change tab
      on<LoadCatalogueEvent>((event, emit) => emit(LoadCatalogueState('')));

      // change selection
      on<LoadMembersEvent>((event, emit) => emit(LoadMembersState(event.id)));

      // load list
      on<LoadMissionsEvent>((event, emit) async {
        emit(const BaseState(isShowLoading: true));
        String mine = '';
        if (shops != null) {
          int i = 0;
          for (var ele in shops!) {
            mine += 'shops[$i][id]=${ele[0]}&shops[$i][price]=${ele[1]}&';
            i++;
          }
          mine = 'coupons/valids?' + mine;
        } else mine = tabIndex == 1 ? 'coupons/current_coupon?' : 'coupons?';
        final data = await ApiClient().getList(mine + 'keyword=' + ctrSearch.text.trim() + '&', page: _page, limit: 20, isOnePage: true);
        _handleLoadList(data);
        emit(LoadMissionsState(null));
      });
    }

    loadList(reload: false);
    scroller.addListener(_listenScroll);
  }

  @override
  Future<void> close() async {
    ctrSearch.dispose();
    scroller.removeListener(_listenScroll);
    scroller.dispose();
    list.clear();
    super.close();
  }

  Future<void> loadList({bool reload = true}) async {
    if (_loading != null) return;
    _loading = 1;
    if (reload) {
      _page = 1;
      list.clear();
    }
    add(LoadMissionsEvent(0, '', '', false));
  }

  void _listenScroll() {
    if (_page > 0 && scroller.position.maxScrollExtent == scroller.position.pixels) loadList(reload: false);
  }

  void _handleLoadList(dynamic data) {
    if (data.isNotEmpty) {
      list.addAll(data);
      data.length == 20 ? _page++ : _page = 0;
    } else _page = 0;
    _loading = null;
  }

  void clear() {
    ctrSearch.text = '';
    add(ShowClearSearchEvent(false));
    loadList();
  }

  void changeTab(int index) {
    if (index == tabIndex) return;
    tabIndex = index;
    add(LoadCatalogueEvent());

    currentSelect = -1;
    add(LoadMembersEvent(currentSelect));

    loadList(reload: true);
  }

  void selectItem(int index) {
    if (currentSelect != index && currentSelect > -1) {
      list[currentSelect].update('is_selected', (value) => false, ifAbsent: () => false);
      add(LoadMembersEvent(currentSelect));
    }

    bool temp = list[index].containsKey('is_selected');
    if (temp) {
      temp = !(list[index]['is_selected']??false);
      list[index].update('is_selected', (value) => temp, ifAbsent: () => temp);
    } else {
      temp = true;
      list[index].putIfAbsent('is_selected', () => true);
    }

    currentSelect = temp ? index : -1;
    add(LoadMembersEvent(index));
  }
}