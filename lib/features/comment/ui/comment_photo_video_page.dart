import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/models/item_option.dart';
import 'package:hainong/common/ui/avatar_circle_widget.dart';
import 'package:hainong/common/ui/divider_widget.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/features/main/bloc/main_bloc.dart';
import 'comment_item_page.dart';
import '../comment_bloc.dart';
import '../model/comment_model.dart';

class CommentPhVPage extends BasePage {
  final ItemModel2 item;
  final Function? reloadItem;
  final double? height;
  CommentPhVPage(this.item, {this.height, this.reloadItem, Key? key}) : super(key: key, pageState: _CommentPhVPageState());

  void refresh(String type, int id) => (pageState as _CommentPhVPageState).resetList(type: type, id: id);
}

class _CommentPhVPageState extends BasePageState {
  final TextEditingController _ctr = TextEditingController();
  final FocusNode _fc = FocusNode();
  final List<CommentModel> _list = [];
  final ScrollController _scroller = ScrollController();
  int _page = 1, _id = -1, _idTemp = -1;
  String _type = '', _avatar = '';
  bool _isLock = false, _sortLike = false;

  @override
  void dispose() {
    final page = widget as CommentPhVPage;
    if (page.reloadItem != null) page.reloadItem!(true);
    _ctr.dispose();
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
    final page = widget as CommentPhVPage;
    _id = _idTemp = page.item.classable_id;
    _type = page.item.classable_type;
    _next();
    bloc!.add(GetAvatarEvent());
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    return GestureDetector(onVerticalDragDown: (details) {clearFocus();},
        onTapUp: (value) {clearFocus();}, child: createUI());
  }

  @override
  Widget createUI() {
    final CommentPhVPage page = widget as CommentPhVPage;
    return Column(children: [
      Container(constraints: BoxConstraints(maxHeight: page.height??0.32.sh),
          child: BlocBuilder(bloc: bloc, builder: (context, state) =>
            ListView.builder(padding: EdgeInsets.zero, controller: _scroller, shrinkWrap: true,
              itemCount: _list.length, itemBuilder: (context, index) => CommentItemPage(_list[index], hasControl: true,
                  index: index, showTime: true, margin: EdgeInsets.only(bottom: 40.sp), funReloadParent: _reloadPost),
                physics: const AlwaysScrollableScrollPhysics()),
          buildWhen: (state1, state2) => state2 is LoadListCommentState)),// || state2 is ReloadListCommentState),
      const DividerWidget(),
    BlocBuilder(bloc: BlocProvider.of<MainBloc>(context), builder: (context, state) {
    bool show = true;
    if (state is HideTextFieldState) show = state.hideKeyboard;
    return show ? Container(padding: EdgeInsets.all(40.sp), color: Colors.white, child: Row(children: [
        BlocBuilder(builder: (context, state) {
          if (state is GetAvatarState && _avatar.isEmpty) _avatar = state.avatar;
          return AvatarCircleWidget(link: _avatar, size: 120.sp);
        }, bloc: bloc, buildWhen: (oldS, newS) => newS is GetAvatarState),
        SizedBox(width: 40.sp),
        Expanded(child: Container(constraints: BoxConstraints(minHeight: 0, maxHeight: 0.5.sh),
          child: SingleChildScrollView(child: Column(children: [
            UtilUI.createTextField(context, _ctr, _fc, null,
              MultiLanguage.get('lbl_write_comment'), inputAction: TextInputAction.newline, maxLines: null,
              inputType: TextInputType.multiline, onPressIcon: _sendComment,
              padding: EdgeInsets.all(40.sp), sizeBorder: 100.sp, suffixIcon: const Icon(Icons.send_outlined))
        ], mainAxisSize: MainAxisSize.min))))
      ])) : const SizedBox();
    }, buildWhen: (oldS, newS) => newS is HideTextFieldState)
    ]);
  }

  void _listenScroller() {
    if (_scroller.position.maxScrollExtent == _scroller.position.pixels && _page > 0) _next();
  }

  void _sendComment() async {
    if (!constants.isLogin) {
      UtilUI.showDialogTimeout(context, message: languageKey.msgLoginOrCreate);
      return;
    }
    clearFocus();
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
    if (_page > 0) bloc!.add(LoadListCommentEvent(_page, _type, _idTemp, _sortLike));
  }

  void _handleLoadList(LoadListCommentState state) {
    if (isResponseNotError(state.response) && state.response.data is CommentsModel) {
      if (_id != _idTemp) {
        setState((){
          _list.clear();
        });
        _id = _idTemp;
      }
      List<CommentModel> tmp = (state.response.data as CommentsModel).list;
      for (var element in tmp) {
        _list.add(element);
      }
      tmp.length < constants.limitPage ? _page = 0 : _page++;
    }
  }

  void _handleSendComment(SendCommentState state) {
    _isLock = false;
    if (isResponseNotError(state.response)) {
      _reloadPost();
      resetList();
      _ctr.text = '';
    }
  }

  void _reloadPost() {
    final page = widget as CommentPhVPage;
    if (page.reloadItem != null) page.reloadItem!(true);
  }

  void resetList({String? type, int? id}) {
    _page = 1;
    if (id != null && _idTemp != id) {
      _type = type!;
      _idTemp = id;
    }
    setState((){
      _list.clear();
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
      resetList();
      bloc!.add(ChangeFilterEvent());
      Util.trackActivities('comment', path: 'Comment -> Option Dialog -> Choose Sort By ${sortLike ? 'Most Liked' : 'Latest'}');
    }
    Navigator.of(context).pop(false);
  }
}
