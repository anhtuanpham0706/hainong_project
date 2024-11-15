import 'dart:async';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/features/comment/ui/comment_photo_video_page.dart';
import 'package:hainong/features/function/info_news/news/news_bloc.dart';
import 'package:hainong/features/home/ui/import_ui_home.dart';
import 'package:hainong/features/post/sub_ui/controls_post.dart';
import 'package:hainong/features/post/ui/share_page.dart';
import 'package:photo_view/photo_view.dart';
import '../models/item_list_model.dart';
import '../models/item_option.dart';
import 'animation/animated_page.dart';
import 'animation/scale_effect.dart';
import 'image_network_asset.dart';
import 'label_custom.dart';
import 'loading.dart';

class SliderVideoPage extends StatefulWidget {
  final Post item;
  final int index;
  final Function? reloadPosts;
  const SliderVideoPage(this.item, {Key? key, this.index = 0, this.reloadPosts}) : super(key: key);

  @override
  _SliderVideoPageState createState() => _SliderVideoPageState();
}

class _SliderVideoPageState extends State<SliderVideoPage> {
  int index = 0, _shopId = -1;
  bool _lock = false, _checkPostAuto = false;
  late PageController _scaleController;
  final ScrollController _scroller = ScrollController();
  final HomeBloc _subBloc = HomeBloc(HomeState());
  late CommentPhVPage _commentPage;
  late double start;

  @override
  void dispose() {
    _scaleController.dispose();
    _scroller.dispose();
    _subBloc.close();
    super.dispose();
  }

  @override
  void initState() {
    index = widget.index;
    _scaleController = PageController(initialPage: index > 0 ? index : 0);
    SharedPreferences.getInstance().then((value) {
      _shopId = value.getInt(Constants().shopId)??-1;
      _subBloc.add(ReloadPostHomeEvent());
    });
    _commentPage  = CommentPhVPage(widget.item.images.list[index], reloadItem: _reloadImage);
    super.initState();
    _subBloc.stream.listen((state) {
      if (state is LikePostHomeState) {
        if (state.response.data is ItemModel) {
          widget.item.images.list[index].user_liked = state.response.data.user_liked;
          widget.item.images.list[index].total_like = state.response.data.total_like;
        }
        _lock = false;
      } else if (state is UnlikePostHomeState) {
        if (state.response.checkOK(passString: true)) {
          widget.item.images.list[index].user_liked = false;
          widget.item.images.list[index].total_like --;
        }
        _lock = false;
      } else if (state is SharePostHomeState && state.response.checkOK(passString: true)) {
        widget.item.user_shared = true;
        widget.item.images.list[index].user_shared = true;
        Navigator.of(context).pop(false);
        if (widget.reloadPosts != null) widget.reloadPosts!();
      } else if (state is TransferPointState && state.response.checkOK(passString: true)) {
        UtilUI.showCustomDialog(context, MultiLanguage.get('msg_transfer'), title: MultiLanguage.get(LanguageKey().ttlAlert));
      } else if (state is LoadImageDtlHomeState && state.response.checkOK()) {
        widget.item.images.list[index].copyComment(state.response.data);
      } else if (state is WarningPostHomeState && _isResponseNotError(state.response, passString: true)) {
        final LanguageKey languageKey = LanguageKey();
        UtilUI.showCustomDialog(context, 'Báo ảnh/video đã gửi xong', title: MultiLanguage.get(languageKey.ttlAlert));
      } else if (state is CreatePostState && _isResponseNotError(state.response)) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(MultiLanguage.get('msg_'+(_checkPostAuto?'':'in')+'active_process_post_auto'))));
      }else if (state is CheckProcessPostAutoState) {
        _checkPostAuto = state.isActive ?? false;
      }
    });
    _subBloc.add(CheckProcessPostAutoEvent());
  }

  void _jumpTo(int value) {
    //if (_lock) return;
    //_lock = true;
    index = value;
    _subBloc.add(ChangeIndexHomeEvent(index));
    _subBloc.add(ReloadPostHomeEvent());
    final item = widget.item.images.list[index];
    _commentPage.refresh(item.classable_type, item.classable_id);
    //Timer(const Duration(seconds: 1), () => _lock = false);
  }

  @override
  Widget build(BuildContext context) {
    final temp = Column(children: [
      const Divider(height: 0.2, color: Colors.grey),
      SizedBox(height: 1.sh - 440.sp, width: 1.sw, child: Stack(children: [
        PageView.builder(controller: _scaleController, padEnds: false,
          onPageChanged: _jumpTo, physics: const BouncingScrollPhysics(),
          itemCount: widget.item.images.list.length, itemBuilder: (context, index) =>
            AnimatedPage(controller: _scaleController, index: index, effect: const ScaleEffect(),
              child: Util.isImage(widget.item.images.list[index].name) ? Stack(children: [
                Container(alignment: Alignment.center, color: Colors.black,
                  child: ImageNetworkAsset(path: widget.item.images.list[index].name,
                  error: 'assets/images/ic_default.png', cache: true, rateCache: 2, width: 1.sw)),
                Container(alignment: Alignment.bottomRight, margin: EdgeInsets.all(40.sp),
                  child: ButtonImageWidget(0, _zoomImage, Column(children: [
                    Icon(Icons.zoom_out_map, size: 80.sp, color: Colors.white),
                    LabelCustom('Zoom', size: 25.sp, weight: FontWeight.w500)
                  ], mainAxisSize: MainAxisSize.min)))
              ]) : VideoPage(widget.item.images.list[index].name, index, autoPlay: false,
                  height: 1.sh - 440.sp, key: Key(DateTime.now().toString())))
        ),
        if (widget.item.images.list.length > 1) _preNextUI(Icons.arrow_back_ios_rounded, Alignment.centerLeft, -1),
        if (widget.item.images.list.length > 1) _preNextUI(Icons.arrow_forward_ios_rounded, Alignment.centerRight, 1),
        Loading(_subBloc)
      ])),
      Padding(padding: EdgeInsets.symmetric(horizontal: 20.sp), child:
      BlocBuilder(bloc: _subBloc, builder: (context, state) => ControlsPost(
          widget.item.images.list[index].user_liked,
          widget.item.images.list[index].user_comment,
          widget.item.user_shared,
          widget.item.images.list[index].shop_id > 0 && widget.item.images.list[index].shop_id != _shopId,
          widget.item.images.list[index].total_like,
          widget.item.images.list[index].total_comment,
          _like, _unlike, _comment, _share, _transferPoint, index: index),
          buildWhen: (oldS, newS) => newS is LikePostHomeState || newS is UnlikePostHomeState ||
              newS is SharePostHomeState || newS is LoadImageDtlHomeState || newS is ReloadPostHomeState)),
      _commentPage
    ]);
    return Scaffold(appBar: AppBar(
      title: LabelCustom(widget.item.shop_name, size: 48.sp, align: TextAlign.center),
      centerTitle: true, backgroundColor: Colors.black, actions: [
        BlocBuilder(bloc: _subBloc, buildWhen: (olds, news)=> news is ReloadPostHomeState,
          builder: (context, state) {
            if (_shopId.toString() != widget.item.shop_id.toString()) return IconButton(icon: Icon(Icons.more_vert, size: 60.sp, color: Colors.white), onPressed: _menu);
            return const SizedBox();
          })
      ]), body: SingleChildScrollView(child: temp, controller: _scroller));
  }

  Widget _preNextUI(IconData icon, align, int rate) => Align(alignment: align,
    child: IconButton(icon: Icon(icon, size: 120.sp, color: const Color(0x6FFFFFFF)),
    onPressed: () {
        final next = index + rate;
        if (next < 0 || next == widget.item.images.list.length) return;
        _scaleController.jumpToPage(next);
    }));

  void _like(BuildContext context, int index) {
    if (Constants().isLogin) {
      if (!_lock) {
        _lock = true;
        _subBloc.add(LikePostHomeEvent(widget.item.images.list[index].classable_id.toString(), widget.item.images.list[index].classable_type, index));
        Util.trackActivities('post', path: 'Photo/video Post -> Like Button -> Like Photo/video (id = ${widget.item.images.list[index].id})');
      }
    } else UtilUI.showCustomDialog(context, MultiLanguage.get(LanguageKey().msgLoginOrCreate));
  }

  void _unlike(BuildContext context, int index) {
    if (Constants().isLogin) {
      if (!_lock) {
        _lock = true;
        _subBloc.add(UnlikePostHomeEvent(widget.item.images.list[index].classable_id.toString(), widget.item.images.list[index].classable_type, index));
        Util.trackActivities('post', path: 'Photo/video Post -> Like Button -> Unlike Photo/video (id = ${widget.item.images.list[index].id})');
      }
    } else UtilUI.showCustomDialog(context, MultiLanguage.get(LanguageKey().msgLoginOrCreate));
  }

  void _comment(BuildContext context) => _scroller.animateTo(_scroller.position.maxScrollExtent, duration: const Duration(seconds: 1), curve: Curves.ease);

  void _share(BuildContext context, int index) {
    if (Constants().isLogin) {
      UtilUI.showOptionDialog(context, 'Chọn chia sẻ', [
        ItemModel(id: 'share_app', name: 'Chia sẻ qua ứng dụng khác'),
        ItemModel(id: 'share_post', name: 'Chia sẻ lên tường của tôi')
      ], '').then((value) {
        if (value != null) value.id == 'share_post' ?
        UtilUI.goToNextPage(context, SharePage(widget.item, index, _subBloc, _shopId.toString())) :
        UtilUI.shareTo(context, '/p/${widget.item.id}/i/${widget.item.images.list[index].id}', 'Photo/video Post -> Option Share Dialog -> Choose "Share"', 'post');
      });
    } else UtilUI.shareTo(context, '/p/${widget.item.id}/i/${widget.item.images.list[index].id}', 'Photo/video Post -> Option Share Dialog -> Choose "Share"', 'post');
  }

  void _transferPoint(BuildContext context) {
    if (!Constants().isLogin) {
      UtilUI.showCustomDialog(context, MultiLanguage.get(LanguageKey().msgLoginOrCreate));
      return;
    }
    if (widget.item.shop_id != _shopId.toString()) {
      UtilUI.showConfirmDialog(context, '',
          MultiLanguage.get('lbl_input_point'), MultiLanguage.get('msg_input_point'),
          title: MultiLanguage.get('ttl_transfer_point'), showMsg: false, inputType: TextInputType.number)
          .then((value) async {
        if (value != null && value is String && value.isNotEmpty) {
          Util.trackActivities('post', path: 'Photo/video Post -> "Give Point" Dialog -> OK Button');
          int point = 0;
          try {
            point = int.parse(value);
          }catch(_) {}
          final prefs = await SharedPreferences.getInstance();
          if (point > (prefs.getInt('points')??0)) {
            UtilUI.showCustomDialog(context, MultiLanguage.get('msg_enough_point'))
                .then((value) => _transferPoint(context));
            Util.trackActivities('post', path: 'Photo/video Post -> Open Waring Dialog');
            return;
          }
          if (point > 0) {
            _subBloc.add(TransferPointEvent(value, widget.item.user_id));
            Util.trackActivities('post', path: 'Photo/video Post -> Give Point Button -> Open "Give Point" Dialog');
          } else _transferPoint(context);
        }
      });
    }
  }

  void _report() {
    Navigator.of(context).pop();
    UtilUI.showConfirmDialog(
        context, MultiLanguage.get('msg_input_reason'), '', '',
        title: 'Báo xấu',
        isCheckEmpty: false)
        .then((value) => _sendReport(value));
    Util.trackActivities('post', path: 'Photo/video Post -> Option Dialog -> Choose "Report Bad Photo/video Post" -> Open Report Photo/video Post Dialog');
  }

  void _sendReport(reason) {
    if (reason is String) {
      _subBloc.add(WarningPostHomeEvent(widget.item.id, reason, index, imageId: widget.item.images.list[index].id));
      Util.trackActivities('post', path: 'Photo/video Post -> Report Photo/video Post Dialog -> OK Button -> Send "Report Bad Post" with content = '+reason);
    } else Util.trackActivities('post', path: 'Photo/video Post -> Report Photo/video Post Dialog -> Close Button');
  }

  void _menu() async {
    if (Constants().isLogin) {
      if (_shopId.toString() == widget.item.shop_id) return;
      UtilUI.showOptionDialog2(context, MultiLanguage.get('ttl_option'), [ItemOption('assets/images/ic_warning.png', ' Báo ảnh/video không hợp lệ', _report, false)]);
      Util.trackActivities('post', path: 'Photo/video Post -> Option Menu Button -> Open Option Dialog');
    } else UtilUI.showCustomDialog(context, MultiLanguage.get(LanguageKey().msgLoginOrCreate));
  }

  void _reloadImage(bool reload) {
    _subBloc.add(LoadImageDtlHomeEvent(widget.item.images.list[index].id, widget.item.id));
    _subBloc.add(ReloadPostHomeEvent());
  }

  bool _isResponseNotError(state, {bool passString = false, bool showError = true}) {
    if (state.checkTimeout()) {
      if (showError) UtilUI.showDialogTimeout(context);
      return false;
    }

    if (state.checkOK(passString: passString)) return true;

    if (showError && state.data != null) UtilUI.showCustomDialog(context, state.data);

    return false;
  }

  void _swipeLR(DragUpdateDetails details) {
    if (details.delta.distance > 10 && !_lock) _jumpTo(details.delta.dx > 0 ? 1 : -1);
  }

  void _zoomImage() => showDialog(context: context, builder: (context) =>
    Dialog(child: Stack(alignment: Alignment.topRight, children: [
        PhotoView(imageProvider: FadeInImage.assetNetwork(placeholder: 'assets/images/ic_default.png',
            imageErrorBuilder: (_,__,___) => Image.asset('assets/images/ic_default.png', fit: BoxFit.cover),
            image: widget.item.images.list[index].name, fit: BoxFit.cover, imageCacheWidth: 5.sw.toInt()).image,
            minScale: 0.2, maxScale: 2.0),
        Container(margin: EdgeInsets.only(top: 40.sp + WidgetsBinding.instance.window.padding.top.sp, right: 40.sp),
          child: ButtonImageWidget(100, () => Navigator.of(context).pop(null), Padding(padding: EdgeInsets.all(20.sp),
              child: Icon(Icons.close, color: Colors.white, size: 80.sp)), color: Colors.white24))
    ]), insetPadding: EdgeInsets.zero), useSafeArea: false);
}
