import 'dart:async';

import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/tab_item.dart';
import 'package:hainong/features/post/bloc/post_list_bloc.dart';
import '../news_bloc.dart';
import '../news_model.dart';
import 'news_item.dart';
import 'news_manage_detail_page.dart';

class NewsManageListPage extends BasePage {
  NewsManageListPage({Key? key}):super(key: key, pageState: _NewsManageListPageState());
}

class _NewsManageListPageState extends BasePageState {
  int _page = 1, _index = -1, _lock = 0;
  final List<NewsModel> _list = [];
  final ScrollController _scroller = ScrollController();

  @override
  void dispose() {
    _list.clear();
    _scroller.dispose();
    Util.clearPermission(hasCTV: true);
    super.dispose();
  }

  @override
  initState() {
    if (Constants().contributeRole!.containsKey('articles')) _index = 0;
    if (Constants().contributeRole!.containsKey('videos') && _index == -1) _index = 1;
    if (_index == -1) UtilUI.goBack(context, false);
    bloc = NewsBloc();
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadListManageState) {
        if (isResponseNotError(state.response)) {
          final list = state.response.data.list;
          if (list.isNotEmpty) _list.addAll(list);
          list.length == 20 ? _page++ : _page = 0;
        } else _page = 0;
        _lock = 0;
      } else if (state is ChangeTabState) _reload();
    });
    _loadMore();
    _scroller.addListener(() {
      if (_page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) _loadMore();
    });
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Stack(
    children: [
      Scaffold(appBar: AppBar(title: UtilUI.createLabel('Danh sách tin', textAlign: TextAlign.center), elevation: 5),
        body: Column(children: [
          /*Container(color: Colors.white, child: BlocBuilder(bloc: bloc,
              buildWhen: (state1, state2) => state2 is ChangeTabState,
              builder: (context, state) => Row(children: [
                if (Constants().contributeRole!.containsKey('articles')) TabItem('Tin nông nghiệp', 0, _index == 0, _changeTab, parseTitle: false),
                if (!Constants().contributeRole!.containsKey('articles')) const Expanded(child: SizedBox()),
                if (Constants().contributeRole!.containsKey('videos')) TabItem('Tin video', 1, _index == 1, _changeTab, parseTitle: false),
                if (!Constants().contributeRole!.containsKey('videos')) const Expanded(child: SizedBox())
              ]))),*/
          Expanded(child: RefreshIndicator(onRefresh: () async => _reload(), child: BlocBuilder(bloc: bloc,
              buildWhen: (state1, state2) => state2 is LoadListManageState,
              builder: (context, state) => ListView.separated(
                  padding: EdgeInsets.zero, controller: _scroller, itemCount: _list.length,
                  itemBuilder: (context, index) => NewsItem(_list[index], index, (){}, isVideo: _index == 1, isEdit: true, reload: _reload),
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  physics: const AlwaysScrollableScrollPhysics()))))
        ], mainAxisSize: MainAxisSize.min), backgroundColor: Colors.white, floatingActionButton:
          FloatingActionButton.small(backgroundColor: StyleCustom.primaryColor,
            onPressed: () => UtilUI.goToNextPage(context,
                NewsManageDetailPage(NewsModel(classable_type: 'article'), -1, _reload)),
            child: Icon(Icons.add, color: Colors.white, size: 48.sp))
      ),
      Loading(bloc)
    ]
  );

  void _loadMore() {
    if (_lock == 1) return;
    bloc!.add(LoadListManageEvent(_page, _index));
    _lock = 1;
  }

  void _changeTab(int index) {
    if (_index != index) {
      _index = index;
      bloc!.add(ChangeTabEvent(index));
      _reload();
    }
    String type = index == 0 ? 'Articles' : 'Video';
    Util.trackActivities(type.toLowerCase(), path: 'Manage $type List Screen -> Choose Tab "$type"');
  }

  void _reload() {
    if (_index == -1 || _lock == 1) return;
    setState(() => _list.clear());
    _page = 1;
    _loadMore();
  }
}
