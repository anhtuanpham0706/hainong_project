import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/tab_item.dart';
import 'package:hainong/features/profile/ui/point_history_page.dart';
import 'point_item.dart';
import '../point_bloc.dart';

class PointListPage extends BasePage {
  PointListPage({Key? key}):super(key: key, pageState: _PointListPageState());
}

class _PointListPageState extends BasePageState {
  int _page = 1;
  String _status = 'pending';
  final List<PointModel> _list = [];
  final ScrollController _scroller = ScrollController();

  @override
  void dispose() {
    _list.clear();
    _scroller.removeListener(_listener);
    _scroller.dispose();
    super.dispose();
  }

  @override
  initState() {
    bloc = PointBloc();
    super.initState();
    bloc!.stream.listen((state) {
      if (state is GetPointListState) _handleResponseLoadPoints(state);
      else if (state is UpdateStatusState && isResponseNotError(state.response, passString: true)) _reload();
    });
    _loadMore();
    _scroller.addListener(_listener);
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Stack(
    children: [
      Scaffold(appBar: AppBar(elevation: 5, centerTitle: true,
          title: UtilUI.createLabel(MultiLanguage.get('lbl_point_list')),
        actions: [
          IconButton(onPressed: _historyPoint, icon: Icon(Icons.history_outlined,size: 60.sp,color: Colors.white,))
        ],
      ),
        backgroundColor: Colors.white,
        body: Column(children: [
          BlocBuilder(bloc: bloc,
            buildWhen: (state1, state2) => state2 is ChangeTabState,
            builder: (context, state) => Row(children: [
              TabItem('lbl_point_pending', 'pending', _status == 'pending', _changeTab),
              TabItem('lbl_point_accepted', 'accepted', _status == 'accepted', _changeTab),
              TabItem('lbl_point_rejected', 'rejected', _status == 'rejected', _changeTab)
            ])),
          Expanded(child: RefreshIndicator(
          onRefresh: _reload,
          child: BlocBuilder(
            bloc: bloc,
            buildWhen: (state1, state2) => state2 is ChangeTabState || state2 is GetPointListState,
            builder: (context, state) => ListView.builder(padding: EdgeInsets.zero,
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scroller, itemCount: _list.length,
                itemBuilder: (context, index) => PointItem(_list[index], _changeStatus, index, _status))
            )
          ))
      ])),
      Loading(bloc)
    ]
  );

  void _historyPoint() {
    UtilUI.goToNextPage(context, HistoryPointPage());
  }

  void _listener() {
    if (_page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) _loadMore();
  }

  void _loadMore() => bloc!.add(GetPointListEvent(_page, _status));

  void _handleResponseLoadPoints(GetPointListState state) {
    if (isResponseNotError(state.response)) {
      final List<PointModel> listTemp = state.response.data.list;
      if (listTemp.isNotEmpty) {
        _list.addAll(listTemp);
        listTemp.length == constants.limitPage?_page++:_page = 0;
      } else _page = 0;
    }
  }

  void _changeTab(String status) {
    if (_status != status) {
      _status = status;
      bloc!.add(ChangeTabEvent());
      _reload();
    }
  }

  Future<void> _reload() async {
    _list.clear();
    _page = 1;
    _loadMore();
  }

  void _changeStatus(int id, String status) => bloc!.add(UpdateStatusEvent(id, status));
}
