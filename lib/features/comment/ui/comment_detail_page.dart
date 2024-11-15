import 'dart:async';
import 'package:hainong/common/models/item_option.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/features/main/bloc/main_bloc.dart';
import 'comment_item_page.dart';
import '../comment_bloc.dart';
import '../model/comment_model.dart';

class CommentDetailPage extends BasePage {
  final CommentModel item;
  final Function? reloadParent;
  final bool isSubComment;
  CommentDetailPage(this.item, {this.isSubComment = true, this.reloadParent, Key? key}) : super(key: key, pageState: _CommentDetailPageState());
}

class _CommentDetailPageState extends BasePageState {
  final TextEditingController _ctr = TextEditingController();
  final List<CommentModel> _list = [];
  final ScrollController _scroller = ScrollController();
  late StreamSubscription _stream;
  int _page = 1;
  bool _isLock = false;
  String? _content;

  @override
  void dispose() {
    _stream.cancel();
    _ctr.dispose();
    _list.clear();
    _scroller.removeListener(_listenScroller);
    _scroller.dispose();
    CommentItemPageState.idComment = null;
    super.dispose();
  }

  @override
  initState() {
    _scroller.addListener(_listenScroller);
    bloc = CommentBloc(CommentState());
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadListAnswerState) _handleLoadList(state);
      else if (state is AnswerCommentState) _handleAnswerComment(state);
      else if (state is EditCommentState) {
        if (isResponseNotError(state.resp, passString: true)) _reloadParent();
        else (widget as CommentDetailPage).item.content = _content!;
        _content = null;
      } else if (state is DeleteCommentState && isResponseNotError(state.resp, passString: true)) {
        _reloadParent();
        UtilUI.goBack(context, true);
      }
    });
    _next();
    _stream = BlocProvider.of<MainBloc>(context).stream.listen((state) {
      if (state is ReloadSubCommentState) _resetList();
    });
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    final page = widget as CommentDetailPage;
    if (!page.isSubComment) {
      return Column(children: [
        BlocBuilder(bloc: bloc,
            buildWhen: (state1, state2) => state2 is LoadListAnswerState,
            builder: (context, state) => ListView.separated(padding: EdgeInsets.only(top: 40.sp), controller: _scroller,
                separatorBuilder: (context, index) => const Divider(height: 0.5, color: Colors.grey),
                itemCount: _list.length, itemBuilder: (context, index) => CommentItemPage(_list[index], hasControl: true,
                    index: index, showChild: false, isComment: false, hasIcon: false, showTime: true,
                    funReloadParent: _reloadParent), shrinkWrap: true, physics: const NeverScrollableScrollPhysics())),
        BlocBuilder(bloc: bloc, buildWhen: (state1, state2) => state2 is LoadListAnswerState,
          builder: (context, state) => _page > 0 ? ButtonImageWidget(0, _next, Text('Xem thêm ...',
              style: TextStyle(fontSize: 30.sp, color: Colors.blue))) : const SizedBox())
      ], crossAxisAlignment: CrossAxisAlignment.end);
    }
    return Scaffold(backgroundColor: StyleCustom.backgroundColor,
      appBar: AppBar(elevation: 5, centerTitle: true,
      title: LabelCustom('Chi tiết bình luận', color: Colors.white,
        align: TextAlign.center, size: 50.sp, weight: FontWeight.normal)),
      body: CommentItemPage(page.item, hasControl: true, openRoot: true,
        index: -1, showChild: true, isComment: true, hasIcon: false,
        showTime: true, funReloadParent: _reloadParent));
  }

  @override
  Widget createUI() => const SizedBox();

  void _reloadParent() {
    final reload = (widget as CommentDetailPage).reloadParent;
    if (reload != null && _list.isNotEmpty) reload();
  }

  void _listenScroller() {
    if (_scroller.position.maxScrollExtent == _scroller.position.pixels && _page > 0) _next();
  }

  void _sendAnswer() {
    if (_ctr.text.trim().isEmpty) return;
    if (_isLock) return;
    _isLock = true;
    final FocusScopeNode currentScope = FocusScope.of(context);
    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) FocusManager.instance.primaryFocus!.unfocus();
    final item = (widget as CommentDetailPage).item;
    bloc!.add(AnswerCommentEvent(_ctr.text.trim(), item.classable_id));
    bloc!.add(TrackEvent('comment_detail', 'Comment Detail Screen -> Answer Comment -> Send Answer For Comment "${item.content}"'));
  }

  void _next() {
    if (_page > 0) {
      final item = (widget as CommentDetailPage).item;
      bloc!.add(LoadListAnswerEvent(_page, item.classable_id));
    }
  }

  void _handleLoadList(LoadListAnswerState state) {
    if (isResponseNotError(state.response) && state.response.data is CommentsModel) {
      List<CommentModel> tmp = (state.response.data as CommentsModel).list;
      if (tmp.isNotEmpty) setState(() {_list.addAll(tmp);});
      tmp.length < constants.limitPage ? _page = 0 : _page++;
    }
  }

  void _handleAnswerComment(AnswerCommentState state) {
    _isLock = false;
    if (isResponseNotError(state.response)) {
      _resetList();
      _ctr.text = '';
      _reloadParent();
    }
  }

  void _resetList() {
    _page = 1;
    _list.clear();
    _next();
  }

  void _menu() {
    final List<ItemOption> options = [];
    options.add(ItemOption('assets/images/ic_edit_post.png', MultiLanguage.get('lbl_edit_comment'), _edit, false));
    final item = (widget as CommentDetailPage).item;
    if (item.rate < 1) options.add(ItemOption('assets/images/ic_delete_circle.png', MultiLanguage.get('lbl_delete_comment'), _delete, false));
    UtilUI.showOptionDialog2(context, MultiLanguage.get('ttl_option'), options);
    Util.trackActivities('comment_detail', path: 'Comment Detail -> Option Menu Button -> Open Option Dialog');
  }

  void _delete() {
    Navigator.of(context).pop();
    UtilUI.showCustomDialog(context, MultiLanguage.get('msg_question_delete_comment'), isActionCancel: true).then((value) {
      if(value != null && value) {
        final page = widget as CommentDetailPage;
        bloc!.add(DeleteCommentEvent(page.item.id, (Constants().userId??-11) == page.item.user.id, true, -1));
        bloc!.add(TrackEvent('comment_detail', 'Comment Detail -> Confirm Dialog -> OK Button -> Delete Comment (id = ${page.item.id})'));
      } else Util.trackActivities('comment_detail', path: 'Comment Detail -> Confirm Dialog -> Cancel Button');
    });
    Util.trackActivities('comment_detail', path: 'Comment Detail -> Option Dialog -> Choose "Delete Comment" -> Open Confirm Dialog');
  }

  void _edit() {
    Navigator.of(context).pop();
    UtilUI.showConfirmDialog(context, MultiLanguage.get('lbl_write_answer'),
      '', '', title: 'Cập nhật bình luận', isCheckEmpty: false, line: 0,
      initContent: (widget as CommentDetailPage).item.content, padding: EdgeInsets.all(30.sp),
      action: TextInputAction.newline, inputType: TextInputType.multiline).then((value) {
        if (value != null && value is String && value.isNotEmpty) {
          final item = (widget as CommentDetailPage).item;
          _content = item.content;
          item.content = value;
          bloc!.add(EditCommentEvent(value, item.id, (Constants().userId??-11) == item.user.id, true));
        }
      });
    Util.trackActivities('comment_detail', path: 'Comment Detail -> Option Dialog -> Choose "Edit Comment" -> Open Edit Dialog');
  }
}
