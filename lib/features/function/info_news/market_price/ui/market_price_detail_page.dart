import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:graphic/graphic.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/box_dec_custom.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/content_shadow.dart';
import 'package:hainong/common/ui/core_button_custom.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/features/function/info_news/news/news_bloc.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import '../model/market_price_history_model.dart';
import '../market_price_bloc.dart';
import '../model/market_price_model.dart';
import 'market_price_create_report_page.dart';
import 'market_price_history_item.dart';

class MarketPriceDtlPage extends BasePage {
  final MarketPriceModel item;
  final Function funReloadChart;
  final Function? funReloadList;

  MarketPriceDtlPage(this.item, this.funReloadChart, {this.funReloadList, Key? key})
      : super(key: key, pageState: _MarketPriceDtlPageState());
}

class _MarketPriceDtlPageState extends BasePageState {
  final TextEditingController _ctrFeedback = TextEditingController();
  final ScrollController _scroller = ScrollController();
  final List<MkPHistoryModel> _list = [MkPHistoryModel()];
  final List<MkPHistoryModel> _chartData = [];
  late MarketPriceModel model;
  late MarketPriceModel item;
  late IconData icon;
  late String price;
  final ItemModel _filterTime = ItemModel(id: '6', name: '1 tuần');
  String _unit = '';
  bool _checkPostAuto = false;

  @override
  void dispose() {
    _list.clear();
    _chartData.clear();
    _scroller.removeListener(_listenScroller);
    _scroller.dispose();
    _ctrFeedback.dispose();
    super.dispose();
  }

  @override
  void initState() {
    initData((widget as MarketPriceDtlPage).item);
    bloc = MarketPriceBloc();
    bloc!.add(CheckProcessPostInMarketEvent());
    bloc!.stream.listen((state) {
      if (state is LoadHistoryListState && isResponseNotError(state.resp, showError: false)) {
        _list.addAll(state.resp.data.list);
      } else if (state is ChangeInterestState && isResponseNotError(state.resp, passString: true)) {
        final page = widget as MarketPriceDtlPage;
        page.item.user_liked = !page.item.user_liked;
        setState(() {});
        page.funReloadChart();
        if (page.funReloadList != null) page.funReloadList!();
      } else if (state is ReportState && isResponseNotError(state.resp, passString: true)) {
        UtilUI.showCustomDialog(context, MultiLanguage.get('msg_report_price'), title: MultiLanguage.get('ttl_alert'));
      } else if (state is CreatePostState && isResponseNotError(state.response)) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(MultiLanguage.get('msg_'+(_checkPostAuto?'':'in')+'active_process_post_auto'))));
      } else if(state is CheckProcessPostInMarketState){
        _checkPostAuto = state.isActive ?? false;
      } else if (state is LoadChartsState) {
        if (_chartData.isNotEmpty) _chartData.clear();
        if (state.data != null && state.data!.isNotEmpty) _chartData.addAll(state.data!.first.details.list);
      }
    });
    super.initState();
    _loadNext();
    _loadChart();
    _scroller.addListener(_listenScroller);
  }

  void initData(MarketPriceModel model){
    item = (widget as MarketPriceDtlPage).item;
    icon = Icons.swap_vert;
    if (item.lastDetail.price_difference > 0) icon = Icons.north;
    if (item.lastDetail.price_difference < 0) icon = Icons.south;
    _unit =' đ/${(widget as MarketPriceDtlPage).item.unit}';
    price = '';
    price = Util.doubleToString(item.lastDetail.price);
    price += _unit;
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    return Scaffold(
        appBar: AppBar(title: UtilUI.createLabel(item.title, fontSize: 42.sp), elevation: 0, centerTitle: true, actions: [
          IconButton(
              onPressed: () => _selectOptionSharePrice(context),
              icon: Image.asset('assets/images/ic_share.png', width: 48.sp, height: 48.sp, color: Colors.white))
        ]),
        backgroundColor: StyleCustom.primaryColor,
        body: GestureDetector(
            onTapDown: (value) => clearFocus(),
            child: Stack(children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: RefreshIndicator(
                  child: BlocBuilder(
                      bloc: bloc,
                      buildWhen: (oldState, newState) => newState is LoadHistoryListState,
                      builder: (context, state) => ListView.builder(
                          dragStartBehavior: DragStartBehavior.down,
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: _scroller,
                          padding: EdgeInsets.only(bottom: 40.sp),
                          itemCount: _list.length,
                          itemBuilder: (context, index) {
                            if (index == 0) return _bodyOnTheList(item, icon, price);
                            return Container(
                              width: 1.sw,
                              margin: EdgeInsets.fromLTRB(40.sp, 0, 40.sp, 0),
                              padding: EdgeInsets.symmetric(horizontal: 40.sp),
                              decoration: BoxDecoration(
                                borderRadius: (index == _list.length - 1) ? BorderRadius.only(
                                  bottomRight: Radius.circular(10.sp),
                                  bottomLeft: Radius.circular(10.sp),
                                ) : null,
                                color: Colors.white,
                              ),
                              child: MarketPriceHistoryItem(_list[index],_unit, _report),
                            );
                          })),
                  onRefresh: () async => _loadNext(reload: true),
                ),
              ),
              Loading(bloc, bgColor: Colors.transparent)
            ])));
  }

  Widget _bodyOnTheList(MarketPriceModel item, IconData icon, String price) =>
    Column(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(15.sp),
        child: FadeInImage.assetNetwork(
            imageErrorBuilder: (_, __, ___) => UtilUI.imageDefault(width:  1.sw * 3 / 4),
            imageScale: 0.5,
            placeholder: 'assets/images/ic_default.png',
            width:  1.sw * 3 / 4,
            image: Util.getRealPath(item.image),
            fit: BoxFit.cover),
      ),
      Container(padding: EdgeInsets.all(48.sp), child: Row(children: [
            Expanded(child: Row(children: [
              Icon(Icons.location_on, color: Colors.white, size: 36.sp),
              const SizedBox(width: 2),
              Flexible(child: UtilUI.createLabel(item.province_name, line: 2, fontWeight: FontWeight.normal, fontSize: 36.sp))
            ], mainAxisAlignment: MainAxisAlignment.center)),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child:
                UtilUI.createLabel(Util.strDateToString(item.last_price_updated_at, pattern: 'dd/MM/yyyy'),
                    fontWeight: FontWeight.normal, fontSize: 36.sp, line: 1, textAlign: TextAlign.center)),
            Expanded(child: Row(children: [
              Icon(icon, color: Colors.white, size: item.lastDetail.price_difference != 0 ? 38.sp : 48.sp),
              Flexible(child: UtilUI.createLabel(Util.doubleToString(item.lastDetail.price_difference) + _unit, line: 2, fontWeight: FontWeight.normal, fontSize: 36.sp))
            ], mainAxisAlignment: MainAxisAlignment.center))
          ], mainAxisAlignment: MainAxisAlignment.center)),
      if (price.isNotEmpty)
        Padding(
            child: UtilUI.createLabel(price, fontWeight: FontWeight.w500, fontSize: 72.sp),
            padding: EdgeInsets.only(bottom: 48.sp)),
      BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is LoadChartsState,
        builder: (context, state) {
          return ContentShadow(Column(children: [
            Padding(child: Row(children: [
              Expanded(child: UtilUI.createLabel(item.title, fontWeight: FontWeight.normal,
                  fontSize: 42.sp, color: const Color(0xFF3A3A3A))),
              if(constants.isLogin) Row(children: [
                CoreButtonCustom(_changeInterest, BlocBuilder(bloc: bloc,
                    buildWhen: (oldS, newS) => newS is ChangeInterestState,
                    builder: (context, state) {
                      return Image.asset('assets/images/v5/ic_bookmark.png',
                          color: (widget as MarketPriceDtlPage).item.user_liked ? const Color(0xFF1AAD80) : null,
                          height: 42.sp);
                    }), sizeRadius: 50, padding: EdgeInsets.all(10.sp)),
                UtilUI.createLabel(MultiLanguage.get('lbl_interest'),
                    fontWeight: FontWeight.normal, fontSize: 42.sp, color: const Color(0xFF1AAD80))
              ])
            ]), padding: EdgeInsets.all(40.sp)),
            const Divider(height: 1),
            Padding(padding: EdgeInsets.fromLTRB(40.sp, 40.sp, 40.sp, 0), child: Row(children: [
              _option(Util.dateToString(DateTime.now().add(Duration(days: -int.parse(_filterTime.id))),
                  pattern: 'dd/MM/yyyy'), Icons.date_range, hasExp: true),
              _option(Util.dateToString(DateTime.now(), pattern: 'dd/MM/yyyy'), Icons.date_range, hasExp: true),
              ButtonImageWidget(5, _showFilterTime, _option(_filterTime.name, Icons.arrow_drop_down))
            ])),
            SingleChildScrollView(padding: EdgeInsets.zero, scrollDirection: Axis.horizontal,
                child: SizedBox(width: 1.sw, height: 0.38.sh, child: _uiChart()))
          ], mainAxisSize: MainAxisSize.min),
              padding: EdgeInsets.zero, radius: 16.sp,
              margin: EdgeInsets.fromLTRB(40.sp, 0, 40.sp, 40.sp));
        }),
      if(constants.isLogin) ContentShadow(
          CoreButtonCustom(
              _reportUpdatePrice,
              Row(children: [
                Icon(Icons.edit, color: const Color(0xFF1AAD80), size: 38.sp),
                UtilUI.createLabel(MultiLanguage.get('lbl_contribute'),
                    fontWeight: FontWeight.normal, fontSize: 42.sp, color: const Color(0xFF1AAD80))
              ], mainAxisAlignment: MainAxisAlignment.center),
              padding: EdgeInsets.all(24.sp)),
          padding: EdgeInsets.zero),
      Container(
        width: 1.sw,
        margin: EdgeInsets.fromLTRB(40.sp, 0, 40.sp, 0),
        padding: EdgeInsets.symmetric(horizontal: 40.sp),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10.sp),
              topLeft: Radius.circular(10.sp),
            ),
            color: Colors.white),
        child: Column(children: [
          Padding(
              child: UtilUI.createLabel(MultiLanguage.get('lbl_price_his'),
                  fontWeight: FontWeight.normal, fontSize: 48.sp, color: const Color(0xFF313131)),
              padding: EdgeInsets.all(32.sp)),
          const Divider(height: 1),
          Padding(
              child: Row(children: [
                Expanded(
                    flex: 2,
                    child: UtilUI.createLabel('Năm',
                        fontWeight: FontWeight.normal,
                        fontSize: 30.sp,
                        textAlign: TextAlign.center,
                        color: const Color(0xFFA8A8A8))),
                Expanded(
                    flex: 7,
                    child: UtilUI.createLabel('Giá',
                        fontWeight: FontWeight.normal,
                        fontSize: 30.sp,
                        textAlign: TextAlign.center,
                        color: const Color(0xFF7C7C7C))),
                const Expanded(flex: 1, child: SizedBox()),
                const Expanded(flex: 1, child: SizedBox())
              ]),
              padding: EdgeInsets.fromLTRB(20.sp, 20.sp, 20.sp, 20.sp)),
        ]),
      )
    ]);

  Widget _uiChart() {
    if (_chartData.length == 1) {
      return Chart(rebuild: true,
          data: _chartData,
          elements: [
            LineElement()
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
            'created_at': Variable(accessor: (MkPHistoryModel v) => v.created_at, scale: OrdinalScale(maxTickCount: 1,
                formatter: (v) => Util.strDateToString(v, pattern: 'dd/MM'))),
            'price': Variable(accessor: (MkPHistoryModel v) => v.price,
                scale: LinearScale(formatter: (v) => Util().formatNum(v),
                    ticks: [
                      0.0,
                      _chartData[0].max_price * 0.25,
                      _chartData[0].max_price * 0.5,
                      _chartData[0].max_price * 0.75,
                      _chartData[0].max_price
                    ]
                )),
            'title': Variable(accessor: (MkPHistoryModel v) => v.title)
          },
          selections: {'tap': PointSelection(on: {GestureType.tap}, dim: 1)},
          tooltip: TooltipGuide(renderer: UtilUI().tooltip),
          crosshair: CrosshairGuide(followPointer: [false, true]),
          annotations: UtilUI().getPoints(_chartData, colorPoint: Colors.blue)
      );
    }

    final List<num> dates = [];
    num from = 0, to = 0, delta = 0;

    final now = DateTime.now();
    dynamic temp = DateTime(now.year, now.month, now.day);
    to = temp.millisecondsSinceEpoch;
    temp = temp.add(Duration(days: -int.parse(_filterTime.id)));
    from = temp.millisecondsSinceEpoch;
    delta = (to - from) / 6;

    dates.add(from);
    dates.add(from + delta);
    dates.add(from + delta * 2);
    dates.add(from + delta * 3);
    dates.add(from + delta * 4);
    dates.add(from + delta * 5);
    dates.add(to);

    if (_chartData.length > 1) {
      temp = _chartData[_chartData.length - 1].created_at2;
      if (temp <= dates[1]) dates.insert(0, from - delta);
      temp = _chartData[0].created_at2;
      if (dates[dates.length - 1] <= temp) dates.add(to + delta);

      return Chart(rebuild: true,
        data: _chartData,
        elements: [
          /*AreaElement(shape: ShapeAttr(value: BasicAreaShape(smooth: true)),
                color: ColorAttr(value: Colors.blue.withAlpha(20))),*/
          LineElement(color: ColorAttr(value: Colors.blue), size: SizeAttr(value: 2),
              shape: ShapeAttr(value: BasicLineShape(smooth: true)))
        ],
        padding: (size) => EdgeInsets.fromLTRB(200.sp, 40.sp, 160.sp, 120.sp),
        axes: [
          AxisGuide(label: LabelStyle(TextStyle(fontSize: 28.sp, color: Colors.black),
              offset: const Offset(0, 20)), tickLine: TickLine(length: 4)),
          AxisGuide(label: LabelStyle(TextStyle(fontSize: 32.sp, color: Colors.red),
              align: Alignment.centerLeft, offset: const Offset(-10, 0)),
              grid: StrokeStyle(color: Colors.black26, width: 0.8))
        ],
        variables: {
          'created_at2': Variable(accessor: (MkPHistoryModel v) => v.created_at2,
              scale: LinearScale( //tickCount: _chartData.length > 5 ? 6 : _chartData.length, min: from, max: to, nice: true,
                  formatter: (fm) =>
                      Util.dateToString(DateTime.fromMillisecondsSinceEpoch(fm.toInt()), pattern: 'dd/MM'),
                  ticks: dates)),
          'price': Variable(accessor: (MkPHistoryModel v) => v.price,
              scale: LinearScale(formatter: (fm) => Util().formatNum(fm),
                  ticks: [
                    0.0,
                    _chartData[0].max_price * 0.25,
                    _chartData[0].max_price * 0.5,
                    _chartData[0].max_price * 0.75,
                    _chartData[0].max_price
                  ]
              )),
          'created_at': Variable(accessor: (MkPHistoryModel v) => v.created_at),
          'title': Variable(accessor: (MkPHistoryModel v) => v.title)
        },
        selections: {'tap': PointSelection(on: {GestureType.tap}, dim: 1)},
        tooltip: TooltipGuide(renderer: UtilUI().tooltip),
        crosshair: CrosshairGuide(followPointer: [false, true]),
        annotations: UtilUI().getPoints(_chartData, colorPoint: Colors.blue, useDate2: true)
      );
    }

    return Chart(rebuild: true,
        data: [
          MkPHistoryModel(created_at2: dates[1].toInt()),
          MkPHistoryModel(created_at2: dates[5].toInt()),
        ],
        elements: [
          LineElement(color: ColorAttr(value: Colors.transparent), size: SizeAttr(value: 0))
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
          'created_at2': Variable(accessor: (MkPHistoryModel v) => v.created_at2, scale: LinearScale(ticks: dates,
                  formatter: (fm) => Util.dateToString(DateTime.fromMillisecondsSinceEpoch(fm.toInt()), pattern: 'dd/MM'))),
          'price': Variable(accessor: (MkPHistoryModel v) => v.price, scale: LinearScale(formatter: (fm) => Util().formatNum(fm),
                  ticks: [0.0, 25000.0, 50000.0, 75000.0, 100000.0]))
        }
    );
  }

  Widget _option(String label, IconData icon, {bool hasExp = false}) {
    final labelUI = LabelCustom(label, size: 38.sp, color: Colors.black, weight: FontWeight.w400);
    final temp = Container(margin: hasExp ? EdgeInsets.only(right: 20.sp) : null,
        padding: EdgeInsets.fromLTRB(20.sp, 20.sp, 10.sp, 20.sp),
        decoration: BoxDecCustom(hasShadow: false, hasBorder: true, borderColor: Colors.grey),
        child: Row(children: [
          hasExp ? Expanded(child: labelUI) : labelUI,
          Icon(icon, size: 48.sp)
        ]));
    return hasExp ? Expanded(child: temp) : temp;
  }

  void _listenScroller() {
    if ((bloc as MarketPriceBloc).page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) _loadNext();
  }

  void _loadNext({bool reload = false}) {
    if (reload) {
      _list.removeRange(1, _list.length);
      (bloc as MarketPriceBloc).page = 1;
    }
    bloc!.add(LoadHistoryListEvent((widget as MarketPriceDtlPage).item.id, reload));
  }

  void _changeInterest() async {
    if (await UtilUI().alertVerifyPhone(context)) return;
    final item = (widget as MarketPriceDtlPage).item;
    bloc!.add(ChangeInterestEvent(item.id, item.user_liked));
    Util.trackActivities('market_price_detail', path: 'Market price detail Screen -> Tap interest button');
  }

  void _reportUpdatePrice() =>
      UtilUI.goToNextPage(context, MarketPriceCreateReportPage(marketPriceModel: (widget as MarketPriceDtlPage).item,isCreate: true,),
          funCallback: (value) {
        if (value) {
          _loadNext(reload: true);
          final reload = (widget as MarketPriceDtlPage).funReloadList;
          if(reload!=null){
            reload();
          }
        }
      });

  void _report(int PriceId) => SharedPreferences.getInstance().then((prefs) async {
        Util.trackActivities('market_price_detail', path: 'Market price detail Screen -> Open dialog feedback/quote');
        if (!constants.isLogin) {
          UtilUI.showCustomDialog(context, MultiLanguage.get(languageKey.msgLoginOrCreate));
          return;
        }
        if (await UtilUI().alertVerifyPhone(context)) return;
        UtilUI.showConfirmDialog(
                context, '', MultiLanguage.get('lbl_input_feedback_price'), MultiLanguage.get('lbl_input_feedback_price'),
                title: MultiLanguage.get('ttl_feedback_price'), showMsg: false)
            .then((value) {
          if (value != null && value is String) {
            final item = (widget as MarketPriceDtlPage).item;
            bloc!.add(ReportEvent(item.id, PriceId, value));
          }
          Util.trackActivities('market_price_detail', path: 'Market price detail Screen -> Send feedback');
        });
      });

  void _selectOptionSharePrice(BuildContext context) async {
    if (await UtilUI().alertVerifyPhone(context)) return;
    final List<ItemModel> options = [
      ItemModel(id: 'share_app', name: 'Chia sẻ qua ứng dụng khác'),
     if(constants.isLogin) ItemModel(id: 'share_post', name: 'Chia sẻ lên tường của tôi')
    ];
    UtilUI.showOptionDialog(context, MultiLanguage.get('ttl_option'), options, '').then((value) {
      if (value != null) value.id == 'share_app' ? _shareToApp() : _shareToPost();
    });
    Util.trackActivities('market_price_detail', path: 'News Detail -> Share Menu -> Open Option Dialog');
  }

  _shareToPost() {
    bloc!.add(CreatePostEvent('${Constants().domain}/modules/thong-tin-gia-ca-thi-truong/${(widget as MarketPriceDtlPage).item.id}'));
    Util.trackActivities('market_price_detail', path: 'Market Price Detail -> Tap Button Share To Social Screen');
  }

  void _shareToApp() => UtilUI.shareTo(context,
    '/modules/thong-tin-gia-ca-thi-truong/${(widget as MarketPriceDtlPage).item.id}',
    'Market Price Detail -> Option Share Dialog -> Choose "Share"', 'market_price_detail');

  void _showFilterTime() => UtilUI.showOptionDialog(context, 'Chọn mốc thời gian', [
    ItemModel(id: '6', name: '1 tuần'),
    ItemModel(id: '29', name: '1 tháng'),
    ItemModel(id: '89', name: '3 tháng'),
    ItemModel(id: '179', name: '6 tháng'),
  ], _filterTime.id).then((value) {
    if (value != null) _applyFilterTime(value);
  });

  void _applyFilterTime(ItemModel value) {
    if (value.id != _filterTime.id) {
      _filterTime.setValue(value.id, value.name);
      _loadChart();
    }
  }

  void _loadChart() => bloc!.add(LoadChartsEvent(id: (widget as MarketPriceDtlPage).item.id, time: _filterTime.id));
}
