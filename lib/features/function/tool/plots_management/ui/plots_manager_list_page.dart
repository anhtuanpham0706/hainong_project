import 'package:hainong/common/ui/avatar_circle_widget.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/features/function/info_news/news/news_bloc.dart';
import '../plots_management_bloc.dart';
import 'plots_management_list_page.dart';

class PlotsManagerListPage extends BasePage {
  PlotsManagerListPage({Key? key}):super(key: key, pageState: _PlotsManagerListPageState());
}

class _PlotsManagerListPageState extends BasePageState {
  int _page = 1;
  final List<dynamic> _list = [];
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
    bloc = PlotsManagementBloc();
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadListManageState && isResponseNotError(state.response)) {
        final list = state.response.data.list;
        if (list.isNotEmpty) {
          _list.addAll(list);
          list.length == 20 ? _page++ : _page = 0;
        } else _page = 0;
      }
    });
    _loadMore();
    _scroller.addListener(_listener);
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Scaffold(
    appBar: AppBar(title: UtilUI.createLabel('Danh sách người quản lý', textAlign: TextAlign.center),
        centerTitle: true, elevation: 5, titleSpacing: 0), backgroundColor: color,
    body: Stack(
      children: [
        RefreshIndicator(onRefresh: _reload, child: BlocBuilder( bloc: bloc,
          buildWhen: (state1, state2) => state2 is LoadListManageState,
          builder: (context, state) => ListView.builder(padding: EdgeInsets.zero, controller: _scroller,
            itemCount: _list.length, physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return ButtonImageWidget(0, () {
                UtilUI.goToNextPage(context, PlotsManageListPage(idAssigned: _list[index].id));
              }, Padding(child: Row(children: [
                AvatarCircleWidget(link: _list[index].image, size: 160.sp),
                SizedBox(width: 20.sp),
                Expanded(child: Column(children: [
                  LabelCustom(_list[index].name, color: StyleCustom.textColor6C),
                  SizedBox(height: 20.sp),
                  Row(children: [
                    Icon(Icons.phone_android, size: 36.sp, color: Colors.orange),
                    Expanded(
                        child: UtilUI.createLabel(' ' + _list[index].phone,
                            color: StyleCustom.textColor6C, fontSize: 30.sp, fontWeight: FontWeight.normal))
                  ])
                ], crossAxisAlignment: CrossAxisAlignment.start))
              ]), padding: EdgeInsets.all(40.sp)), color: index % 2 == 0 ? const Color(0xFFF5F5F5) : Colors.transparent);
            })
        )),
        Loading(bloc)
      ])
    );

  void _listener() {
    if (_page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) _loadMore();
  }

  void _loadMore() => bloc!.add(LoadListManageEvent(_page, 0));

  Future<void> _reload() async {
    _list.clear();
    _page = 1;
    _loadMore();
  }
}
