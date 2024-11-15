import 'package:hainong/common/ui/box_dec_custom.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/multi_language.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/common/util/util_ui.dart';
import '../model/diagnostic_history_model.dart';
import 'diagnostic_history_detail_page.dart';

class DiagnosticHistoryItem extends StatelessWidget {
  final DiagnosticHistoryModel item;
  const DiagnosticHistoryItem(this.item, {Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) {
    final style1 = TextStyle(fontSize: 42.sp, fontWeight: FontWeight.w500, color: const Color(0xFF505050));
    final style2 = TextStyle(fontSize: 33.sp, color: const Color(0xFF696969));
    return InkWell(
      onTap: () => UtilUI.goToNextPage(context, DiagnosisHistoryDetailPage(item)),
      child: Container(
          margin: EdgeInsets.symmetric(vertical: 20.sp),
          padding: EdgeInsets.all(32.sp),
          decoration: BoxDecCustom(), child: Column(children: [
        Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(48.sp),
              child: FadeInImage.assetNetwork(image: Util.getRealPath(item.image),
                  placeholder: 'assets/images/ic_default.png',
                  width: 96.sp,
                  height: 96.sp,
                  fit: BoxFit.fill, imageErrorBuilder: (context, obj, stack) => Image.asset('assets/images/ic_default.png',
                      width: 96.sp,
                      height: 96.sp,
                      fit: BoxFit.fill))),
          SizedBox(width: 28.sp),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.category_name, style: style1),
            SizedBox(height: 8.sp),
            Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
              Text(item.address, style: style2),
              Container(decoration: BoxDecoration(
                  color: Colors.orange, borderRadius: BorderRadius.circular(10.sp)),
                  width: 10.sp, height: 10.sp, margin: EdgeInsets.only(left: 10.sp, right: 10.sp)),
              Text(Util.getTimeAgo(item.created_at), style: style2),
            ])
          ]))
        ]),
        Divider(height: 50.sp, thickness: 0.5),
        Row(children: [
          Image.asset('assets/images/ic_pest.png', width: 36.sp, height: 36.sp),
          Expanded(flex:6, child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
            Text(' ' + item.suggest, style: style1),
            Text(MultiLanguage.get('lbl_disease'), style: style2)
          ])),
          item.suggest.toLowerCase().contains(MultiLanguage.get('lbl_unknown').toLowerCase()) ? const SizedBox() :
          Expanded(flex:5, child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, alignment: WrapAlignment.end, children: [
            Image.asset('assets/images/ic_diagnostic.png', width: 36.sp, height: 36.sp),
            Text(' ' + item.percent.toString() + '%', style: style1),
            Text(MultiLanguage.get('lbl_diagnostic'), style: style2)
          ]))
        ])
      ])
      ),
    );
  }
}