import 'package:flutter_html/flutter_html.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/features/function/info_news/news/news_model.dart';
import 'package:hainong/common/multi_language.dart';
import 'package:hainong/common/style_custom.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/util/util.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';

class PestsHandbookDetailPage extends StatelessWidget {
  final NewsModel item;
  const PestsHandbookDetailPage(this.item, {Key? key}):super(key:key);

  @override
  Widget build(BuildContext context) => Stack(children: [
      Scaffold(appBar: AppBar(elevation: 0, titleSpacing: 0, centerTitle: true, title: LabelCustom(
          MultiLanguage.get('ttl_pests_handbook_detail'), align: TextAlign.center, size: 50.sp)),
          body: ListView(children: [
            /*Container(height: 0.3.sh, decoration: BoxDecoration(
              image: DecorationImage(image: FadeInImage.assetNetwork(image: Util.hasDomain(item.image) ? item.image : Constants().baseUrlImage + item.image,
                  placeholder: 'assets/images/ic_default.png').image, fit: BoxFit.fill)
            )),*/
            Container(padding: EdgeInsets.fromLTRB(20.sp, 20.sp, 20.sp, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.title, style: TextStyle(fontSize: 54.sp, color: Colors.black, fontWeight: FontWeight.w500)),
                  SizedBox(height: 10.sp),
                  Row(children: [
                    Icon(Icons.calendar_today, color: StyleCustom.textColor6C, size: 24.sp),
                    SizedBox(width: 10.sp),
                    Text(Util.dateToString(Util.stringToDateTime(item.created_at),
                        locale: Constants().localeVI, pattern: 'dd/MM/yyyy'),
                        style: TextStyle(color: StyleCustom.textColor6C, fontSize: 30.sp))
                  ]),
                  Html(data: item.content, style: {"body": Style(fontSize: FontSize(48.sp))},
                      //onLinkTap: (url, render, map, ele) => launchUrl(Uri.parse(url!)),
                      onLinkTap: (url, render, map, ele) => launch(url!, enableJavaScript: true),
                      //onImageTap: (url, render, map, ele) => launchUrl(Uri.parse(url!))),
                      onImageTap: (url, render, map, ele) => launch(url!, enableJavaScript: true)),
            ]))
          ])
      )
    ]);
}