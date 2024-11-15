import 'package:hainong/common/base_response.dart';
import 'post_item_page.dart';
import 'highlight_post_item_page.dart';
import 'import_lib_ui_post.dart';

class PostDetailPage extends StatefulWidget {
  final Post item;
  final int index;
  final HomeBloc bloc;
  final String shopId;
  final HighlightPostDetailCallback? callback;

  const PostDetailPage(this.item, this.index, this.bloc, this.shopId, this.callback, {Key? key}):super(key:key);

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> implements PostDetailCallback {
  PostItemPage? post;

  @override
  dispose() {
    post = null;
    super.dispose();
  }

  @override
  reloadPost(Post post) {
    widget.item.copyAll(post);
    widget.callback?.reloadPost(post);
    widget.bloc.add(ReloadPostsHomeEvent());
  }

  @override
  showLoginOrCreate({context}) =>
    UtilUI.showCustomDialog(context, MultiLanguage.get(LanguageKey().msgLoginOrCreate));

  @override
  initState() {
    super.initState();
    widget.bloc.stream.listen((state) {
      if (state is SharePostHomeState) {
        _callback(true, state);
      } else if (state is DeletePostHomeState) {
        _callback(widget.item.user_shared, state);
      } else if (state is WarningPostHomeState) {
        if (state.response.checkTimeout())
          UtilUI.showDialogTimeout(context);
        else if (state.response.checkOK()) {
          final LanguageKey languageKey = LanguageKey();
          UtilUI.showCustomDialog(
              context, MultiLanguage.get(languageKey.msgWarningPostSuccess),
              title: MultiLanguage.get(languageKey.ttlAlert));
        } else UtilUI.showCustomDialog(context, state.response.data.toString());
      }
    });
  }

  _callback(bool value, state) {
    final BaseResponse base = state.response as BaseResponse;
    if (!base.checkTimeout() && base.checkOK(passString: true)) {
      widget.item.user_shared = value;
      Navigator.of(context).pop(state);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: TaskBarWidget(LanguageKey().ttlDetails).createUI(),
    backgroundColor: StyleCustom.backgroundColor,
    body: ListView(children: [
      BlocBuilder(bloc: widget.bloc, buildWhen: (state1, state2) =>
        state2 is SharePostHomeState || state2 is ReloadPostsHomeState,
        builder: (context, state) {
          post = null;
          post = PostItemPage(widget.item, widget.index, widget.bloc, widget.shopId,
            isCollapse: false, callback: this,
            key: Key(DateTime.now().toString()), refreshPost: reloadPost);
          Timer(const Duration(seconds: 2), () {
            try {
              post?.videoPage?.stopScroll();
              post?.subItem?.videoPage?.stopScroll();
            } catch(_){}
          });
          return post!;
        })
    ]));
}
