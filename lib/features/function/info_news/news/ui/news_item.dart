import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import '../news_model.dart';
import 'news_detail_page.dart';
import 'news_manage_detail_page.dart';

class NewsItem extends StatelessWidget {
  final NewsModel item;
  final bool isVideo, isEdit;
  final Function funPlayNext, reload;
  final int index;
  const NewsItem(this.item, this.index, this.funPlayNext, {this.isVideo = false, this.isEdit = false,required this.reload, Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) => ButtonImageWidget(0.0, () => _goToDetail(context),
    Container(padding: EdgeInsets.all(40.sp), //height: 220.sp,
      decoration: BoxDecoration(color: index%2==0?const Color(0x01000000):Colors.white),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        ClipRRect(child: FadeInImage.assetNetwork(image: Util.getRealPath(item.image),
            imageErrorBuilder: (_, __, ___) => Image.asset('assets/images/ic_default.png', width: 200.sp, height: 140.sp, fit: BoxFit.fill),
            placeholder: 'assets/images/ic_default.png', width: 220.sp, height: 160.sp, fit: BoxFit.cover),
            borderRadius: BorderRadius.circular(20.sp)),
        Expanded(child: Padding(padding: EdgeInsets.only(left: 40.sp), child:
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 52.sp, color: Colors.black, fontWeight: FontWeight.w500)),
          SizedBox(height: 6.sp),
          Row(children: [
            Icon(Icons.calendar_today, color: StyleCustom.textColor6C, size: 24.sp),
            SizedBox(width: 10.sp),
            Text(Util.dateToString(Util.stringToDateTime(item.created_at),
                locale: Constants().localeVI, pattern: 'dd/MM/yyyy'),
                style: TextStyle(color: StyleCustom.textColor6C, fontSize: 32.sp))
          ]),
          //Expanded(child: SizedBox(height: 40.sp)),
          //const Divider(height: 0.5)
        ])))
      ])));

  void _goToDetail(BuildContext context) {
    String temp = isVideo ? 'Videos' : 'Articles';
    UtilUI.goToNextPage(context, isEdit ? NewsManageDetailPage(item, index, reload) : NewsDetailPage(item, index, funPlayNext: funPlayNext, isVideo: isVideo),funCallback: reload);
    Util.trackActivities(temp.toLowerCase(), path: 'List $temp Screen -> Open $temp ${isEdit?'Updating':'Detail'}');
  }
}
