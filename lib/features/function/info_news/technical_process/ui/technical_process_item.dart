import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import '../technical_process_model.dart';
import 'technical_process_detail_page.dart';

class TechnicalProcessItem extends StatelessWidget {
  final TechnicalProcessModel item;
  final int index;
  const TechnicalProcessItem(this.item, this.index, {Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) => ButtonImageWidget(0.0, () => _goToDetail(context),
      Container(padding: EdgeInsets.fromLTRB(40.sp, 40.sp, 40.sp, 0), height: 740.sp - (item.summary == ''? 120.sp : 0.sp), child:
      Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        ClipRRect(child: FadeInImage.assetNetwork(image: Util.getRealPath(item.image),
            imageErrorBuilder: (_,__,___) => Image.asset('assets/images/ic_default.png', width: 1.sw, height: 400.sp,fit: BoxFit.fitWidth),
            placeholder: 'assets/images/ic_default.png', width: 1.sw, height: 400.sp,fit: BoxFit.fitWidth,),
            borderRadius: BorderRadius.circular(20.sp)),
            SizedBox(height: 30.sp),
        Expanded(child: Padding(padding: EdgeInsets.only(left: 10.sp, right: 10.sp), child:
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 40.sp, color: StyleCustom.primaryColor,fontWeight: FontWeight.bold),),
          SizedBox(height: 10.sp),
          Row(children: [
            Icon(Icons.calendar_today, color: StyleCustom.textColor6C, size: 24.sp),
            SizedBox(width: 10.sp),
            Text(Util.dateToString(Util.stringToDateTime(item.created_at),
                locale: Constants().localeVI, pattern: 'dd/MM/yyyy HH:mm'),
                style: TextStyle(color: StyleCustom.textColor6C, fontSize: 30.sp))
          ]),
          SizedBox(height: 20.sp),
          if (item.summary.isNotEmpty) Text(item.summary, style: TextStyle(fontSize: 40.sp,color: Colors.black),
            maxLines: 2, overflow: TextOverflow.ellipsis)
        ])))
  ]), color: index%2!=0?const Color(0xFFFAFAFA):Colors.white));

  void _goToDetail(BuildContext context) => UtilUI.goToNextPage(context, TechnicalProcessDetailPage(item), );
}
