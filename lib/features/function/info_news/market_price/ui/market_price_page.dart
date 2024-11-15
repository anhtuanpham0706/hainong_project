import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:graphic/graphic.dart';
import 'package:clock/clock.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/models/item_option.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/content_shadow.dart';
import 'package:hainong/common/ui/core_button_custom.dart';
import 'package:hainong/common/ui/empty_search.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/title_helper.dart';
import '../model/market_price_history_model.dart';
import 'market_price_create_report_page.dart';
import 'market_price_item.dart';
import '../market_price_bloc.dart';
import '../model/market_price_model.dart';

class MarketPricePage extends BasePage {
  MarketPricePage({bool hasBack = true, Key? key}) : super(key: key, pageState: _MarketPricePageState(hasBack));
}

class _MarketPricePageState extends BasePageState {
  final TextEditingController _ctrKeyword = TextEditingController();
  final FocusNode _fcKeyword = FocusNode();
  final ScrollController _scroller = ScrollController();
  final List<MarketPriceModel> _list = [MarketPriceModel(), MarketPriceModel()];
  String _time = '', _type = 'all', _keyword = '';
  final ItemModel _location = ItemModel();
  final List<ItemModel> _provinces = [ItemModel(id: '', name: 'Tất cả')];
  int _tabIndex = 3;
  List? data;
  bool hasBack, _isLoading = false;
  _MarketPricePageState(this.hasBack);

  @override
  void dispose() {
    _list.clear();
    _provinces.clear();
    _scroller.removeListener(_listenScroller);
    _scroller.dispose();
    _ctrKeyword.dispose();
    _fcKeyword.dispose();
    super.dispose();
  }

  @override
  void clearFocus() {
    _fcKeyword.unfocus();
  }

  @override
  void initState() {
    bloc = MarketPriceBloc();
    bloc!.stream.listen((state) {
      if (state is LoadListState) {
        if (isResponseNotError(state.resp)) _list.addAll(state.resp.data.list);
        if (_list.length == 2 && (bloc as MarketPriceBloc).page == 0) _list.add(MarketPriceModel());
        _isLoading = false;
      } else if (state is ChangeInterestState && isResponseNotError(state.resp, passString: true)) {
        _refresh(state.index!);
      } else if (state is LoadProvinceState) {
        _provinces.addAll(state.resp.data.list);
        if (state.showLocation) _showLocations(loadProvince: false);
      } else if (state is ReportState && isResponseNotError(state.resp, passString: true)) {
        UtilUI.showCustomDialog(context, MultiLanguage.get('msg_feedback_success'), title: MultiLanguage.get('ttl_alert'));
      } else if (state is LoadChartsState && state.data != null) {
        data = state.data;
      }
    });
    super.initState();
    _loadNext();
    bloc!.add(LoadProvinceEvent());
    bloc!.add(LoadChartsEvent());
    _scroller.addListener(_listenScroller);
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Scaffold(
    appBar: AppBar(elevation: 0, centerTitle: true, titleSpacing: 0,
        automaticallyImplyLeading: hasBack,
        title: hasBack ? const TitleHelper('lbl_market_price', url: 'https://help.hainong.vn/muc/2') : Row(children: [
          SizedBox(width: 40.sp),
          ButtonImageWidget(200, () => UtilUI.goBack(context, false),
              Row(children: [
                Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back, color: Colors.white),
                Image.asset('assets/images/ic_logo.png', width: 200.sp, fit: BoxFit.fill)
              ])),
          const Expanded(child: TitleHelper('lbl_market_price', url: 'https://help.hainong.vn/muc/2')),
          SizedBox(width: 100.sp)
        ]),
        actions: [
          Row(children: [
            Padding(padding: EdgeInsets.only(right: 40.sp),
                child: ButtonImageWidget(100, _shareToApp, Image.asset('assets/images/ic_share.png', color: Colors.white, width: 52.sp))),
            if (constants.isLogin) Padding(padding: EdgeInsets.only(right: 40.sp),
                child: ButtonImageWidget(100, _createReport, Image.asset('assets/images/ic_add.png', color: Colors.white, width: 52.sp)))
          ])
        ]), backgroundColor: const Color(0xFFF1F1F1),
    body: GestureDetector(onTapDown: (value) => clearFocus(),
      child: Stack(children: [
        Column(children: [
          Container(color: StyleCustom.primaryColor, child: BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is ChangeTabState,
              builder: (context, state) {
                if (state is ChangeTabState) _tabIndex = state.index;
                return Row(children: [
                  TabItem('lbl_all', 3, _tabIndex == 3, _changeTabIndex),
                  TabItem('lbl_fertilizer', 0, _tabIndex == 0, _changeTabIndex),
                  TabItem('lbl_agricultural', 1, _tabIndex == 1, _changeTabIndex),
                  if(constants.isLogin) TabItem('lbl_interest', 2, _tabIndex == 2, _changeTabIndex)
                ]);
              })),
          Expanded(child: RefreshIndicator(child: BlocBuilder(bloc: bloc, buildWhen: (oldState, newState) => newState is LoadListState,
              builder: (context, state) => ListView.separated(
                  dragStartBehavior: DragStartBehavior.down, physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scroller, padding: EdgeInsets.all(40.sp), itemCount: _list.length,
                  separatorBuilder: (context, index) => SizedBox(height: 20.sp),
                  itemBuilder: (context, index) {
                    if (index > 1) {
                      if (index > _list.length - 1) return const SizedBox();
                      return _list[index].id > 0 ? MarketPriceItem(index,
                          _list[index], () => bloc!.add(LoadChartsEvent()),
                          (){}, _changeInterest, bloc as MarketPriceBloc,
                          funReloadList: () => _loadNext(reload: true)) :
                      BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is LoadChartsState,
                        builder: (context, state) => SizedBox(height: data != null && data!.isNotEmpty ? 0.25.sh : 0.6.sh,
                          child: EmptySearch(_keyword)));
                    }
                    if (index == 1) {
                      return ContentShadow(
                          Row(children: [
                            CoreButtonCustom(() {
                              clearFocus();
                              _loadNext(reload: true);
                            },
                              Icon(Icons.search, color: StyleCustom.primaryColor, size: 48.sp),
                              padding: EdgeInsets.all(10.sp),
                              sizeRadius: 40.sp,
                            ),
                            Expanded(
                                child: TextField(onSubmitted: (value) {
                                  //clearFocus();
                                  _loadNext(reload: true);
                                }, controller: _ctrKeyword, focusNode: _fcKeyword,
                                    style: TextStyle(fontSize: 36.sp, color: const Color(0xFF494747)),
                                    textInputAction: TextInputAction.search,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.only(left: 8.sp, right: 24.sp),
                                        hintStyle: TextStyle(fontSize: 36.sp, color: const Color(0xFF494747)),
                                        hintText: MultiLanguage.get('lbl_product2'),
                                        filled: true,
                                        fillColor: Colors.transparent,
                                        border: InputBorder.none))),
                            _Line(),
                            Icon(Icons.location_on_outlined, color: StyleCustom.primaryColor, size: 48.sp),
                            Expanded(
                                child: CoreButtonCustom(
                                    _showLocations,
                                    Row(children: [
                                      Expanded(
                                          child: BlocBuilder(
                                              bloc: bloc,
                                              buildWhen: (oldS, newS) => newS is SetLocationState || newS is ResetSearchState,
                                              builder: (context, state) => LabelCustom(
                                                  _location.name.isEmpty ? MultiLanguage.get('lbl_location') : _location.name,
                                                  size: 36.sp,
                                                  color: const Color(0xFF494747),
                                                  weight: FontWeight.normal))),
                                      Icon(Icons.arrow_drop_down, color: const Color(0xFF919191), size: 48.sp)
                                    ]),
                                    padding: EdgeInsets.all(20.sp))),
                            _Line(),
                            Expanded(
                                child: CoreButtonCustom(
                                    _selectDate,
                                    BlocBuilder(
                                        bloc: bloc,
                                        buildWhen: (oldS, newS) => newS is SetDateState || newS is ResetSearchState,
                                        builder: (context, state) => LabelCustom(_time.isEmpty ? MultiLanguage.get('lbl_time') : _time,
                                            size: 36.sp, color: const Color(0xFF494747), weight: FontWeight.normal, line: 1)),
                                    padding: EdgeInsets.all(20.sp))),
                            CoreButtonCustom(
                              _resetSearch,
                              Icon(Icons.highlight_off, color: const Color(0xFFF56464), size: 48.sp),
                              padding: EdgeInsets.all(10.sp),
                              sizeRadius: 40.sp,
                            )
                          ]),
                          padding: EdgeInsets.all(20.sp),
                          margin: EdgeInsets.only(bottom: 20.sp),
                          radius: 16.sp);
                    }
                    return BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is LoadChartsState,
                        builder: (context, state) {
                          if (data != null && data!.isNotEmpty) {
                            List<Widget> titles = [];
                            ColorAttr? color;
                            double width = 0.9.sw;
                            int index = 0;
                            data![0].result.forEach((ele) {
                              titles.add(_Item(ele.title, index));
                              index++;
                            });

                            //if (data![0].date_range.length > 7) width += (data![0].date_range.length - 1) * 0.05.sw;
                            //if (data![1].length > 7) width += (data![1].length - 1) * 0.05.sw;
                            //if (data![0].result == 1) width = 0.9.sw;

                            if (data![0].result.length > 1) {
                              color = ColorAttr(variable: 'name',
                                  values: [Colors.red, Colors.blue, Colors.yellow, Colors.green, Colors.orange],
                                  onSelection: {
                                    'groupMouse': {false: (color) => color.withAlpha(100)},
                                    'groupTouch': {false: (color) => color.withAlpha(100)}
                                  }
                              );
                            }

                            return ContentShadow(Column(children: [
                              Container(child: Wrap(children: titles, runSpacing: 16.sp, spacing: 16.sp),
                                  decoration: BoxDecoration(color: const Color(0xFFF7F7F7),
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(16.sp))),
                                  padding: EdgeInsets.all(32.sp), width: 1.sw),
                              SingleChildScrollView(scrollDirection: Axis.horizontal, child:
                              Container(
                                  margin: EdgeInsets.fromLTRB(40.sp, 0, 40.sp, 20.sp), width: width, height: 0.28.sh,
                                  child: data![0].result.length > 1 ? Chart(data: data![1],
                                      rebuild: true,
                                      variables: {
                                        'date': Variable(accessor: (Map map) => map['date'] as String,
                                            scale: OrdinalScale(formatter: (v) =>
                                                Util.dateToString(
                                                    Util.stringToDateTime(v, pattern: 'dd/MM/yyyy HH:mm'),
                                                    pattern: 'dd/MM'), tickCount: data![1].length > 7 ? 8 : data![1].length)
                                        ),
                                        'points': Variable(accessor: (Map map) => map['points'] as num,
                                            scale: LinearScale(formatter: (v) => Util().formatNum(v), min: .0, nice: true)),
                                        'name': Variable(accessor: (Map map) => map['name'] as String),
                                      },
                                      elements: [
                                        LineElement(position: Varset('date') * Varset('points') / Varset('name'),
                                            shape: ShapeAttr(value: BasicLineShape(smooth: true)),
                                            size: SizeAttr(value: 2),
                                            color: color),
                                        PointElement(size: SizeAttr(value: 10), color: color)
                                      ],
                                      padding: (size) => EdgeInsets.fromLTRB(160.sp, 80.sp, 80.sp, 160.sp),
                                      axes: [
                                        AxisGuide(label: LabelStyle(TextStyle(fontSize: 28.sp, color: Colors.black),
                                            offset: const Offset(0, 20)), tickLine: TickLine(length: 4)),
                                        AxisGuide(label: LabelStyle(TextStyle(fontSize: 32.sp, color: Colors.red),
                                            align: Alignment.centerLeft, offset: const Offset(-10, 0)),
                                            grid: StrokeStyle(color: Colors.black26, width: 0.8))
                                      ],
                                      selections: {
                                        'tooltipMouse': PointSelection(on: {GestureType.hover},
                                            devices: {PointerDeviceKind.mouse}),
                                        'groupMouse': PointSelection(on: {GestureType.hover},
                                            variable: 'name', devices: {PointerDeviceKind.mouse}),
                                        'tooltipTouch': PointSelection(on: {
                                          GestureType.scaleUpdate, GestureType.tapDown,
                                          GestureType.longPressMoveUpdate},
                                            devices: {PointerDeviceKind.touch}),
                                        'groupTouch': PointSelection(on: {
                                          GestureType.scaleUpdate, GestureType.tapDown,
                                          GestureType.longPressMoveUpdate},
                                            variable: 'name', devices: {PointerDeviceKind.touch})
                                      },
                                      tooltip: TooltipGuide(
                                          selections: {'tooltipTouch', 'tooltipMouse'},
                                          followPointer: [true, true],
                                          element: 0,
                                          renderer: UtilUI().tooltip2)) :
                                  Chart(rebuild: true,
                                      data: data![0].result.first.details.list,
                                      elements: [
                                        LineElement(color: ColorAttr(value: Colors.red), size: SizeAttr(value: 4.sp),
                                            shape: ShapeAttr(value: BasicLineShape(smooth: true)))
                                      ],
                                      padding: (size) => EdgeInsets.fromLTRB(160.sp, 40.sp, 160.sp, 120.sp),
                                      axes: [
                                        AxisGuide(label: LabelStyle(TextStyle(fontSize: 28.sp, color: Colors.black),
                                            offset: const Offset(0, 20)), tickLine: TickLine(length: 4)),
                                        AxisGuide(label: LabelStyle(TextStyle(fontSize: 32.sp, color: Colors.red),
                                            align: Alignment.centerLeft, offset: const Offset(-10, 0)),
                                            grid: StrokeStyle(color: Colors.black26, width: 0.8))
                                      ],
                                      variables: {
                                        'created_at': Variable(accessor: (MkPHistoryModel v) =>
                                        v.created_at, scale: OrdinalScale(
                                            maxTickCount: data![0].result.first.details.list.length,
                                            formatter: (v) => Util.strDateToString(v, pattern: 'dd/MM'))),
                                        'price': Variable(accessor: (MkPHistoryModel v) => v.price,
                                            scale: LinearScale(formatter: (v) => Util().formatNum(v), min: .0, nice: true)),
                                        'title': Variable(accessor: (MkPHistoryModel v) => v.title)
                                      },
                                      selections: {'tap': PointSelection(on: {GestureType.tap}, dim: 1)},
                                      tooltip: TooltipGuide(renderer: UtilUI().tooltip),
                                      annotations: UtilUI().getPoints(data![0].result.first.details.list)
                                  )))
                            ], mainAxisSize: MainAxisSize.min),
                                padding: EdgeInsets.zero, radius: 16.sp,
                                margin: EdgeInsets.only(bottom: 40.sp));
                          }
                          return const SizedBox();
                        });
                  })),
              onRefresh: () async => _loadNext(reload: true)))
        ]),
        Loading(bloc, bgColor: Colors.transparent)
      ])));

  void _selectOption(BuildContext context) async {
    List<ItemOption> options = [];
    options.add(ItemOption('assets/images/ic_share.png', MultiLanguage.get('ttl_share_price'), () {
      _shareToApp();
    }, false));
    if(constants.isLogin) options.add(ItemOption('assets/images/ic_add.png', MultiLanguage.get('lbl_contribute'),_createReport, false));

    UtilUI.showOptionDialog2(context, MultiLanguage.get('ttl_option'), options);
  }

  // void _selectOptionSharePrice(BuildContext context) async{
  //   final List<ItemModel> options = [
  //     ItemModel(id: 'share_app', name: 'Chia sẻ qua ứng dụng khác'),
  //     ItemModel(id: 'share_post', name: 'Chia sẻ lên tường của tôi')
  //   ];
  //   UtilUI.showOptionDialog(context, MultiLanguage.get('ttl_option'), options, '').then((value) {
  //     if (value != null) value.id == 'share_app' ? _shareToApp() : _shareToPost();
  //   });
  //   Util.trackActivities(path: 'News Detail -> Share Menu -> Open Option Dialog');
  //
  //
  // }
  //
  // _shareToPost() {
  //
  // }

  _shareToApp() async {
    //UtilUI.goBack(context, true);
    if (await UtilUI().alertVerifyPhone(context)) return;
    UtilUI.shareTo(context, '/modules/gia-ca-thi-truong/', 'Market Price List -> Option Share Dialog -> Choose "Share"', 'market_price');
  }

  void _changeTabIndex(int index) {
    if (index == 3) {
      if (_type == 'all') return;
      _type = 'all';
      Util.trackActivities('market_price', path: 'Market Price Screen -> Show Tab Tất cả');
    }
    if (index == 0) {
      if (_type == 'fertilizer') return;
      _type = 'fertilizer';
      Util.trackActivities('market_price', path: 'Market Price Screen -> Show Tab Phân bón');
    }
    if (index == 1) {
      if (_type == 'agricultural') return;
      _type = 'agricultural';
      Util.trackActivities('market_price', path: 'Market Price Screen -> Show Tab Nông sản');
    }
    if (index == 2) {
      Util.trackActivities('market_price', path: 'Market Price Screen -> Show Tab giá cả quan tâm');
      if (!constants.isLogin) {
        UtilUI.showCustomDialog(context, MultiLanguage.get(languageKey.msgLoginOrCreate));
        return;
      }
      if (_type.isEmpty) return;
      _type = '';
    }
    bloc!.add(ChangeTabEvent(index));
    _resetSearch();
  }

  void _resetSearch() {
    _ctrKeyword.text = '';
    _time = '';
    _location.id = '';
    _location.name = '';
    bloc!.add(ResetSearchEvent());
    clearFocus();
    _loadNext(reload: true);
  }

  void _showLocations({bool loadProvince = true}) {
    clearFocus();
    if (_provinces.isEmpty) {
      if (loadProvince) bloc!.add(LoadProvinceEvent(showLocation: true));
      return;
    }
    UtilUI.showOptionDialog(context, MultiLanguage.get(languageKey.lblProvince), _provinces, _location.id, hasClose: true).then((value) {
      if (value != null) _setLocation(value);
    });
  }

  void _setLocation(ItemModel value) {
    if (_location.id == value.id) return;
    _location.id = value.id;
    _location.name = value.name;
    bloc!.add(SetLocationEvent());
    _loadNext(reload: true);
  }

  void _selectDate() {
    clearFocus();
    try {
      final now = DateTime.now();
      String current = _time;
      if (_time.isEmpty) current = Util.dateToString(now, pattern: 'dd/MM/yyyy', locale: constants.localeVI);
      DatePicker.showDatePicker(context,
          minTime: const Clock().yearsAgo(10),
          maxTime: now,
          showTitleActions: true,
          onConfirm: (DateTime date) => _setDate(date),
          currentTime: Util.stringToDateTime(current, pattern: 'dd/MM/yyyy'),
          locale: LocaleType.vi);
    } catch (_) {}
  }

  void _setDate(DateTime date) {
    _time = Util.dateToString(date, pattern: 'dd/MM/yyyy', locale: constants.localeVI);
    bloc!.add(SetDateEvent());
    _loadNext(reload: true);
  }

  void _listenScroller() {
    if ((bloc as MarketPriceBloc).page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) _loadNext();
  }

  void _loadNext({bool reload = false}) {
    if (_isLoading) return;
    _keyword = _ctrKeyword.text;
    if (reload) {
      _list.removeRange(2, _list.length);
      (bloc as MarketPriceBloc).page = 1;
    }
    _isLoading = true;
    bloc!.add(LoadListEvent(_ctrKeyword.text.trim(), _time, _location.id, _type));
  }

  void _createReport() async {
    //UtilUI.goBack(context, false);
    if (await UtilUI().alertVerifyPhone(context)) return;
    UtilUI.goToNextPage(context, MarketPriceCreateReportPage(), funCallback: (value) {
      if (value) {
        _loadNext(reload: true);
      }
    });
  }

  void _changeInterest(int index) async {
    if (await UtilUI().alertVerifyPhone(context)) return;
    bloc!.add(ChangeInterestEvent(_list[index].id, _list[index].user_liked, index: index));
    Util.trackActivities('market_price', path: 'Market price Screen -> Tap interest button');
  }

  void _refresh(int index) {
    _tabIndex == 2 ? _loadNext(reload: true) : _list[index].user_liked = !_list[index].user_liked;
    data?.clear();
    bloc!.add(LoadChartsEvent());
  }
}

class TabItem extends StatelessWidget {
  final String label;
  final int index;
  final bool active;
  final Function funChange;

  const TabItem(this.label, this.index, this.active, this.funChange, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Expanded(child: CoreButtonCustom(() => funChange(index),
    Column(children: [
          LabelCustom(MultiLanguage.get(label),
              weight: active ? FontWeight.w700 : FontWeight.w400,
              color: active ? Colors.white : const Color(0xFFEAEAEA),
              size: 42.sp),
          if (active)
            Divider(
              height: 12.sp,
              color: Colors.white,
              thickness: 6.sp,
            )
        ], mainAxisSize: MainAxisSize.min),
    margin: EdgeInsets.symmetric(horizontal: 30.sp), padding: EdgeInsets.symmetric(vertical: 40.sp)
  ));
}

class _Line extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.sp), color: Colors.grey.shade300),
      height: 100.sp,
      width: 3.sp, margin: EdgeInsets.only(right: 10.sp));
}

class _Item extends StatelessWidget {
  final String title;
  final int index;

  const _Item(this.title, this.index, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(color: getColor(), width: 24.sp, height: 24.sp, margin: EdgeInsets.only(right: 8.sp)),
        UtilUI.createLabel(title, fontWeight: FontWeight.normal, fontSize: 30.sp, color: const Color(0xFF3A3A3A))
      ], mainAxisSize: MainAxisSize.min);

  Color getColor() {
    switch (index) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.green;
      case 4:
        return Colors.orange;
    }
    return Colors.transparent;
  }
}
