import 'package:hainong/common/ui/box_dec_custom.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/image_network_asset.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/features/membership_package/mem_package_history_list_bloc.dart';

class TreeListPage extends BasePage {
  final List list;
  TreeListPage(this.list, {Key? key}):super(key: key, pageState: _TreeListPageState());
}

class _TreeListPageState extends BasePageState {

  @override
  void initState() {
    bloc = MemPackageHistoryListBloc(isMemPackage: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    final ctr = bloc as MemPackageHistoryListBloc;
    return GestureDetector(child: Scaffold(appBar: AppBar(elevation: 5, titleSpacing: 0,
        centerTitle: true, title: UtilUI.createLabel('Danh sách cây trồng'),
        actions: [
          IconButton(onPressed: () => UtilUI.goBack(context, ctr.select((widget as TreeListPage).list)), icon: LabelCustom('Chọn', size: 46.sp), iconSize: 150.sp)
        ],
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
                hintText: 'Nhập tên cây cần tìm kiếm', contentPadding: EdgeInsets.symmetric(horizontal: 40.sp), isDense: true,
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
            itemBuilder: (context, index) => _Item(bloc as MemPackageHistoryListBloc, ctr.list[index], index, ctr.selectItem),
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

class _Item extends StatelessWidget {
  final MemPackageHistoryListBloc bloc;
  final dynamic item;
  final int index;
  final Function(int) funSelect;
  const _Item(this.bloc, this.item, this.index, this.funSelect);
  @override
  Widget build(BuildContext context) => ButtonImageWidget(10, _gotoDetail,
    Container(decoration: BoxDecCustom(radius: 10), child: Row(children: [
      ClipRRect(child: ImageNetworkAsset(path: item['image']??'', height: 160.sp, width: 160.sp), borderRadius: BorderRadius.circular(10)),
      SizedBox(width: 40.sp),
      Expanded(child: LabelCustom(item['name']??'', color: Colors.green, size: 48.sp, weight: FontWeight.normal)),
      ButtonImageWidget(0, () => funSelect(index), BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is GetLocationState && newS.latLng == index,
        builder: (context, state) => Icon((item['is_selected']??false) ? Icons.check_box : Icons.check_box_outline_blank, size: 64.sp, color: Colors.green)))
    ], mainAxisAlignment: MainAxisAlignment.start), padding: EdgeInsets.all(40.sp)));

  void _gotoDetail() {}
}