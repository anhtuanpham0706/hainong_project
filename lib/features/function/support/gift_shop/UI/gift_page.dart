import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/features/login/login_model.dart';
import 'package:hainong/common/models/item_option.dart';
import 'gift_history_page.dart';
import 'gift_item_page.dart';
import '../bloc/gift_bloc.dart';
import '../gift_catalog_model.dart';
import '../gift_model.dart';
import '../topup_data_model.dart';
import '../receive_point_page.dart';

class GiftShopPage extends BasePage {
  GiftShopPage({Key? key}):super(key: key, pageState: _GiftShopPageState());
}

class _GiftShopPageState extends BasePageState {
  List<GiftModel> _listGift = [];
  List<TopUpModel> _listTopUp = [];
  List<GiftCatalogModel> _listCatalog = [];
  final ScrollController _scroller = ScrollController();
  int? _userPoint = 0;
  String? _userLevel = "";
  int _page = 1, menuIndex = 0, catalog_id = -1;
  bool expanded = false;

  @override
  void dispose() {
    _listGift.clear();
    _listTopUp.clear();
    _listCatalog.clear();
    _scroller.removeListener(_listenerScroll);
    _scroller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    bloc = GiftBloc();
    super.initState();
    bloc!.stream.listen((state) {
      if(state is LoadGiftState && isResponseNotError(state.response)){
        _handleLoadList(state.response.data);
      } else if(state is ChangeGiftState){
        if (state.response.success) {
          UtilUI.showCustomDialog(context, 'Đổi quà thành công vui lòng chờ quản trị viên xác nhận', title: "Thông báo").then((value)  {
            if(value != null && value) {
              bloc!.add(GetInfoEvent());
              _page = 1;
              _listGift.clear();
              _loadMore();
            }
          });
        } else {
          UtilUI.showCustomDialog(context, state.response.msg.contains('bạn đã đổi, nếu bạn muốn tiếp tục hãy chọn quà khác')
              ? state.response.msg : 'Đổi quà không thành công', title: "Thông báo");
        }
      } else if(state is GetInfoState){
        if(state.response.success){
          _savePoint(state.response.data);
        } else {
          _getInfoUser();
        }
      } else if(state is LoadListTopUpState && isResponseNotError(state.response)){
        _listTopUp = state.response.data.list;
      } else if(state is LoadCatalogState && isResponseNotError(state.response)) {
        setState(() {
          _listCatalog.add(GiftCatalogModel(name: "Tất cả"));
          _listCatalog.addAll(state.response.data.list);
        });
      } else if(state is ChangeTopUpState){
        if(state.response.success){
          UtilUI.showCustomDialog(context, 'Đổi Data thành công',title: "Thông báo").then((value)  {
            if(value != null && value){
              bloc!.add(GetInfoEvent());
            }
          });
        } else {
          UtilUI.showCustomDialog(context, 'Đổi Data không thành công',title: "Thông báo");
        }
      }
    });
    bloc!.add(GetInfoEvent());
    bloc!.add(LoadCatalogEvent());
    bloc!.add(LoadListTopUpEvent());
    _loadNew();
    _scroller.addListener(_listenerScroll);
  }

  void _listenerScroll() {
    if (_page > 0 && _scroller.position.pixels == _scroller.position.maxScrollExtent) _loadMore();
  }

  void _loadMore() {
    if (_page > 0) bloc!.add(LoadGiftEvent(catalog_id,_page));
  }

  void _loadNew() {
    _listGift.clear();
    _page = 1;
    bloc!.add(LoadGiftEvent(catalog_id,_page));
  }

  void _handleLoadList(GiftModels data) {
    if (data.list.isNotEmpty) {
      _listGift.addAll(data.list);
      data.list.length == constants.limitPage*2 ? _page++ : _page = 0;
    } else _page = 0;
  }

  void _savePoint(LoginModel user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("points", user.points);
    _userPoint = user.points;
    _userLevel = user.user_level;
  }

  void _getInfoUser() async {
    final prefs = await SharedPreferences.getInstance();
    _userLevel =  prefs.getString('user_level');
    _userPoint = prefs.getInt('points');
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    return Stack(children: [
      Scaffold(
        appBar: AppBar(
            backgroundColor: StyleCustom.primaryColor,
            title: Text("Danh sách quà tặng",style: TextStyle(color: Colors.white,fontSize: 50.sp),),
            actions: [IconButton(onPressed: () {
              _selectOption();
            }, icon: Icon(Icons.menu_outlined,size: 60.sp,color: Colors.white,))]
        ),
        backgroundColor: Color(0XFFF0F0F0),
        body: Column(
          children: [
            BlocBuilder(
                bloc: bloc,
                buildWhen: (oldstate, newstate) => newstate is GetInfoState,
                builder: (context, state) {
                  return Padding(
                    padding: EdgeInsets.all(30.sp),
                    child: Container(
                      height: 250.sp,
                      width: 1.sw,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(15.sp))
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                              padding: EdgeInsets.only(left: 60.sp),
                              child: Image.asset('assets/images/ic_prize.png',
                                  width: 160.sp, height: 180.sp, fit: BoxFit.fill)),
                          Padding(
                            padding: EdgeInsets.all(25.sp),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(left: 0.sp,bottom: 10.sp),
                                    child: Image.asset('assets/images/ic_three_stars.png',
                                        width: 100.sp, height: 60.sp, fit: BoxFit.fill)),
                                Text("Điểm tích lũy",style: TextStyle(fontSize: 40.sp),),
                                Text(Util.doubleToString((_userPoint??0).toDouble()),style: TextStyle(fontSize: 62.sp),),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 60.sp,top: 25.sp,bottom: 25.sp),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(left: 0.sp,bottom: 10.sp),
                                    child: Image.asset('assets/images/ic_crown.png',
                                        width: 100.sp, height: 60.sp, fit: BoxFit.fill)),
                                Text("Xếp hạng",style: TextStyle(fontSize: 40.sp),),
                                Text(_userLevel.toString(),style: TextStyle(fontSize: 58.sp),),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            BlocBuilder(
                bloc: bloc,
                buildWhen: (OldState, NewState) => NewState is ExpandedTopUpState,
                builder: (context, state) {
                  if(state is ExpandedTopUpState){
                    expanded = state.expanded;
                  }
                  return Padding(
                    padding: EdgeInsets.all(15.sp),
                    child: GestureDetector(
                      onTap: (){
                        bloc!.add(ExpandedTopUpEvent(expanded));
                      },
                      child: Container(
                        width: 1.sw,
                        padding: EdgeInsets.all(30.sp),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black,width: 1.sp),
                            borderRadius: BorderRadius.all(Radius.circular(15.sp))
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Nạp Data",style: TextStyle(fontSize: 48.sp,color: Colors.black,fontWeight: FontWeight.bold),),
                            SizedBox(
                              height: 60.sp,
                              width: 60.sp,
                              child: Icon(!expanded ? Icons.expand_more : Icons.expand_less,color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            BlocBuilder(
                bloc: bloc,
                buildWhen: (oldstate, newstate) => newstate is LoadListTopUpState|| newstate is GetInfoState || newstate is ExpandedTopUpState,
                builder: (context, state) {
                  final List<Widget> list_topup = [];
                  if (!expanded) return const SizedBox();
                  if(_listTopUp != []){
                    for(int i = 0; i < _listTopUp.length; i++) {
                      list_topup.add(
                          Padding(
                            padding: EdgeInsets.all(15.sp),
                            child: GestureDetector(
                              onTap: (){
                                if(_userPoint! >= _listTopUp[i].point || _listTopUp[i].point == 0) {
                                  bloc!.add(ChangeTopUpEvent(_listTopUp[i].id));
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(20.sp),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(25.sp)),
                                    border: Border.all(color: Colors.black,width: 1.sp)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(10.sp),
                                      child: Container(
                                          height: 100.sp,
                                          width:  100.sp,
                                          alignment: Alignment.bottomRight,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8.sp),
                                              image: DecorationImage(
                                                  image: _listTopUp[i].image.isNotEmpty
                                                      ? FadeInImage.assetNetwork(
                                                      image: _listTopUp[i].image,
                                                      placeholder: 'assets/images/ic_default.png')
                                                      .image
                                                      : Image.asset('assets/images/ic_default.png').image,
                                                  fit: BoxFit.cover)),
                                          child: const SizedBox()),
                                    ),
                                    SizedBox(width: 40.sp,),
                                    Text(_listTopUp[i].capacity,style: TextStyle(color: Colors.black,fontSize: 48.sp,fontWeight: FontWeight.bold),),
                                    SizedBox(width: 40.sp,),
                                    Text("${_listTopUp[i].point} điểm",style: TextStyle(color: Colors.orange,fontSize: 42.sp,fontWeight: FontWeight.bold),),
                                    SizedBox(width: 60.sp,),
                                    Container(
                                      decoration: BoxDecoration(
                                          color:  _userPoint! >= _listTopUp[i].point || _listTopUp[i].point == 0 ? StyleCustom.primaryColor : Color(0XFFB9BBBA),
                                          borderRadius: BorderRadius.all(Radius.circular(25.sp))
                                      ),
                                      child: Center(child: Padding(
                                        padding: EdgeInsets.all(25.sp),
                                        child: Text("Đổi điểm",style: TextStyle(color: Colors.white,fontSize: 38.sp),),
                                      )),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                      );
                    }
                    return Container(
                        constraints: BoxConstraints(
                            maxHeight: 800.sp
                        ),
                        child: SingleChildScrollView(child: Column(children: list_topup)));
                  }
                  return const SizedBox();
                }),
            BlocBuilder(
                bloc: bloc,
                buildWhen: (Old, New) => New is ChangeMenuCatalogState || New is LoadCatalogState,
                builder: (context, state) {
                  if(state is ChangeMenuCatalogState){
                    menuIndex = state.index;
                  }
                  return SizedBox(width: 1.sw, height: 150.sp, child: ListView.builder(scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.only(left: 15.sp, bottom: 10.sp),
                      itemCount: _listCatalog.length,
                      itemBuilder: (BuildContext context, int index) => Container(alignment: Alignment.center,
                        padding: EdgeInsets.only(top: 10.sp, right: 20.sp),
                        child: GestureDetector(
                          onTap: () {
                            bloc!.add(ChangeMenuCatalogEvent(index));
                            catalog_id = _listCatalog[index].id;
                            _loadNew();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: index == menuIndex ? StyleCustom.primaryColor : Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(20.sp)),
                                border: Border.all(color: Colors.black,width: 1.sp)
                            ),
                            padding: EdgeInsets.all(20.sp),
                            child: Text(_listCatalog[index].name,style: TextStyle(fontSize: 48.sp,color:  index == menuIndex ? Colors.white : Colors.black,fontWeight: FontWeight.bold),),
                          ),
                        ),
                      )));
                }),
            Expanded(
              child: BlocBuilder(bloc: bloc,
                  buildWhen: (oldState, newState) => newState is LoadGiftState || newState is GetInfoState,
                  builder: (context, state) =>  AlignedGridView.count(
                      padding: EdgeInsets.only(left: 16.sp, right: 16.sp, top: 0.sp), controller: _scroller,
                      crossAxisCount: 2, mainAxisSpacing: 8.sp, crossAxisSpacing: 8.sp, itemCount: _listGift.length,
                      itemBuilder: (BuildContext context, int index) => _listGift.isEmpty ? const SizedBox() :
                      GiftShopItem(_listGift[index],_userPoint!,_changePoint)
                  )),
            )
          ],
        ),
      ),
      Loading(bloc)
    ]);
  }

  _selectOption() async {
    if (bloc!.state.isShowLoading) return;
    final List<ItemOption> options = [];
    options.add(ItemOption('assets/images/ic_history.png', ' Lịch sử đổi quà', () {
      UtilUI.goBack(context, false);
      UtilUI.goToNextPage(context, const GiftHistoryPage());
    }, false));
    options.add(ItemOption('assets/images/ic_calendar.png', ' Nhiệm vụ nhận điểm', () {
      UtilUI.goBack(context, false);
      UtilUI.goToNextPage(context, const ReceivePointPage());
    }, false));
    UtilUI.showOptionDialog2(context, MultiLanguage.get('ttl_option'), options);
    Util.trackActivities('weathers', path: 'Post -> Option Menu Button -> Open Option Dialog');
  }

  void _changePoint(GiftModel item){
    UtilUI.showCustomDialog(context, 'Bạn có chắc đổi điểm lấy quà đã chọn không?', isActionCancel: true,title: "Thông báo")
        .then((value) {
      if (value != null && value) bloc!.add(ChangeGiftEvent(item.id,item.classable_type));
    });
  }
}
