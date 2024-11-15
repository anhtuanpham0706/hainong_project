import 'package:flutter_html/flutter_html.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/image_network_asset.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/util/util_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class Main2Item extends StatelessWidget {
  final String title, icon;
  final Function funAction;
  const Main2Item(this.title, this.icon, this.funAction, {Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) => ButtonImageWidget(100, funAction, Image.asset('assets/images/v5/ic_$icon.png', fit: BoxFit.fitWidth));
}

class PopupDetail extends StatelessWidget {
  final String title, des, image;
  const PopupDetail(this.title, this.des, this.image, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.white,
    appBar: AppBar(elevation: 5, centerTitle: true, title: UtilUI.createLabel('Chi tiết quảng cáo')),
    body: ListView(children: [
      Padding(padding: EdgeInsets.all(40.sp), child: LabelCustom(title, size: 56.sp, color: Colors.black87, weight: FontWeight.w500)),
      //ImageNetworkAsset(path: image, width: 1.sw),
      Html(data: des, style: {"body": Style(fontSize: FontSize(48.sp))},
        onLinkTap: (url, render, map, ele) => launchUrl(Uri.parse(url!), mode: LaunchMode.externalApplication),
        onImageTap: (url, render, map, ele) => launchUrl(Uri.parse(url!), mode: LaunchMode.externalApplication)
      )
    ])
  );
}