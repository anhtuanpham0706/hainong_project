import 'package:hainong/common/ui/ads.dart';
import 'package:hainong/common/ui/banner_2nong.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/divider_widget.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/tab_item.dart';
import 'package:hainong/common/ui/title_helper.dart';
import 'package:hainong/features/function/info_news/video/video_list_page.dart';
import '../news_bloc.dart';
import '../news_model.dart';
import 'news_detail_page.dart';
import 'news_item.dart';

class NewsListPage extends BasePage {
  static bool? autoPLayNews;
  final bool isVideo;
  NewsListPage({Key? key, this.isVideo = false}):super(key: key, pageState: _NewsListPageState());
}

class _NewsListPageState extends BasePageState {
  final ScrollController _scroller = ScrollController();
  final List<NewsModel> _list = [NewsModel()];
  int _page = 1;
  bool isVideo = false;

  @override
  void dispose() {
    if (Constants().isLogin) Constants().indexPage = null;
    _list.clear();
    _scroller.removeListener(_listenerScroll);
    _scroller.dispose();
    Util.clearPermission();
    NewsListPage.autoPLayNews = null;
    super.dispose();
  }

  @override
  void initState() {
    NewsListPage.autoPLayNews = false;
    Util.getPermission();
    isVideo = (widget as NewsListPage).isVideo;
    bloc = NewsBloc();
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadListState && isResponseNotError(state.response)) _handleLoadList(state.response.data);
    });
    _loadMore();
    _scroller.addListener(_listenerScroll);
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Stack(children: [
    Scaffold(appBar: AppBar(elevation: 5, titleSpacing: 0,
      title: const Padding(padding: EdgeInsets.only(right: 48), child: TitleHelper('lbl_news', url: 'https://help.hainong.vn/muc/9'))),
      body: Stack(children: [
        BlocBuilder(bloc: bloc, buildWhen: (state1, state2) => state2 is LoadListState,
            builder: (context, state) => Column(children: [
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                TabItem('Tin tức', 0, true, (){}, parseTitle: false),
                TabItem('Video ngắn', 1, false, (index) => UtilUI.goToNextPage(context, VideoListPage()), parseTitle: false)
              ]),
              Expanded(child: ListView.builder(controller: _scroller, itemCount: _list.length,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _list.length > 1 ? Column(children: [
                        ButtonImageWidget(0, _goToDetail, Container(padding: EdgeInsets.all(40.sp),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              ClipRRect(child: FadeInImage.assetNetwork(image: Util.getRealPath(_list[1].image),
                                  imageErrorBuilder: (_, __, ___) => Image.asset('assets/images/ic_default.png', width: 1.sw, height: 0.2.sh, fit: BoxFit.cover),
                                  placeholder: 'assets/images/ic_default.png', width: 1.sw, height: 0.2.sh, fit: BoxFit.cover),
                                  borderRadius: BorderRadius.circular(20.sp)),
                              Padding(padding: EdgeInsets.only(top: 20.sp, bottom: 10.sp), child: Text(_list[1].title, maxLines: 2,
                                  overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 52.sp, color: Colors.black, fontWeight: FontWeight.bold))),
                              Row(children: [
                                Icon(Icons.calendar_today, color: StyleCustom.textColor6C, size: 24.sp),
                                SizedBox(width: 10.sp),
                                Text(Util.dateToString(Util.stringToDateTime(_list[1].created_at), locale: constants.localeVI, pattern: 'dd/MM/yyyy'),
                                    style: TextStyle(color: StyleCustom.textColor6C, fontSize: 30.sp))
                              ])
                            ]))),
                        DividerWidget(height: 1, margin: EdgeInsets.only(bottom: 2.sp))
                      ]) : const SizedBox();
                    }
                    if (index == 1) return const Ads('article');
                    return NewsItem(_list[index], index, _playNext, isVideo: isVideo, reload: (){});
                  }))
            ])),
        Banner2Nong('article')
      ], alignment: Alignment.bottomRight)
    ),
    Loading(bloc)
  ]);

  void _listenerScroll() {
    if (_page > 0 && _scroller.position.pixels == _scroller.position.maxScrollExtent) _loadMore();
  }

  void _loadMore() {
    if (_page > 0) bloc!.add(LoadListEvent(_page, (widget as NewsListPage).isVideo));
  }

  void _handleLoadList(NewsModels data) {
    if (data.list.isNotEmpty) {
      _list.addAll(data.list);
      data.list.length == constants.limitPage*2 ? _page++ : _page = 0;
    } else _page = 0;
  }

  void _goToDetail() {
    if (_list.length > 1) {
      UtilUI.goToNextPage(context, NewsDetailPage(_list[1], 1, funPlayNext: _playNext, isVideo: isVideo));
      String temp = isVideo ? 'Videos' : 'Articles';
      Util.trackActivities(temp.toLowerCase(), path: 'List $temp Screen -> Show $temp Detail');
    }
  }

  void _playNext(int index, {bool isPre = true}) {
      isPre ? index++ : index--;
      if (index < 1) return;
      if (index == _list.length) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) =>
          NewsDetailPage(_list[index], index, funPlayNext: _playNext, isVideo: isVideo, isNext: index < _list.length - 1),
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(child: child, position: animation.drive(Tween(begin: Offset(isPre ? 1 : -1, 0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeInOut))))
      ));
      if (index == _list.length - 5) _loadMore();
  }
}