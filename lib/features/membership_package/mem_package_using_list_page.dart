import 'package:hainong/common/ui/box_dec_custom.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/image_network_asset.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/mem_package_content.dart';
import 'package:hainong/common/ui/tab_item.dart';
import 'mem_package_detail_page.dart';
import 'mem_package_history_list_page.dart';
import 'mem_package_using_list_bloc.dart';

class MemPackageUsingListPage extends BasePage {
  MemPackageUsingListPage({Key? key}):super(key: key, pageState: _UsingListState());
}

class _UsingListState extends BasePageState {
  int _tab = 0;

  @override
  void initState() {
    bloc = MemPackageUsingListBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    final ctr = bloc as MemPackageUsingListBloc;
    return Scaffold(appBar: AppBar(elevation: 5,
      titleSpacing: 0, centerTitle: true, title: UtilUI.createLabel('Gói cước'), actions: [
        IconButton(onPressed: () => UtilUI.goToNextPage(context, MemPackageHistoryListPage(id: ctr.myMemPackage != null ? ctr.myMemPackage['id']??-1 : -1)), icon: const Icon(Icons.history))
      ]),
      body: Stack(children: [
        Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            TabItem('Danh sách', 0, _tab == 0, _changeTab, parseTitle: false),
            TabItem('Đang dùng', 1, _tab == 1, _changeTab, parseTitle: false)
          ]),
          Expanded(child: _tab == 0 ? BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is LoadListState,
            builder: (context, state) {
              return RefreshIndicator(child: ListView.separated(padding: EdgeInsets.all(46.sp),
                physics: const AlwaysScrollableScrollPhysics(), controller: ctr.scroller,
                itemCount: ctr.list.length, separatorBuilder: (context, index) => SizedBox(height: 40.sp),
                itemBuilder: (context, index) => _UsingItem(ctr.list[index], ctr.myMemPackage != null && ctr.list[index]['id'] == ctr.myMemPackage['id'], _reload)
              ), onRefresh: ctr.loadList);
            }) : (ctr.myMemPackage != null ? MemPackageDetailPage(ctr.myMemPackage,
              MemPackageContent(ctr.myMemPackage), inUse: true, hasHeader: false, isMine: true, fnReload: _reload) : const SizedBox()))
        ]),
        Loading(bloc)
      ]));
  }

  void _changeTab(index) {
    if (_tab != index) setState(() => _tab = index);
  }

  void _reload(dynamic value) {
    final ctr = bloc as MemPackageUsingListBloc;
    if (value == null) setState(() => ctr.myMemPackage = value);
    else {
      ctr.loadMyMemPackage();
      setState(() {});
    }
  }
}

class _UsingItem extends StatelessWidget {
  final dynamic item;
  final bool inUse;
  final Function reload;
  const _UsingItem(this.item, this.inUse, this.reload);
  @override
  Widget build(BuildContext context) {
    final content = MemPackageContent(item);
    return ButtonImageWidget(10, () => UtilUI.goToNextPage(context, MemPackageDetailPage(item, content, inUse: inUse, fnReload: reload)),
      Container(decoration: BoxDecCustom(radius: 10), padding: EdgeInsets.all(25.sp),
        child: Row(children: [
          Container(decoration: BoxDecCustom(radius: 100), margin: EdgeInsets.only(right: 20.sp),
            child: ClipRRect(child: ImageNetworkAsset(path: item['image']??'', height: 180.sp, width: 180.sp),
            borderRadius: BorderRadius.circular(100))),
          Expanded(child: content)
        ])
      ));
  }
}