import 'package:hainong/common/ui/box_dec_custom.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/image_network_asset.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/tab_item.dart';
import 'exe_contribution_detail_page.dart';
import 'exe_contribution_list_bloc.dart';
import 'exe_contribution_type.dart';

class ExeContributionListPage extends BasePage {
  ExeContributionListPage({Key? key}):super(key: key, pageState: _ContributionListState());
}

class _ContributionListState extends BasePageState {
  final _bloc = ExeContributionListBloc();

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    return Scaffold(appBar: AppBar(elevation: 5,
      titleSpacing: 0, centerTitle: true, title: UtilUI.createLabel('Đóng góp'), actions: [
        //IconButton(onPressed: () {}, icon: const Icon(Icons.history))
      ]),
      body: Stack(children: [
        Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            TabItem('Danh sách', 0, _bloc.tab == 0, _changeTab, parseTitle: false, size: 48.sp),
            TabItem('Đang thực hiện', 1, _bloc.tab == 1, _changeTab, parseTitle: false, size: 48.sp),
            TabItem('Hết hạn', 2, _bloc.tab == 2, _changeTab, parseTitle: false, size: 48.sp)
          ]),
          Expanded(child: BlocBuilder(bloc: _bloc, buildWhen: (oldS, newS) => newS is LoadListState,
            builder: (context, state) => RefreshIndicator(child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(), controller: _bloc.scroller,
              itemCount: _bloc.list.length, separatorBuilder: (context, index) => SizedBox(height: 40.sp),
              itemBuilder: (context, index) => _ContributionItem(_bloc.list[index], _bloc.loadList, _bloc.tab == 2),
            padding: EdgeInsets.all(46.sp)), onRefresh: _bloc.loadList)))
        ]),
        Loading(_bloc)
      ]));
  }

  void _changeTab(int index) => _bloc.changeTab(index, () => setState((){}));
}

class _ContributionItem extends StatelessWidget {
  final dynamic item;
  final Function reload;
  final bool isExpired;
  const _ContributionItem(this.item, this.reload, this.isExpired);
  @override
  Widget build(BuildContext context) {
    return ButtonImageWidget(10, () => UtilUI.goToNextPage(context, ExeContributionDetailPage(item, _isExe(), reload: reload)),
      Container(decoration: BoxDecCustom(radius: 10),
        child: Column(children: [
          ClipRRect(child: Stack(children: [
            ImageNetworkAsset(path: item['avatar']??'', height: 0.2.sh, width: 1.sw),
            if (isExpired) Container(color: const Color(0x8FFFFFFF),
              child: Image.asset('assets/images/v8/ic_expired_v8.png', height: 0.2.sh, width: 1.sw, fit: BoxFit.scaleDown))
          ]), borderRadius: const BorderRadius.vertical(top: Radius.circular(10))),
          Padding(padding: EdgeInsets.all(40.sp), child: Column(children: [
            LabelCustom(item['name']??'', color: Colors.green, size: 52.sp, line: 5, overflow: TextOverflow.ellipsis, weight: FontWeight.w500),
            Padding(padding: EdgeInsets.only(top: 20.sp, bottom: 40.sp), child: Row(children: [
              Icon(Icons.access_time, size: 50.sp, color: Colors.black87),
              LabelCustom(' ' + Util.strDateToString(item['start_date']??'', pattern: 'dd/MM/yyyy') + ' - ' +
                  Util.strDateToString(item['end_date']??'', pattern: 'dd/MM/yyyy'), size: 40.sp, color: Colors.black87, weight: FontWeight.w400)
            ], crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.start)),
            if (Util.checkKeyFromJson(item, 'contribution_mission_details') && item['contribution_mission_details'].isNotEmpty) ...[
              LabelCustom('Yêu cầu đóng góp:', color: Colors.black87, size: 48.sp, weight: FontWeight.w500),
              _uiRequirements(),
              SizedBox(height: 10.sp)
            ],
            Row(children: [
              Expanded(child: LabelCustom(item['contribution_mission_status']??'', color: Colors.green, size: 42.sp, weight: FontWeight.w400)),
              Image.asset('assets/images/v8/ic_gift.png', width: 48.sp),
              ExeContributionType(item),
            ], mainAxisAlignment: MainAxisAlignment.end)
          ], crossAxisAlignment: CrossAxisAlignment.start))
        ])
      ));
  }

  Widget _uiRequirements() {
    List<Widget> list = [];
    for(var ele in item['contribution_mission_details']) {
      String temp = MultiLanguage.get(ele['mission_type']??'');
      switch(ele['mission_type']) {
        case 'referral_user':
          if (ele['action_type'] == 'intro_products') temp = ' ● Giới thiệu sản phẩm';
          break;
        case 'contribute_interact':
          temp = ' ● ' + ele['action_name']??'';
      }
      list.add(Padding(padding: EdgeInsets.symmetric(vertical: 10.sp),
          child: LabelCustom(temp, size: 42.sp, color: Colors.black87, weight: FontWeight.w500)));
    }
    return Column(children: list, crossAxisAlignment: CrossAxisAlignment.start);
  }

  bool _isExe() {
    final String temp = item['contribution_mission_status_type']??'';
    return temp.contains('completed') || temp.contains('processing');
  }
}