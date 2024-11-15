import 'package:flutter/services.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/shadow_decoration.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import 'mission_ui.dart';

class MissionReviewItem extends StatefulWidget {
  dynamic item;
  final int index;
  final bool isView, isLeader;
  final Function funCheckPer;
  final _MissionReviewItemState pageState = _MissionReviewItemState();
  MissionReviewItem(this.item, this.index, this.isView, this.isLeader, this.funCheckPer, {Key? key}):super(key:key);

  @override
  _MissionReviewItemState createState() => pageState;
}

class _MissionReviewItemState extends State<MissionReviewItem> with AutomaticKeepAliveClientMixin {
  final TextEditingController ctrPer1 = TextEditingController(), ctrPer2 = TextEditingController();
  final FocusNode fcPer1 = FocusNode(), fcPer2 = FocusNode();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    ctrPer1.removeListener(_listenPer);
    ctrPer2.removeListener(_listenPer);
    ctrPer1.dispose();
    fcPer1.dispose();
    ctrPer2.dispose();
    fcPer2.dispose();
    super.dispose();
  }

  @override
  void initState() {
    int per1 = (widget.item['percent_rate']??0).toInt(), per2 = (widget.item['owner_percent_rate']??0).toInt();
    if (per1 > 0) ctrPer1.text = per1.toString();
    if (per2 > 0) ctrPer2.text = per2.toString();
    widget.item['point'] = (widget.item['mission_point']??.0).toDouble() * per1/100 * per2/100;
    if (!widget.isView) {
      ctrPer1.addListener(_listenPer);
      ctrPer2.addListener(_listenPer);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final status = widget.item['status']??'';
    return Container(child: Column(children: [
      MissionLine('Tên thành viên', widget.item['user_name']??''),
      MissionLine('Số điện thoại', widget.item['user_phone']??'', padding: EdgeInsets.symmetric(horizontal: 40.sp)),
      MissionLine('Tên VN tham gia', widget.item['mission_detail_title']??''),
      MissionLine('Điểm thưởng NV', Util.doubleToString((widget.item['mission_point']??.0).toDouble()), padding: EdgeInsets.fromLTRB(40.sp, 0, 40.sp, 40.sp)),

      if (status == 'accepted') ...[
        LabelCustom('Đánh giá thành viên', size: 42.sp, color: const Color(0xFF1AAD80), weight: FontWeight.normal),
        Container(padding: EdgeInsets.only(top: 20.sp), width: 0.8.sw,
            child: TextFieldCustom(ctrPer1, fcPer1, null, 'Nhập % mức độ hài lòng (từ 0 - 100%)', readOnly: !widget.isLeader || widget.isView,
                type: TextInputType.number, color: const Color(0XFFF5F6F8), borderColor: const Color(0XFFF5F6F8), maxLength: 3,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))], align: TextAlign.center)),

        SizedBox(height: 40.sp),
        LabelCustom('Đánh giá chất lượng hoàn thành nhiệm vụ', size: 42.sp, color: const Color(0xFF1AAD80), weight: FontWeight.normal),
        Container(padding: EdgeInsets.only(top: 20.sp), width: 0.8.sw,
            child: TextFieldCustom(ctrPer2, fcPer2, null, 'Nhập % mức độ hài lòng (từ 0 - 100%)', readOnly: widget.isLeader || widget.isView,
                type: TextInputType.number, color: const Color(0XFFF5F6F8), borderColor: const Color(0XFFF5F6F8), maxLength: 3,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))], align: TextAlign.center)),

        SizedBox(height: 40.sp),
        LabelCustom(Util.doubleToString((widget.item['point']??.0).toDouble()), size: 54.sp, color: const Color(0xFF424242), weight: FontWeight.normal),
        LabelCustom('Điểm thưởng nhận được', size: 38.sp, color: const Color(0xFF424242), weight: FontWeight.normal),
        SizedBox(height: 40.sp)
      ],

      if (status != 'accepted') MissionLine('Trạng thái', MultiLanguage.get('opt_' + status), padding: EdgeInsets.fromLTRB(40.sp, 0, 40.sp, 40.sp))
    ]), decoration: ShadowDecoration(size: 16.sp), margin: EdgeInsets.all(20.sp),);
  }

  void _listenPer() {
    if (!fcPer1.hasFocus || !fcPer2.hasFocus) {
      if (widget.funCheckPer(ctrPer1, fcPer1)) return;

      double point = (widget.item['mission_point']??.0).toDouble();
      double per1 = 0;
      if (ctrPer1.text.isNotEmpty) {
        per1 = double.parse(ctrPer1.text);
        if (per1 > 100) {
          ctrPer1.text = ctrPer1.text.substring(0, ctrPer1.text.length - 1);
          per1 = double.parse(ctrPer1.text) / 100;
          UtilUI.showCustomDialog(context, 'Phần trăm không được lớn hơn 100');//.whenComplete(() => fcPer1.requestFocus());
        } else if (per1 == 0) {
          ctrPer1.text = '';
          UtilUI.showCustomDialog(context, 'Phần trăm phải lớn hơn 0');//.whenComplete(() => fcPer1.requestFocus());
        } else per1 = per1 / 100;
      }
      double per2 = 0;
      if (ctrPer2.text.isNotEmpty) {
        per2 = double.parse(ctrPer2.text);
        if (per2 > 100) {
          ctrPer2.text = ctrPer2.text.substring(0, ctrPer2.text.length - 1);
          per2 = double.parse(ctrPer2.text) / 100;
          UtilUI.showCustomDialog(context, 'Phần trăm không được lớn hơn 100');//.whenComplete(() => fcPer2.requestFocus());
        } else if (per2 == 0) {
          ctrPer2.text = '';
          UtilUI.showCustomDialog(context, 'Phần trăm phải lớn hơn 0');//.whenComplete(() => fcPer2.requestFocus());
        } else per2 = per2 / 100;
      }
      widget.item['point'] = point * per1 * per2;
      setState(() {});
    }
  }
}