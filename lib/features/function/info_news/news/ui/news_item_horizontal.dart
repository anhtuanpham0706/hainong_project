import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import '../news_model.dart';
import 'news_detail_page.dart';

class NewsItemHorizontal extends StatelessWidget {
  final NewsModel item;
  final bool isVideo;
  final int hasReplace;
  const NewsItemHorizontal(this.item, this.isVideo, this.hasReplace, {Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) => Container(margin: EdgeInsets.only(right: 20.sp), width: 0.3.sw, child:
    ButtonImageWidget(0, () => _goToDetail(context),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(child: FadeInImage.assetNetwork(image: Util.getRealPath(item.image),
            imageErrorBuilder: (_,__,___) => Image.asset('assets/images/ic_default.png', width: 0.3.sw, height: 200.sp, fit: BoxFit.fitWidth),
            placeholder: 'assets/images/ic_default.png', width: 0.3.sw, height: 200.sp, fit: BoxFit.fitWidth),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20.sp), topRight: Radius.circular(20.sp))),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(child: Text(item.title, overflow: TextOverflow.ellipsis,
              maxLines: 1, style: TextStyle(fontSize: 36.sp, color: Colors.black)),
              padding: EdgeInsets.symmetric(vertical: 10.sp)),
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Icon(Icons.calendar_today, color: StyleCustom.textColor6C, size: 24.sp),
            SizedBox(width: 10.sp),
            Expanded(child: Text(Util.dateToString(Util.stringToDateTime(item.created_at),
                locale: Constants().localeVI, pattern: 'dd/MM/yyyy'),
                style: TextStyle(color: StyleCustom.textColor6C, fontSize: 30.sp)))
          ])
        ]))
  ])));

  void _goToDetail(BuildContext context) {
    final page = NewsDetailPage(item, -1, isVideo: isVideo, hasReplace: hasReplace + 1);
    hasReplace > 0 ? UtilUI.goToPage(context, page, null) : UtilUI.goToNextPage(context, page);
  }
}
