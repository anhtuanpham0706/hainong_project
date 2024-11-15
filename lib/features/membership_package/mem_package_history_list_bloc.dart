import 'dart:async';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import '../function/support/mission/mission_bloc.dart';
export '../function/support/mission/mission_bloc.dart';

class MemPackageHistoryListBloc extends BaseBloc {
  final TextEditingController ctrSearch = TextEditingController();
  final ScrollController scroller = ScrollController();
  final List list = [];
  int _page = 1;

  MemPackageHistoryListBloc({bool isMemPackage = true}) {
    on<ShowClearSearchEvent>((event, emit) => emit(ShowClearSearchState(event.value)));
    if (isMemPackage) {
      on<LoadMissionsEvent>((event, emit) async {
        emit(const BaseState(isShowLoading: true));
        final data = await ApiClient().getList('membership_packages/membership_packages/histories?keyword=' +
            ctrSearch.text.trim() + '&', page: _page, limit: 20, isOnePage: true);
        _handleLoadList(data);
        emit(LoadMissionsState(null));
      });
    } else {
      on<LoadMissionsEvent>((event, emit) async {
        emit(const BaseState(isShowLoading: true));
        final data = await ApiClient().getList('category_trees?keyword=' + ctrSearch.text.trim() + '&', page: _page, limit: 20, isOnePage: true);
        _handleLoadList(data);
        emit(LoadMissionsState(null));
      });
      on<GetLocationEvent>((event, emit) => emit(GetLocationState(event.address)));
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
  }

  void clear() {
    ctrSearch.text = '';
    add(ShowClearSearchEvent(false));
    loadList();
  }

  void selectItem(int index) {
    bool temp = list[index].containsKey('is_selected');
    if (temp) {
      temp = !(list[index]['is_selected']??false);
      list[index].update('is_selected', (value) => temp, ifAbsent: () => temp);
    } else {
      list[index].putIfAbsent('is_selected', () => true);
    }
    add(GetLocationEvent(index));
  }

  List<ItemModel> select(List root) {
    final List<ItemModel> trees = [];
    String temp;
    for(var item in list) {
      temp = item['name'] ?? '';
      if ((item['is_selected']??false) && !_existsName(root, temp)) trees.add(ItemModel(id: temp, name: temp));
    }
    return trees;
  }

  bool _existsName(List root, String name) {
    for(var item in root) {
      if (item.name == name) return true;
    }
    return false;
  }
}