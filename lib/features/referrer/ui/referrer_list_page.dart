import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hainong/common/import_lib_system.dart';
import 'package:hainong/common/ui/base_page.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/empty_search.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/task_bar_widget.dart';
import 'package:hainong/features/main/bloc/scroll_bloc.dart';
import 'package:hainong/features/referrer/referrer_bloc.dart';
import 'package:hainong/features/referrer/referrer_event.dart';
import 'package:hainong/features/referrer/model/referrer_model.dart';
import 'package:hainong/features/referrer/referrer_state.dart';
import 'package:hainong/features/shop/shop_model.dart';
import 'package:hainong/features/shop/ui/shop_page.dart';

class ReferrerListPage extends BasePage {
  final List<ReferrerModel>? selectReferrers;
  final List<ReferrerModel>? selectFriends;
  Function(List<ReferrerModel> selectReferrers, List<ReferrerModel> selectFriends)?
      callBackSelectItems;

  ReferrerListPage({Key? key, this.selectFriends, this.selectReferrers, this.callBackSelectItems})
      : super(key: key, pageState: ReferrerListPageState());
}

class ReferrerListPageState extends BasePageState {
  List<ReferrerModel> _listReferrer = [];
  List<ReferrerModel> _listFriend = [];
  List<ReferrerModel> _selectReferrers = [];
  List<ReferrerModel> _selectFriends = [];
  bool allSelected = false;
  bool isShowSearch = false;
  String _key = '', _currentPhone = '';
  int _page = 1;
  final ScrollController _scroller = ScrollController();
  final ScrollBloc _scrollBloc = ScrollBloc(ScrollState());
  final TextEditingController _ctrSearch = TextEditingController();
  late Function(List<ReferrerModel> selectReferrers, List<ReferrerModel> selectFriends)
      callBackSelectItems;

  @override
  void dispose() {
    _scroller.dispose();
    _scrollBloc.close();
    _listFriend.clear();
    _listReferrer.clear();
    bloc?.close();
    super.dispose();
  }

  @override
  void search(String key) {
    _initSearch(key);
    _loadMore();
  }

  void searchPhone(){
    if (isShowSearch) {
      if(_currentPhone.contains(_ctrSearch.text)){
        UtilUI.showCustomDialog(context, MultiLanguage.get('msg_referral_add_available'), title: MultiLanguage.get(languageKey.ttlAlert), alignMessageText: TextAlign.center);
      }else{
        bloc?.add(LoadReferrerEvent(phone: _ctrSearch.text));
      }
    }
  }

  void _initSearch(String keyword) {
    _key = keyword;
    _page = 1;
  }

  @override
  void initState() {
    super.initState();
    getPhoneUser();
    callBackSelectItems = (widget as ReferrerListPage).callBackSelectItems ?? (_, __) => () {};
    final _friends = (widget as ReferrerListPage).selectFriends ?? [];
    final _referrers = (widget as ReferrerListPage).selectReferrers ?? [];
    _selectFriends.addAll(_friends);
    _selectReferrers.addAll(_referrers);
    _listReferrer = _selectReferrers;
    checkShowAll();
    bloc = ReferrerBloc(ReferrerState());
    bloc!.stream.listen((state) {
      if (state is LoadFriendListState) _handleLoadFriendList(state);
      if (state is LoadReferrerState) _handleLoadReferrer(state);
      if (state is LoadShopReferrerState) {
        _handleLoadShop(state);
      }
    });
    _loadMore();
    _scroller.addListener(_listenerScroll);
  }

  _handleLoadShop(LoadShopReferrerState state) {
    if (state.response.data is String) return;
    ShopModel shop = state.response.data as ShopModel;
    if (shop.id > -1) {
      UtilUI.goToNextPage( context,ShopPage(shop: state.response.data,isOwner: false,hasHeader: true,isView: true,));
      Util.trackActivities('post', path: 'Post -> Information User/Shop -> Open Shop Screen');
    }
  }

  _goToShop(int userId, String shopId) {
    bloc?.add(LoadShopReferrerEvent(userId, shopId));
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    return Scaffold(
        appBar: TaskBarWidget('Danh sách giới thiệu', lblButton: MultiLanguage.get('ttl_confirm'),
            onPressed: () {
          callBackSelectItems(_selectReferrers, _selectFriends);
          Navigator.of(context).pop();
        }).createUI(),
        body: RefreshIndicator(
          onRefresh: () async => search(_key),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [PreferredSize( preferredSize: Size(0.5.sw, 140.sp),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                    decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(60.sp),border:Border.all(width: 1, color: const Color(0xFFA4A4A4))),
                                    padding: EdgeInsets.all(30.sp),
                                    margin: EdgeInsets.fromLTRB(0.sp, 40.sp, 0.sp, 40.sp),
                                    child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(right: 20.sp),
                                            child: ButtonImageWidget(100,_search,Icon(Icons.search,size: 48.sp, color: const Color(0xFF676767))),
                                          ),
                                          Expanded(child: TextField(
                                                  controller: _ctrSearch,
                                                  onChanged: (value) {
                                                    setState(() { value.length >= 10 ? isShowSearch = true : isShowSearch = false; });
                                                    if (value.length == 1) bloc!.add(ShowClearSearchEvent(true));
                                                    if (value.isEmpty) bloc!.add(ShowClearSearchEvent(false));
                                                  },
                                                  onSubmitted: (value) => searchPhone(),
                                                  textInputAction: TextInputAction.search,
                                                  decoration: InputDecoration(
                                                      hintStyle: TextStyle(fontSize: 36.sp,color: const Color(0xFF959595)),
                                                      hintText: 'Nhập số điện thoại',
                                                      contentPadding: EdgeInsets.zero,
                                                      isDense: true,
                                                      border: const UnderlineInputBorder(borderSide: BorderSide.none)))),
                                          BlocBuilder(bloc: bloc,
                                              buildWhen: (oldS, newS) => newS is ShowClearSearchState,
                                              builder: (context, state) {
                                                bool show = false;
                                                if (state is ShowClearSearchState) show = state.value;
                                                return show
                                                    ? Padding(padding: EdgeInsets.only(right: 20.sp),child: ButtonImageWidget(100,_clear,Icon(Icons.clear,size: 48.sp,color: const Color(0xFF676767))))
                                                    : const SizedBox();
                                              }),
                                        ])),
                              ),
                              GestureDetector(
                                onTap: () => searchPhone(),
                                child: Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.only(left: 10),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isShowSearch ? StyleCustom.buttonColor : Colors.grey,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text("Tìm",style: TextStyle(color: Colors.white, fontSize: 16)),
                                ),
                              )
                            ],
                          )),
                      if(isHasData())
                        if(isShowTitleCheckAll())...[
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: Row(
                              children: [
                                SizedBox(width: 20,height: 20,child: Checkbox(activeColor: Colors.green,value: allSelected, onChanged: (bool? value) => selectAll())),
                                SizedBox(width: 20.w),
                                Text(allSelected ? 'Bỏ chọn tất cả' : 'Chọn tất cả',style: const TextStyle(fontSize: 18)),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        _listReferrer.isNotEmpty
                          ? Column(children: [
                              Padding(padding: EdgeInsets.symmetric(vertical: 10.h),
                                child: Align(alignment: Alignment.centerLeft,
                                  child: Text(MultiLanguage.get('lbl_referrers'),style: const TextStyle(fontSize: 18, color: Colors.black54),)),
                                ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                controller: _scroller,
                                padding: EdgeInsets.zero,
                                itemCount: _listReferrer.length,
                                itemBuilder: (context, index) => _buildListTile(false, _listReferrer[index]),
                              ),
                            ])
                          : Container(),
                        _listFriend.isNotEmpty
                          ? Column(children: [
                              Padding(padding: EdgeInsets.symmetric(vertical: 10.h),
                                child: Align(alignment: Alignment.centerLeft,
                                  child: Text(MultiLanguage.get('lbl_friends'),style: const TextStyle( fontSize: 18, color: Colors.black54)))
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                controller: _scroller,
                                padding: EdgeInsets.zero,
                                itemCount: _listFriend.length,
                                        itemBuilder: (context, index) => _buildListTile(true, _listFriend[index]),
                              )])
                            : Container()
                    ],
                  ),
                ),
                Loading(bloc)
              ],
            ),
          ),
        ));
  }

  void _search() => clearFocus();

  Widget _buildListTile(bool isFriend, ReferrerModel item) {
    if (item.id != -1) {
      bool isCheck = isFriend ? _selectFriends.contains(item) : _selectReferrers.contains(item);
      return Padding(padding: EdgeInsets.symmetric(vertical: 20.sp),
        child: Row(children: [
            SizedBox(width: 20,height: 20,
                child: Checkbox(activeColor: Colors.green,value: isCheck,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null && value) {
                        isFriend ? _selectFriends.add(item) : _selectReferrers.add(item);
                      } else {
                        isFriend ? _selectFriends.remove(item) : _selectReferrers.remove(item);
                      }
                      checkShowAll();
                    });
                  },
                )),
            const SizedBox(width: 10),
            item.image.isNotEmpty == true
              ? GestureDetector(
                  onTap: () => _goToShop(item.id, item.shop_id.toString()),
                  child: SizedBox(width: 160.w,height: 160.w,
                    child: CircleAvatar(backgroundImage: NetworkImage(item.image))),
                )
              : GestureDetector(
                  onTap: () => _goToShop(item.id, item.shop_id.toString()),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(width: 160.w,height: 160.w,child: const CircleAvatar(backgroundColor: Colors.greenAccent),),
                      if (item.name.isNotEmpty) Text(item.name[0],textAlign: TextAlign.center,style: const TextStyle(fontSize: 24, color: Colors.white))],
                  ),
                ),
            SizedBox(width: 30.w),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,style: TextStyle(fontSize: 18)),
                  Text(item.phone,style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  void checkShowAll() {
    bool friendCondition = _listFriend.isNotEmpty &&
        _listReferrer.isEmpty &&
        _listFriend.length == _selectFriends.length;
    bool referrerCondition = _listReferrer.isNotEmpty &&
        _listFriend.isEmpty &&
        _listReferrer.length == _selectReferrers.length;
    bool bothCondition = _selectFriends.isNotEmpty &&
        _selectReferrers.isNotEmpty &&
        _listFriend.isNotEmpty &&
        _listReferrer.isNotEmpty &&
        _selectFriends.length == _listFriend.length &&
        _selectReferrers.length == _listReferrer.length;
    allSelected = friendCondition || referrerCondition || bothCondition;
  }

  void _listenerScroll() {
    if (_page > 0 && _scroller.position.pixels == _scroller.position.maxScrollExtent) _loadMore();
  }

  void _loadMore() {
    if (_page > 0) bloc!.add(LoadFriendListEvent(_page, keyword: _ctrSearch.text));
  }

  void _handleLoadFriendList(state) {
    if(isResponseNotError(state.response)){
      final data = state.response.data;
      if (data.list.isNotEmpty) {
        _listFriend = data.list;
        moveReferrersToFriends();
        data.list.length == constants.limitPage * 2 ? _page++ : _page = 0;
        checkShowAll();
      } else {
        _page = 0;
      }
    }
  }

  void moveReferrersToFriends() {
    if (_selectReferrers.isNotEmpty) {
      List<ReferrerModel> _selectReferrersCurrent = [];
      for (var referrer in _selectReferrers) {
        if (_listFriend.any((friend) => friend.id == referrer.id)) {
          _selectFriends.add(referrer);
          _selectReferrersCurrent.add(referrer);
        }
      }
      _selectReferrers.removeWhere((referrer) => _selectReferrersCurrent.contains(referrer));
    }
  }

  void _handleLoadReferrer(state) {
    if(isResponseNotError(state.response)){
      final data = state.response.data;
      if (_listFriend.contains(data)) {
        UtilUI.showCustomDialog(context, MultiLanguage.get('msg_phone_add_friends'),title: MultiLanguage.get(languageKey.ttlAlert));
      } else {
        _ctrSearch.clear();
        isShowSearch = false;
        if (!_listReferrer.contains(data) || _listReferrer.isEmpty) {
          setState(() => _listReferrer.add(data));
        }
        checkShowAll();
      }
    }
  }

  void selectAll() {
    setState(() {
      if (allSelected) {
        _selectFriends.clear();
        _selectReferrers.clear();
      } else {
        _selectFriends = _listFriend.map((item) => item).toList();
        _selectReferrers = _listReferrer.map((item) => item).toList();
      }
      allSelected = !allSelected;
    });
  }

  void _clear() {
    clearFocus();
    _ctrSearch.text = '';
    isShowSearch = false;
    bloc!.add(ShowClearSearchEvent(false));
  }

  void getPhoneUser() async {
    final prefs = await SharedPreferences.getInstance();
    _currentPhone = prefs.getString('phone') ?? '';
  }

  bool isShowTitleCheckAll() {
    return (_listFriend.isNotEmpty && _listFriend.length > 1) ||
          (_listReferrer.isNotEmpty && _listReferrer.length > 1) ||
          (_listReferrer.isNotEmpty && _listFriend.isNotEmpty);
  }

  bool isHasData() => _listReferrer.isNotEmpty || _listFriend.isNotEmpty;
}
