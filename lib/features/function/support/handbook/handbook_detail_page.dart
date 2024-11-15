import 'package:flutter_html/flutter_html.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/util/util_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'handbook_page.dart';

class HandBookDetailPage extends StatelessWidget {
  final HandbookModel item;
  const HandBookDetailPage(this.item, {Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(elevation: 0, titleSpacing: 0,
      title: UtilUI.createLabel('Bài viết'), centerTitle: true), backgroundColor: Colors.white,
      body: ListView(children: [
        Row(children: [
          Image.asset('assets/images/ic_question.png', width: 56.sp, height: 56.sp),
          SizedBox(width: 40.sp),
          Expanded(child: UtilUI.createLabel(item.question, textAlign: TextAlign.left, line: 100,
              fontSize: 54.sp, fontWeight: FontWeight.w500, color: const Color(0xFF494949)))
        ]),
        Padding(padding: EdgeInsets.symmetric(vertical: 40.sp), child: const Divider(height: 2)),
        UtilUI.createLabel('Trả lời', textAlign: TextAlign.left, line: 100,
            fontSize: 54.sp, fontWeight: FontWeight.w500, color: const Color(0xFF1AAD80)),
        Html(data: item.answer, style: {"body": Style(fontSize: FontSize(46.sp), margin: EdgeInsets.zero)},
            onLinkTap: (url, render, map, ele) => launch(url!, enableJavaScript: true),
            onImageTap: (url, render, map, ele) => launch(url!, enableJavaScript: true))
      ], padding: EdgeInsets.all(40.sp))
  );
}