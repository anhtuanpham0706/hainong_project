import 'package:hainong/features/home/ui/list_highlight_post_page.dart';
import '../bloc/editor_bloc.dart';
import '../sub_ui/icon_play_default.dart';
import 'import_lib_ui_post.dart';
import 'post_detail_page.dart';
import 'post_item_page.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

abstract class HighlightPostDetailCallback {
  reloadPost(Post post);
}

class HighlightPostItemPage extends StatelessWidget
    implements HighlightPostDetailCallback {
  final Post item;
  final int index;
  final HomeBloc bloc;
  final String shopId;
  final ListHighlightPostCallback callback;
  final Map<String, Widget> _thumbnailVideos = {};
  final EditorBloc _editorBloc = EditorBloc(EditorState());

  HighlightPostItemPage(this.item, this.index, this.bloc,
      this.shopId, this.callback, {Key? key}) : super(key: key) {
    if (item.shared_post_id.isEmpty) {
      if (item.images.list.isEmpty) {
        _setThumbnail(UtilUI.imageDefault(asset: 'assets/images/bg_splash.png'));
      } else {
        String temp = item.images.list[0].name;
        if (Util.isImage(temp)) {
          _setThumbnail(FadeInImage.assetNetwork(
              placeholder: 'assets/images/bg_splash.png',
              image: Util.getRealPath(temp),
              imageScale: 0.5,
              imageErrorBuilder: (context, obj, stack) => Image.asset('assets/images/bg_splash.png', fit: BoxFit.cover),
              fit: BoxFit.cover));
        } else {
          _thumbnailVideos.putIfAbsent(item.id, () => Container(color: Colors.black12, child: const IconPlayDefault()));
          VideoThumbnail.thumbnailData(video: Util.getRealPath(temp),
              imageFormat: ImageFormat.WEBP, quality: 50).then((listByte) {
            if (listByte != null) { _setThumbnail(Container(
                decoration: BoxDecoration(color: Colors.black12, image: DecorationImage(
                  image: Image.memory(listByte).image, fit: BoxFit.cover)),
                child: const IconPlayDefault())); }
          });
        }
      }
    }
  }

  _setThumbnail(Widget image) {
    _thumbnailVideos.update(item.id, (value) => image, ifAbsent: () => image);
    _editorBloc.add(LoadVideoEditorEvent());
  }

  @override
  reloadPost(Post post) {
    callback.reloadHighlightPost(post);
  }

  @override
  Widget build(BuildContext context) => Container(
      width: 0.3.sw,
      decoration:
          ShadowDecoration(size: 10.sp, bgColor: Colors.white, opacity: 0.15),
      margin: EdgeInsets.only(right: 30.sp, bottom: 10.sp),
      child: OutlinedButton(style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: Colors.transparent,
              ),
              padding: EdgeInsets.zero),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>
              PostDetailPage(item, index, bloc, shopId, this))),
          child: Column(children: [
            Expanded(
                child: SizedBox(
                    width: 0.3.sw,
                    child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.sp),
                            topRight: Radius.circular(10.sp)),
                        child: item.shared_post_id.isEmpty
                            ? BlocBuilder(
                                bloc: _editorBloc,
                                buildWhen: (state1, state2) => state2 is LoadVideoEditorState,
                                builder: (context, state) => _thumbnailVideos[item.id]!)
                            : PostItemPage(item, index, bloc, shopId,
                                isHideControls: true,
                                isHideOption: true,
                                isHighlight: true)))),
            Container(
                padding: EdgeInsets.all(20.sp),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          item.shared_post_id.isNotEmpty
                              ? item.description
                              : item.title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: StyleCustom.textColor2C,
                              fontSize: 30.sp,
                              fontWeight: FontWeight.bold),
                          maxLines: 1),
                      SizedBox(height: 20.sp),
                      Row(children: [
                        Icon(Icons.location_on,
                            color: StyleCustom.buttonColor, size: 30.sp),
                        Expanded(
                            child: Text(' ' + item.province_name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 25.sp,
                                    fontWeight: FontWeight.normal,
                                    color: StyleCustom.textColor6C)))
                      ])
                    ]))
          ])));
}
