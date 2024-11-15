import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/features/function/support/mission/ui/mission_detail_page.dart';
import '../mission_bloc.dart';
import 'mission_review_page.dart';
import 'mission_ui.dart';

class MissionSubDetailPage extends BasePage {
  final dynamic parent, item;
  final bool showParent;
  final Function? reload;
  MissionSubDetailPage(this.parent, this.item, {this.showParent = false, this.reload, Key? key}) : super(pageState: _MissionSubDetailPageState(), key: key);
}

class _MissionSubDetailPageState extends BasePageState {

  @override
  void initState() {
    bloc = MissionBloc('sub');
    super.initState();
    bloc!.stream.listen((state) {
      if (state is JoinMissionState && isResponseNotError(state.resp, passString: true)) {
        UtilUI.showCustomDialog(context, 'Bạn đã đăng ký tham gia nhiệm vụ thành công. Vui lòng chờ duyệt').whenComplete(() => UtilUI.goBack(context, true));
        final page = widget as MissionSubDetailPage;
        if (page.reload != null) page.reload!(1);
      } else if (state is LeaveMissionState && isResponseNotError(state.resp, passString: true)) {
        UtilUI.showCustomDialog(context, 'Bạn đã rút khỏi nhiệm vụ thành công').whenComplete(() => UtilUI.goBack(context, true));
        final page = widget as MissionSubDetailPage;
        if (page.reload != null) page.reload!(-1);
      } else if (state is SaveMissionState && isResponseNotError(state.resp, passString: true)) {
        final page = widget as MissionSubDetailPage;
        if (page.reload != null) page.reload!(0);
        UtilUI.showCustomDialog(context, 'Hoàn thành nhiệm vụ thành công').whenComplete(() {
          UtilUI.goBack(context, true);
          _rate();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    final page = widget as MissionSubDetailPage;
    dynamic item = page.item;
    final List images = (item['images']??[]).toList();
    String status = '', expired = '', accept = 'Chờ duyệt';
    bool leader = item['is_leader']??false, fullMem = (item['total_joined']??0).toInt() == (item['number_joins']??0).toInt();
    int id = item['user_id']??-1;
    if (id != Constants().userId) status = (item['joined'] ?? false) ? 'Đã tham gia' : 'Chưa tham gia';

    expired = item['work_status']??'pending';

    switch (item['author_status']??'') {
      case 'accepted': accept = 'Đã duyệt'; break;
      case 'rejected': accept = 'Bị từ chối'; break;
    }

    return Stack(children: [
      Scaffold(backgroundColor: color, appBar: AppBar(elevation: 0, titleSpacing: 0, centerTitle: true,
          toolbarHeight: 200.sp, title: UtilUI.createLabel('Thông tin nhiệm vụ ' + (item['title']??''), line: 2)),
        body: Column(children: [
          Expanded(child: ListView(padding: EdgeInsets.all(40.sp), children: [
            MissionLine('Tên NV', item['title']??'', hasPadding: !page.showParent, padding: page.showParent ? null : EdgeInsets.only(bottom: 40.sp)),
            //MissionLine('Danh mục NV', item['mission_catalogue_name']??'', padding: EdgeInsets.symmetric(vertical: 40.sp)),
            if (page.showParent) ButtonImageWidget(0, () {
                  UtilUI.goBack(context, false);
                  UtilUI.goToNextPage(context, MissionDetailPage(page.parent));
                },
                MissionLine('Tên NV tổng', item['mission_title']??'', more: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 48.sp), padding: EdgeInsets.symmetric(vertical: 40.sp))),
            MissionLine('Bắt đầu', Util.strDateToString(item['start_date']??'', pattern: 'dd/MM/yyyy'), hasPadding: false),
            MissionLine('Kết thúc', Util.strDateToString(item['end_date']??'', pattern: 'dd/MM/yyyy'), padding: EdgeInsets.symmetric(vertical: 40.sp)),
            MissionLine('Mô tả NV', '', padding: EdgeInsets.symmetric(horizontal: 40.sp), flex: 10, hasPadding: false),
            (item['content']??'').isEmpty ? SizedBox(height: 40.sp) : Padding(padding: EdgeInsets.fromLTRB(0, 20.sp, 0, 40.sp), child:
              LabelCustom(item['content']??'', color: const Color(0xFF1AAD80), size: 42.sp, weight: FontWeight.normal)),
            MissionLine('Tỉnh/TP', item['province_name']??'', hasPadding: false),
            MissionLine('Quận/Huyện', item['district_name']??'', padding: EdgeInsets.symmetric(vertical: 40.sp)),
            MissionLine('ĐC canh tác', item['address']??'', hasPadding: false),
            MissionLine('DT canh tác (m2)', Util.doubleToString((item['acreage']??.0).toDouble()), padding: EdgeInsets.only(top: 40.sp), flex: 4),
            if (images.isNotEmpty) SizedBox(height: 0.25.sw + 20.sp,
              child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: images.length,
                padding: EdgeInsets.only(top: 20.sp),
                separatorBuilder: (context, index) => SizedBox(width: 20.sp),
                itemBuilder: (context, index) {
                  String image = images[index]['name']??'';
                  return FadeInImage.assetNetwork(placeholder: 'assets/images/ic_default.png', height: 0.25.sw,
                      image: Util.getRealPath(image), fit: BoxFit.scaleDown,
                      imageScale: 0.5, imageErrorBuilder: (_,__,___) => Image.asset('assets/images/ic_default.png',
                          width: 0.36.sw, height: 0.25.sw, fit: BoxFit.fill));
                })),
            if (status.isNotEmpty) MissionLine('Trạng thái', status, padding: EdgeInsets.only(top: 40.sp)),
          ])),
          if (expired == 'pending' && status == 'Chưa tham gia') Padding(child: ButtonImageWidget(16.sp, fullMem ? (){} : _join,
              Container(padding: EdgeInsets.all(40.sp), width: 1.sw - 80.sp, child: LabelCustom(
                  fullMem ? 'Đã đủ thành viên tham gia' : 'Tham gia nhiệm vụ',
                  color: Colors.white, size: 48.sp, weight: FontWeight.normal, align: TextAlign.center)),
                color: fullMem ? Colors.grey : StyleCustom.primaryColor),
            padding: EdgeInsets.symmetric(vertical: 40.sp)),
          if (expired == 'pending' && status == 'Đã tham gia' && accept == 'Đã duyệt' && leader)
            Padding(child: ButtonImageWidget(16.sp, _complete,
              Container(padding: EdgeInsets.all(40.sp), width: 1.sw - 80.sp, child: LabelCustom('Hoàn thành nhiệm vụ',
                  color: Colors.white, size: 48.sp, weight: FontWeight.normal, align: TextAlign.center)), color: StyleCustom.primaryColor),
              padding: EdgeInsets.only(top: 40.sp)),
          if (expired == 'pending' && status == 'Đã tham gia' && accept == 'Đã duyệt') Padding(child: ButtonImageWidget(16.sp, _leave,
              Container(padding: EdgeInsets.all(40.sp), width: 1.sw - 80.sp, child: LabelCustom('Rút khỏi nhiệm vụ',
                  color: Colors.white, size: 48.sp, weight: FontWeight.normal, align: TextAlign.center)), color: Colors.black26),
            padding: EdgeInsets.symmetric(vertical: 40.sp)),
          if (expired == 'pending' && status == 'Đã tham gia' && accept == 'Chờ duyệt') Padding(child: ButtonImageWidget(16.sp, (){},
              Container(padding: EdgeInsets.all(40.sp), width: 1.sw - 80.sp, child: LabelCustom('Chờ duyệt',
                  color: Colors.white, size: 48.sp, weight: FontWeight.normal, align: TextAlign.center)), color: Colors.orangeAccent),
            padding: EdgeInsets.symmetric(vertical: 40.sp)),
          if (expired == 'pending' && status == 'Đã tham gia' && accept == 'Bị từ chối') Padding(child: ButtonImageWidget(16.sp, (){},
              Container(padding: EdgeInsets.all(40.sp), width: 1.sw - 80.sp, child: LabelCustom('Bị từ chối',
                  color: Colors.white, size: 48.sp, weight: FontWeight.normal, align: TextAlign.center)), color: Colors.red),
            padding: EdgeInsets.symmetric(vertical: 40.sp)),
          if (expired != 'pending' && (page.parent['work_status']??'pending') == 'pending' && leader)
            Padding(child: ButtonImageWidget(16.sp, _rate,
              Container(padding: EdgeInsets.all(40.sp), width: 1.sw - 80.sp, child: LabelCustom('Đánh giá',
                  color: Colors.white, size: 48.sp, weight: FontWeight.normal, align: TextAlign.center)), color: StyleCustom.primaryColor),
            padding: EdgeInsets.only(top: 40.sp)),
          if (expired != 'pending') Padding(child: ButtonImageWidget(16.sp, (){},
              Container(padding: EdgeInsets.all(40.sp), width: 1.sw - 80.sp, child: LabelCustom('Đã hoàn thành',
                  color: Colors.white, size: 48.sp, weight: FontWeight.normal, align: TextAlign.center)), color: Colors.black26),
            padding: EdgeInsets.symmetric(vertical: 40.sp))
        ])),
      Loading(bloc)
    ]);
  }

  void _join() {
    if (!Constants().isLogin) {
      UtilUI.showCustomDialog(context, MultiLanguage.get('msg_login_create_account'));
      return;
    }
    final page = widget as MissionSubDetailPage;
    bloc!.add(JoinMissionEvent(page.parent['id']??-1, page.item['id']??-1));
  }

  void _complete() => bloc!.add(SaveMissionEvent((widget as MissionSubDetailPage).item['id'], '', '', '', '', '', '',
      '', '', status: 'completed', idParent: (widget as MissionSubDetailPage).parent['id']));

  void _leave() => UtilUI.showCustomDialog(context, 'Bạn có chắc muốn rút khỏi nhiệm vụ này không?', isActionCancel: true).then((value) {
    if (value != null && value) {
      final page = widget as MissionSubDetailPage;
      bloc!.add(LeaveMissionEvent(page.parent['id']??-1, page.item['id']??-1, page.item['id_for_out']??-1));
    }
  });

  void _rate() {
    final page = widget as MissionSubDetailPage;
    UtilUI.goToNextPage(context, MissionReviewPage(page.parent['id']??-1, page.item['id']??-1, (page.item['total_joined']??0).toInt(), (page.parent['work_status']??'pending') == 'completed', isLeader: true));
  }
}