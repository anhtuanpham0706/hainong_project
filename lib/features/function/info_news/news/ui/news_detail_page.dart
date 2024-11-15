import 'dart:async';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/database_helper.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/features/comment/ui/comment_page.dart';
import 'package:hainong/features/post/model/post.dart';
import 'package:hainong/features/profile/ui/show_avatar_page.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:just_audio/just_audio.dart';
import 'package:npk_core/service/util.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webviewx/webviewx.dart';
import '../news_bloc.dart';
import '../news_model.dart';
import 'news_list_page.dart';

class NewsDetailPage extends BasePage {
  final NewsModel item;
  final bool isVideo, isNext;
  final Function? funPlayNext;
  final int index, hasReplace;
  NewsDetailPage(this.item, this.index, {this.funPlayNext, Key? key, this.isVideo = false,
    this.isNext = true, this.hasReplace = 0}) : super(key: key, pageState: _NewsDetailPageState());
}

class _NewsDetailPageState extends BasePageState {
  final ScrollController _mainScroller = ScrollController(), _scroller = ScrollController();
  final List<NewsModel> _list = [];
  int _page = 1;
  AudioPlayer? _player;
  bool _isPlay = false, _isFinished = false, _checkPostAuto = false, _isScroll = false;
  WebViewXController? _controller;
  String _func = 'Articles';

  @override
  void dispose() async {
    try {
      if (_player != null) {
        if (_player!.playing) await _player!.stop();
        await _player!.dispose();
      }
      _controller?.dispose();
    } catch (_) {}
    _list.clear();
    //_scroller.removeListener(_listenerScroll);
    _scroller.dispose();
    _mainScroller.removeListener(_listenerMainScroll);
    _mainScroller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    bloc = NewsBloc(isNews: true, id: (widget as NewsDetailPage).item.id);
    bloc!.add(CheckProcessPostAutoInNewsEvent());
    super.initState();
    if ((widget as NewsDetailPage).isVideo) {
      _func = 'Videos';
      NewsListPage.autoPLayNews = false;
    }
    _initPlayController();
    bloc!.stream.listen((state) {
      if (state is LoadListWithCatState && isResponseNotError(state.response, showError: false)) {
        _handleLoadList(state.response.data);
      } else if (state is AddFavoriteState) {
        _handleResponseAddFavorite(state);
      } else if (state is RemoveFavoriteState) {
        _handleResponseRemoveFavorite(state);
      } else if (state is CreatePostState && isResponseNotError(state.response)){
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(MultiLanguage.get('msg_'+(_checkPostAuto?'':'in')+'active_process_post_auto'))));
      }
      else if(state is CheckProcessPostAutoInNewsState){
        _checkPostAuto = state.isActive ?? false;
      }
    });
    //_loadMore();
    //_scroller.addListener(_listenerScroll);
    DBHelperUtil().isSwipeLeft().then((value) {
      if (value) Timer(const Duration(seconds: 1), () => _showGuidSwipeLeft());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final page = widget as NewsDetailPage;
    if ((page.index > 1 || page.isNext) && page.funPlayNext != null) {
      _mainScroller.addListener(_listenerMainScroll);
      /*Timer(const Duration(milliseconds: 1500), () {
        _mainScroller.jumpTo(0.5);
        Timer(const Duration(milliseconds: 1000), () {
          _mainScroller.addListener(_listenerMainScroll);
        });
      });*/
    }
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    final page = widget as NewsDetailPage;
    return Scaffold(appBar: AppBar(elevation: 5, titleSpacing: 0,
        title: UtilUI.createLabel('Chi tiết bài viết', textAlign: TextAlign.center), actions: [
          IconButton(onPressed: _showMenu, icon: Image.asset('assets/images/ic_share.png',
              width: 48.sp, height: 48.sp, color: Colors.white))
        ], centerTitle: true
    ),
      backgroundColor: Colors.white,
      body: GestureDetector(child: ListView(//controller: _mainScroller,
        padding: EdgeInsets.symmetric(vertical: page.index > -1 ? 1 : 0), children: [
          Padding(padding: EdgeInsets.all(20.sp), child: Text(page.item.title, style: TextStyle(fontSize: 76.sp, color: Colors.black, fontWeight: FontWeight.w500))),
          Padding(padding: EdgeInsets.only(left:20.sp), child: Row(children: [
            Icon(Icons.calendar_today, color: StyleCustom.textColor6C, size: 32.sp),
            SizedBox(width: 10.sp),
            Text(Util.dateToString(Util.stringToDateTime(page.item.created_at),
                locale: constants.localeVI, pattern: 'dd/MM/yyyy'),
                style: TextStyle(color: StyleCustom.textColor6C, fontSize: 42.sp)),
            SizedBox(width: 10.sp),
            page.index > 1 && page.funPlayNext != null ? ButtonImageWidget(32.sp,
              () => _playPreNext(pre: false), Icon(Icons.skip_previous, size: 92.sp, color: Colors.red)) :
              Icon(Icons.skip_previous, size: 92.sp, color: Colors.grey),
            Padding(padding: EdgeInsets.symmetric(horizontal: 20.sp), child:
              _hasAudio() && !page.isVideo ? BlocBuilder(bloc: bloc,
                buildWhen: (oldState, newState) => newState is PlayAudioState,
                builder: (context, state) {
                  bool play = false;
                  if (state is PlayAudioState) play = state.value;
                  return ButtonImageWidget(32.sp, _playPauseAudio,
                      Icon(play ? Icons.pause_circle_filled : Icons.play_circle_fill,
                          color: Colors.red, size: 92.sp));
                }) : Icon(Icons.play_circle_fill, color: Colors.grey, size: page.isVideo ? 0 : 92.sp)),
            page.funPlayNext != null && page.isNext ? ButtonImageWidget(32.sp,
              _playPreNext, Icon(Icons.skip_next, size: 92.sp, color: Colors.red)) :
              Icon(Icons.skip_next, size: 92.sp, color: Colors.grey),
            BlocBuilder(
                bloc: bloc,
                buildWhen: (state1, state2) =>
                state2 is AddFavoriteState || state2 is RemoveFavoriteState  || state2 is LoadListWithCatState,
                builder: (context, state) => constants.isLogin ? GestureDetector(
                  onTap: () async {
                    if (await UtilUI().alertVerifyPhone(context)) return;
                    if(page.item.is_favourite){
                      bloc!.add(RemoveFavoriteEvent(page.item.favourite_id));
                    } else {
                      bloc!.add(AddFavoriteEvent(page.item.id,page.item.classable_type));
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: 50.sp,right: 15.sp),
                    child: Image.asset(
                        page.item.is_favourite
                            ? 'assets/images/ic_love_fill.png'
                            : 'assets/images/ic_love_outline.png',
                        height: 60.sp,
                        width: 60.sp),
                  ),
                ) : const SizedBox()),

            if (_hasAudio() && !page.isVideo && NewsListPage.autoPLayNews != null) Expanded(child: Column(children: [
              BlocBuilder(bloc: bloc, buildWhen: (state1, state2) => state2 is AutoSwitchState,
                  builder: (context, state) => Switch(value: NewsListPage.autoPLayNews??false, onChanged: (value) {
                    if (NewsListPage.autoPLayNews == value) return;
                    NewsListPage.autoPLayNews = value;
                    bloc!.add(AutoSwitchEvent(value));
                  }, )),
              Padding(padding: EdgeInsets.only(right: 20.sp), child: Text('Tự chuyển bài', style: TextStyle(color: StyleCustom.textColor6C, fontSize: 30.sp))),
            ], crossAxisAlignment: CrossAxisAlignment.end))
          ])),
          if (page.item.content.isNotEmpty) BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is SetHeightState,
              builder: (context, state) {
                double height = 10, hasHeight = 0;
                if (state is SetHeightState) {
                  height = state.height;
                  hasHeight = 1;
                }
                return SizedBox(child:WebViewX(jsContent: {EmbeddedJsContent(js: constants.jvWebView, mobileJs: constants.jvWebView)},
                    initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.alwaysAllow,
                    initialContent: page.item.content, initialSourceType: SourceType.html,
                    height: height, width: 1.sw, onWebViewCreated: (controller) => _controller = controller,
                    webSpecificParams: const WebSpecificParams(webAllowFullscreenContent: false),
                    mobileSpecificParams: const MobileSpecificParams(androidEnableHybridComposition: true),
                    navigationDelegate: (navigation) async {
                      if (!_isFinished) return NavigationDecision.navigate;
                      String http = navigation.content.source;
                      if (!http.contains('http')) http = 'https://$http';
                      Util.isImage(http) ? UtilUI.goToNextPage(context, ShowAvatarPage(http)) : launchUrl(Uri.parse(http), mode: LaunchMode.externalApplication);
                      return NavigationDecision.prevent;
                    },
                    onPageFinished: (value) async {
                      _isFinished = true;
                      if (hasHeight == 0) {
                          await _controller?.scrollBy(0, 10);
                          String heightStr = await _controller?.evalRawJavascript("document.documentElement.scrollHeight") ?? "0";
                          bloc!.add(SetHeightEvent(double.parse(heightStr)));
                      }
                    }), width: 1.sw, height: height);
              }),
          Padding(padding: EdgeInsets.all(20.sp),
              child: Text(MultiLanguage.get('comment'), style: TextStyle(fontSize: 48.sp, color: Colors.black, fontWeight: FontWeight.w500))),
          BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is SetHeightState ,
            builder: (context, state) => state is SetHeightState || _isFinished ?
              CommentPage(Post(classable_id: page.item.id.toString(), classable_type: page.item.classable_type2),
                  hasHeader: false, hideSnackBar: _closeSnackBar) : const SizedBox()),
          /*Padding(padding: EdgeInsets.symmetric(horizontal: 20.sp),
              child: Text(MultiLanguage.get( (widget as NewsDetailPage).isVideo ?'ttl_similar_video':'lbl_similar_news'), style: TextStyle(fontSize: 48.sp, color: Colors.black, fontWeight: FontWeight.w500))),
          SizedBox(height: 360.sp, child: BlocBuilder(bloc: bloc,
              buildWhen: (oldState, newState) => newState is LoadListWithCatState,
              builder: (context, state) => ListView.builder(padding: EdgeInsets.all(20.sp),
                  itemCount: _list.length, controller: _scroller, scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => NewsItemHorizontal(_list[index], page.isVideo, page.hasReplace))))*/
      ]), onHorizontalDragEnd: (details) {
        final dx = details.velocity.pixelsPerSecond.dx;
        final page = widget as NewsDetailPage;
        if (dx.abs() > 10 //&& _mainScroller.position.maxScrollExtent <= 1.sw
            && ((page.index > 1 && dx > 0) || (page.isNext && dx < 0))
            && page.funPlayNext != null) _playPreNext(pre: dx < 0, showConfirm: true);
      }));
  }

  bool _hasAudio() => (widget as NewsDetailPage).item.audio_link.isNotEmpty;

  void _initPlayController() {
    if (!_hasAudio() || (widget as NewsDetailPage).isVideo) return;
    _player = AudioPlayer();
    _player!.setUrl((widget as NewsDetailPage).item.audio_link).whenComplete(() {
      if (NewsListPage.autoPLayNews!) _playPauseAudio();
      _player!.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          if (_isPlay && NewsListPage.autoPLayNews!) _playNext();
          _player!.seek(const Duration(seconds: 0)).whenComplete(() => _player!.pause().whenComplete(() => _isPlay = false));
          bloc!.add(PlayAudioEvent(false));
        }
      });
    });
  }

  void _closeSnackBar() => _isScroll ? ScaffoldMessenger.of(context).removeCurrentSnackBar() : '';

  void _playPreNext({bool pre = true, bool showConfirm = false}) {
    /*if (_isScroll) {
      _closeSnackBar();
      return;
    }
    _isScroll = true;
    if (showConfirm) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bạn có muốn xem tin ${pre ? 'kế' : 'trước'} không?'),
          behavior: SnackBarBehavior.floating, elevation: 0, margin: EdgeInsets.fromLTRB(10, 10, 10,
              pre ? 10 : 1.sh - WidgetsBinding.instance.window.padding.top - kToolbarHeight - 10),
          action: SnackBarAction(label: 'Xem', onPressed: () {
            _isScroll = false;
            _playPreNext(pre: pre);
          }),
          duration: const Duration(seconds: 5), dismissDirection: DismissDirection.none))
          .closed.whenComplete(() {
            final pos = _mainScroller.position.pixels;
            if ((pos == 0 || pos == _mainScroller.position.maxScrollExtent) &&
                _mainScroller.position.maxScrollExtent > 1.sw) _mainScroller.jumpTo(pre ? pos - 0.5 : 0.5);
            _isScroll = false;
          });
      return;
    }*/

    if (_player == null) {
      _playNext(pre: pre);
      return;
    }
    _player!.pause().whenComplete(() {
      _isPlay = false;
      bloc!.add(PlayAudioEvent(false));
      _playNext(pre: pre);
    });
  }

  void _playNext({bool pre = true}) {
    final page = widget as NewsDetailPage;
    final next = page.funPlayNext;
    if (next != null) next(page.index, isPre: pre);
    _isScroll = false;
  }

  void _playPauseAudio({bool changeAudio = true}) {
    _isPlay = !_isPlay;
    bloc!.add(PlayAudioEvent(_isPlay));
    if (changeAudio) _isPlay ? _player?.play() : _player?.pause();
  }

  void _listenerScroll() {
    if (_page > 0 && _scroller.position.pixels == _scroller.position.maxScrollExtent) _loadMore();
  }

  void _listenerMainScroll() {
    if ((_mainScroller.position.pixels == _mainScroller.position.maxScrollExtent || _mainScroller.position.pixels == 0)
        && (widget as NewsDetailPage).funPlayNext != null) _playPreNext(pre: _mainScroller.position.pixels > 0, showConfirm: true);
  }

  void _loadMore() => bloc!.add(LoadListWithCatEvent(_page, (widget as NewsDetailPage).item.id, (widget as NewsDetailPage).isVideo));

  void _handleLoadList(NewsModels data) {
    if (data.list.isNotEmpty) {
      _list.addAll(data.list);
      data.list.length == constants.limitPage ? _page++ : _page = 0;
    } else _page = 0;
  }

  void _shareToApp() {
    final page = widget as NewsDetailPage;
    UtilUI.shareTo(context, '/${page.isVideo?'videos':'tin-tuc'}/${page.item.id}', 'News Detail -> Option Share Dialog -> Choose "Share"', _func.toLowerCase());
  }

  void _showMenu() async {
    if (await UtilUI().alertVerifyPhone(context)) return;
    final List<ItemModel> options = [
      ItemModel(id: 'share_app', name: 'Chia sẻ qua ứng dụng khác'),
     if(constants.isLogin) ItemModel(id: 'share_post', name: 'Chia sẻ lên tường của tôi')
    ];
    UtilUI.showOptionDialog(context, MultiLanguage.get('ttl_option'), options, '').then((value) async {
      if (value != null) {
        value.id == 'share_app' ? _shareToApp() : _shareToPost();
      }
    });
    Util.trackActivities(_func.toLowerCase(), path: _func + ' Detail -> Share Menu -> Open Option Dialog');
  }

  void _shareToPost() {
    final page = widget as NewsDetailPage;
    bloc!.add(CreatePostEvent('${Constants().domain}/${page.isVideo?'videos':'tin-tuc'}/${page.item.id}'));
    Util.trackActivities(_func.toLowerCase(), path: _func + ' Detail -> Tap Button Share To Social Screen');
  }

  bool _handleResponse(response, {bool passString = false}) {
    final BaseResponse tmp = response as BaseResponse;
    if (tmp.checkTimeout()) UtilUI.showDialogTimeout(context);
    else if (tmp.checkOK(passString: passString)) return true;
    else UtilUI.showCustomDialog(context, tmp.data).then((value) => print(value));
    return false;
  }

  void _handleResponseAddFavorite(AddFavoriteState state) {
    if (_handleResponse(state.response)) {
      (widget as NewsDetailPage).item.is_favourite = true;
      (widget as NewsDetailPage).item.favourite_id = state.response.data.id;
    }
  }

  void _handleResponseRemoveFavorite(RemoveFavoriteState state) {
    if (_handleResponse(state.response, passString: true)) (widget as NewsDetailPage).item.is_favourite = false;
  }

  void _showGuidSwipeLeft() => showDialog(useSafeArea: false, context: context, builder: (context) =>
    Dialog(child: GestureDetector(child: Container(color: Colors.black54, alignment: Alignment.centerRight, child: Column(
        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
      Image.asset('assets/images/v7/ic_swipe_left.png', width: 200.sp),
      const SizedBox(height: 10),
      LabelCustom('Vuốt trái\nđể xem thêm', weight: FontWeight.w400, size: 48.sp, align: TextAlign.center)
    ])), onTap: () => UtilUI.goBack(context, null)), insetPadding: EdgeInsets.zero, backgroundColor: Colors.transparent, elevation: 0), barrierColor: Colors.transparent);
}