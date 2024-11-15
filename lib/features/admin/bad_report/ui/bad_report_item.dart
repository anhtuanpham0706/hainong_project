import 'package:hainong/common/ui/avatar_circle_widget.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/button_image_circle_widget.dart';
import 'package:hainong/common/ui/string_html.dart';
import '../bad_report_model.dart';

class BadReportItem extends StatelessWidget {
  final BadReportModel item;
  final Function funLoadComment, funDelete;
  const BadReportItem(this.item, this.funLoadComment, this.funDelete, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => item.id < 1 ? const SizedBox() :
    Stack(alignment: Alignment.topRight, children: [
      ButtonImageCircleWidget(0, () => funLoadComment(item.objId, item.type),
        child: Container(color: Colors.white, padding: EdgeInsets.fromLTRB(40.sp, item.content.isEmpty ? 40.sp : 0, 40.sp, 40.sp),
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Column(children: [
                if (item.content.isNotEmpty) SizedBox(height: 40.sp),
                AvatarCircleWidget(link: item.image, size: 120.sp),
                Container(width: 200.sp, padding: EdgeInsets.only(top: 10.sp),
                    child: UtilUI.createLabel(item.name, color: StyleCustom.textColor2C, fontSize: 28.sp,
                        fontWeight: FontWeight.normal, textAlign: TextAlign.center, line: 2))
              ]),
              SizedBox(width: 40.sp),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.content.isNotEmpty) Container(constraints: BoxConstraints(maxHeight: 136.sp),
                        child: StringHtml(item.content, allowGotoShop: false, clearPage: false), padding: EdgeInsets.only(bottom: 10.sp)),
                    if (item.reason.isNotEmpty) Padding(padding: EdgeInsets.only(bottom: 10.sp), child:
                      UtilUI.createLabel('Lý do: ' + item.reason, color: StyleCustom.textColor2C, fontSize: 36.sp, style: FontStyle.italic,
                        fontWeight: FontWeight.normal, overflow: TextOverflow.clip)),
                    Row(children: [
                      Icon(Icons.av_timer, size: 40.sp, color: Colors.orange),
                      Expanded(child: UtilUI.createLabel(' ${Util.getTimeAgo(item.created_at)}',
                          color: StyleCustom.textColor6C, fontSize: 30.sp, fontWeight: FontWeight.normal))
                    ])
                  ]))
            ]))),
      Container(padding: EdgeInsets.all(5.sp), decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50), color: Colors.black12
        ), margin: EdgeInsets.only(top: 20.sp, right: 20.sp),
        child: ButtonImageCircleWidget(50, funDelete, child: Icon(Icons.clear, color: Colors.white, size: 56.sp)))
  ]);
}
