import 'package:hainong/common/constants.dart';
import 'package:hainong/features/function/info_news/news/news_model.dart';
import 'package:hainong/common/style_custom.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/common/util/util_ui.dart';
import 'pests_handbook_detail_page.dart';

class PestsHandbookItem extends StatelessWidget {
  final Constants constants;
  final NewsModel item;
  const PestsHandbookItem(this.constants, this.item, {Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) => ButtonImageWidget(0.0, () => _goToDetail(context),
      Container(padding: EdgeInsets.fromLTRB(40.sp, 40.sp, 40.sp, 0), height: 220.sp, child:
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(child: FadeInImage.assetNetwork(image: Util.getRealPath(item.image),
            placeholder: 'assets/images/ic_default.png', width: 200.sp, height: 140.sp, fit: BoxFit.fill,
          imageErrorBuilder: (_,__,___) => Image.asset('assets/images/ic_default.png', fit: BoxFit.fill),
          placeholderErrorBuilder: (_,__,___) => Image.asset('assets/images/ic_default.png', fit: BoxFit.fill)
        ),
            borderRadius: BorderRadius.circular(20.sp)),
        Expanded(child: Padding(padding: EdgeInsets.only(left: 20.sp, right: 20.sp), child:
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 42.sp, color: Colors.black)),
          SizedBox(height: 6.sp),
          Row(children: [
            Icon(Icons.calendar_today, color: StyleCustom.textColor6C, size: 24.sp),
            SizedBox(width: 10.sp),
            Text(Util.dateToString(Util.stringToDateTime(item.created_at),
                locale: constants.localeVI, pattern: 'dd/MM/yyyy'),
                style: TextStyle(color: StyleCustom.textColor6C, fontSize: 30.sp))
          ]),
          Expanded(child: SizedBox(height: 40.sp)),
          const Divider(height: 0.5)
        ])))
  ])));

  void _goToDetail(BuildContext context) {
    UtilUI.goToNextPage(context, PestsHandbookDetailPage(item), );
    Util.trackActivities('pests_hand_book', path: 'Pests Hand Book List Screen -> Show Detail ${item.content}');
  }
}
