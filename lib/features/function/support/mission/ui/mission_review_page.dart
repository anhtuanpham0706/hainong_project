import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'mission_review_item.dart';
import '../mission_bloc.dart';

class MissionReviewPage extends BasePage {
  MissionReviewPage(int idParent, int idDetail, int total, bool isView, {bool isLeader = false, Key? key}) : super(pageState: _MissionReviewPageState(idParent, idDetail, total, isView, isLeader), key: key);
}

class _MissionReviewPageState extends BasePageState {
  final List _list = [];
  final int idParent, idDetail, total;
  final bool isView, isLeader;

  _MissionReviewPageState(this.idParent, this.idDetail, this.total, this.isView, this.isLeader);

  @override
  void dispose() {
    _list.clear();
    super.dispose();
  }

  @override
  void initState() {
    bloc = MissionBloc('review');
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadReviewsState) {
        _list.addAll(state.resp);
      } else if (state is ReviewMissionState) {
        if (state.status.isNotEmpty) {
          UtilUI.showCustomDialog(context, state.status).whenComplete(() {
            if (state.resp is FocusNode) state.resp.requestFocus();
          });
        } else if (isResponseNotError(state.resp, passString: true)) {
          UtilUI.showCustomDialog(context, 'Đánh giá thành công').whenComplete(() => UtilUI.goBack(context, true));
        }
      }
    });
    bloc!.add(LoadReviewsEvent(idParent, idDetail: idDetail));
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Stack(children: [
    GestureDetector(onTap: clearFocus, onHorizontalDragDown: (_) => clearFocus(), onVerticalDragDown: (_) => clearFocus(),
      child: Scaffold(backgroundColor: color,
        appBar: AppBar(elevation: 0, titleSpacing: 0, centerTitle: true,
          title: UtilUI.createLabel('Đánh giá thành viên'),
          bottom: PreferredSize(preferredSize: Size(1.sw, 100.sp), child: Padding(padding: EdgeInsets.only(bottom: 40.sp),
              child: LabelCustom('Tổng số: $total', size: 48.sp, weight: FontWeight.normal)))
        ),
        body: Column(children: [
          Expanded(child: BlocBuilder(bloc: bloc,
              buildWhen: (oldState, newState) => newState is LoadReviewsState,
              builder: (context, state) => ListView.builder(padding: EdgeInsets.all(20.sp),
                  physics: const AlwaysScrollableScrollPhysics(), itemCount: _list.length, addRepaintBoundaries: false,
                  itemBuilder: (context, index) {
                    if (!_list[index].containsKey('pageState')) _list[index].putIfAbsent('pageState', () => MissionReviewItem(_list[index], index, isView, isLeader, _checkPer));
                    return _list[index]['pageState']??const SizedBox();
                  }))),
          const Divider(height: 0.5, color: Colors.black12),
          if (!isView) Container(child: ButtonImageWidget(16.sp, _save,
              Padding(child: LabelCustom('Lưu', size: 48.sp, weight: FontWeight.normal, align: TextAlign.center), padding: EdgeInsets.all(40.sp)),
              color: StyleCustom.primaryColor), width: 1.sw, padding: EdgeInsets.all(40.sp))
        ]))),
    Loading(bloc)
  ]);

  bool _checkPer(ctr, fc) {
    double total = 0, per = 0, more = 0;
    String temp;
    for (var item in _list) {
      temp = (item['pageState'] as MissionReviewItem).pageState.ctrPer1.text;
      if (temp.isNotEmpty) {
        per = double.parse(temp);
        total += per;
      }
    }
    if (total > 100) {
      if (ctr.text.isNotEmpty) more = double.parse(ctr.text);
      ctr.text = (100 - (total - more)).toInt().toString();
      UtilUI.showCustomDialog(context, 'Tổng phần trăm đánh giá thành viên không được lớn hơn 100');//.whenComplete(() => fc.requestFocus());
      return true;
    }
    return false;
  }

  void _save() => bloc!.add(ReviewMissionEvent(idParent, idDetail, -1, '', list: _list));
}