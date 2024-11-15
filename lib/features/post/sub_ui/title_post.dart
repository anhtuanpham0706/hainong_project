import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hainong/common/ui/shadow_decoration.dart';
import 'package:hainong/common/ui/string_html.dart';
import 'package:hainong/common/ui/youtube_player_custom.dart';
import 'package:hainong/common/util/util.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../bloc/editor_bloc.dart';
import '../model/meta_data_model.dart';
import 'import_lib_post_sub_ui.dart';

class TitlePost extends StatelessWidget {
  final EditorBloc bloc;
  final String title, shortTitle;
  final bool isCollapse, allowGotoShop, clearPage, isShop;
  final List<YoutubeCallback> listYoutube;
  final Function? stopVideo;
  const TitlePost(this.bloc, this.title, this.shortTitle, this.isCollapse, this.allowGotoShop, this.listYoutube,
      {this.clearPage = true, this.stopVideo, this.isShop = false, Key? key}):super(key:key);

  @override
  Widget build(context) {
    final content = Padding(padding: EdgeInsets.symmetric(vertical: 20.sp), child: StringHtml(title, shortHtml: shortTitle, allowGotoShop: allowGotoShop, clearPage: clearPage));
    return Padding(
        padding: EdgeInsets.only(left: 40.sp, right: 40.sp, bottom: 0.sp),
        child: BlocBuilder(
            bloc: bloc,
            buildWhen: (state1, state2) => state2 is LoadUrlEditorState,
            builder: (context, state) {
              final List<Widget> list = [];
              if (state is LoadUrlEditorState) list.addAll(_createContentUrlList(state.list));

              return Column(children: [
                content,
                Wrap(children: list)
              ]);
            }));
  }

  List<Widget> _createContentUrlList(List<MetaDataModel> list) {
    final List<Widget> listWidget = [];
    listYoutube.clear();
    for (var element in list) {
      final String? id = YoutubePlayer.convertUrlToId(element.url);
      if (id != null) {
        final youtube = YoutubePlayerCustom(id, element.image, element.url, stopVideo: stopVideo, isShop: isShop);
        listYoutube.add(youtube);
        listWidget.add(youtube);
      } else {
        listWidget.add(_CreateContentUrlItem(element));
      }
    }
    return listWidget;
  }
}

class _CreateContentUrlItem extends StatelessWidget {
  final MetaDataModel item;
  const _CreateContentUrlItem(this.item, {Key? key}):super(key:key);

  @override
  Widget build(context) => Container(
      decoration: ShadowDecoration(opacity: 0.1),
      margin: EdgeInsets.all(10.sp),
      child: OutlinedButton(
          style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: Colors.transparent,
              ),
              padding: EdgeInsets.all(20.sp)),
          //onPressed: () => launchUrl(Uri.parse(item.url), mode: LaunchMode.externalNonBrowserApplication),
          onPressed: () => launch(item.url, enableJavaScript: true),
          child: Row(children: [
            FadeInImage.assetNetwork(
                placeholder: 'assets/images/ic_logo_login.png',
                imageErrorBuilder: (_,__,___) => Image.asset('assets/images/ic_logo_login.png', width: 300.sp,
                    height: 180.sp, fit: BoxFit.fill),
                placeholderErrorBuilder: (_,__,___) => Image.asset('assets/images/ic_logo_login.png', width: 300.sp,
                    height: 180.sp, fit: BoxFit.fill),
                image: Util.getRealPath(item.image),
                    width: 300.sp, height: 180.sp, fit: BoxFit.fill),
            SizedBox(width: 20.sp),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: TextStyle(color: Colors.black87, fontSize: 36.sp, fontWeight: FontWeight.bold)),
                      Text(item.description, maxLines: 2, style: TextStyle(color: Colors.black87,
                              fontSize: 34.sp, fontWeight: FontWeight.normal)),
                      Text(item.domain, style: TextStyle(color: Colors.black87, fontSize: 30.sp, fontWeight: FontWeight.normal))
                    ]))
          ])));
}