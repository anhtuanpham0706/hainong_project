import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/image_network_asset.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/features/main/ui/main_page.dart';
import 'package:hainong/features/profile/ui/profile_page.dart';
import 'exe_contribution_detail_bloc.dart';
import 'exe_contribution_image_page.dart';
import 'exe_contribution_type.dart';

class ExeContributionDetailPage extends BasePage {
  ExeContributionDetailPage(dynamic detail, bool isDaily, {Function? reload, Key? key}):super(key: key, pageState: _DetailState(detail, isDaily, reload: reload));
}

class _DetailState extends BasePageState {
  final dynamic detail;
  final Function? reload;
  bool isDaily, _isExe = false;

  _DetailState(this.detail, this.isDaily, {this.reload});

  @override
  void initState() {
    bloc = ExeContributionDetailBloc(detail['id']);
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadMembersState) {
        _checkExe(state.resp['child_contribution_missions']);
        detail.removeWhere((key, value) => key == 'child_contribution_missions');
        detail.putIfAbsent('description', () => state.resp['description']);
        detail.putIfAbsent('participation_policy', () => state.resp['participation_policy']);
        detail.putIfAbsent('child_contribution_missions', () => state.resp['child_contribution_missions']);
        setState(() {});
      } else if (state is JoinMissionState && isResponseNotError(state.resp, passString: true)) {
        UtilUI.showCustomDialog(context, 'Đã tham gia thành công và tiếp tục thực hiện đóng góp').whenComplete(() {
          if (reload != null) reload!();
          setState(() => isDaily = true);
          _execute();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    final hasExe = Util.checkKeyFromJson(detail, 'child_contribution_missions') && detail['child_contribution_missions'].isNotEmpty;
    final temp = Stack(children: [
      ImageNetworkAsset(path: detail['avatar']??'', height: 0.4.sh, width: 1.sw),
      Column(children: [
        Expanded(child: SingleChildScrollView(child: Column(children: [
          SizedBox(height: 0.3.sh),
          Container(padding: EdgeInsets.all(40.sp),
              decoration: const BoxDecoration(color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              child: Column(children: [
                LabelCustom(detail['name']??'', color: Colors.green, size: 52.sp, weight: FontWeight.w500),
                Padding(padding: EdgeInsets.only(top: 20.sp, bottom: 40.sp), child: Row(children: [
                  Icon(Icons.access_time, size: 50.sp, color: Colors.black87),
                  LabelCustom(' ' + Util.strDateToString(detail['start_date']??'', pattern: 'dd/MM/yyyy') + ' - ' +
                      Util.strDateToString(detail['end_date']??'', pattern: 'dd/MM/yyyy'), size: 40.sp, color: Colors.black87, weight: FontWeight.w400)
                ], crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.start)),
                Row(children: [
                  Expanded(child: LabelCustom(detail['contribution_mission_status']??'', color: Colors.green, size: 42.sp, weight: FontWeight.w400)),
                  Image.asset('assets/images/v8/ic_gift.png', width: 48.sp),
                  ExeContributionType(detail),
                ], mainAxisAlignment: MainAxisAlignment.end),
                SizedBox(height: 40.sp),
                Row(children: [
                  LabelCustom('Đối tượng tham gia', color: Colors.black87, size: 48.sp),
                  Expanded(child: LabelCustom(MultiLanguage.get(detail['participation_policy']??''), color: Colors.black87, size: 42.sp, weight: FontWeight.w400, align: TextAlign.right))
                ], crossAxisAlignment: CrossAxisAlignment.center),
                (detail['description']??'').isEmpty ? SizedBox(height: 40.sp) :
                Padding(padding: EdgeInsets.symmetric(vertical: 40.sp),
                    child: LabelCustom(detail['description']??'', color: Colors.black87, size: 48.sp, weight: FontWeight.w400)),
                if (hasExe) ...[
                  LabelCustom('Danh sách cần thực hiện', color: Colors.green, size: 48.sp, weight: FontWeight.w500),
                  _uiExeList()
                ]
              ], crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min))
        ], mainAxisSize: MainAxisSize.min))),
        if (hasExe && _isExe) Padding(padding: EdgeInsets.all(40.sp), child: ButtonImageWidget(10, isDaily ? _execute : _join,
            Container(padding: EdgeInsets.all(40.sp), alignment: Alignment.center, width: 1.sw,
                child: LabelCustom(isDaily ? 'Thực hiện' : 'Tham gia', size: 50.sp)), color: StyleCustom.primaryColor))
      ])
    ]);
    return Stack(children: [
      Scaffold(backgroundColor: Colors.white, body: temp,
          appBar: AppBar(title: UtilUI.createLabel('Chi tiết đóng góp'), centerTitle: true, elevation: 0)),
      Loading(bloc)
    ]);
  }

  Widget _uiExeList() {
    if (!detail.containsKey('child_contribution_missions')) return const SizedBox();

    List<Widget> list = [];
    for(var ele in detail['child_contribution_missions']) {
      list.add(ExeContributionItem(ele, isDaily, _checkGoto));
    }
    return Column(children: list);
  }

  void _checkExe(dynamic list) {
    String temp = detail['contribution_mission_status_type'];
    _isExe = temp == 'happenning' || temp == 'processing' || temp == 'uncompleted';
    if (!isDaily) isDaily = temp == 'processing' || temp == 'completed' || temp == 'uncompleted';
    if (!_isExe) return;

    for(var ele in list) {
      if (ele['daily_progress'] < ele['daily_target']) {
        _isExe = true;
        return;
      }
    }

    _isExe = false;
  }

  void _reload() {
    bloc!.add(LoadMembersEvent(detail['id']));
    if (reload != null) reload!();
  }

  void _join() => bloc!.add(JoinMissionEvent(detail['id'], -1));

  void _execute() {
    for(var ele in detail['child_contribution_missions']) {
      if (_checkGoto(ele)) return;
    }
  }

  bool _checkGoto(ele) {
    if (ele['daily_progress'] >= ele['daily_target']) return false;

    if (ele['mission_type'] == 'contribute_images') {
      UtilUI.goToNextPage(context, ExeContributionImagePage(detail['id'], ele, _reload));
      return true;
    }

    if (ele['action_type'] == 'intro_registrations') {
      UtilUI.goToNextPage(context, ProfilePage());
      return true;
    }

    if (ele['action_type'] == 'intro_products') {
      UtilUI.goToNextPage(context, MainPage(index: 4, funDynamicLink: Constants().funChatBotLink));
      return true;
    }

    if (ele['mission_type'] == 'contribute_interact' && ele['action_type'] == 'prices') {
      UtilUI.goToNextPage(context, MainPage(index: 3, funDynamicLink: Constants().funChatBotLink, funReloadPrePage: _reload));
      return true;
    }

    if (ele['mission_type'] == 'contribute_content' || ele['mission_type'] == 'contribute_interact') {
      UtilUI.goToNextPage(context, MainPage(index: 2, funDynamicLink: Constants().funChatBotLink, funReloadPrePage: _reload));
      return true;
    }

    return false;
  }
}