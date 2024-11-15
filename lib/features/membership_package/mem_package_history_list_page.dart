import 'package:hainong/common/ui/box_dec_custom.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/image_network_asset.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/mem_package_content.dart';
import 'mem_package_detail_page.dart';
import 'mem_package_history_list_bloc.dart';

class MemPackageHistoryListPage extends BasePage {
  final int id;
  MemPackageHistoryListPage({Key? key, this.id = -1}):super(key: key, pageState: _HistoryListState());
}

class _HistoryListState extends BasePageState {

  @override
  void initState() {
    bloc = MemPackageHistoryListBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    final id = (widget as MemPackageHistoryListPage).id;
    final ctr = bloc as MemPackageHistoryListBloc;
    return GestureDetector(child: Scaffold(appBar: AppBar(elevation: 5, titleSpacing: 0,
        centerTitle: true, title: UtilUI.createLabel('Nhật ký gói cước sử dụng'),
        bottom: PreferredSize(preferredSize: Size(0.5.sw, 140.sp), child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.sp)),
          padding: EdgeInsets.all(30.sp), margin: EdgeInsets.fromLTRB(40.sp, 0, 40.sp, 40.sp),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            ButtonImageWidget(100, _search, Image.asset('assets/images/ic_search.png', width: 42.sp, color: const Color(0xFF8B8D8A))),
            Expanded(child: TextField(controller: ctr.ctrSearch,
              onChanged: (value) {
                if (value.length == 1) bloc!.add(ShowClearSearchEvent(true));
                if (value.isEmpty) bloc!.add(ShowClearSearchEvent(false));
              },
              onSubmitted: (value) => _search(),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(hintStyle: TextStyle(fontSize: 36.sp, color: const Color(0xFF959595)),
                hintText: 'Nhập từ khóa hoặc nội dung tìm kiếm', contentPadding: EdgeInsets.symmetric(horizontal: 40.sp), isDense: true,
                border: const UnderlineInputBorder(borderSide: BorderSide.none))
            )),
            BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is ShowClearSearchState,
              builder: (context, state) {
                bool show = false;
                if (state is ShowClearSearchState) show = state.value;
                return show ? Padding(padding: EdgeInsets.only(right: 20.sp), child: ButtonImageWidget(100, _clear,
                  Icon(Icons.clear, size: 48.sp, color: const Color(0xFF676767)))) : const SizedBox();
              })
          ])))),
      body: Stack(children: [
        BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is LoadMissionsState,
          builder: (context, state) => RefreshIndicator(child: ListView.separated(padding: EdgeInsets.all(40.sp),
            separatorBuilder: (context, index) => SizedBox(height: 40.sp),
            physics: const AlwaysScrollableScrollPhysics(), itemCount: ctr.list.length,
            itemBuilder: (context, index) => _HistoryItem(ctr.list[index], id),
            controller: ctr.scroller), onRefresh: ctr.loadList)),
        Loading(bloc)
      ])), onTap: clearFocus);
  }

  void _search() {
    clearFocus();
    (bloc as MemPackageHistoryListBloc).loadList();
  }

  void _clear() {
    clearFocus();
    (bloc as MemPackageHistoryListBloc).clear();
  }
}

class _HistoryItem extends StatelessWidget {
  final dynamic item;
  final int id;
  const _HistoryItem(this.item, this.id);
  @override
  Widget build(BuildContext context) {
    final expire = item['using_status'] != 'in_use';
    return ButtonImageWidget(10, () => UtilUI.goToNextPage(context,
        MemPackageDetailPage(item['membership_package'], MemPackageContent(item['membership_package']), inUse: !expire, idHistory: item['id'])),
    Container(decoration: BoxDecCustom(radius: 10), child: Row(children: [
      ClipRRect(child: ImageNetworkAsset(path: item['membership_package']['image']??'', height: 160.sp, width: 160.sp),
          borderRadius: BorderRadius.circular(10)),
      SizedBox(width: 40.sp),
      Expanded(child: Column(children: [
        Row(children: [
          Expanded(child: LabelCustom(item['membership_package']['name']??'', color: Colors.green, size: 48.sp)),
          Container(padding: const EdgeInsets.all(5), margin: EdgeInsets.only(left: 10.sp),
              decoration: BoxDecCustom(radius: 5, hasShadow: false, bgColor: expire ? Colors.red : Colors.green),
              child: LabelCustom(expire ? 'Hết hạn' : 'Đang dùng', size: 36.sp, weight: FontWeight.w400))
        ], mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start),
        SizedBox(height: 10.sp),
        _Row('Ngày bắt đầu: ', Util.strDateToString(item['start_date']??'', pattern: 'dd/MM/yyyy')),
        Padding(padding: EdgeInsets.symmetric(vertical: 10.sp), child:
          _Row('Ngày kết thúc: ', Util.strDateToString(item['end_date']??'', pattern: 'dd/MM/yyyy'))),
        _Row('Hình thức đổi: ', _type())
      ]))
    ]), padding: EdgeInsets.all(40.sp)));
  }

  String _type() {
    switch(item['using_type']??'') {
      case 'point': return 'Đổi điểm';
      case 'level': return 'Nâng hạng';
      default: return 'Tiền';
    }
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  const _Row(this.label, this.value) : super();
  @override
  Widget build(BuildContext context) => Row(children: [
    LabelCustom(label, color: Colors.black87, size: 40.sp, weight: FontWeight.w400),
    Expanded(child: LabelCustom(value, color: Colors.black, size: 42.sp, weight: FontWeight.w400))
  ], crossAxisAlignment: CrossAxisAlignment.start);
}