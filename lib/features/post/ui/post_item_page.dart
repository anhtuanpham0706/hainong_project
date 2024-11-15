import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/models/item_option.dart';
import 'package:hainong/common/ui/slider_video_page.dart';
import 'package:hainong/common/ui/video_page.dart';
import 'package:hainong/common/ui/youtube_player_custom.dart';
import 'package:hainong/features/comment/ui/comment_page.dart';
import '../bloc/editor_bloc.dart';
import '../sub_ui/controls_post.dart';
import '../sub_ui/icon_play_default.dart';
import '../sub_ui/image_theme_post.dart';
import '../sub_ui/shop_info_post.dart';
import '../sub_ui/thumbnail.dart';
import '../sub_ui/title_post.dart';
import 'post_page.dart';
import 'package:hainong/features/shop/shop_model.dart';
import 'package:hainong/features/shop/ui/shop_page.dart';
import 'share_page.dart';
import 'import_lib_ui_post.dart';

abstract class PostDetailCallback {
  reloadPost(Post post);

  showLoginOrCreate({context});
}

class PostItemPage extends StatelessWidget implements ControlVideoListener {
  final Post item;
  final int index;
  final String shopId;
  final HomeBloc bloc;
  final bool isHideOption,
      isHideControls,
      isHighlight,
      isCollapse,
      isOwner,
      isShop,
      allowGotoShop, clearPage;
  final Function? reloadPosts, refreshPost;
  final HomeBloc subBloc = HomeBloc(HomeState());
  final EditorBloc _editorBloc = EditorBloc(EditorState());
  final PostDetailCallback? callback;
  final Map<String, Widget> _thumbnailVideos = {};
  double? playSize;
  VideoPage? videoPage;
  PostItemPage? subItem;
  final ControlVideoListener? controlListener;
  bool _lock = false, hideComment = false, autoPlay;
  StreamSubscription? stream;
  final List<YoutubeCallback> _listYoutube = [];

  @override
  void play(int index) {
    controlListener?.play(this.index);
  }

  @override
  void stop(int index) {
    controlListener?.stop(this.index);
  }

  reloadPost(String id, bool check, int count) {
    item.user_liked = check;
    item.total_like = count;
    subBloc.add(ReloadPostHomeEvent());
  }

  PostItemPage(this.item, this.index, this.bloc, this.shopId,
      {Key? key, this.isHideOption = false,
      this.isHideControls = false,
      this.isShop = false,
      this.isCollapse = true,
      this.callback,
      this.isHighlight = false,
      this.playSize,
      this.autoPlay = false,
      this.isOwner = false,
      this.allowGotoShop = true,
      this.clearPage = true,
      this.reloadPosts,
      this.refreshPost,
      this.controlListener}) : super(key: key) {
    subBloc.stream.listen((state) {
      if (state is LoadPostHomeState) {
        _lock = false;
        _handleResponseLoadPost(state);
      } else if (state is LikePostHomeState) {
        bloc.add(LikePostHomeEvent(state.id, '', state.index, response: state.response));
        if (state.response.data is ItemModel) subBloc.add(LoadPostHomeEvent(item.id, 0));
        _lock = false;
      } else if (state is UnlikePostHomeState) {
        bloc.add(UnlikePostHomeEvent(state.id, '', state.index, response: state.response));
        if (state.response.checkOK(passString: true)) subBloc.add(LoadPostHomeEvent(item.id, 0));
        _lock = false;
      } else if (state is LoadSubPostHomeState) _handleLoadSubPost(state);
      else if(state is FollowPostState) {
        bloc.add(FollowPostEvent('', '', response: state.response));
        if (state.response.checkOK(passString: true)) item.user_followed = true;
        _lock = false;
      } else if(state is UnFollowPostState) {
        bloc.add(UnFollowPostEvent('', '', response: state.response));
        if (state.response.checkOK(passString: true)) item.user_followed = false;
        _lock = false;
      }
    });
    if (item.shared_post_id.isNotEmpty) {
      item.title = item.description;
      subBloc.add(LoadSubPostHomeEvent(item.shared_post_id));
    }
    _editorBloc.add(LoadUrlEditorEvent(item.title));
  }

  @override
  Widget build(BuildContext context) {
    if (isHighlight) {
      return BlocBuilder(
          bloc: subBloc,
          buildWhen: (oldState, newState) =>
              newState is LoadSubPostHomeState && newState.response.data is! String,
          builder: (context, state) => BlocBuilder(
              bloc: _editorBloc,
              buildWhen: (oldState, newState) =>
                  newState is LoadSubVideoEditorState,
              builder: (context, state) => state is LoadSubVideoEditorState
                  ? _thumbnailVideos[state.url]!
                  : UtilUI.imageDefault(asset: 'assets/images/bg_splash.png')));
    }

    Decoration decoration;
    if (isHideOption) {
      decoration = BoxDecoration(
          borderRadius: BorderRadius.circular(20.sp),
          border: Border.all(color: Colors.black26, width: 0.5));
    } else decoration = ShadowDecoration(opacity: 0.2);

    return Container(padding: isShop || (isHideControls && isHideOption) ? null : EdgeInsets.symmetric(horizontal: 20.sp),
        decoration: decoration, margin: EdgeInsets.fromLTRB(isShop ? 40.sp : 0, 10.sp, isShop ? 40.sp : 0, 20.sp),
        child: BlocBuilder(bloc: _editorBloc,
            buildWhen: (state1, state2) => state2 is ReloadItemEditorState,// || state2 is LoadPostHomeState|| state2 is UnFollowPostState || state2 is FollowPostState,
            builder: (context, state) =>
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ShopInfoPost(item.created_at, item.shop_image, item.shop_name, isHideOption, _goToShop, _selectOption,
                      item.viewed, item.total_connect),
                  TitlePost(_editorBloc, item.title, item.short_title, isCollapse, allowGotoShop, _listYoutube, clearPage: clearPage, stopVideo: _stopAll, isShop: isShop),
                  SizedBox(height: 20.sp),
                  item.shared_post_id.isNotEmpty ? BlocBuilder(bloc: subBloc, buildWhen: (oldState, newState) =>
                      newState is LoadSubPostHomeState && newState.response.data is! String,
                    builder: (context, state) {
                      if (state is LoadSubPostHomeState && state.response.data is! String) {
                        subItem = PostItemPage(state.response.data, index, subBloc, shopId,
                          isHideOption: true, isHideControls: true, controlListener: controlListener,
                          isShop: isShop, clearPage: clearPage, autoPlay: autoPlay);
                        return Container(child: subItem, padding: EdgeInsets.symmetric(horizontal: 40.sp));
                      }
                      return const SizedBox();
                    })
                    : ImageThemePost(item.images.list, controlListener, this, _showImagesPage, index, isShop: isShop, funStopYtb: _stopYtb),
                  if (!isHideControls) Padding(child: BlocBuilder(
                              bloc: subBloc,
                              buildWhen: (oldState, newState) =>
                                  (newState is LoadPostHomeState &&
                                      newState.response.data is! String) ||
                                  newState is ReloadPostHomeState,
                              builder: (context, state) => ((state is LoadPostHomeState &&
                                          state.response.data is! String) ||
                                      state is ReloadPostHomeState || state is HomeState)
                                  ? ControlsPost(
                                      item.user_liked,
                                      item.user_comment,
                                      item.user_shared, item.shop_id.isNotEmpty && item.shop_id != shopId,
                                      item.total_like,
                                      item.total_comment,
                                      _like, _unlike, _comment,
                                      _share, _transferPoint)
                                  : Container()), padding: EdgeInsets.symmetric(horizontal: 20.sp)),
                ])));
  }

  void stopPlay() {
    videoPage?.stopPlay();
    subItem?.stopPlay();
    _stopYtb();
  }

  void stopScroll() {
    if (autoPlay) {
      videoPage?.stopScroll();
      subItem?.stopScroll();
    }
    _stopYtb();
  }

  void _stopYtb() {
    for (var item in _listYoutube) {
      item.playPause(false);
    }
  }

  void _stopAll() {
    controlListener?.stop(index);
    controlListener?.stop(1000000 + index);
  }

  _setThumbnail(String url, Widget value) =>
      _thumbnailVideos.update(url, (newValue) => value, ifAbsent: () => value);

  _showImagesPage(BuildContext context, int index) {
    stopPlay();
    UtilUI.goToNextPage(context, SliderVideoPage(item, index: index, reloadPosts: reloadPosts));
  }

  _showLoginOrCreate(context) => callback?.showLoginOrCreate(context: context);

  _selectOption(BuildContext context) async {
    if (Constants().isLogin) {
      final prefs = await SharedPreferences.getInstance();
      final String permission = prefs.getString('manager_type')??'member';
      final List<ItemOption> options = [];
      final bool show = shopId == item.shop_id;
      final bool followed = item.user_followed;
      if (!show) options.add(ItemOption(followed == true ? 'assets/images/ic_delete_circle.png': 'assets/images/ic_add.png',
         followed == true ? ' Bỏ theo dõi bài viết' : MultiLanguage.get('lbl_follow_post'), () =>_followPost(context, item, followed), false));
      if (!show) options.add(ItemOption('assets/images/ic_warning.png', MultiLanguage.get('lbl_report_post'), () => _report(context), false));
      if (show || permission == 'admin') options.add(ItemOption('assets/images/ic_edit_post.png', MultiLanguage.get('lbl_edit_post'), () => _edit(context, permission), false));
      if (show || permission == 'admin') options.add(ItemOption('assets/images/ic_delete_circle.png', MultiLanguage.get('lbl_delete_post'), () => _delete(context, permission), false));
      if (options.isNotEmpty) {
        UtilUI.showOptionDialog2(context, MultiLanguage.get('ttl_option'), options);
        Util.trackActivities('post', path: 'Post -> Option Menu Button -> Open Option Dialog');
      }
    } else _showLoginOrCreate(context);
  }

  void _followPost(BuildContext context,Post item, bool statusFollow){
    Navigator.pop(context);
    if(statusFollow){
      subBloc.add(UnFollowPostEvent(item.classable_type, item.classable_id));
    }
    else{
      subBloc.add(FollowPostEvent(item.classable_type, item.classable_id));
    }
  }

  void _shareTo(BuildContext context) {
    //Navigator.of(context).pop();
    UtilUI.shareTo(context, '/p/${item.id}', 'Post -> Option Share Dialog -> Choose "Share"', 'post');
  }

  _report(BuildContext context) {
    Navigator.of(context).pop();
    UtilUI.showConfirmDialog(
            context, MultiLanguage.get('msg_input_reason'), '', '',
            title: MultiLanguage.get('lbl_report_post'),
            isCheckEmpty: false)
        .then((value) => _sendReport(value));
    Util.trackActivities('post', path: 'Post -> Option Dialog -> Choose "Report Bad Post" -> Open Report Post Dialog');
  }

  _sendReport(status) {
    if (status is String) {
      bloc.add(WarningPostHomeEvent(item.id, status, index));
      Util.trackActivities('post', path: 'Post -> Report Post Dialog -> OK Button -> Send "Report Bad Post" with content = $status');
    } else Util.trackActivities('post', path: 'Post -> Report Post Dialog -> Close Button');
  }

  _edit(BuildContext context, String permission) {
    Navigator.of(context).pop();
    UtilUI.goToNextPage(context, item.user_share_id.isEmpty ? PostPage(item.shop_name, item.shop_image, item: item, permission: permission)
            : SharePage(item, index, bloc, shopId, isCreate: false, permission: permission), funCallback: _editPageCallback);
    Util.trackActivities('post', path: 'Post -> Option Dialog -> Choose "Edit Post" -> Open "Edit Post" Screen');
  }

  _editPageCallback(value) {
    if (value != null && reloadPosts != null) reloadPosts!();
    if (value != null && value is BaseResponse && refreshPost != null) refreshPost!(value.data);
    if (hideComment) subBloc.add(LoadPostHomeEvent(item.id, 0));
  }

  _delete(BuildContext context, String permission) {
    Navigator.of(context).pop();
    UtilUI.showCustomDialog(context, MultiLanguage.get('msg_question_delete_post'), isActionCancel: true).then((value) {
      if(value != null && value) {
        bloc.add(DeletePostHomeEvent(item.id, index, permission));
        Util.trackActivities('post', path: 'Post -> Confirm Dialog -> OK Button -> Delete Post (id = ${item.id})');
      } else Util.trackActivities('post', path: 'Post -> Confirm Dialog -> Cancel Button');
    });
    Util.trackActivities('post', path: 'Post -> Option Dialog -> Choose "Delete Post" -> Open Confirm Dialog');
  }

  _like(BuildContext context) async {
    if (Constants().isLogin) {
      if (item.shop_id.isNotEmpty && !_lock) {
        if (await UtilUI().alertVerifyPhone(context)) return;
        _lock = true;
        subBloc.add(LikePostHomeEvent(item.classable_id, item.classable_type, index));
        Util.trackActivities('post', path: 'Post -> Like Button -> Like Post (id = ${item.id})');
      }
    } else _showLoginOrCreate(context);
  }

  _unlike(BuildContext context) async {
    if (Constants().isLogin) {
      if (!_lock) {
        if (await UtilUI().alertVerifyPhone(context)) return;
        _lock = true;
        subBloc.add(UnlikePostHomeEvent(item.classable_id, item.classable_type, index));
        Util.trackActivities('post', path: 'Post -> Like Button -> Unlike Post (id = ${item.id})');
      }
    } else _showLoginOrCreate(context);
  }

  _comment(BuildContext context) async {
    if (hideComment) return;
    if (Constants().isLogin) {
      UtilUI.goToNextPage(context, CommentPage(item, reloadItem: commentCallback, post: this, openKeyboard: true), funCallback: (value) => commentCallback(value));
      Util.trackActivities('post', path: 'Post -> Comment Button -> Open Comment Screen');
    } else _showLoginOrCreate(context);
  }

  commentCallback(value) => subBloc.add(LoadPostHomeEvent(item.id, 0));

  _share(BuildContext context) async {
    if (Constants().isLogin) {
      if (await UtilUI().alertVerifyPhone(context)) return;
      UtilUI.showOptionDialog(context, 'Chọn chia sẻ', [
        ItemModel(id: 'share_app', name: 'Chia sẻ qua ứng dụng khác'),
        ItemModel(id: 'share_post', name: 'Chia sẻ lên tường của tôi')
      ], '').then((value) {
        if (value != null) value.id == 'share_post' ? _shareSocial(context) : _shareTo(context);
      });
    } else _shareTo(context);
  }

  void _shareSocial(BuildContext context) {
    UtilUI.goToNextPage(context, SharePage(item, index, bloc, shopId));
    Util.trackActivities('post', path: 'Share Button -> Open Share Screen');
  }

  _goToShop(BuildContext context) {
    if (item.shop_id.isNotEmpty && allowGotoShop) {
      if (item.shop_id == shopId) {
        controlListener?.stop(index);
        UtilUI.goToNextPage(context, ShopPage(hasHeader: true));
        Util.trackActivities('post', path: 'Post -> Information User/Shop -> Open My Shop Screen');
      } else {
        if (_lock) return;
        _lock = true;
        stream = bloc.stream.listen((state) {
          if (state is LoadShopHomeState) {
            _handleLoadShop(state);
            _lock = false;
            stream?.cancel();
            stream = null;
          }
        });
        bloc.add(LoadShopHomeEvent(context, item.shop_id));
      }
    }
    Util.trackActivities('post', path: 'Post -> Information User/Shop');
  }

  _handleResponseLoadPost(LoadPostHomeState state) {
    if (state.response.data is Post) {
      item.copy(state.response.data);
      callback?.reloadPost(state.response.data);
    }
  }

  _handleLoadShop(LoadShopHomeState state) {
    if (state.response.data is String) return;
    ShopModel shop = state.response.data as ShopModel;
    if (shop.id > -1 && allowGotoShop) {
      controlListener?.stop(index);
      UtilUI.goToNextPage(state.context, ShopPage(shop: state.response.data,
            isOwner: false, hasHeader: true, isView: true));
      Util.trackActivities('post', path: 'Post -> Information User/Shop -> Open Shop Screen');
    }
  }

  _handleLoadSubPost(LoadSubPostHomeState state) {
    if (state.response.data is Post) {
      final list = state.response.data.images.list;
      if (list.isNotEmpty) {
        final url = Util.getRealPath(list[0].name);
        if (url.isEmpty || Util.isImage(url)) {
          _setThumbnail(
              url,
              FadeInImage.assetNetwork(
                  placeholder: 'assets/images/bg_splash.png',
                  image: url,
                  imageScale: 0.5,
                  fit: BoxFit.fill));
          _editorBloc.add(LoadSubVideoEditorEvent(url));
        } else {
          _setThumbnail(
              url,
              Container(
                  color: Colors.black12,
                  child: IconPlayDefault(size: playSize)));
          try {
            Thumbnail().loadThumbnail(url).then((listByte) {
              _setThumbnail(
                  url,
                  Container(
                      decoration: BoxDecoration(
                          color: Colors.black12,
                          image: DecorationImage(
                              image: Image
                                  .memory(listByte!)
                                  .image,
                              fit: BoxFit.fill)),
                      child: IconPlayDefault(size: playSize)));
              _editorBloc.add(LoadSubVideoEditorEvent(url));
            }).catchError((e){});
          } catch(_){}
        }
      }
    }
  }

  void _transferPoint(BuildContext context) {
    if (!Constants().isLogin) {
      _showLoginOrCreate(context);
      return;
    }
    if (item.shop_id.isNotEmpty && item.shop_id != shopId) {
      UtilUI.showConfirmDialog(context, '',
          MultiLanguage.get('lbl_input_point'), MultiLanguage.get('msg_input_point'),
          title: MultiLanguage.get('ttl_transfer_point'), showMsg: false, inputType: TextInputType.number)
          .then((value) async {
        if (value != null && value is String && value.isNotEmpty) {
          Util.trackActivities('post', path: 'Post -> "Give Point" Dialog -> OK Button');
          int point = 0;
          try {
            point = int.parse(value);
          }catch(_) {}
          final prefs = await SharedPreferences.getInstance();
          if (point > (prefs.getInt('points')??0)) {
            UtilUI.showCustomDialog(context, MultiLanguage.get('msg_enough_point'))
                .then((value) => _transferPoint(context));
            Util.trackActivities('post', path: 'Post -> Open Waring Dialog');
            return;
          }
          if (point > 0) {
            stream = bloc.stream.listen((state) {
              if (state is TransferPointState) {
                _lock = false;
                stream?.cancel();
                stream = null;
                if (state.response.checkTimeout()) {
                  UtilUI.showDialogTimeout(context);
                  return;
                }
                if (state.response.checkOK(passString: true))
                  UtilUI.showCustomDialog(context, MultiLanguage.get('msg_transfer'), title: MultiLanguage.get('ttl_alert'));
                else UtilUI.showCustomDialog(context, state.response.data).whenComplete(() => _transferPoint(context));
              }
            });
            bloc.add(TransferPointEvent(value, item.user_id));
            Util.trackActivities('post', path: 'Post -> Give Point Button -> Open "Give Point" Dialog');
          } else _transferPoint(context);
        }
      });
    }
  }
}
