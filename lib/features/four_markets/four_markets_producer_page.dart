import 'package:hainong/common/ui/image_network_asset.dart';
import '../main/ui/header_main.dart';
import '../product/ui/import_ui_product.dart';
import 'four_markets_list_page.dart';

class FourMarketProducerPage extends BasePage {
  FourMarketProducerPage({Key? key}) : super(key: key, pageState: FourMarketProducerPageState());
}

class FourMarketProducerPageState extends BasePageState {
  int _page = 1;
  String _key = '';
  final List _list = [];
  final ScrollController _scroller = ScrollController();
  final ScrollBloc _scrollBloc = ScrollBloc(ScrollState());
  final _ctrSearch = TextEditingController();
  final _focusSearch = FocusNode();

  @override
  void dispose() {
    _scrollBloc.close();
    _scroller.dispose();
    _list.clear();
    _ctrSearch.removeListener(_listenerSearch);
    _ctrSearch.dispose();
    _focusSearch.dispose();
    super.dispose();
  }

  @override
  void initState() {
    bloc = ProductListBloc(ProductListState(), type: 'producer');
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadBAsState) _handleLoadProducers(state);
    });
    _loadProducers();
    _setScroller();
    _ctrSearch.addListener(_listenerSearch);
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) =>
    GestureDetector(onTapDown: (value) => clearFocus(), child: Scaffold(
      appBar: HeaderAppBar(_ctrSearch, _focusSearch, _search, _clearSearch, _scrollBloc, buttonHelper()),
      body: Stack(children: [
        RefreshIndicator(child: BlocBuilder(bloc: bloc,
            buildWhen: (oldBAS, newBAS) => newBAS is LoadBAsState,
            builder: (context, stateBA) => GridView.count(controller: _scroller,
                childAspectRatio: 0.5.sw/0.25.sw, crossAxisCount: 2,
                padding: EdgeInsets.all(40.sp), shrinkWrap: true,
                mainAxisSpacing: 40.sp, crossAxisSpacing: 40.sp,
                children: List.generate(_list.length, (indexBA) =>
                    ButtonImageWidget(0, () => UtilUI.goToNextPage(context,
                        FourMarketListPage(ItemModel(), 'producer_market', bas: _list[indexBA])),
                        Stack(children: [
                          ClipRRect(borderRadius: BorderRadius.circular(10),
                              child: ImageNetworkAsset(path: _list[indexBA].image, width: 0.5.sw, height: 0.25.sw)),
                          if (_list[indexBA].prestige == 1)
                            Image.asset('assets/images/v8/ic_prestige_business.png', width: 80.sp, height: 80.sp)
                        ], alignment: Alignment.topRight))))), onRefresh: () async => search(_key)),
        Loading(bloc)
      ])
    ));

  @override
  void search(String key) {
    clearFocus();
    _initSearch(key);
    _loadProducers();
  }

  void _search() => search(_ctrSearch.text);

  void _clearSearch() {
    _ctrSearch.text = '';
    search('');
  }

  void _listenerSearch() => _scrollBloc.add(HideClearScrollEvent(_ctrSearch.text.isEmpty));

  void _setScroller() => _scroller.addListener(() {
    if (_scroller.position.atEdge && _scroller.position.pixels > 0 && _page > 0) _loadProducers();
  });

  void _initSearch(String keyword) {
    _key = keyword;
    _page = 1;
    _list.clear();
  }

  void _loadProducers() => bloc!.add(LoadBAsEvent(page: _page, keyword: _key));

  void _handleLoadProducers(LoadBAsState state) {
    if (isResponseNotError(state.bas)) {
      final List listTemp = state.bas.data.list;
      if (listTemp.isNotEmpty) {
        _list.addAll(listTemp);
        _page = listTemp.length == 30 ? _page + 1 : 0;
      } else _page = 0;
    }
  }
}
