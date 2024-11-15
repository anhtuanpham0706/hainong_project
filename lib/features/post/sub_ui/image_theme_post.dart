import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/image_network_asset.dart';
import 'package:hainong/common/ui/video_page.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/common/util/util_ui.dart';
import 'package:hainong/features/post/ui/post_item_page.dart';
import 'import_lib_post_sub_ui.dart';

class ImageThemePost extends StatelessWidget {
  final List<ItemModel> list;
  final ControlVideoListener? listener;
  final Function funPlayVideoImage;
  final Function? funStopYtb;
  final int indexRoot;
  final PostItemPage post;
  final bool isShop;

  const ImageThemePost(this.list, this.listener, this.post, this.funPlayVideoImage,
      this.indexRoot, {this.isShop = false, this.funStopYtb, Key? key}):super(key:key);

  @override
  Widget build(context) {
    switch (list.length) {
      case 0:
        return const SizedBox();
      case 1:
        return _createItem(1.sw, 0.5.sh, 0, listener, funPlayVideoImage, -1, isOne: true)[0];
      case 2:
        final List<dynamic> list0 = _createItem(0.5.sw, 0.25.sh, 0, listener, funPlayVideoImage, -1);
        final List<dynamic> list1 = _createItem(0.5.sw, 0.25.sh, 1, listener, funPlayVideoImage, list0[1]);
        return Row(children: [
          Expanded(child: list0[0]),
          Padding(padding: EdgeInsets.all(2.sp)),
          Expanded(child: list1[0])
        ]);
      case 3:
        final List<dynamic> list0 = _createItem(0.6.sw, 0.5.sh, 0, listener, funPlayVideoImage, -1);
        final List<dynamic> list1 = _createItem(0.4.sw, 0.25.sh - 2.sp, 1, listener, funPlayVideoImage, list0[1]);
        final List<dynamic> list2 = _createItem(0.4.sw, 0.25.sh, 2, listener, funPlayVideoImage, list1[1]);
        return Row(children: [
          Expanded(flex: 6, child: list0[0]),
          SizedBox(width: 4.sp, height: 4.sp),
          Expanded(flex: 4, child: Column(children: [
            list1[0], SizedBox(width: 4.sp, height: 4.sp), list2[0]
          ]))
        ]);
      default:
        final List<dynamic> list0 = _createItem(0.5.sw, 0.25.sh, 0, listener, funPlayVideoImage, -1);
        final List<dynamic> list1 = _createItem(0.5.sw, 0.25.sh, 1, listener, funPlayVideoImage, list0[1]);
        final List<dynamic> list2 = _createItem(0.5.sw, 0.25.sh, 2, listener, funPlayVideoImage, list1[1]);
        final List<dynamic> list3 = _createItem(0.5.sw, 0.25.sh, 3, listener, funPlayVideoImage, list2[1]);
        return Row(children: [
          Expanded(flex: 1, child: Column(children: [
            list0[0], Padding(padding: EdgeInsets.all(2.sp)), list1[0],
          ])),
          SizedBox(width: 4.sp, height: 4.sp),
          Expanded(flex: 1, child: Column(children: [
                list2[0],
                SizedBox(width: 4.sp, height: 4.sp),
                Stack(alignment: Alignment.center, children: [
                  list3[0],
                  OutlinedButton(onPressed: () => funPlayVideoImage(context, 3),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.transparent), padding: EdgeInsets.zero),
                      child: Container(color: list.length > 4 ? Colors.black45 : Colors.transparent,
                          width: 0.5.sw, height: 0.25.sh, alignment: Alignment.center,
                          child: list.length > 4 ? UtilUI.createLabel('+' + (list.length - 4).toString(), fontSize: 60.sp) : Container()))
                ])
          ])),
        ]);
    }
  }

  List<dynamic> _createItem(double width, double height, int index, ControlVideoListener? listener,
      Function function, int indexPlay, {bool isOne = false}) {
    Widget temp;
    if (Util.isImage(list[index].name)) temp = _CreateImage(width, height, list[index].name, index, listener, function);
    else {
      if (indexPlay == -1) indexPlay = index;
      temp = _CreateVideo(width, height, list[index].name, index, listener, function, post, indexPlay, indexRoot, isShop, isOne, funStopYtb: funStopYtb);
    }
    return [temp, indexPlay];
  }
}

class _CreateImage extends StatelessWidget {
  final double width, height;
  final String url;
  final int index;
  final ControlVideoListener? listener;
  final Function funPlayVideoImage;

  const _CreateImage(this.width, this.height, this.url, this.index, this.listener,
      this.funPlayVideoImage, {Key? key}):super(key:key);

  @override
  Widget build(context) => OutlinedButton(
      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.transparent), padding: EdgeInsets.zero),
      onPressed: () => funPlayVideoImage(context, index),
      child: ImageNetworkAsset(path: url, asset: 'assets/images/ic_default.png', width: width, height: height, cache: true, rateCache: 2));
}

class _CreateVideo extends StatelessWidget {
  final double width, height;
  final String url;
  final int index;
  final ControlVideoListener? listener;
  final Function funPlayVideoImage;
  final Function? funStopYtb;
  final int indexPlay, indexRoot;
  final PostItemPage post;
  final bool isShop, isOne;

  const _CreateVideo(this.width, this.height, this.url, this.index, this.listener,
      this.funPlayVideoImage, this.post, this.indexPlay, this.indexRoot, this.isShop, this.isOne, {this.funStopYtb, Key? key}):super(key:key);

  @override
  Widget build(context) {
    final VideoPage temp = VideoPage(Util.getRealPath(url), indexRoot,
        width: width,
        height: height,
        autoPlay: false,
        isPage: false,
        isOne: isOne,
        showControl: index == 0 && !isShop,
        enableFullscreen: false,
        enablePlayPause: indexPlay == index,
        volume: indexPlay == index ? 1.0 : 0.0,
        listener: () => funPlayVideoImage(context, index),
        firstStop: true, notPlay: index > 0 || isShop,
        controlListener: listener, stopYtb: funStopYtb);
    if (indexPlay == index && index == 0) post.videoPage = temp;
    return temp;
  }
}
