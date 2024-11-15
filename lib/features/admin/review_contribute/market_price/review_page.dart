import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/features/function/info_news/market_price/ui/market_price_create_report_page.dart';
import 'package:hainong/features/function/info_news/technical_process/ui/technical_process_create_contribute_page.dart';
import 'package:hainong/features/function/tool/diagnose_pests/ui/diagnostis_pests_contribute_page.dart';
import 'package:hainong/features/post/bloc/post_list_bloc.dart';
import '../review_bloc.dart';
import 'review_item.dart';

class ReviewPage extends BasePage {
  final String title;
  final int index;
  ReviewPage(this.title, this.index, {Key? key}):super(key: key, pageState: _ReviewPageState());
}

class _ReviewPageState extends BasePageState {
  int _page = 1;
  final List<dynamic> _list = [];
  final ScrollController _scroller = ScrollController();

  @override
  void dispose() {
    _list.clear();
    _scroller.dispose();
    super.dispose();
  }

  @override
  initState() {
    bloc = ReviewBloc();
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadFollowersPostListState && isResponseNotError(state.response)) {
        final listTemp = state.response.data.list;
        if (listTemp.isNotEmpty) {
          _list.addAll(listTemp);
          listTemp.length == 20 ?_page++ : _page = 0;
        } else _page = 0;
      }
    });
    _loadMore();
    _scroller.addListener(() {
      if (_page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) _loadMore();
    });
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Stack(children: [
      Scaffold(appBar: AppBar(title: UtilUI.createLabel((widget as ReviewPage).title), centerTitle: true),
        body: RefreshIndicator(onRefresh: _reload, child: BlocBuilder(bloc: bloc,
            buildWhen: (state1, state2) => state2 is LoadFollowersPostListState,
            builder: (context, state) => _list.isNotEmpty ? ListView.builder(
                padding: EdgeInsets.zero, controller: _scroller, itemCount: _list.length,
                itemBuilder: (context, index) => ReviewItem(_list[index], index, _loadDetail),
                physics: const AlwaysScrollableScrollPhysics()) :
            SizedBox(height: 1.sh, child: ListView(children: const []))
        )), backgroundColor: color
      ),
      Loading(bloc)
    ]
  );

  void _loadMore() => bloc!.add(LoadFollowersPostListEvent(_page, (widget as ReviewPage).index));

  Future<void> _reload() async {
    setState(() {
      _list.clear();
    });
    _page = 1;
    _loadMore();
  }

  void _loadDetail(int index) {
    switch((widget as ReviewPage).index) {
      case 0: UtilUI.goToNextPage(context, MarketPriceCreateReportPage(marketPriceModel: _list[index], isReview: true, funReload: _reload)); break;
      case 1: UtilUI.goToNextPage(context, TPCreateContributePage(detail: _list[index], isReview: true, funReload: _reload)); break;
      case 2: UtilUI.goToNextPage(context, DiagnosePetsContributePage(const [], detail: _list[index], isReview: true, funReload: _reload)); break;
    }
  }
}
