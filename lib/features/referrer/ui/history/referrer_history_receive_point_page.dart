import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/ui_farm.dart';
import 'package:hainong/features/referrer/referrer_bloc.dart';
import 'package:hainong/features/referrer/referrer_event.dart';
import 'package:hainong/features/referrer/referrer_state.dart';

class ReferrerHistoryReceivePointPage extends BasePage {
  ReferrerHistoryReceivePointPage({Key? key})
      : super(pageState: _ReferrerHistoryReceivePointPageState(), key: key);
}

class _ReferrerHistoryReceivePointPageState extends BasePageState {
  final TextEditingController _ctrSearch = TextEditingController(),
      _ctrCat = TextEditingController();
  final ScrollController _scroller = ScrollController();
  final List _list = [];
  bool _lock = false;
  int _page = 1;
  int? totalPoint = 0;

  @override
  void dispose() {
    _scroller.removeListener(_listenScroller);
    _scroller.dispose();
    _list.clear();
    _ctrSearch.dispose();
    _ctrCat.dispose();
    super.dispose();
  }

  void _listenScroller() {
    if (_page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) _loadMore();
  }

  void _loadMore() {
    if (_lock) return;
    _lock = true;
    bloc!.add(LoadReferrerHistoryListEvent("receive_point_referral"));
  }

  @override
  void initState() {
    bloc = ReferrerBloc(ReferrerState());
    super.initState();
    bloc!.stream.listen((state) {
      if (state is GetReferrerHistoryState) {
        if (isResponseNotError(state.data)) {
          final list = state.data.data;
          totalPoint = state.totalPoint;
          if (list.isEmpty) {
            _page = 0;
          } else {
            setState(() {
              _list.addAll(list);
              list.length == 20 ? _page++ : _page = 0;
            });
          }
        }
        _lock = false;
      }
      _lock = false;
    });
    _loadMore();
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Column(
        children: [
          Align(alignment: Alignment.centerRight,child: Padding(padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 12.sp),
            child: Row(mainAxisAlignment: MainAxisAlignment.end,children: [
              Text("Tổng nhận: ",style: TextStyle(color: Colors.black87)),
              Text("$totalPoint",style: const TextStyle(color: Colors.green),)]),
            ),
          ),
          Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal,
              child: SizedBox(width: 2.sw,child: Column(children: [
                  FarmManageTitle(
                    const [
                      ['Người giới thiệu', 10, TextAlign.center],
                      ['Ngày giới thiệu', 7, TextAlign.center],
                      ['Tên sản phẩm', 10, TextAlign.center],
                      ['Mã đơn hàng', 7, TextAlign.center],
                      ['Số lượng', 7, TextAlign.center],
                      ['Điểm nhận thưởng', 7, TextAlign.center]
                    ],
                    width: 2.sw,size: 13,padding: 20.sp,
                  ),
                  Expanded(
                      child: RefreshIndicator(
                          child: BlocBuilder( bloc: bloc,
                              buildWhen: (oldState, newState) => newState is LoadReferrerHistoryListState,
                              builder: (context, state) => ListView.builder(
                                  padding: EdgeInsets.zero,
                                  controller: _scroller,
                                  shrinkWrap: true,
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  itemCount: _list.length,
                                  itemBuilder: (context, index) {
                                    return FarmManageItem([
                                      [_list[index]['pointable_referraler_name'] ?? '',10, TextAlign.center],
                                      [Util.strDateToString(_list[index]['pointable_created_at'] ?? '',pattern: 'dd/MM/yyyy'),7,TextAlign.center],
                                      [_list[index]["pointable_product_name"] ?? '',10, TextAlign.center],
                                      [_list[index]["pointable_invoice_user_sku"] ?? '',7,TextAlign.center],
                                      [_list[index]['pointable_quantity'].toString(),7,TextAlign.center],
                                      [_list[index]['point'].toString(), 7, TextAlign.center]
                                    ], index, maxLine: 2);
                                  })),
                          onRefresh: () async => _reset()))
                ]),
              ),
            ),
          ),
        ],
      );

  void _reset({bool hasBack = false}) {
    if (hasBack) UtilUI.goBack(context, false);
    _list.clear();
    _page = 1;
  }
}
