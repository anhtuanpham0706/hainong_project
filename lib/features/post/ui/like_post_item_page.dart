import 'package:hainong/common/ui/image_network_asset.dart';
import 'package:hainong/common/ui/string_html.dart';
import '../sub_ui/icon_play_default.dart';
import 'highlight_post_item_page.dart';
import 'import_lib_ui_post.dart';
import 'post_detail_page.dart';
import 'post_item_page.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../bloc/editor_bloc.dart';

abstract class LikePostItemPageCallback {
  removeLikePost(int index);
}

class LikePostItemPage extends StatelessWidget
    implements HighlightPostDetailCallback {
  final Post item;
  final int index;
  final HomeBloc bloc;
  final String shopId;
  final LikePostItemPageCallback callback;
  final Function? funCallBackRemoveItem;
  final Map<String, Widget> _thumbnailVideos = {};
  final EditorBloc _editorBloc = EditorBloc(EditorState());

  LikePostItemPage(
      this.item, this.index, this.bloc, this.shopId, this.callback, {this.funCallBackRemoveItem, Key? key}):super(key:key) {
    if (item.shared_post_id.isEmpty) {
      if (item.images.list.isEmpty) {
        _setThumbnail(UtilUI.imageDefault(asset: 'assets/images/bg_splash.png'));
      } else {
        String temp = item.images.list[0].name;
        if (Util.isImage(temp))
          _setThumbnail(ImageNetworkAsset(path: temp, asset: 'assets/images/bg_splash.png', error: 'assets/images/bg_splash.png'));
        else
          _thumbnailVideos.putIfAbsent(item.id, () => Container(color: Colors.black12, child: IconPlayDefault(size: 60.sp)));
        VideoThumbnail.thumbnailData(
          video: Util.getRealPath(temp),
          imageFormat: ImageFormat.WEBP,
          quality: 50,
        ).then((listByte) {
          if (listByte != null) _setThumbnail(Container(
              decoration: BoxDecoration(
                  color: Colors.black12,
                  image: DecorationImage(
                      image: Image.memory(listByte).image, fit: BoxFit.cover)),
              child: IconPlayDefault(size: 60.sp)));
        });
      }
    } //else item.title = item.description;
  }

  _setThumbnail(Widget image) {
    _thumbnailVideos.update(item.id, (value) => image, ifAbsent: () => image);
    _editorBloc.add(LoadVideoEditorEvent());
  }

  @override
  reloadPost(Post post) {
    if (!post.user_liked) _deleteLikePost(true);
  }

  _deleteLikePost(bool goBack) {
    callback.removeLikePost(index);
    if (goBack) UtilUI.goBack(this, null);
  }

  void _unlikePost() {
    if(funCallBackRemoveItem!=null){
      funCallBackRemoveItem?.call(index);
    }
    else{
      bloc.add(UnlikePostHomeEvent(item.classable_id, item.classable_type, index));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          ShadowDecoration(size: 10.sp, bgColor: Colors.white, opacity: 0.15),
      margin: EdgeInsets.only(bottom: 30.sp),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
            side: const BorderSide(
              color: Colors.transparent,
            ),
            padding: EdgeInsets.all(40.sp)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PostDetailPage(item, index, bloc, shopId, this),
            ),
          );
          Util.trackActivities('post', path: 'List Like Post Screen -> Open Detail Post ${item.description} Of ${item.shop_name}');
        },
        child: Row(children: [
          Stack(children: [
            Container(
              padding: EdgeInsets.all(10.sp),
              width: 200.sp,
              height: 200.sp,
              decoration: ShadowDecoration(
                  size: 30.sp,
                  opacity: 0.2,
                  borderColor: Colors.grey,
                  width: 0.1),
              child: SizedBox(
                  width: 190.sp,
                  height: 190.sp,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.sp),
                      child: item.shared_post_id.isEmpty
                          ? BlocBuilder(
                              bloc: _editorBloc,
                              buildWhen: (state1, state2) =>
                                  state2 is LoadVideoEditorState,
                              builder: (context, state) =>
                                  _thumbnailVideos[item.id]!)
                          : PostItemPage(item, index, bloc, shopId,
                              isHideControls: true,
                              isHideOption: true,
                              isHighlight: true,
                              playSize: 60.sp))),
            ),
            Container(width: 60.sp, height: 60.sp,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(60.sp)),
              child: ButtonImageCircleWidget(60.sp, _unlikePost, child: Icon(Icons.close, size: 40.sp))
            )
          ]),
          SizedBox(width: 40.sp),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(constraints: BoxConstraints(maxHeight: 290.sp),
                margin: EdgeInsets.only(bottom: 20.sp),
                child: StringHtml(item.title, shortHtml: item.short_title, allowGotoShop: false)
              ),
              Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                AvatarCircleWidget(link: item.shop_image, size: 60.sp),
                SizedBox(width: 20.sp),
                UtilUI.createLabel(item.shop_name,
                    color: StyleCustom.textColor2C, fontSize: 35.sp),
                SizedBox(width: 20.sp),
                Text(
                  Util.getTimeAgo(item.created_at),
                  style: TextStyle(
                      color: StyleCustom.textColor6C,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.normal),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
