import 'dart:async';
import 'package:hainong/common/models/item_option.dart';
import 'package:hainong/common/ui/avatar_circle_widget.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/divider_widget.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/features/home/bloc/home_bloc.dart';
import 'package:hainong/features/login/bloc/login_bloc.dart';
import 'package:hainong/features/main/bloc/main_bloc.dart';
import 'package:hainong/features/post/model/post.dart';
import 'package:hainong/features/post/ui/post_item_page.dart';
import 'comment_item_page.dart';
import '../comment_bloc.dart';
import '../model/comment_model.dart';

class CommentPage extends BasePage {
  final Post item;
  final bool hasHeader, showTime, openKeyboard;
  final Function? reloadItem, hideSnackBar;
  final double? height;
  final PostItemPage? post;
  CommentPage(this.item, {this.post, this.height, this.showTime = true, this.hasHeader = true,
    this.openKeyboard = false, this.reloadItem, this.hideSnackBar, Key? key}) : super(key: key, pageState: _CommentPageState());
}

class _CommentPageState extends BasePageState {
  final TextEditingController _ctr = TextEditingController();
  final FocusNode _fc = FocusNode();
  final List<CommentModel> _list = [];
  final ScrollController _scroller = ScrollController();
  late StreamSubscription _stream;
  StreamSubscription? _streamHome;
  int _page = 1, _id = -1;
  String _type = '', _avatar = '';
  bool _isLock = false, _sortLike = false;

  @override
  void dispose() {
    _stream.cancel();
    _streamHome?.cancel();
    final page = widget as CommentPage;
    if (page.reloadItem != null) page.reloadItem!(true);
    page.post?.hideComment = false;
    _ctr.dispose();
    _fc.removeListener(_listenText);
    _fc.dispose();
    _list.clear();
    _scroller.removeListener(_listenScroller);
    _scroller.dispose();
    Util.clearPermission();
    CommentItemPageState.idComment = null;
    super.dispose();
  }

  @override
  initState() {
    Util.getPermission();
    _scroller.addListener(_listenScroller);
    bloc = CommentBloc(CommentState());
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadListCommentState) _handleLoadList(state);
      else if (state is SendCommentState) _handleSendComment(state);
    });
    final page = widget as CommentPage;
    if (page.post != null) {
      page.post!.hideComment = true;
      _streamHome = page.post!.bloc.stream.listen((state) {
        if (state is DeletePostHomeState && page.post!.hideComment) Navigator.of(context).pop(true);
        else if (state is SharePostHomeState && state.response.checkOK(passString: true)) page.post!.subBloc.add(LoadPostHomeEvent(page.item.id, 0));
      });
      _list.add(CommentModel());
    }
    _id = int.parse(page.item.classable_id);
    _type = page.item.classable_type;
    _next();
    _stream = BlocProvider.of<MainBloc>(context).stream.listen((state) {
      if (state is ReloadListCommentState) _resetList();
    });
    _fc.addListener(_listenText);
    if (page.openKeyboard) Timer(const Duration(milliseconds: 1000), _fc.requestFocus);
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    final CommentPage page = widget as CommentPage;
    if (page.hasHeader) return super.build(context, color: color);
    return createUI();
  }

  @override
  Widget createUI() {
    final CommentPage page = widget as CommentPage;
    final Widget child = Column(children: [
      page.hasHeader ? Expanded(child: RefreshIndicator(child: BlocBuilder(bloc: bloc, builder: (context, state) =>
            ListView.builder(padding: EdgeInsets.zero, controller: _scroller,
              itemCount: _list.length, itemBuilder: (context, index) {
                if (page.post == null || index > 0) {return CommentItemPage(_list[index], hasControl: true, funReloadParent: _reloadPost,
                    index: index, showTime: true, margin: EdgeInsets.only(bottom: 40.sp));}
                return Column(children: [
                  BlocBuilder(bloc: page.post!.subBloc, buildWhen: (oldS, newS) => newS is LoadPostHomeState,
                      builder: (context, statePost) {
                        if (page.item.shared_post_id.isNotEmpty && page.post != null) page.post!.subBloc.add(LoadSubPostHomeEvent(page.item.shared_post_id));
                        if (statePost is LoadPostHomeState) {
                          page.post!.item.copy(statePost.response.data);
                          return page.post!.build(context);
                        }
                        return page.post!;
                      }),
                  ButtonImageWidget(0, _menu, Container(child: Row(children: [
                    BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is ChangeFilterState,
                        builder: (context, state) => Text(_sortLike?'Yêu thích nhất ':'Mới nhất ', style: TextStyle(fontSize: 36.sp))),
                    Icon(Icons.keyboard_arrow_down, size: 48.sp, color: Colors.grey)
                  ]), padding: EdgeInsets.all(40.sp), color: Colors.white, margin: EdgeInsets.only(bottom: 20.sp)))
                ]);
              }, physics: const AlwaysScrollableScrollPhysics()),
          buildWhen: (state1, state2) => state2 is LoadListCommentState),
          onRefresh: () async => _resetList())) :
        Container(constraints: BoxConstraints(maxHeight: page.height??0.32.sh),
          child: BlocBuilder(bloc: bloc, builder: (context, state) =>
            ListView.builder(padding: EdgeInsets.only(top: 20.sp), controller: _scroller, shrinkWrap: true,
              itemCount: _list.length, itemBuilder: (context, index) => CommentItemPage(_list[index], hasControl: true,
                  index: index, showTime: page.showTime, margin: EdgeInsets.only(bottom: 40.sp)), physics: const AlwaysScrollableScrollPhysics()),
          buildWhen: (state1, state2) => state2 is LoadListCommentState)),// || state2 is ReloadListCommentState),
      const DividerWidget(),
      BlocBuilder(bloc: BlocProvider.of<MainBloc>(context), builder: (context, state) {
        bool show = true;
        if (state is HideTextFieldState) show = state.hideKeyboard;
        if (!show) {
          bloc!.add(FocusTextLoginEvent(false));
          return const SizedBox();
        }
        return Container(padding: EdgeInsets.all(40.sp), color: Colors.white, child: Column(children: [
          BlocBuilder(builder: (context, state2) {
            bool focus = false;
            if (state2 is FocusTextLoginState) focus = state2.value;
            if (!focus) return const SizedBox();
            return GestureDetector(onTap: super.clearFocus, child: Icon(Icons.clear, color: Colors.black38, size: 60.sp));
          }, bloc: bloc, buildWhen: (oldS2, newS2) => newS2 is FocusTextLoginState),
          Container(constraints: BoxConstraints(minHeight: 0, maxHeight: 0.1.sh),
            child: Row(children: [
              AvatarCircleWidget(link: _avatar, size: 120.sp),
              SizedBox(width: 40.sp),
              //Expanded(child: _editor)
              Expanded(child: UtilUI.createTextField(context, _ctr, _fc, null,
                MultiLanguage.get('lbl_write_comment'), inputAction: TextInputAction.newline, maxLines: null,
                inputType: TextInputType.multiline, onPressIcon: _sendComment,
                padding: EdgeInsets.all(40.sp), sizeBorder: 100.sp, suffixIcon: const Icon(Icons.send_outlined))
              )
          ]))
        ], crossAxisAlignment: CrossAxisAlignment.end));
      }, buildWhen: (oldS, newS) => newS is HideTextFieldState)
    ], mainAxisAlignment: MainAxisAlignment.end);
    return page.hasHeader ? Scaffold(backgroundColor: StyleCustom.backgroundColor,
        appBar: AppBar(elevation: 5, title: UtilUI.createLabel('Bình luận'), centerTitle: true), body: child) : child;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SharedPreferences.getInstance().then((prefs) {
      setState(() => _avatar = prefs.getString('image')??'');
    });
  }

  @override
  void clearFocus() {}

  void _listenText() {
    final page = widget as CommentPage;
    if (page.hideSnackBar != null) page.hideSnackBar!();
    bloc!.add(FocusTextLoginEvent(_fc.hasFocus));
  }

  void _listenScroller() {
    if (_scroller.position.maxScrollExtent == _scroller.position.pixels && _page > 0) _next();
  }

  void _sendComment() async {
    if (!constants.isLogin) {
      UtilUI.showDialogTimeout(context, message: languageKey.msgLoginOrCreate);
      return;
    }
    super.clearFocus();
    if (_isLock) return;
    _ctr.text = _ctr.text.trim();
    if (_ctr.text.isNotEmpty) {
      if (_ctr.text.length < 6) {
        UtilUI.showCustomDialog(context, 'Nội dung phải ít nhất 6 ký tự trở lên').whenComplete(() => _fc.requestFocus());
        return;
      }
      if (await UtilUI().alertVerifyPhone(context)) return;
      _isLock = true;
      bloc!.add(SendCommentEvent(_ctr.text, _type, _id));
      CommentItemPageState.idComment = -1;
      if (mounted) BlocProvider.of<MainBloc>(context).add(HideTextFieldEvent(true));
    }
  }

  void _next() {
    if (_page > 0) bloc!.add(LoadListCommentEvent(_page, _type, _id, _sortLike));
  }

  void _handleLoadList(LoadListCommentState state) {
    if (isResponseNotError(state.response) && state.response.data is CommentsModel) {
      List<CommentModel> tmp = (state.response.data as CommentsModel).list;
      _list.addAll(tmp);
      tmp.length < constants.limitPage ? _page = 0 : _page++;
    }
  }

  void _handleSendComment(SendCommentState state) {
    _isLock = false;
    if (isResponseNotError(state.response)) {
      _reloadPost();
      _resetList();
      _ctr.text = '';
    }
  }

  void _reloadPost() {
    final page = widget as CommentPage;
    if (page.reloadItem != null) page.reloadItem!(true);
  }

  void _resetList() {
    _page = 1;
    setState((){
      final page = widget as CommentPage;
      page.post == null ? _list.clear() : _list.removeRange(1, _list.length);
    });
    _next();
  }

  void _menu() {
    final List<ItemOption> options = [];
    options.add(ItemOption('', 'Mới nhất', () => _changeSort(false), false));
    options.add(ItemOption('', 'Yêu thích nhất', () => _changeSort(true), false));
    UtilUI.showOptionDialog2(context, 'Xem', options);
    Util.trackActivities('comment', path: 'Comment -> Option Menu Button -> Open Option Dialog');
  }

  void _changeSort(bool sortLike) {
    if (_sortLike != sortLike) {
      _sortLike = sortLike;
      _resetList();
      bloc!.add(ChangeFilterEvent());
      Util.trackActivities('comment', path: 'Comment -> Option Dialog -> Choose Sort By ${sortLike ? 'Most Liked' : 'Latest'}');
    }
    Navigator.of(context).pop(false);
  }
}
