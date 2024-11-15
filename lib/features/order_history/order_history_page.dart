import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/button_item_map.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/shadow_decoration.dart';
import 'package:hainong/common/ui/tab_item.dart';
import '../cart/cart_bloc.dart';
import '../cart/cart_model.dart';
import '../function/info_news/news/news_bloc.dart';
import '../profile/point_bloc.dart';
import 'order_detail_page.dart';

class OrderHistoryPage extends BasePage {
  final int idBusiness;
  OrderHistoryPage({this.idBusiness = -1, Key? key}) : super(pageState: _OrderHisPageState(), key:key);
}
class _OrderHisPageState extends BasePageState {
  final ScrollController _scroller = ScrollController();
  final List<OrderModel> _list = [];
  String _tab = 'mine', _status = 'pending';
  int _page = 1;
  bool _lock = false;

  @override
  void dispose() {
    _scroller.removeListener(_listener);
    _scroller.dispose();
    _list.clear();
    super.dispose();
  }

  @override
  void initState() {
    if ((widget as OrderHistoryPage).idBusiness > 0) _tab == 'mine';
    bloc = CartBloc(type: 'list');
    bloc!.stream.listen((state) {
      if (state is GetPointListState) {
        if (isResponseNotError(state.response)) {
          final list = state.response.data.list;
          if (list.isNotEmpty) {
            _list.addAll(list);
            list.length == 20 ? _page++ : _page = 0;
          } else _page = 0;
        }
        _lock = false;
      } else if (state is ChangeStatusManageState || state is ChangeTabState) _reload();
    });
    super.initState();
    _scroller.addListener(_listener);
    _loadMore();
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    final isBusiness = (widget as OrderHistoryPage).idBusiness > 0;
    return Scaffold(appBar: AppBar(titleSpacing: 0, centerTitle: true, elevation: 2,
        title: UtilUI.createLabel(isBusiness ? 'Danh sách đơn hàng' : 'Lịch sử đơn hàng')), backgroundColor: color,
        body: Stack(children: [
          Column(children: [
            if (!isBusiness) BlocBuilder(bloc: bloc,
                buildWhen: (state1, state2) => state2 is ChangeTabState,
                builder: (context, state) => Row(children: [
                  TabItem('Của tôi', 'mine', _tab == 'mine', _changeTab, parseTitle: false),
                  TabItem('Khách hàng đặt', 'client', _tab == 'client', _changeTab, parseTitle: false)
                ])),
            Padding(child: BlocBuilder(bloc: bloc,
                buildWhen: (state1, state2) => state2 is ChangeStatusManageState,
                builder: (context, state) => Row(children: [
                  ButtonMap('Chờ duyệt', () => _changeStatus('pending'), active: _status == 'pending', size: 42.sp, padding: 8, activeColor: Colors.orangeAccent),
                  const SizedBox(width: 10),
                  ButtonMap('Hoàn thành', () => _changeStatus('done'), active: _status == 'done', size: 42.sp, padding: 8, activeColor: Colors.green),
                  const SizedBox(width: 10),
                  ButtonMap('Đã huỷ', () => _changeStatus('cancelled'), active: _status == 'cancelled', size: 42.sp, padding: 8, activeColor: Colors.red)
                ])), padding: EdgeInsets.fromLTRB(40.sp, 40.sp, 40.sp, 0)),
            Expanded(child: RefreshIndicator(onRefresh: () async => _reload(),
                child: BlocBuilder(bloc: bloc, buildWhen: (state1, state2) => state2 is GetPointListState,
                    builder: (context, state) => ListView.separated(
                        padding: EdgeInsets.all(40.sp),
                        physics: const AlwaysScrollableScrollPhysics(),
                        controller: _scroller, itemCount: _list.length,
                        separatorBuilder: (context, index) => SizedBox(height: 40.sp),
                        itemBuilder: (context, index) {
                          Color color = Colors.orangeAccent;
                          if (_status == 'done') color = Colors.green;
                          else if (_status == 'cancelled') color = Colors.red;
                          return Container(decoration: ShadowDecoration(size: 10),
                              child: ButtonImageWidget(10,
                                      () => _openDetail(index),
                                  Padding(padding: EdgeInsets.all(40.sp),
                                      child: Row(children: [
                                        Image.asset('assets/images/ic_invoice_user.png', fit: BoxFit.fill,
                                            width: 100.sp, height: 100.sp, color: color),
                                        SizedBox(width: 20.sp),
                                        Expanded(child: Column(children: [
                                          Row(children: [
                                            Expanded(child: LabelCustom(_list[index].sku, color: Colors.black, line: 1)),
                                            LabelCustom(Util.strDateToString(_list[index].created_at, pattern: 'dd/MM/yyyy'),
                                                color: Colors.black26, weight: FontWeight.normal, size: 36.sp)
                                          ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                                          SizedBox(height: 20.sp),
                                          if (_tab == 'client')
                                            Padding(padding: EdgeInsets.only(bottom: 20.sp),
                                                child: Row(children: [
                                                  Expanded(child: LabelCustom(_list[index].name, weight: FontWeight.normal, color: Colors.black)),
                                                  LabelCustom(_list[index].phone_number, weight: FontWeight.normal, color: Colors.black)
                                                ])),
                                          Row(children: [
                                            LabelCustom('x' + Util.doubleToString(_list[index].quantity),
                                                color: Colors.black, weight: FontWeight.normal),
                                            LabelCustom(Util.doubleToString(_list[index].price_total) + ' đ', color: Colors.red),
                                          ], mainAxisAlignment: MainAxisAlignment.spaceBetween)
                                        ], crossAxisAlignment: CrossAxisAlignment.start))
                                      ]))
                              ));
                        }))
            ))
          ], mainAxisSize: MainAxisSize.min),
          Loading(bloc)
        ]));
  }

  void _listener() {
    if (_page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) _loadMore();
  }

  void _changeTab(String tab) {
    if (_tab != tab) {
      _tab = tab;
      bloc!.add(ChangeTabEvent());
    }
  }

  void _changeStatus(String status) {
    if (_status != status) {
      _status = status;
      bloc!.add(ChangeStatusManageEvent());
    }
  }

  void _loadMore() {
    if (_lock) return;
    bloc!.add(GetPointListEvent(_page, _status, tab: _tab, idBusiness: (widget as OrderHistoryPage).idBusiness));
    _lock = true;
  }

  void _reload() {
    if (_lock) return;
    setState(() => _list.clear());
    _page = 1;
    _loadMore();
  }

  void _openDetail(int index) => UtilUI.goToNextPage(context, OrderDtlPage(_list[index], _tab == 'mine', _reload, idBusiness: (widget as OrderHistoryPage).idBusiness));
}