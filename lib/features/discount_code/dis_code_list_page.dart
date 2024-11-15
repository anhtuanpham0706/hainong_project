import 'package:flutter/services.dart';
//import 'package:hainong/common/database_helper.dart';
import 'package:hainong/common/ui/box_dec_custom.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/image_network_asset.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/tab_item.dart';
import 'dis_code_detail_page.dart';
import 'dis_code_list_bloc.dart';

class DisCodeListPage extends BasePage {
  final bool hasSelect;
  DisCodeListPage({Key? key, this.hasSelect = false, List? shops}):super(key: key, pageState: _DisCodeListState(shops));
}

class _DisCodeListState extends BasePageState {

  _DisCodeListState(List? shops) {
    bloc = DisCodeListBloc(shops: shops);
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    final hasSelect = (widget as DisCodeListPage).hasSelect;
    final ctr = bloc as DisCodeListBloc;
    final list = BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is LoadMissionsState, builder: (context, state) {
      if (ctr.list.isEmpty) return const SizedBox();
      return RefreshIndicator(child: ListView.separated(padding: EdgeInsets.all(40.sp),
        separatorBuilder: (context, index) => SizedBox(height: 40.sp),
        physics: const AlwaysScrollableScrollPhysics(), itemCount: ctr.list.length,
        itemBuilder: (context, index) => DisCodeItem(ctr.list[index], hasSelect, index, bloc as DisCodeListBloc),
        controller: ctr.scroller), onRefresh: ctr.loadList);
      });
    return GestureDetector(child: Scaffold(backgroundColor: Colors.white, appBar: AppBar(elevation: 5, titleSpacing: 0,
        centerTitle: true, title: UtilUI.createLabel('Mã giảm giá'),
        bottom: PreferredSize(preferredSize: Size(1.sw, hasSelect || !constants.isLogin ? 140.sp : 260.sp),
          child: Column(children: [
            Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
              padding: EdgeInsets.all(30.sp), margin: EdgeInsets.symmetric(horizontal: 40.sp),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                ButtonImageWidget(20, _search, Image.asset('assets/images/ic_search.png', width: 42.sp, color: const Color(0xFF8B8D8A))),
                Expanded(child: TextField(controller: ctr.ctrSearch,
                    onChanged: (value) {
                      if (value.length == 1) bloc!.add(ShowClearSearchEvent(true));
                      if (value.isEmpty) bloc!.add(ShowClearSearchEvent(false));
                    },
                    onSubmitted: (value) => _search(),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(hintStyle: TextStyle(fontSize: 36.sp, color: const Color(0xFF959595)),
                        hintText: 'Nhập mã giảm giá', contentPadding: EdgeInsets.symmetric(horizontal: 40.sp), isDense: true,
                        border: const UnderlineInputBorder(borderSide: BorderSide.none))
                )),
                BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is ShowClearSearchState,
                    builder: (context, state) {
                      bool show = false;
                      if (state is ShowClearSearchState) show = state.value;
                      return show ? Padding(padding: EdgeInsets.only(right: 20.sp), child: ButtonImageWidget(100, _clear,
                          Icon(Icons.clear, size: 48.sp, color: const Color(0xFF676767)))) : const SizedBox();
                    })
              ])),
            hasSelect || !constants.isLogin ? SizedBox(height: 40.sp) : BlocBuilder(bloc: bloc,
              buildWhen: (oldS, newS) => newS is LoadCatalogueState,
              builder: (context, state) => Row(children: [
                  TabItem('Tất cả', 0, ctr.tabIndex == 0, ctr.changeTab, parseTitle: false, color: Colors.white, expanded: false),
                  TabItem('Của tôi', 1, ctr.tabIndex == 1, ctr.changeTab, parseTitle: false, color: Colors.white, expanded: false)
              ], mainAxisAlignment: MainAxisAlignment.spaceAround))
        ]))),
      body: Stack(children: [
        hasSelect ? Column(children: [
          Expanded(child: list),
          Container(padding: EdgeInsets.all(40.sp), width: 1.sw,
            child: BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is LoadMembersState,
              builder: (context, state) => ButtonImageWidget(16.sp, () {
                /*final coupon = ctr.list[ctr.currentSelect];
                DBHelperUtil().setCoupon({
                  'id': coupon['id']??-1,
                  'coupon_code': coupon['coupon_code']??'',
                  'coupon_type': coupon['coupon_type']??'',
                  'image': coupon['image']??'',
                  'start_date': coupon['start_date']??'',
                  'end_date': coupon['end_date']??'',
                  'classable_type': coupon['classable_type']??'',
                  'classable_id': coupon['classable_id']??-1,
                  'value': (coupon['value']??.0).toDouble(),
                  'max_value': coupon['max_value']??.0,
                  'min_invoice_value': coupon['min_invoice_value']??.0,
                  'invoice_users_percent': coupon['invoice_users_percent']??.0
                });*/
                UtilUI.goBack(context, ctr.list[ctr.currentSelect]);
              }, Padding(padding: EdgeInsets.all(40.sp), child: LabelCustom('Đồng ý', color: Colors.white, size: 48.sp,
                  align: TextAlign.center)), color: ctr.currentSelect < 0 ? const Color(0xFFEFEFEF) : StyleCustom.primaryColor)))
        ]) : list,
        Loading(bloc)
      ])), onTap: clearFocus);
  }

  void _search() {
    clearFocus();
    (bloc as DisCodeListBloc).loadList();
  }

  void _clear() {
    clearFocus();
    (bloc as DisCodeListBloc).clear();
  }
}

class DisCodeItem extends StatelessWidget {
  final dynamic item;
  final int index;
  final bool hasSelect;
  final DisCodeListBloc bloc;
  const DisCodeItem(this.item, this.hasSelect, this.index, this.bloc, {Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) {
    final enable = (item['use_status']??false) && (item['shop_ids']??[]).isNotEmpty;
    return ButtonImageWidget(10, () async {
        if (index < 0) return;
        final prefs = await SharedPreferences.getInstance();
        if (item['user_id'] != prefs.getInt('id')) return;
        UtilUI.goToNextPage(context, DisCodeDetailPage(item));
      },
      Container(decoration: BoxDecCustom(bgColor: Colors.transparent), child: IntrinsicHeight(child: Row(children: [
        Expanded(flex: 3, child: FittedBox(child: Stack(children: [
          Image.asset('assets/images/v8/bg_discount_item.png'),
          ImageNetworkAsset(path: item['image']??'', width: 0.4.sw, fit: BoxFit.fitWidth, uiError: const SizedBox()),
        ], alignment: Alignment.center), fit: BoxFit.fill)),
        Expanded(flex: 7, child: Container(color: enable ? Colors.white : const Color(0xFFEFEFEF), child: Column(children: [
          Row(children: [
            LabelCustom(item['coupon_code']??'', color: Colors.black, size: 48.sp, weight: FontWeight.w700),
            const SizedBox(width: 5),
            ButtonImageWidget(0, () {
              Clipboard.setData(ClipboardData(text: item['coupon_code']));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mã giảm giá đã được lưu")));
            }, Icon(Icons.copy, color: Colors.black, size: 58.sp)),
            const Expanded(child: SizedBox()),
            if (hasSelect && enable) ButtonImageWidget(20, () => bloc.selectItem(index),
              BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is LoadMembersState && newS.resp == index,
                builder: (context, state) {
                  bool select = item['is_selected']??false;
                  return Icon(select ? Icons.check_circle : Icons.radio_button_unchecked, color: select ? Colors.orange : const Color(0xFFCDCDCD));
                }))
          ], mainAxisSize: MainAxisSize.min),
          Padding(padding: EdgeInsets.only(top: 10.sp, bottom: 20.sp),
              child: LabelCustom(_getDescription(), color: Colors.black, size: 42.sp, weight: FontWeight.w400)),
          LabelCustom(_getUsing(), color: const Color(0xFF818181), size: 34.sp, weight: FontWeight.w400),
          SizedBox(height: 10.sp),
          Row(children: [
            Icon(Icons.access_time, color: const Color(0xFF818181), size: 42.sp),
            LabelCustom(' Hiệu lực: ', color: const Color(0xFF818181), size: 34.sp, weight: FontWeight.w400),
            Expanded(child: Wrap(children: [
              LabelCustom(Util.strDateToString(item['start_date'], pattern: 'dd/MM/yyyy') + ' - ', color: const Color(0xFF818181), size: 34.sp, weight: FontWeight.w400),
              LabelCustom(Util.strDateToString(item['end_date'], pattern: 'dd/MM/yyyy'), color: const Color(0xFF818181), size: 34.sp, weight: FontWeight.w400)
            ]))
          ], crossAxisAlignment: CrossAxisAlignment.start),
        ], crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center), padding: EdgeInsets.all(20.sp)))
      ], crossAxisAlignment: CrossAxisAlignment.stretch)))
    );
  }

  String _getDescription() {
    String des = '';
    if (item['coupon_type'] == 'percent') {
      des = 'Giảm ${item['value']}%. Giảm tối đa ' + Util.doubleToString(item['max_value']) + 'đ';
    } else {
      des = 'Giảm ${Util.doubleToString(item['value'].toDouble())}đ cho đơn hàng tối thiểu ' + Util.doubleToString(item['min_invoice_value']) + 'đ';
    }
    return des;
  }

  String _getUsing() {
    double value = item['invoice_users_percent']??-1;
    if (value > 0) return 'Đã dùng $value%';
    return '';
  }
}