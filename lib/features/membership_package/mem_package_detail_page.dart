import 'package:hainong/common/ui/box_dec_custom.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/image_network_asset.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/avatar_circle_widget.dart';
import 'package:hainong/common/ui/mem_package_content.dart';
import 'mem_package_detail_bloc.dart';

class MemPackageDetailPage extends BasePage {
  final bool inUse, hasHeader, isConfirm, isMine;
  final int idHistory;
  final Function? fnReload;
  MemPackageDetailPage(dynamic detail, dynamic content, {Key? key, this.inUse = false, this.hasHeader = true, this.isMine = false,
    this.isConfirm = false, this.fnReload, this.idHistory = -1}):super(key: key, pageState: _DetailState(detail, content));
}

class _DetailState extends BasePageState {
  final dynamic detail, content;
  final List _payments = [
    'point',
    //'vnpay',
    //'momo',
    //'zalopay'
  ];
  bool _show = true;

  _DetailState(this.detail, this.content);

  @override
  void initState() {
    _show = !(widget as MemPackageDetailPage).isMine;
    bloc = MemPackageDetailBloc(detail['id'], !detail.containsKey('membership_package_features'), (widget as MemPackageDetailPage).idHistory);
    super.initState();
    bloc!.stream.listen((state) {
      if (state is ShowClearSearchState) setState(() {});
      else if (state is GetAddressState && isResponseNotError(state.address, passString: true)) _showDialogSuccess();
      else if (state is JoinMissionState && isResponseNotError(state.resp, passString: true)) _showDialogSuccess();
      else if (state is LoadReviewsState && isResponseNotError(state.resp, passString: true)) {
        setState(() => _show = false);
        UtilUI.showCustomDialog(context, 'Đã từ chối kích hoạt gói cước thành công');
      } else if (state is LoadCatalogueState) setState(() {});
      else if (state is LoadMembersState) {
        if (state.resp.containsKey('error')) {
          UtilUI.showCustomDialog(context, state.resp['error']).whenComplete(() => UtilUI.goBack(context, false));
          return;
        }
        detail.putIfAbsent('membership_package_features', () => state.resp['membership_package_features']);
        if (content == null) detail.addAll(state.resp);
        setState(() {});
      } else if (state is LeaveMissionState && isResponseNotError(state.resp, passString: true)) {
        final reload = (widget as MemPackageDetailPage).fnReload;
        if (reload != null) reload(null);
        UtilUI.showCustomDialog(context, 'Bạn đã hủy gói cước thành công', title: 'Thông báo');
      }
    });
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    final ctr = bloc as MemPackageDetailBloc;
    final page = widget as MemPackageDetailPage;
    final temp = Stack(children: [
      ImageNetworkAsset(path: detail['image']??'', height: 0.4.sh, width: 1.sw),
      Container(decoration: BoxDecoration(color: Colors.white,
          boxShadow: [BoxShadow(
              color: Colors.grey.withOpacity(0.5), spreadRadius: 1, blurRadius: 7, offset: const Offset(0, 1) // changes position of shadow
          )],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
          padding: EdgeInsets.all(40.sp), margin: EdgeInsets.only(top: 0.3.sh),
          child: Scaffold(
            backgroundColor: Colors.white,
              body: Column(children: [
            content ?? MemPackageContent(detail), SizedBox(height: 40.sp),
            LabelCustom(ctr.isRegister ? 'Phương thức đổi gói cước sử dụng' : 'Danh sách tính năng nhận được', color: Colors.green, size: 50.sp, weight: FontWeight.w400),
            Expanded(child: ctr.isRegister ? _getMethods(_payments) : _getFeatures(detail['membership_package_features']??[])),
            if (!page.inUse && !page.isConfirm && _show && page.idHistory < 0)
              Padding(padding: EdgeInsets.symmetric(vertical: 40.sp), child: ButtonImageWidget(10, _register,
                Container(padding: EdgeInsets.all(40.sp), alignment: Alignment.center, width: 1.sw,
                    child: LabelCustom(ctr.isRegister ? 'Thanh toán' : 'Đăng ký', size: 50.sp)), color: StyleCustom.primaryColor)),
            if (page.isMine && !_show && page.idHistory < 0) Padding(padding: EdgeInsets.symmetric(vertical: 40.sp), child: ButtonImageWidget(10, _dismiss,
                Container(padding: EdgeInsets.all(40.sp), alignment: Alignment.center, width: 1.sw,
                    child: LabelCustom('Hủy gói cước', size: 50.sp)), color: Colors.orange)),
            if (page.isConfirm && _show && page.idHistory < 0) Padding(padding: EdgeInsets.symmetric(vertical: 40.sp), child: ButtonImageWidget(10, _confirm,
                Container(padding: EdgeInsets.all(40.sp), alignment: Alignment.center, width: 1.sw,
                    child: LabelCustom('Xác nhận sử dụng gói cước', size: 50.sp)), color: StyleCustom.primaryColor)),
            if (ctr.isRegister) Padding(padding: EdgeInsets.only(bottom: 40.sp), child:
              ButtonImageWidget(10, ctr.cancel, Container(padding: EdgeInsets.all(40.sp), alignment: Alignment.center,
                width: 1.sw, child: LabelCustom('Hủy', size: 50.sp)), color: Colors.black12))
          ], crossAxisAlignment: CrossAxisAlignment.start)))
    ]);
    String title = 'Chi tiết gói cước';
    if (page.hasHeader && page.idHistory > 0) title += (page.inUse ? ' đang' : ' đã') + ' dùng';
    return Stack(children: [
      page.hasHeader ? Scaffold(backgroundColor: Colors.white, body: temp,
          appBar: AppBar(title: UtilUI.createLabel(title), centerTitle: true, elevation: .0)) : temp,
      Loading(bloc)
    ]);
  }

  Widget _getFeatures(List features) => ListView.separated(padding: EdgeInsets.symmetric(vertical: 40.sp),
      separatorBuilder: (context, index) => SizedBox(height: 20.sp), itemCount: features.length,
      itemBuilder: (context, index) {
        final modules = (bloc as MemPackageDetailBloc).modules;
        final String mKey = features[index]['app_module_key']??'';
        if (!modules.containsKey(mKey) || !modules[mKey]!.status) return const SizedBox();

        final number = (features[index]['used_times']??.0).toDouble();
        String temp = '';
        if (features[index].containsKey('current_used_times')) {
          final used = (features[index]['current_used_times']??.0).toDouble();
          temp = 'Sử dụng: ' + Util.doubleToString(used) + '/' + Util.doubleToString(number);
        } else temp = Util.doubleToString(number) + ' lần sử dụng';
        final platforms = features[index]['app_sessions']??[];
        return Container(padding: EdgeInsets.all(20.sp),
            decoration: BoxDecCustom(radius: 5, bgColor: const Color(0x1FD9D9D9), borderColor: const Color(0x66C4C4C4), width: 1.5, hasBorder: true, hasShadow: false),
            child: Row(children: [
              AvatarCircleWidget(link: _getIcon(mKey), size: 100.sp, assetsImageReplace: 'assets/images/ic_default.png'),
              SizedBox(width: 20.sp),
              Expanded(child: Column(children: [
                Row(children: [
                  Expanded(child: LabelCustom(features[index]['feature_name']??'', color: Colors.black, size: 38.sp, weight: FontWeight.w400)),
                  Expanded(child: LabelCustom(features[index]['app_module_name']??'', color: Colors.black, size: 38.sp, weight: FontWeight.w400, align: TextAlign.right))
                ], crossAxisAlignment: CrossAxisAlignment.start),
                SizedBox(height: 20.sp),
                Row(children: [
                  Expanded(child: LabelCustom(temp, color: Colors.black, size: 38.sp, weight: FontWeight.w400)),
                  Expanded(child: LabelCustom('Nền tảng: ', color: Colors.black, size: 38.sp, weight: FontWeight.w400, align: TextAlign.right)),
                  if (platforms.isNotEmpty) _getPlatforms(platforms[0] == 'web'),
                  if (platforms.length == 2) _getPlatforms(platforms[1] == 'web'),
                ])
              ]))
            ])
        );
      });

  Widget _getMethods(List methods) {
    final ctr = bloc as MemPackageDetailBloc;
    return BlocBuilder(bloc: ctr, buildWhen: (oldS, newS) => newS is GetLocationState,
      builder: (context, state) => ListView.separated(padding: EdgeInsets.symmetric(vertical: 40.sp),
        separatorBuilder: (context, index) => SizedBox(height: 40.sp), itemCount: methods.length,
        itemBuilder: (context, index) {
          return ButtonImageWidget(5, () => ctr.changeMethod(methods[index]),
              Container(padding: EdgeInsets.all(40.sp), decoration: BoxDecCustom(radius: 5),
                  child: Row(children: [
                    Container(width: 20, height: 20, margin: const EdgeInsets.only(right: 5), padding: const EdgeInsets.all(2),
                        decoration: BoxDecCustom(radius: 100, hasShadow: false, hasBorder: true, borderColor: Colors.black,
                            width: 2, bgColor: ctr.method == methods[index] ? Colors.greenAccent : Colors.white)),
                    LabelCustom(MultiLanguage.get('opt_' + methods[index]), size: 40.sp, color: Colors.black, weight: FontWeight.w400)
                  ])));
        }));
  }

  Widget _getPlatforms(bool isWeb) => Icon(isWeb ? Icons.language : Icons.phone_android, color: isWeb ? Colors.blue : Colors.orange, size: 48.sp);

  String _getIcon(String icon) {
    final modules = (bloc as MemPackageDetailBloc).modules;
    return modules.containsKey(icon) ? modules[icon]!.icon : '';
  }

  void _showDialogSuccess() => showDialog(useSafeArea: false, context: context,
    builder: (context) => Scaffold(
      appBar: AppBar(title: UtilUI.createLabel('Thanh toán'), centerTitle: true, automaticallyImplyLeading: false),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 0.1.sh,horizontal: 40.sp),
        child: Column(children: [
          Image.asset('assets/images/v7/ic_v7_success.png'),
          LabelCustom('Thành công!', color: Colors.black87, size: 80.sp),
          Padding(padding: EdgeInsets.only(bottom: 80.sp),
              child: LabelCustom('Hãy truy cập và sử dụng tính năng mới nhé', color: Colors.black26, size: 42.sp, weight: FontWeight.w400)),
          ButtonImageWidget(10, () => UtilUI.goBack(context, ''),
            Container(padding: EdgeInsets.all(40.sp), alignment: Alignment.center,
                child: LabelCustom('Hoàn thành', size: 50.sp)), color: StyleCustom.primaryColor),
      ], mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
        ))
    )).whenComplete(() {
      (bloc as MemPackageDetailBloc).cancel();
      setState(() => _show = false);
      final reload = (widget as MemPackageDetailPage).fnReload;
      if (reload != null) reload(detail);
    });

  void _confirm() {
    String temp = 'Bạn có chắc là muốn dùng gói cước này không?\nChọn "Đồng ý" ';
    final ctr = bloc as MemPackageDetailBloc;
    if (ctr.idCurrent != -1 && ctr.id != ctr.idCurrent && !ctr.isRegister) {
      temp += 'thì gói cước hiện tại "${(bloc as MemPackageDetailBloc).idCurrentName}" sẽ được thay thế bằng gói cước mới\n';
    } else {
      temp += 'để kích hoạt dùng gói cước này\n';
    }
    temp += 'Chọn "Từ chối" để không kích hoạt gói cước này';

    UtilUI.showCustomDialog(context, temp, isActionCancel: true, lblCancel: 'TỪ CHỐI', isClose: true).then((value) {
      if (value != null) bloc!.add(JoinMissionEvent(detail['id'], value ? 1 : 0));
    });
  }

  void _register() {
    final ctr = bloc as MemPackageDetailBloc;
    if(ctr.idCurrent != -1 && ctr.id != ctr.idCurrent && !ctr.isRegister){
      UtilUI.showCustomDialog(context, 'Bạn đang sử dụng gói cước "${ctr.idCurrentName}", cần được hủy trước khi đăng ký gói cước mới.\n'
        'Chọn "Đồng ý" để huỷ gói cước hiện tại và kích hoạt dùng gói cước mới\n', isClose: true).then((value) {
          if (value != null && value) ctr.add(ShowClearSearchEvent(!ctr.isRegister));
        });
    } else {
      ctr.add(ShowClearSearchEvent(!ctr.isRegister));
    }
  }

  void _dismiss() => UtilUI.showCustomDialog(context, 'Bạn có chắc là muốn hủy gói cước này không?\n'
      'Nếu bạn chọn "Đồng ý" thì gói cước hiện tại của bạn đang dùng sẽ được hủy',
      isActionCancel: true).then((value) {
    if (value != null && value) bloc!.add(LeaveMissionEvent(detail['id'], 0, 0));
  });
}