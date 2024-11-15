import 'package:flutter_html/flutter_html.dart';
import 'package:hainong/common/models/item_option.dart';
import 'package:hainong/common/ui/avatar_circle_widget.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/ui/shadow_decoration.dart';
import 'package:hainong/common/ui/slider_video_page.dart';
import 'package:hainong/features/comment/model/comment_model.dart';
import 'package:hainong/common/import_lib_system.dart';
import 'package:hainong/features/comment/ui/comment_detail_page.dart';
import 'package:hainong/features/function/info_news/news/ui/news_detail_page.dart';
import 'package:hainong/features/function/info_news/news/ui/news_list_page.dart';
import 'package:hainong/features/function/info_news/video/video_list_page.dart';
import 'package:hainong/features/home/bloc/home_bloc.dart';
import 'package:hainong/features/main/bloc/main_bloc.dart';
import 'package:hainong/features/notification/notification_bloc.dart';
import 'package:hainong/features/post/ui/post_detail_page.dart';
import 'package:hainong/features/product/ui/product_detail_page.dart';
import 'package:hainong/features/shop/ui/import_ui_shop.dart';
import 'package:hainong/features/shop/ui/shop_page.dart';
import '../comment_bloc.dart';

class CommentItemPage extends StatefulWidget {
  final CommentModel item;
  final bool showTime, hasControl, isComment, hasIcon, showChild, openRoot;
  final EdgeInsets? margin, padding;
  final int? index;
  final Function? funReloadParent;
  const CommentItemPage(this.item, {this.funReloadParent, this.showChild = true, this.hasIcon = true,
    this.isComment = true, this.hasControl = false, this.index, this.showTime = false,
    this.margin, this.padding, this.openRoot = false, Key? key}) :super(key: key);
  @override
  CommentItemPageState createState() => CommentItemPageState();
}

class CommentItemPageState extends State<CommentItemPage> {
  static int? idComment = -1;
  TextEditingController? _ctrAnswer;
  FocusNode? _fcAnswer;
  final _bloc = CommentBloc(CommentState());
  late StreamSubscription _stream;
  String _avatar = '';
  bool _isLock = false, _isAnswer = true, _showDetail = false, _showLabel = true;

  @override
  void dispose() {
    _stream.cancel();
    _bloc.close();
    _ctrAnswer?.dispose();
    _fcAnswer?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SharedPreferences.getInstance().then((prefs) {
      setState(() => _avatar = prefs.getString('image')??'');
    });
  }

  @override
  void initState() {
    _bloc.stream.listen((state) {
      if (state is LikeCommentState && isResponseNotError(state.resp, passString: true)) {
        widget.item.user_liked = true;
        widget.item.total_likes++;
      } else if (state is UnlikeCommentState && isResponseNotError(state.resp, passString: true)) {
        widget.item.user_liked = false;
        widget.item.total_likes--;
      } else if (state is ReportCommentState && isResponseNotError(state.resp, passString: true)) {
        UtilUI.showCustomDialog(context, MultiLanguage.get('msg_warning_comment_success'), title: MultiLanguage.get('ttl_alert'));
      } else if (state is AnswerCommentState && isResponseNotError(state.response)) {
        if (widget.funReloadParent != null) {
          widget.funReloadParent!();
        }
        _hideKeyboard();
        setState(() {
          widget.item.user_commented = true;
          widget.item.total_answers++;
          _showLabel = !_showDetail;
          widget.item.copyAnswer(state.response.data);
        });
        BlocProvider.of<MainBloc>(context).add(ReloadSubCommentEvent());
      } else if (state is GetCommentState) {
        setState(() {
          _showDetail = widget.isComment && state.value.answer != null && state.value.answer!.id > 0;
          _showLabel = !_showDetail && state.value.total_answers > 0;
          widget.item.copy(state.value);
        });
      } else if (state is DeleteCommentState && isResponseNotError(state.resp, passString: true)) {
        if (widget.funReloadParent != null) {
          widget.funReloadParent!();
        }
        setState(() {
          widget.item.id = -1;
        });
        BlocProvider.of<MainBloc>(context).add(ReloadSubCommentEvent());
      } else if (state is EditCommentState) {
        if (isResponseNotError(state.resp, passString: true)) {
          setState(() {
            widget.item.content = _ctrAnswer!.text;
          });
        }
        _hideKeyboard();
      } else if (state is LoadPostState) {
        SharedPreferences.getInstance().then((prefs) {
          if (prefs.containsKey('shop_id')) {UtilUI.goToNextPage(context,
              PostDetailPage(state.response.data, 0, HomeBloc(HomeState()),
                  (prefs.getInt(Constants().shopId)??0).toString(), null));}
        });
      } else if (state is LoadNewsState) {
        NewsListPage.autoPLayNews = false;
        UtilUI.goToNextPage(context, NewsDetailPage(state.response.data, -1, isVideo: state.type == 'Video'));
      } else if (state is LoadImageDtlState && isResponseNotError(state.response)) {
        UtilUI.goToNextPage(context, SliderVideoPage(state.response.data, index: state.id));
      }
    });
    super.initState();
    _stream = BlocProvider.of<MainBloc>(context).stream.listen((state) {
      if (state is HideTextFieldState) _bloc.add(OpenInputEvent(idComment == widget.item.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: 30.sp, color: Colors.blue);
    final String permission = Constants().permission??'';
    final bool owner = (Constants().userId??-11) == widget.item.user.id;
    bool show = owner || permission == 'admin';
    if (!owner) {
      if (widget.item.classable_type == 'Comment' && permission == 'smod') show = true;
      if (widget.item.classable_type == 'SubComment' && (permission == 'smod' || permission == 'mod')) show = true;
    }

    if (widget.item.id == -1) return const SizedBox();
    String content = widget.item.replier.id > 0 ? '<span style="color: #42A5F5">@${widget.item.replier.name}</span> ' : '';
    content += widget.item.content.replaceAll('\n', '<br>');
    return Container(margin: widget.margin, padding: widget.padding??EdgeInsets.fromLTRB(40.sp, 40.sp, 20.sp, 20.sp),
      decoration: widget.isComment ? ShadowDecoration(opacity: widget.showTime || widget.item.rate < 1 ? 0.15 : 0.0) : const BoxDecoration(color: Colors.white),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          ButtonImageWidget(200, _goToShop, AvatarCircleWidget(link: widget.item.user.image, size: 120.sp)),
          SizedBox(width: 30.sp),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Column(children: [
                ButtonImageWidget(5, _goToShop, UtilUI.createLabel(widget.item.user.name, color: Colors.black, fontSize: 45.sp)),
                Row(children: [widget.showTime || widget.item.rate < 1 ? Icon(Icons.av_timer, size: 40.sp, color: Colors.orange) : Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 5.sp),
                    decoration: BoxDecoration(color: StyleCustom.buttonColor, borderRadius: BorderRadius.circular(30.sp)),
                    child: Row(children: [
                      Text(widget.item.rate.toString(), style: TextStyle(color: Colors.white, fontSize: 30.sp)),
                      Icon(Icons.star, color: Colors.white, size: 30.sp)
                    ])),
                  UtilUI.createLabel(' ' + Util.getTimeAgo(widget.item.created_at), color: Colors.black87, fontSize: 30.sp, fontWeight: FontWeight.normal)
                ]),
              ], crossAxisAlignment: CrossAxisAlignment.start)),
              (show || (widget.openRoot && widget.item.source_id > 0)) ?
                ButtonImageWidget(50, _selectOption, Padding(padding: const EdgeInsets.all(5),
                    child: Icon(Icons.more_vert, size: 58.sp, color: const Color(0xFFCDCDCD)))) : SizedBox(width: 20.sp)
            ], crossAxisAlignment: CrossAxisAlignment.start),
            Padding(child: Html(data: content, style: {
                  'html': Style(margin: EdgeInsets.zero, padding: EdgeInsets.zero),
                  'body': Style(margin: EdgeInsets.zero, padding: EdgeInsets.zero),
                  'span': Style(margin: EdgeInsets.zero, padding: EdgeInsets.zero),
                  'div': Style(margin: EdgeInsets.zero, padding: EdgeInsets.zero),
                  'p': Style(margin: EdgeInsets.zero, padding: EdgeInsets.zero)
            }), padding: EdgeInsets.only(top: 10.sp, bottom: 20.sp))
          ]))
        ], crossAxisAlignment: CrossAxisAlignment.start),

        Row(children: [
              ButtonImageWidget(0, _like, BlocBuilder(bloc: _bloc, buildWhen: (oldS, newS) => newS is LikeCommentState || newS is UnlikeCommentState,
                  builder: (context, state) => Row(children: [
                    Image.asset('assets/images/ic_like.png',
                        color: widget.item.user_liked ? StyleCustom.likeColor : StyleCustom.borderTextColor,
                        height: 32.sp, width: 32.sp),
                    Text((widget.item.user_liked ? ' Đã thích' : ' Thích') + (widget.item.total_likes > 0 ? ' (${widget.item.total_likes})' : ''), style: style)
                  ]))),
              Padding(child: ButtonImageWidget(0, _openInputAnswer, BlocBuilder(bloc: _bloc, buildWhen: (oldS, newS) =>
                newS is AnswerCommentState,
                  builder: (context, state) => Row(children: [
                    Image.asset('assets/images/ic_comment.png',
                        color: widget.item.user_commented ? StyleCustom.likeColor : StyleCustom.borderTextColor,
                        height: 32.sp, width: 32.sp),
                    //Text((widget.item.user_commented ? ' Đã trả lời' : ' Trả lời') + (widget.item.total_answers > 0 ? ' (${widget.item.total_answers})' : ''), style: style)
                    Text(widget.item.user_commented ? ' Đã trả lời' : ' Trả lời', style: style)
                  ]))), padding: EdgeInsets.symmetric(horizontal: 30.sp)),
              ButtonImageWidget(0, _report, Row(children: [
                Image.asset('assets/images/ic_warning.png', color: StyleCustom.borderTextColor, height: 32.sp, width: 32.sp),
                Text(' Vi phạm', style: style)
              ])),
              SizedBox(width: 30.sp),
              //if (widget.isComment && widget.item.answer != null && widget.item.answer!.id > 0)
                ButtonImageWidget(0, _showHideDetail, BlocBuilder(bloc: _bloc,
                    buildWhen: (oldS, newS) => newS is ShowDetailState, builder: (context, state) =>
                    widget.isComment && widget.item.total_answers > 0 && _showLabel ? Row(children: [
                      Icon(Icons.comment, size: 32.sp, color: StyleCustom.borderTextColor),
                      Text(' Bình luận' + (widget.item.total_answers > 0 ?
                      ' (${widget.item.total_answers})' : ''), style: style)
                    ]) : const SizedBox()))
            ]),

        BlocBuilder(bloc: _bloc, buildWhen: (oldS, newS) => newS is OpenInputState,
                builder: (context, state) {
                  bool show = false;
                  if (state is OpenInputState) show = state.value;
                  return show ? Column(children: [
                    GestureDetector(onTap: () => _hideKeyboard(),
                        child: Icon(Icons.clear, color: Colors.black38, size: 60.sp)),
                    Container(padding: EdgeInsets.only(top: 20.sp), color: Colors.white,
                      constraints: BoxConstraints(minHeight: 0, maxHeight: 0.1.sh),
                      child: Row(children: [
                        AvatarCircleWidget(link: _avatar, size: 120.sp),
                        SizedBox(width: 40.sp),
                        Expanded(child: UtilUI.createTextField(context, _ctrAnswer, _fcAnswer, null,
                          MultiLanguage.get('lbl_write_answer'), inputAction: TextInputAction.newline, maxLines: null,
                          inputType: TextInputType.multiline, onPressIcon: _sendAnswer,
                          padding: EdgeInsets.all(40.sp), sizeBorder: 20.sp, suffixIcon: const Icon(Icons.send_outlined)))
                    ]))
                  ], crossAxisAlignment: CrossAxisAlignment.end) : const SizedBox();
                }),

        if (widget.isComment) Padding(child: BlocBuilder(bloc: _bloc,
              buildWhen: (oldS, newS) => newS is ShowDetailState, builder: (context, state) =>
                _showDetail ? CommentDetailPage(widget.item, isSubComment: false, reloadParent: _reloadParent) : const SizedBox()
              ), padding: EdgeInsets.only(left: 40.sp))
      ]));
  }

  bool isResponseNotError(BaseResponse state, {bool passString = false, bool showError = true}) {
    _isLock = false;
    if (state.checkTimeout()) {
      if (showError) UtilUI.showDialogTimeout(context);
      return false;
    }
    if (state.checkOK(passString: passString)) return true;
    if (showError && state.data != null) UtilUI.showCustomDialog(context, state.data);
    return false;
  }

  void _hideKeyboard() {
    _isLock = false;
    _bloc.add(OpenInputEvent(false));
    idComment = -1;
    if (mounted) BlocProvider.of<MainBloc>(context).add(HideTextFieldEvent(true));
  }

  void _like() {
    if (!Constants().isLogin) {
      UtilUI.showDialogTimeout(context, message: LanguageKey().msgLoginOrCreate);
      return;
    }
    if (_isLock) return;
    _isLock = true;
    widget.item.user_liked ? _bloc.add(UnlikeCommentEvent(widget.item.classable_id, widget.item.classable_type)) :
      _bloc.add(LikeCommentEvent(widget.item.classable_id, widget.item.classable_type));
    Util.trackActivities('comment', path: 'Comment -> ${widget.item.user_liked?'Unlike':'Like'} Comment "${widget.item.content}"');
  }

  void _openInputAnswer() {
    _isAnswer = true;
    _ctrAnswer??= TextEditingController();
    _fcAnswer??= FocusNode();
    idComment = widget.item.id;
    _ctrAnswer!.text = '';
    _bloc.add(OpenInputEvent(true));
    if (mounted) BlocProvider.of<MainBloc>(context).add(HideTextFieldEvent(false));
    _fcAnswer!.requestFocus();
    Util.trackActivities('comment', path: 'Comment -> Answer Comment -> Show Keyboard');
  }

  void _sendAnswer() async {
    if (!Constants().isLogin) {
      UtilUI.showDialogTimeout(context);
      return;
    }
    if (_ctrAnswer!.text.trim().isEmpty) return;
    if (_ctrAnswer!.text.length < 6) {
      UtilUI.showCustomDialog(context, 'Nội dung phải ít nhất 6 ký tự trở lên').whenComplete(() => _fcAnswer!.requestFocus());
      return;
    }
    if (await UtilUI().alertVerifyPhone(context)) return;
    if (_isLock) return;
    _isLock = true;
    //final FocusScopeNode currentScope = FocusScope.of(context);
    //if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) FocusManager.instance.primaryFocus!.unfocus();
    if (_isAnswer) {
      _bloc.add(AnswerCommentEvent(_ctrAnswer!.text.trim(), widget.isComment ? widget.item.classable_id :
        widget.item.comment_id.toString(), replierId: widget.isComment ? null : widget.item.user.id, parentId: widget.isComment ? null : widget.item.id));
    } else {
      _bloc.add(EditCommentEvent(_ctrAnswer!.text.trim(), widget.item.id, (Constants().userId??-11) == widget.item.user.id, widget.isComment));
    }
    Util.trackActivities('comment', path: 'Comment -> ${_isAnswer ? 'Answer' : 'Edit'} Comment -> Send ${_isAnswer ? 'Answer' : 'Editing'} For Comment "${widget.item.content}"');
  }

  void _report() {
    if (!Constants().isLogin) {
      UtilUI.showDialogTimeout(context);
      return;
    }
    UtilUI.showConfirmDialog(context, MultiLanguage.get('msg_input_reason'), '', '', title: 'Báo cáo bình luận',
        isCheckEmpty: false).then((value) => _sendReport(value));
    Util.trackActivities('comment', path: 'Comment -> Choose "Report Comment" -> Open Report Comment Dialog');
  }

  void _sendReport(value) {
    if (value != null && value is String) {
      if (_isLock) return;
      _isLock = true;
      _bloc.add(ReportCommentEvent(widget.item.classable_id, widget.item.classable_type, value, widget.index!));
      _bloc.add(TrackEvent('Comment -> Report Comment Dialog -> OK Button -> Send "Report Comment" with content = $value', 'comment'));
    } else Util.trackActivities('comment', path: 'Comment -> Report Comment Dialog -> Close Button');
  }

  void _reloadParent() {
    _bloc.add(GetCommentEvent(widget.item.id));
    if (widget.funReloadParent != null) widget.funReloadParent!();
  }

  void _showHideDetail() {
    if (!_showDetail) {
      _showDetail = true;
      _showLabel = false;
      _bloc.add(ShowDetailEvent());
    }
  }

  void _selectOption() async {
    await Util.getPermission();
    final String permission = Constants().permission??'';
    final bool owner = (Constants().userId??-11) == widget.item.user.id;
    bool show = owner || permission == 'admin';
    if (!owner) {
      if (widget.item.classable_type == 'Comment' && permission == 'smod') show = true;
      if (widget.item.classable_type == 'SubComment' && (permission == 'smod' || permission == 'mod')) show = true;
    }

    final List<ItemOption> options = [];
    if (widget.item.source_id > 0) {
      String type = 'bài viết';
      switch(widget.item.source_type) {
        case 'Product': type = 'sản phẩm'; break;
        case 'Article': type = 'tin tức'; break;
        case 'Video': type = 'tin video'; break;
        case 'Image': type = 'ảnh'; break;
        case 'ShortVideo': type = 'video ngắn'; break;
      }
      options.add(ItemOption('', 'Đến màn hình $type gốc', _gotoRoot, false, icon: Icons.insert_comment_outlined));
    }
    if (show) options.add(ItemOption('assets/images/ic_edit_post.png', MultiLanguage.get('lbl_edit_comment'), _edit, false));
    if (show && widget.item.rate < 1) options.add(ItemOption('assets/images/ic_delete_circle.png', MultiLanguage.get('lbl_delete_comment'), _delete, false));
    if (options.isNotEmpty) {
      UtilUI.showOptionDialog2(context, MultiLanguage.get('ttl_option'), options);
      Util.trackActivities('comment', path: 'Comment -> Option Menu Button -> Open Option Dialog');
    }
  }

  void _delete() {
    Navigator.of(context).pop();
    UtilUI.showCustomDialog(context, MultiLanguage.get('msg_question_delete_comment'), isActionCancel: true).then((value) {
      if(value != null && value) {
        _bloc.add(DeleteCommentEvent(widget.item.id, (Constants().userId??-11) == widget.item.user.id, widget.isComment, widget.item.comment_id));
        _bloc.add(TrackEvent('Comment -> Confirm Dialog -> OK Button -> Delete Comment (id = ${widget.item.id})', 'comment'));
      } else Util.trackActivities('comment', path: 'Comment -> Confirm Dialog -> Cancel Button');
    });
    Util.trackActivities('comment', path: 'Comment -> Option Dialog -> Choose "Delete Comment" -> Open Confirm Dialog');
  }

  void _edit() {
    Navigator.of(context).pop();
    _openInputAnswer();
    _ctrAnswer!.text = widget.item.content;
    _isAnswer = false;
  }

  void _gotoRoot() async {
    Navigator.of(context).pop(false);
    switch(widget.item.source_type) {
      case 'Image': _bloc.add(LoadImageDtlEvent(widget.item.source_id.toString(), widget.item.source_id)); break;
      case 'Post': _bloc.add(LoadPostEvent(widget.item.source_id, type: 'comment_detail')); break;
      case 'Product':
        final pro = ProductModel(id: widget.item.source_id);
        UtilUI.goToNextPage(context, ProductDetailPage(pro, await Util.getShop())); break;
      case 'ShortVideo': UtilUI.goToNextPage(context, VideoListPage(idDetail: widget.item.source_id)); break;
      default: _bloc.add(LoadNewsEvent(widget.item.source_id, widget.item.source_type));
    }
    Util.trackActivities('comment', path: 'Comment -> Loading ${widget.item.source_type} Detail');
  }

  bool? _lock;
  StreamSubscription? _subStream;
  void _goToShop() {
    if (widget.item.user.shop_id.isNotEmpty) {
      SharedPreferences.getInstance().then((prefs) {
        final shopId = prefs.getInt(Constants().shopId).toString();
        if (widget.item.user.shop_id == shopId) {
          UtilUI.goToNextPage(context, ShopPage(hasHeader: true));
          Util.trackActivities('comment', path: 'Comment Item -> Information User/Shop -> Open My Shop Screen');
        } else {
          if (_lock != null && _lock!) return;
          _lock = true;
          _subStream = _bloc.stream.listen((state) {
            if (state is LoadShopHomeState) {
              _handleLoadShop(state);
              _lock = false;
              _lock = null;
              _subStream?.cancel();
              _subStream = null;
            }
          });
          _bloc.add(LoadShopHomeEvent(null, widget.item.user.shop_id));
          Util.trackActivities('comment', path: 'Comment Item -> Information User/Shop');
        }
      });
    }
  }

  void _handleLoadShop(LoadShopHomeState state) {
    if (state.response.data is String) return;
    ShopModel shop = state.response.data as ShopModel;
    if (shop.id > -1) {
      UtilUI.goToNextPage(context, ShopPage(shop: state.response.data,
          isOwner: false, hasHeader: true, isView: true));
      Util.trackActivities('comment', path: 'Comment Item -> Information User/Shop -> Open Shop Screen');
    }
  }
}