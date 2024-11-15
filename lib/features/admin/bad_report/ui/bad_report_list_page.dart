import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/features/comment/ui/comment_detail_page.dart';
import 'package:hainong/features/notification/notification_bloc.dart';
import 'package:hainong/features/post/bloc/post_list_bloc.dart';
import 'package:hainong/features/post/ui/post_detail_page.dart';
import 'package:hainong/features/home/bloc/home_bloc.dart';
import '../bad_report_list_bloc.dart';
import '../bad_report_model.dart';
import 'bad_report_item.dart';

class BadReportListPage extends BasePage {
  final String title;
  final int index;
  BadReportListPage(this.title, this.index, {Key? key}):super(key: key, pageState: _BadReportListPageState());
}

class _BadReportListPageState extends BasePageState {
  int _page = 1, _index = -1, _lock = 0;
  final List<BadReportModel> _list = [];
  final ScrollController _scroller = ScrollController();

  @override
  void dispose() {
    _list.clear();
    _scroller.dispose();
    Util.clearPermission();
    super.dispose();
  }

  @override
  initState() {
    bloc = BadReportBloc(PostListState());
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadFollowersPostListState) _handleResponseLoadFollowers(state);
      else if (state is LoadCommentState) UtilUI.goToNextPage(context, CommentDetailPage(state.response.data, reloadParent: () => _reload()));
      else if (state is LoadPostState) {
        SharedPreferences.getInstance().then((prefs) {
          UtilUI.goToNextPage(context, PostDetailPage(state.response.data, 0,
              HomeBloc(HomeState()), prefs.getInt(constants.shopId).toString(), null));
        });
      } else if (state is DeleteBadReportState && isResponseNotError(state.resp, passString: true)) {
        _list[state.index].id = -1;
      }
      _lock = 0;
    });
    //Util.getPermission().then((value) {
    //  _changeTab(Constants().permission != 'admin' ? 1 : 0);
    //});
    _changeTab((widget as BadReportListPage).index);
    _scroller.addListener(() {
      if (_page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) _loadMore();
    });
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Stack(
    children: [
      Scaffold(appBar: AppBar(title: UtilUI.createLabel((widget as BadReportListPage).title), centerTitle: true),
        body: /*Column(children: [
          Container(color: Colors.white, child: BlocBuilder(bloc: bloc,
              buildWhen: (state1, state2) => state2 is ChangeTabState,
              builder: (context, state) => state is ChangeTabState ?
              SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
                if (Constants().permission!.contains('admin')) TabItem('Bài viết', 0, _index == 0, _changeTab, parseTitle: false, expanded: false),
                TabItem('Bình luận\nbài viết', 1, _index == 1, _changeTab, parseTitle: false, expanded: false),
                TabItem('Bình luận\nsản phẩm', 2, _index == 2, _changeTab, parseTitle: false, expanded: false),
                TabItem('Bình luận\ntin nông nghiệp', 3, _index == 3, _changeTab, parseTitle: false, expanded: false),
                TabItem('Bình luận\ntin video', 4, _index == 4, _changeTab, parseTitle: false, expanded: false)
              ])):const SizedBox())),
          Expanded(child: RefreshIndicator(onRefresh: _reload, child: BlocBuilder(bloc: bloc,
              buildWhen: (state1, state2) => state2 is ChangeTabState || state2 is LoadFollowersPostListState ||
                  (state2 is DeleteBadReportState && isResponseNotError(state2.resp, passString: true, showError: false)),
              builder: (context, state) => _list.isNotEmpty ? ListView.separated(
                  padding: EdgeInsets.zero, controller: _scroller, itemCount: _list.length,
                  itemBuilder: (context, index) => BadReportItem(_list[index], _loadComment, () => _delete(index)),
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  physics: const AlwaysScrollableScrollPhysics()) :
              SizedBox(height: 1.sh, child: ListView(children: const []))
          )))
        ])*/
        RefreshIndicator(onRefresh: _reload, child: BlocBuilder(bloc: bloc,
            buildWhen: (state1, state2) => state2 is ChangeTabState || state2 is LoadFollowersPostListState ||
                (state2 is DeleteBadReportState && isResponseNotError(state2.resp, passString: true, showError: false)),
            builder: (context, state) => _list.isNotEmpty ? ListView.separated(
                padding: EdgeInsets.zero, controller: _scroller, itemCount: _list.length,
                itemBuilder: (context, index) => BadReportItem(_list[index], _loadComment, () => _delete(index)),
                separatorBuilder: (context, index) => const Divider(height: 1),
                physics: const AlwaysScrollableScrollPhysics()) :
            SizedBox(height: 1.sh, child: ListView(children: const []))
        ))
      ),
      Loading(bloc)
    ]
  );

  void _loadMore() => bloc!.add(LoadFollowersPostListEvent(_page, _index));

  _handleResponseLoadFollowers(LoadFollowersPostListState state) {
    if (isResponseNotError(state.response)) {
      final listTemp = state.response.data.list;
      if (listTemp.isNotEmpty) {
        _list.addAll(listTemp);
        listTemp.length == 20 ?_page++ : _page = 0;
      } else _page = 0;
    }
  }

  void _changeTab(int index) {
    if (_index != index) {
      _index = index;
      bloc!.add(ChangeTabEvent(index));
      _reload();

      String type = 'Post';
      switch(index) {
        case 1: type = 'Comment Of Post'; break;
        case 2: type = 'Comment Of Product'; break;
        case 3: type = 'Comment Of Agricultural Article'; break;
        case 4: type = 'Comment Of Video Article'; break;
      }
      Util.trackActivities('', path: 'Manage Bad Report List Screen -> Choose Tab "$type"');
    }
  }

  Future<void> _reload() async {
    setState(() {
      _list.clear();
    });
    _page = 1;
    _loadMore();
  }

  void _loadComment(int id, String type) {
    if (_lock > 0) return;
    _lock ++;
    bloc!.add(type == 'comment' ? LoadCommentEvent(id) : LoadPostEvent(id));
  }

  void _delete(int index) {
    if (_lock > 0) return;
    UtilUI.showCustomDialog(context, 'Bạn có chắc muốn xoá báo vi phạm này không?', isActionCancel: true)
        .then((value) {
      if (value != null && value) {
        _lock ++;
        bloc!.add(DeleteBadReportEvent(_list[index].id, index, _list[index].classable_type));
        Util.trackActivities('', path: 'Manage Bad Report List Screen -> Dialog Confirm Delete -> Choose Button "OK" -> Delete Bad Report With ID = "${_list[index].id}"');
        return;
      }
      Util.trackActivities('', path: 'Manage Bad Report List Screen -> Dialog Confirm Delete -> Choose Button "Cancel"');
    });
    Util.trackActivities('', path: 'Manage Bad Report List Screen -> Show Dialog Confirm Delete');
  }
}
