import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/loading.dart';
import '../ba_bloc.dart';
import '../ba_model.dart';
import 'ba_item.dart';

class BAListPage extends BasePage {
  BAListPage({Key? key}):super(key: key, pageState: _BAListPageState());
}

class _BAListPageState extends BasePageState {
  final ScrollController _scroller = ScrollController();
  final List<BAModel> _list = [];
  int _page = 1;

  @override
  void dispose() {
    _list.clear();
    _scroller.removeListener(_listenerScroll);
    _scroller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    bloc = BABloc('list');
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadListState && isResponseNotError(state.response)) {
        final list = state.response.data.list;
        if (list.isNotEmpty) {
          _list.addAll(list);
          list.length == 20 ? _page++ : _page = 0;
        } else _page = 0;
      }
    });
    _loadMore();
    _scroller.addListener(_listenerScroll);
  }
  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Stack(children: [
    Scaffold(appBar: AppBar(elevation: 5, titleSpacing: 0, title: UtilUI.createLabel(MultiLanguage.get('lbl_link')), centerTitle: true),
      body: BlocBuilder(bloc: bloc, buildWhen: (state1, state2) => state2 is LoadListState,
        builder: (context, state) => ListView.builder(controller: _scroller, itemCount: _list.length,
          itemBuilder: (context, index) => BAItem(_list[index])))
    ),
    Loading(bloc)
  ]);

  void _listenerScroll() {
    if (_page > 0 && _scroller.position.pixels == _scroller.position.maxScrollExtent) _loadMore();
  }

  void _loadMore() => bloc!.add(LoadListEvent(_page));
}