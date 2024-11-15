import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hainong/common/multi_language.dart';
import 'package:hainong/common/util/util.dart';
import '../model/diagnostic_model.dart';

class DiagnosisPestDetailPage extends StatelessWidget {
  final List<Diagnostic> diagnostics;
  const DiagnosisPestDetailPage(this.diagnostics, {Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0,
          titleSpacing: 0,
          title: Text(MultiLanguage.get('ttl_diagnostic_detail'))),
      body: ListView.builder(
        padding: EdgeInsets.fromLTRB(20.sp, 0, 20.sp, 20.sp),
        itemCount: diagnostics.length,
        itemBuilder: (context, index) => _Item(diagnostics[index])
      )
    );
  }
}

class _Item extends StatelessWidget {
  final Diagnostic item;
  const _Item(this.item);
  @override
  Widget build(BuildContext context) {
    String content = '';
    item.predicts.forEach((ele) =>
      content += ele.suggest + (ele.suggest.toLowerCase().contains(MultiLanguage
          .get('lbl_unknown').toLowerCase()) ? ' - ' : ' (${ele.percent}%) - '));
    if (content.isNotEmpty) content = content.substring(0, content.length - 2);
    return item.message.isEmpty ? Stack(
        alignment: Alignment.bottomLeft, children: [
      Container(width: 1.sw, margin: EdgeInsets.only(top: 20.sp),
          child: FadeInImage.assetNetwork(image: Util.getRealPath(item.image),
              placeholder: 'assets/images/ic_default.png', fit: BoxFit.cover)
      ),
      Container(padding: EdgeInsets.all(20.sp), color: Colors.black26, width: 1.sw,
          child: Text(content, style: TextStyle(color: Colors.white, fontSize: 48.sp,
              fontWeight: FontWeight.w500))
      )
    ]) : Container(margin: EdgeInsets.only(top: 20.sp), child: Text('* ' + item.message,
        style: TextStyle(color: Colors.black, fontSize: 48.sp)));
  }
}