import 'dart:async';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/models/item_list_model.dart';
import '../news/news_bloc.dart';
export '../news/news_bloc.dart';

class VideoBloc extends BaseBloc {
  final PageController scaleController = PageController();
  final List<dynamic> list = [];
  final String tag;
  int _page = 1, index = 0, idDetail;
  String tab = 'normal';
  bool isVideo = false, lock = false;
  bool? isComment;

  VideoBloc(this.tag, this.idDetail, {BaseState init = const BaseState()}):super(init:init) {
    on<LoadTechProDtlEvent>((event, emit) async {
      dynamic data = await ApiClient().getData('short_video/short_videos/' + event.id);
      if (data != null) {
        list[index]['viewed'] = data['viewed'];
        list[index]['total_favourites'] = data['total_favourites'];
        list[index]['total_comment'] = data['total_comment'];
      }
      emit(LoadTechProDtlState(BaseResponse()));
    });
    on<CreatePostEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final response = await ApiClient().postAPI2(Constants().apiVersion + 'posts',
          body: {"title": event.title, "post_type": 'public', "description": "", "hash_tag": "[]"});
      final data = await ApiClient().getDataFromString(response, getError: true);
      if (data.containsKey('error')) emit(CreatePostState(BaseResponse(data: data['error'])));
      else emit(CreatePostState(BaseResponse(success: true, data: data.containsKey('message') ? data['message'] : 'Đã chia sẻ thành công')));
      lock = false;
    });
    on<LoadListEvent>((event, emit) async {
      dynamic resp;
      if (idDetail > 0) {
        resp = [];
        final data = await ApiClient().getData('short_video/short_videos/$idDetail');
        if (data != null) resp.add(data);
      } else {
        String params = 'is_feature=$tab&';
        params += event.tag.isEmpty ? '' : 'hash_tag=${event.tag}&';
        resp = await ApiClient().getList('short_video/short_videos?' + params, page: _page, limit: 20, isOnePage: true);
      }
      _handleLoadList(resp);
      emit(LoadListState(BaseResponse()));
    });
    on<AddFavoriteEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final response = await ApiClient().postAPI(Constants().apiVersion + 'account/create_favourite', 'POST', ItemModel(),
          body: {
            "classable_type": event.classableType,
            "classable_id": event.classableId.toString()
          });
      if (response.checkOK()) {
        list[index]['is_favourite'] = true;
        list[index]['favourite_id'] = response.data.id;
        list[index]['total_favourites'] += 1;
      }
      loadDetail();
      emit(AddFavoriteState(response));
      lock = false;
    });
    on<RemoveFavoriteEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final response = await ApiClient().postAPI(Constants().apiVersion+'account/favourite/'+event.favoriteId, 'DELETE', BaseResponse());
      if (response.checkOK(passString: true)) {
        list[index]['is_favourite'] = false;
        list[index]['total_favourites'] -= 1;
      }
      loadDetail();
      emit(RemoveFavoriteState(response));
      lock = false;
    });
    on<AutoSwitchEvent>((event, emit) => emit(AutoSwitchState(event.value)));
    on<SetHeightEvent>((event, emit) => emit(SetHeightState(event.height, ext: event.ext)));
    on<ChangeStatusManageEvent>((event, emit) => emit(ChangeStatusManageState()));
    loadMore();
  }

  @override
  Future<void> close() async {
    scaleController.dispose();
    list.clear();
    super.close();
  }

  void changeTab(String value) {
    if (tab != value) {
      tab = value;
      add(AutoSwitchEvent(true));
      _reset();
    }
  }

  void loadMore() => add(LoadListEvent(_page, true, tag: tag));

  void _handleLoadList(dynamic data) {
    if (data.isNotEmpty) {
      list.addAll(data);
      data.length == 20 ? _page++ : _page = 0;

      if (list.isNotEmpty && list.length < 21) {
        Timer(const Duration(milliseconds: 1000), () => play());
        loadDetail();
      }
    } else _page = 0;
  }

  void onPageChanged(int newIndex) {
    if (index == newIndex) return;
    play(id: 0, reset: true);
    index = newIndex;
    Timer(const Duration(milliseconds: 500), () => play());
    loadDetail();
    if (index == list.length - 10 && _page > 0) loadMore();
  }

  void like() {
    if (lock) return;
    lock = true;
    if (list[index]['is_favourite']) {
      add(RemoveFavoriteEvent(list[index]['favourite_id'].toString()));
    } else {
      add(AddFavoriteEvent(list[index]['id'], list[index]['classable_type']));
    }
  }

  void shareToPost() => add(CreatePostEvent(Constants().domain + '/short_videos/' + list[index]['id'].toString()));

  void _reset() {
    play(id: 0, reset: true);
    index = 0;
    _page = 1;
    list.clear();
    loadMore();
  }

  void loadDetail() => add(LoadTechProDtlEvent(list[index]['id'].toString()));

  void playNext() {
    if (index + 1 < list.length) scaleController.jumpToPage(index + 1);
  }

  void play({int? id, bool reset = false, int? newIndex}) => add(SetHeightEvent((id??list[newIndex??index]['id']).toDouble(),
    ext: {'index': newIndex??index, 'reset': reset}));

  void startComment() {
    isComment = true;
    add(ChangeStatusManageEvent());
  }

  void endComment() {
    isComment = null;
    add(ChangeStatusManageEvent());
    loadDetail();
  }
}