import 'dart:async';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/tab_item.dart';
import 'package:hainong/features/post/bloc/post_list_bloc.dart';
import '../news_bloc.dart';
import '../news_model.dart';
import 'news_item.dart';

class NewsFavoriteListPage extends BasePage {
  NewsFavoriteListPage({Key? key}):super(key: key, pageState: _NewsFavoriteListPageState());
}

class _NewsFavoriteListPageState extends BasePageState {
  int _page = 1, _index = 0, _lock = 0;
  final List<NewsModel> _list = [];
  final ScrollController _scroller = ScrollController();

  @override
  void dispose() {
    _list.clear();
    _scroller.dispose();
    super.dispose();
  }

  @override
  initState() {
    bloc = NewsBloc();
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadListLikeNewsState) {
        if (isResponseNotError(state.response)) {
          final list = state.response.data.list;
          if (list.isNotEmpty) _list.addAll(list);
          list.length == 20 ? _page++ : _page = 0;
        }
        _lock = 0;
      }
    });
    _loadMore();
    _scroller.addListener(() {
      if (_page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) _loadMore();
    });
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Stack(
      children: [
        Scaffold(appBar: AppBar(title: UtilUI.createLabel('Danh sách tin quan tâm', textAlign: TextAlign.center)),
            body: Column(children: [
              Container(color: Colors.white, child: BlocBuilder(bloc: bloc,
                  buildWhen: (state1, state2) => state2 is ChangeTabState,
                  builder: (context, state) => Row(children: [
                    TabItem('Tin nông nghiệp', 0, _index == 0, _changeTab, parseTitle: false),
                    TabItem('Tin video', 1, _index == 1, _changeTab, parseTitle: false),
                  ]))),
              Expanded(child: RefreshIndicator(onRefresh: _reload, child: BlocBuilder(bloc: bloc,
                  buildWhen: (state1, state2) => state2 is ChangeTabState || state2 is LoadListLikeNewsState,
                  builder: (context, state) => ListView.separated(
                      padding: EdgeInsets.zero, controller: _scroller, itemCount: _list.length,
                      itemBuilder: (context, index) => NewsItem(_list[index], index, _reload, isVideo: _index == 1, isEdit: false, reload: _reload),
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      physics: const AlwaysScrollableScrollPhysics()))))
            ]), backgroundColor: Colors.white
        ),
        Loading(bloc)
      ]
  );

  void _loadMore() => bloc!.add(LoadListLikeNewsEvent(_page, _index));

  void _changeTab(int index) {
    if (_lock == 1) return;
    if (_index != index) {
      _index = index;
      bloc!.add(ChangeTabEvent(index));
      _reload();
    }
    String type = index == 0 ? 'Articles' : 'Video';
    Util.trackActivities(type.toLowerCase(), path: 'Favorite $type List Screen -> Choose Tab "$type"');
  }

  Future<void> _reload() async {
    if (_index == -1 || _lock == 1) return;
    _list.clear();
    _page = 1;
    _lock = 1;
    Timer(const Duration(seconds: 1), () => setState(() {
      _loadMore();
    }));
  }
}
