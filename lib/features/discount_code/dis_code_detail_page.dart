import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/ui_farm.dart';
import 'dis_code_list_bloc.dart';
import 'dis_code_list_page.dart';

class DisCodeDetailPage extends BasePage {
  final dynamic detail;
  DisCodeDetailPage(this.detail, {Key? key}):super(key: key, pageState: _DisCodeDetailState());
}

class _DisCodeDetailState extends BasePageState {

  @override
  void initState() {
    bloc = DisCodeListBloc(currentSelect: (widget as DisCodeDetailPage).detail['id'], isDetail: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    final ctr = bloc as DisCodeListBloc;
    return Scaffold(appBar: AppBar(elevation: 5, titleSpacing: 0,
        centerTitle: true, title: UtilUI.createLabel('Danh sách giới thiệu')),
      backgroundColor: Colors.white, body: Stack(children: [
        Column(children: [
          Padding(padding: EdgeInsets.all(40.sp),
              child: DisCodeItem((widget as DisCodeDetailPage).detail, false, -1, ctr)),
          const FarmManageTitle([
            ['Người dùng', 3],
            ['Ngày áp mã', 3, TextAlign.center],
            ['Giá trị giảm', 3, TextAlign.right]
          ], padding: 10),
          Expanded(child: BlocBuilder(buildWhen: (oldS, newS) => newS is LoadMissionsState,
            bloc: bloc, builder: (context, state) {
              return RefreshIndicator(child: ListView.builder(padding: EdgeInsets.zero,
                physics: const AlwaysScrollableScrollPhysics(), itemCount: ctr.list.length,
                itemBuilder: (context, index) => FarmManageItem([
                  [ctr.list[index]['name'], 3, TextAlign.left, Colors.blue],
                  [Util.strDateToString(ctr.list[index]['created_at'], pattern: 'dd/MM/yyyy'), 3, TextAlign.center],
                  [Util.doubleToString(ctr.list[index]['max_discount'])+' đ', 3, TextAlign.right]
                ], index, padding: 10),
                controller: ctr.scroller), onRefresh: ctr.loadList);
            }))
        ]),
        Loading(bloc)
      ]));
  }
}