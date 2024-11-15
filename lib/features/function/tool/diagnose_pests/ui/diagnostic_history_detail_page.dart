import 'package:hainong/common/util/util.dart';
import 'package:hainong/common/util/util_ui.dart';
import 'package:hainong/features/function/support/pests_handbook/ui/pests_handbook_list_page.dart';
import '../model/diagnostic_history_model.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';

class DiagnosisHistoryDetailPage extends StatefulWidget {
  final DiagnosticHistoryModel item;
  const DiagnosisHistoryDetailPage(this.item,{Key? key}) : super(key: key);

  @override
  State<DiagnosisHistoryDetailPage> createState() => _DiagnosisHistoryDetailPageState();
}

class _DiagnosisHistoryDetailPageState extends State<DiagnosisHistoryDetailPage> {
  @override
  Widget build(BuildContext context) {
    final style1 = TextStyle(fontSize: 45.sp, fontWeight: FontWeight.w700, color: Colors.black);
    final style2 = TextStyle(fontSize: 45.sp, color: Colors.black,fontWeight: FontWeight.w400);
    return Scaffold(appBar: AppBar(title: UtilUI.createLabel('Chi tiết chẩn đoán'), centerTitle: true),
      body: ListView(padding: EdgeInsets.symmetric(horizontal: 50.sp, vertical: 30.sp), children: [
          UtilUI.createLabel(widget.item.category_name, color: Colors.black, fontSize: 60.sp),
          Padding(padding: EdgeInsets.symmetric(vertical: 35.sp),
            child: ClipRRect(borderRadius: BorderRadius.circular(48.sp),
              child: FadeInImage.assetNetwork(image: Util.getRealPath(widget.item.image),
                  placeholder: 'assets/images/ic_default.png',
                  width: 1.sw, height: 0.65.sw, fit: BoxFit.fill,
                  imageErrorBuilder: (context, obj, stack) => Image.asset('assets/images/ic_default.png',
                      width: 1.sw, height: 0.8.sw, fit: BoxFit.fill)))
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("Người dùng: ", style: style2),
            Text(widget.item.user_name, style: style2)
          ]),
          Padding(padding: EdgeInsets.symmetric(vertical: 40.sp),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Nơi gửi: ", style: style2),
              Text(widget.item.address, style: style2)
            ])),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("Thời gian gửi: ", style: style2),
            Text(Util.strDateToString(widget.item.created_at,), style: style2)
          ]),
          Padding(padding: EdgeInsets.symmetric(vertical: 40.sp),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Tỉ lệ (AI) chuẩn đoán: ", style: style2),
              Text("${widget.item.percent}%", style: style1)
            ])),
          ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => SizedBox(height: 40.sp),
              itemCount: widget.item.ai_results.length,
              itemBuilder: (context, index) => InkWell(
                onTap: () => UtilUI.goToNextPage(context, PestsHandbookListPage(widget.item.ai_results[index].suggest)),
                child: Row(children: [
                    ClipRRect(borderRadius: BorderRadius.circular(15.sp),
                      child: FadeInImage.assetNetwork(image: Util.getRealPath(widget.item.ai_results[index].image),
                          placeholder: 'assets/images/ic_default.png',
                          width: 0.25.sw, height: 0.16.sw, fit: BoxFit.fill,
                          imageErrorBuilder: (context, obj, stack) => Image.asset('assets/images/ic_default.png',
                              width: 0.25.sw, height: 0.16.sw, fit: BoxFit.fill))),
                    SizedBox(width: 20.sp),
                    Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(widget.item.ai_results[index].suggest, style: style2),
                        Text("${widget.item.ai_results[index].percent}%", style: style2)
                    ]))
                ])))
      ]));
  }
}
