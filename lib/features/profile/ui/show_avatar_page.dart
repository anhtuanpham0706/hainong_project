import 'package:flutter/material.dart';
import 'package:hainong/common/ui/video_page.dart';
import 'package:hainong/common/util/util.dart';
import 'package:photo_view/photo_view.dart';

class ShowAvatarPage extends StatelessWidget {
  final String url;
  final String asset;
  const ShowAvatarPage(this.url, {this.asset = 'v2/ic_avatar_drawer_v2', Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) {
    Widget temp = Image.asset('assets/images/$asset.png', fit: BoxFit.cover);
    if (url.isNotEmpty) {
      final String link = Util.getRealPath(url);
      temp = Util.isImage(url) ? PhotoView(imageProvider: FadeInImage.assetNetwork(
          imageErrorBuilder: (_,__,___) => Image.asset('assets/images/$asset.png', fit: BoxFit.cover),
          placeholder: 'assets/images/$asset.png',
          image: link, imageScale: 0.5, fit: BoxFit.scaleDown).image) : VideoPage(link, 0, autoPlay: false);
    }
    return Scaffold(appBar: AppBar(backgroundColor: Colors.black), body: Column(children: [
      const Divider(height: 0.5, color: Colors.grey),
      Expanded(child: Center(child: temp))
    ]));
  }
}
