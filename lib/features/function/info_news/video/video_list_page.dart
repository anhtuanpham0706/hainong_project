import 'dart:async';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/features/comment/ui/comment_page.dart';
import 'package:hainong/features/function/info_news/video/video_ui.dart';
import 'package:hainong/features/main/bloc/main_bloc.dart';
import 'package:hainong/features/post/model/post.dart';
import 'video_bloc.dart';

class VideoListPage extends BasePage {
  VideoListPage({Key? key, String tag = '', int idDetail = -1}):super(key: key, pageState: _VideoListPageState(tag, idDetail));
}

class _VideoListPageState extends BasePageState {
  late VideoBloc _bloc;
  _VideoListPageState(String tag, int idDetail) {
    _bloc = VideoBloc(tag, idDetail);
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _bloc.stream.listen((state) {
      if (state is AddFavoriteState) {
        isResponseNotError(state.response);
      } else if (state is RemoveFavoriteState) {
        isResponseNotError(state.response, passString: true);
      } else if (state is CreatePostState && isResponseNotError(state.response)) {
        UtilUI.showCustomDialog(context, state.response.data, title: 'Thông báo');
      }
    });
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) =>
    Scaffold(body: Stack(children: [
      BlocBuilder(bloc: _bloc,
        buildWhen: (oldS, newS) => newS is LoadListState || newS is AutoSwitchState,
        builder: (context, state) => _bloc.list.isEmpty ? const SizedBox() : PageView.custom(
          onPageChanged: _bloc.onPageChanged, physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.vertical, controller: _bloc.scaleController, padEnds: false,
          //scrollBehavior: const ScrollBehavior().copyWith(scrollbars: false,
          //  overscroll: false, physics: const AlwaysScrollableScrollPhysics(),
          //  dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
          //  platform: Platform.isIOS ? TargetPlatform.iOS : TargetPlatform.android),
          //itemCount: _bloc.list.length,
          //itemBuilder: (context, index) => Item(_bloc.list[index], index, _bloc) //AnimatedPage(child: _bloc.list[index],
          //  index: index, controller: _bloc.scaleController, effect: const ScaleEffect()),
          childrenDelegate: SliverChildBuilderDelegate((context, index) => Item(_bloc.list[index], index, _bloc),
              childCount: _bloc.list.length, addRepaintBoundaries: false, addSemanticIndexes: false)
        )),
      Container(child: BlocBuilder(bloc: _bloc,
        buildWhen: (oldDtl, newDtl) => newDtl is LoadTechProDtlState || newDtl is ChangeStatusManageState,
        builder: (context, state) => _bloc.list.isEmpty || _bloc.isComment != null ? const SizedBox() : Column(children: [
          Padding(padding: EdgeInsets.symmetric(vertical: 80.sp), child:
            Button('assets/images/ic_love_${_bloc.list[_bloc.index]['is_favourite']??false ? 'fill' : 'outline'}.png',
                _bloc.like, _bloc.list[_bloc.index]['total_favourites'], 'Yêu thích',
                color: (_bloc.list[_bloc.index]['is_favourite']??false) ? Colors.red : Colors.white)),
          Button('assets/images/ic_comment.png', _comment2, _bloc.list[_bloc.index]['total_comment'], 'Bình luận'),
          Padding(padding: EdgeInsets.symmetric(vertical: 80.sp), child:
            Button('', (){}, _bloc.list[_bloc.index]['viewed'] * 7, 'Lượt xem', icon: Icons.remove_red_eye)),
          Button('assets/images/ic_share.png', _share, 0, 'Chia sẻ'),
        ], mainAxisSize: MainAxisSize.min)), alignment: Alignment.bottomRight,
        margin: EdgeInsets.fromLTRB(0, 100, 40.sp, 0.2.sh)),
      BlocBuilder(bloc: _bloc, buildWhen: (oldS, newS) => newS is ChangeStatusManageState,
        builder: (context, state) => _bloc.isComment != null ? const SizedBox() :
          SizedBox(height: 0.2.sh, child: Scaffold(backgroundColor: Colors.transparent,
            appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent, title: _title(), centerTitle: true))))
    ]), backgroundColor: Colors.black);

  Widget _title() {
    if (_bloc.idDetail > 0) return const SizedBox();
    if (_bloc.tag.isNotEmpty) return LabelCustom('#' + _bloc.tag, weight: FontWeight.w400, size: 40.sp);
    return BlocBuilder(bloc: _bloc, buildWhen: (oldS, newS) => newS is AutoSwitchState,
        builder: (context, state) => Row(children: [
          _tab('Mới nhất', 'normal'),
          const SizedBox(),
          _tab('Nổi bật', 'outstanding'),
          const SizedBox(),
        ], mainAxisAlignment: MainAxisAlignment.spaceAround));
  }

  Widget _tab(String title, String type) => GestureDetector(onTap: () => _bloc.changeTab(type),
    child: Container(decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: _bloc.tab == type ? Colors.white : Colors.transparent))),
      child: LabelCustom(title, size: 40.sp, weight: FontWeight.w400)
  ));

  void _share() {
    if (_bloc.lock) return;
    _bloc.lock = true;

    if(!constants.isLogin) {
      _shareToApp();
      return;
    }

    final List<ItemModel> options = [
      ItemModel(id: 'share_app', name: 'Chia sẻ qua ứng dụng khác'),
      ItemModel(id: 'share_post', name: 'Chia sẻ lên tường của tôi')
    ];
    UtilUI.showOptionDialog(context, MultiLanguage.get('ttl_option'), options, '').then((value) {
      if (value != null) value.id == 'share_app' ? _shareToApp() : _bloc.shareToPost();
    }).whenComplete(() => Timer(const Duration(milliseconds: 2000), () => _bloc.lock = false));
  }

  void _shareToApp() {
    _bloc.lock = true;
    UtilUI.shareTo(context, '/short_videos/' + _bloc.list[_bloc.index]['id'].toString(), 'Short video -> Option Share Dialog -> Choose "Share"', 'short_videos');
    Timer(const Duration(milliseconds: 2000), () => _bloc.lock = false);
  }

  void _comment() {
    _bloc.play(id: 0);
    showDialog(useSafeArea: true, context: context, builder: (context) => Column(children: [
      SizedBox(height: 0.6.sh, child:
      CommentPage(Post(classable_id: _bloc.list[_bloc.index]['id'].toString(),
          classable_type: _bloc.list[_bloc.index]['classable_type']), hasHeader: true, height: 0.6.sh))
    ], mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.end)).whenComplete(() {
      _bloc.play();
      _bloc.loadDetail();
    });
  }

  void _comment2() {
    _bloc.startComment();
    showDialog(useSafeArea: true, context: context, barrierColor: Colors.transparent,
      builder: (context) => Column(children: [
        SizedBox(height: 0.6.sh, child: CommentPage(Post(classable_id: _bloc.list[_bloc.index]['id'].toString(),
            classable_type: _bloc.list[_bloc.index]['classable_type']), openKeyboard: true, height: 0.6.sh))
      ], mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.end)).whenComplete(_bloc.endComment);
  }
}