import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/tab_item.dart';
import 'package:hainong/common/ui/title_helper.dart';
import 'package:hainong/common/ui/ui_farm.dart';
import 'introduction_history_bloc.dart';
import 'introduction_history_model.dart';

class IntroductionHistoryPage extends BasePage {
  final int id;
  IntroductionHistoryPage({Key? key, this.id = -1}):super(key: key, pageState: _IntroductionHistoryState());
}

class _IntroductionHistoryState extends BasePageState {
  String _status = 'new_user';
  final ScrollController _scroller = ScrollController();
  int _page = 1;
  IntroductionHistoryModel data = IntroductionHistoryModel();

  @override
  void initState() {
    bloc = IntroductionHistoryBloc();
    bloc!.stream.listen((state) {
      if(state is LoadListIntroHisState){
        _handleLoadList(state.response.data);
      }
    });
    bloc!.add(LoadListIntroHisEvent(_status,page: _page));
    _scroller.addListener(_listenScroll);
    super.initState();
  }

  @override
  void dispose() {
    data.modified_list.clear();
    _scroller.removeListener(_listenScroll);
    _scroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    return Scaffold(
      appBar: AppBar(elevation: 5, titleSpacing: 0, centerTitle: true, title:
        const Padding(padding: EdgeInsets.only(right: 48), child: TitleHelper('Giới thiệu Hai Nông', url: 'https://help.hainong.vn/muc/18'))),
      body: Stack(
        children: [
          Column(
            children: [
              BlocBuilder(bloc: bloc,
                  buildWhen: (oldState, newState) => newState is LoadListIntroHisState || newState is ChangeTabIntroHisState,
                  builder: (context, state) {
                return Column(
                  children: [
                    Row(children: [
                      TabItem('lbl_new_user', 'new_user', _status == 'new_user', _changeTab,size: 40.sp,expanded: false,),
                      TabItem('lbl_reward', 'reward', _status == 'reward', _changeTab,size: 40.sp),
                      TabItem('lbl_receive_reward', 'receive_reward', _status == 'receive_reward', _changeTab,size: 40.sp)
                    ]),
                    Padding(
                      padding:  EdgeInsets.all(40.sp),
                      child: Row(
                          children: [
                            Text(_status == "reward" ? "Tổng trả: " : "Tổng nhận: ", style: TextStyle(fontSize: 42.sp, color: Colors.black87, fontWeight: FontWeight.w500)),
                            Flexible(child: Text(data.total_points.toString() + " điểm", style: TextStyle(fontSize: 42.sp, color: _status != "reward" ? const Color(0xFF1AAD80) : Colors.red, fontWeight: FontWeight.w500))),
                          ], mainAxisAlignment: MainAxisAlignment.end
                      ),
                    ),
                  ],
                );
              }),
              Expanded(
                child: BlocBuilder(
                  bloc: bloc,
                    buildWhen: (state1,state2) => state2 is LoadListIntroHisState|| state2 is ChangeTabIntroHisState,
                    builder: (context, state) {
                  return _status != 'new_user' ?  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        FarmManageTitle( [[_status == "reward" ? "Người giới thiệu" : "Người mua",3 ],  const ['Ngày giới thiệu', 3, TextAlign.left],const ['Tên sản phẩm', 3,TextAlign.center],
                          const ['Mã đơn hàng', 3,TextAlign.center],const ['Số lượng',2,TextAlign.center],
                          [_status == "reward" ?'Điểm trả thưởng' : 'Điểm nhận thưởng',4,TextAlign.center]],
                            size: 36.sp,
                            padding: 30.sp,width: 2.sw),
                        Expanded(
                          child: SizedBox(
                            width: 2.sw,
                            child: BlocBuilder(bloc: bloc,
                                buildWhen: (oldState, newState) => newState is LoadListIntroHisState || newState is ChangeTabIntroHisState,
                                builder: (context, state) => ListView.builder(
                                    padding: EdgeInsets.zero, controller: _scroller, itemCount: data.modified_list.length,
                                    itemBuilder: (context, index) => FarmManageItem([[data.modified_list[index]['buyer_name'],3],  [data.modified_list[index]['introduction_date'], 3, TextAlign.left],[data.modified_list[index]['product_name'], 3,TextAlign.left],[data.modified_list[index]['invoice_sku'], 3,TextAlign.center],[data.modified_list[index]['quantity'], 2,TextAlign.center],[(_status == 'reward' ? '-' : "+") + data.modified_list[index]['point'].toString(),4,TextAlign.center,_status == 'reward' ? Colors.red : const Color(0xFF1AAD80)]]
                                        ,index,padding: 30.sp,)
                                )),
                          ),
                        )
                      ],
                    ),
                  ) :  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        FarmManageTitle( const [["Người dùng mới", 3,TextAlign.center],['Số điện thoại', 3, TextAlign.left], ['Ngày đăng ký', 3, TextAlign.center],['Số điểm nhận', 3,TextAlign.center]],
                            size: 38.sp,
                            padding: 20.sp,width: 1.3.sw),
                        Expanded(
                          child: SizedBox(
                            width: 1.3.sw,
                            child: BlocBuilder(bloc: bloc,
                                buildWhen: (oldState, newState) => newState is LoadListIntroHisState || newState is ChangeTabIntroHisState,
                                builder: (context, state) => ListView.builder(
                                    padding: EdgeInsets.zero, controller: _scroller, itemCount: data.modified_list.length,
                                    itemBuilder: (context, index) => FarmManageItem([[data.modified_list[index]['name'],3],  [data.modified_list[index]['phone'], 3, TextAlign.left],[data.modified_list[index]['registration_date'], 3,TextAlign.center],["+" + data.modified_list[index]['point'].toString(),3,TextAlign.center,const Color(0xFF1AAD80)]]
                                      ,index,padding: 20.sp,)
                                )),
                          ),
                        )
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
          Loading(bloc)
        ],
      ),
    );
  }

  void _listenScroll() {
    if (_page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) {
      bloc!.add(LoadListIntroHisEvent(_status,page: _page));
    }
  }

  void _handleLoadList(dynamic response) {
    if (response != null && response is IntroductionHistoryModel && response.modified_list.isNotEmpty) {
      data.total_points = response.total_points;
      data.modified_list.addAll(response.modified_list);
      response.modified_list.length == 20 ? _page++ : _page = 0;
    } else {
      _page = 0;
    }
  }

  void reload() {
    data.total_points = 0;
    data.modified_list.clear();
  }

  void _changeTab(String status) {
    if (_status != status) {
      _status = status;
      reload();
      bloc!.add(ChangeTabIntroHisEvent());
    bloc!.add(LoadListIntroHisEvent(_status,page: _page));
    }
  }
}