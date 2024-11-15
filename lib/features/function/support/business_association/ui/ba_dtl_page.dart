import 'package:flutter_html/flutter_html.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/common/util/util_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';

class BADetailPage extends StatefulWidget {
  final dynamic item;
  const BADetailPage(this.item, {Key? key}) :super(key: key);
  @override
  _BADetailPageState createState() => _BADetailPageState();
}

class _BADetailPageState extends State<BADetailPage> {
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(elevation: 5, titleSpacing: 0, centerTitle: true,
    title: UtilUI.createLabel('Thông tin doanh nghiệp', textAlign: TextAlign.center),
    // actions: [if (widget.item.is_owner) IconButton(onPressed: () => UtilUI.goToNextPage(context, BAEditPage(widget.item),
    //     funCallback: (value) {
    //       if (value != null) setState(() {});
    //     }), icon: Icon(Icons.edit, color: Colors.white, size: 64.sp)
    // )]
  ),
    body: ListView(children: [
      FadeInImage.assetNetwork(image: Util.getRealPath(widget.item.image),
        placeholder: 'assets/images/ic_default.png', height: 0.3.sh, fit: BoxFit.fill,
        imageErrorBuilder: (_,__,___) => Image.asset('assets/images/ic_default.png', height: 0.3.sh, fit: BoxFit.fill)),
      Container(padding: EdgeInsets.fromLTRB(20.sp, 20.sp, 20.sp, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.item.name, style: TextStyle(fontSize: 54.sp, color: Colors.black, fontWeight: FontWeight.w500)),
          Padding(padding: EdgeInsets.symmetric(vertical: 20.sp), child: _Item('website', 'WEBSITE',
            InkWell(onTap: () => _openUrl(widget.item.website), child: Padding(padding: EdgeInsets.all(20.sp),
              child: Text(widget.item.website, style: TextStyle(color: Colors.blue, fontSize: 48.sp), textAlign: TextAlign.left))), color: Colors.blue)),
          Padding(padding: EdgeInsets.symmetric(vertical: 20.sp), child: _Item('phone', 'SỐ ĐIỆN THOẠI',
            InkWell(onTap: _call, child: Padding(padding: EdgeInsets.all(20.sp),
              child: Text(widget.item.phone, style: TextStyle(color: Colors.black87, fontSize: 48.sp), textAlign: TextAlign.left))), color: Colors.green)),
          Padding(padding: EdgeInsets.symmetric(vertical: 20.sp), child: _Item('email', 'EMAIL',
            InkWell(onTap: _openMail, child: Padding(padding: EdgeInsets.all(20.sp),
              child: Text(widget.item.email, style: TextStyle(color: Colors.black87, fontSize: 48.sp), textAlign: TextAlign.left))), color: Colors.orangeAccent)),
          Padding(padding: EdgeInsets.symmetric(vertical: 20.sp), child: _Item('location', 'TỈNH/ THÀNH PHỐ - QUẬN/ HUYỆN', _getAddress(), color: Colors.red)),
          Padding(padding: EdgeInsets.symmetric(vertical: 20.sp), child: _Item('location', 'ĐỊA CHỈ', widget.item.address, color: Colors.red)),
          Html(data: widget.item.content, style: {"body": Style(fontSize: FontSize(48.sp))},
            onLinkTap: (url, render, map, ele) => _openUrl(url),
            onImageTap: (url, render, map, ele) => _openUrl(url))
      ]))
    ])
  );

  void _openUrl(String? url) {
    if (url == null || url.isEmpty) return;
    if (!url.contains('http')) url = 'https://' + url;
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  void _call() {
    if (widget.item.phone.isEmpty) return;
    launchUrl(Uri.parse("tel:" + widget.item.phone));
  }

  void _openMail() {
    if (widget.item.email.isEmpty) return;
    launchUrl(Uri.https("mailto:" + widget.item.email), mode: LaunchMode.externalApplication);
  }

  String _getAddress() {
    String temp = widget.item.disName;
    if (widget.item.proName.isNotEmpty) temp += ', ' + widget.item.proName;
    return temp;
  }
}

class _Item extends StatelessWidget {
  final String icon, label;
  final dynamic value;
  final Color color;
  const _Item(this.icon, this.label, this.value, {this.color = Colors.white});
  @override
  Widget build(BuildContext context) => Material(elevation: 2.0, borderRadius: BorderRadius.all(Radius.circular(20.sp)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: EdgeInsets.all(30.sp), decoration: BoxDecoration(color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20.sp), topRight: Radius.circular(20.sp))),
          child: Row(children: [
            Image.asset('assets/images/ic_$icon.png', color: color, width: 60.sp, height: 60.sp),
            SizedBox(width: 20.sp),
            Text(label.toUpperCase(), style: TextStyle(color: Colors.black87, fontSize: 48.sp))
          ])
        ),
        Container(padding: EdgeInsets.all(value is String ? 30.sp:10.sp), width: 1.sw,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.sp), bottomRight: Radius.circular(20.sp))),
            child: value is String ? Text(value, style: TextStyle(color: Colors.black, fontSize: 48.sp)) : value)
      ])
  );
}