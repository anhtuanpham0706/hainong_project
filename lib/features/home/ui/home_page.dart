import 'dart:async';
import 'package:hainong/common/ui/ads.dart';
import 'package:hainong/common/ui/catalogue_item.dart';
import 'package:hainong/common/ui/empty_search.dart';
import 'package:hainong/common/ui/loading.dart';
import 'import_ui_home.dart';

abstract class LoginOrCreateCallback {
  showLoginOrCreate();
}

class HomePage extends BasePage {
  final bool isMyPost, hasHighlight, isView, allowGotoShop, isShop, clearPage, hasPadding;
  final ChangeUICallback? callback;
  final LoginOrCreateCallback? loginCallback;
  final String hashTag, shopId;
  final Widget? header;

  HomePage({Key? key, this.isMyPost = false, this.hashTag = '', this.callback, this.hasHighlight = true, this.shopId = '',
    this.loginCallback, this.isView = false, this.header, this.allowGotoShop = true, this.isShop = false,
    this.clearPage = true, this.hasPadding = false}) : super(key: key, pageState: HomePageState()) { pageState.callback = callback; }
}

class HomePageState extends BasePageState implements ListHighlightPostCallback, PostDetailCallback, ControlVideoListener {
  int _page = 1, _indexCatalogues = -1;
  bool _isLoading = false, _changeUI = false, isLogin = false, _allScroll = false, _autoPlay = true, _checkPostAuto = false;
  String _key = '', _shopId = '';
  final List<Widget> _list = [];
  final ScrollController _scroller = ScrollController();
  final List<dynamic> _catalogues = [];
  final int maxTop = 2;

  @override
  void play(int index) {
    if (index - 1 > maxTop - 1 && _list[index - 1] is PostItemPage) (_list[index - 1] as PostItemPage).stopPlay();
    if (index + 1 < _list.length && _list[index + 1] is PostItemPage) (_list[index + 1] as PostItemPage).stopPlay();
  }

  @override
  void stop(int index) {
    if (index < 1000000 && _list[index] is PostItemPage) (_list[index] as PostItemPage).stopPlay();
    else play(index - 1000000);
  }

  @override
  void dispose() {
    _list.clear();
    _catalogues.clear();
    _scroller.removeListener(_listenScroll);
    _scroller.dispose();
    super.dispose();
  }

  @override
  reloadPost(Post post) {
    //reloadHighlightPost(post);
  }

  @override
  reloadPage() {
    //bloc!.add(ReloadHighlightPostsHomeEvent());
    setState(() {
      search(_key);
    });
  }

  @override
  reloadHighlightPost(Post post) {
    /*bloc!.add(ReloadHighlightPostsHomeEvent());
    for (int index = _list.length - 1; index > maxTop - 1; index--) {
      final temp = _list[index] as PostItemPage;
      if (temp.item.id == post.id) {
        temp.reloadPost(post.id, post.user_liked, post.total_like);
        return;
      }
    }*/
  }

  @override
  showLoginOrCreate({context}) {
    final callback = (widget as HomePage).loginCallback;
    if (callback != null) callback.showLoginOrCreate();
  }

  @override
  initState() {
    SharedPreferences.getInstance().then((value) {
      _shopId = value.getInt(constants.shopId).toString();
      _allScroll = (value.getInt(constants.hideToolbar)??1) == 1;
      _autoPlay = (value.getInt(constants.autoPlayVideo)??1) == 1;
    });
    bloc = HomeBloc(HomeState());
    final page = widget as HomePage;
    if(page.hasHighlight) {
      // _list.add(BlocBuilder(bloc: bloc,
      //     buildWhen: (oldState, newState) => newState is ReloadHighlightPostsHomeState,
      //     builder: (context, state) => ListHighlightPostPage(this)));
      _list.add(const Ads('post'));
      _list.add(SizedBox(height: 150.sp, child: BlocBuilder(bloc: bloc,
          buildWhen: (oldState, newState) => newState is LoadCataloguesHomeState ||
              newState is ChangeIndexHomeState,
          builder: (context, state) => ListView.builder(padding: EdgeInsets.all(20.sp),
            scrollDirection: Axis.horizontal, itemCount: _catalogues.length,
            itemBuilder: (context, index) => CatalogueItem(_catalogues[index],false,_changeIndexCatalogues,index)))));
      bloc!.add(LoadCataloguesHomeEvent());
    } else if (page.header != null) {
      for (int i = 0; i < maxTop - 1; i++) _list.add(const SizedBox());
      _list.add(page.header!);
    } else for (int i = 0; i < maxTop; i++) _list.add(const SizedBox());
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadPostsHomeState) _handleResponseLoadPosts(state);
      else if (state is CreatePostHomeState) {
        if (state.response.checkTimeout()) UtilUI.showDialogTimeout(context);
        else if (state.response.checkOK() &&
            state.response.msg == state.response.msgUpdatePost) Navigator.of(context).pop(state.response);
      } else if (state is DeletePostHomeState) _handleResponseDeletePost(state);
      else if (state is WarningPostHomeState) _handleResponseWarningPost(state);
      else if (state is SharePostHomeState) _handleResponseSharePost(state);
      else if (state is LikePostHomeState && isResponseNotError(state.response, passString: true)) bloc!.add(ReloadHighlightPostsHomeEvent());
      else if (state is UnlikePostHomeState && isResponseNotError(state.response, passString: true)) bloc!.add(ReloadHighlightPostsHomeEvent());
      else if (state is LoadCataloguesHomeState) _catalogues.addAll(state.response);
      else if (state is CheckProcessPostAutoState) _checkPostAuto = state.isActive ?? false;
      else if (state is FollowPostState && isResponseNotError(state.response, passString: true)) UtilUI.showCustomDialog(context, 'Đã theo dõi bài viết',title: 'Thông báo');
      else if (state is UnFollowPostState && isResponseNotError(state.response, passString: true)) UtilUI.showCustomDialog(context, 'Đã huỷ theo dõi bài viết',title: 'Thông báo');;
    });
    bloc!.add(CheckProcessPostAutoEvent());
    search('');
    _scroller.addListener(_listenScroll);
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) =>
    GestureDetector(onTapDown: (value) => clearFocus(),
      child: Stack(children: [
        /*BlocBuilder(buildWhen: (oldState, newState) => newState is BaseState,
          bloc: bloc, builder: (context, state) => _list.length > maxTop || _key.isEmpty || (state as BaseState).isShowLoading ? const SizedBox() :
            Container(height: 0.8.sh, child: EmptySearch(_key), alignment: Alignment.center)),*/
        NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            final page = widget as HomePage;
            if (callback != null && (!page.hasHighlight || _allScroll)) {
              if (_scroller.position.userScrollDirection ==
                ScrollDirection.forward && _changeUI) {
                if (!page.isShop || _scroller.position.pixels == 0.0) _setCollapse(false);
              } else if (_scroller.position.userScrollDirection ==
                ScrollDirection.reverse && !_changeUI) _setCollapse(true);
            }

            //if (scrollNotification is ScrollStartNotification) _startScroll();
            if (scrollNotification is ScrollEndNotification) _stopScroll();

            return true;
          },
          child: RefreshIndicator(child: BlocBuilder(bloc: bloc,
            buildWhen: (oldState, newState) => newState is LoadPostsHomeState,
            builder: (context, state) => ListView.builder(
              //dragStartBehavior: DragStartBehavior.down,
              addRepaintBoundaries: false,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              controller: _scroller, itemCount: _list.length,
              itemBuilder: (context, index) => index < _list.length ? _list[index] : const SizedBox())
          ), onRefresh: () async => setState(() => search(_key)))),
        Loading(bloc)
    ]));

  _setCollapse(bool value) {
    _changeUI = value;
    callback?.collapseHeader(value);
    callback?.collapseFooter(value);
  }

  @override
  search(String key) {
    _initSearch(key);
    _loadPosts(showLoading: true);
  }

  _initSearch(String keyword) {
    _key = keyword;
    _page = 1;
    _isLoading = false;
    if (_list.length > maxTop) _list.removeRange(maxTop, _list.length);
  }

  _loadPosts({bool showLoading = false}) {
    _isLoading = true;
    HomePage page = widget as HomePage;
    bloc!.add(LoadPostsHomeEvent(_key, _page,
        isMyPost: page.isMyPost,
        hashTag: page.hashTag,
        shopId: page.isView ? page.shopId : '', showLoading: showLoading));
  }

  _stopScroll() {
    for(int i = _list.length - 1; i > maxTop - 1; i--) {
      if (_list[i] is PostItemPage) (_list[i] as PostItemPage).stopScroll();
    }
  }

  _handleResponseLoadPosts(LoadPostsHomeState state) {
    if (isResponseNotError(state.response)) {
      final List<Post> listTemp = state.response.data.list;
      if (listTemp.isNotEmpty) {
        final page = widget as HomePage;
        for (int index = 0; index < listTemp.length; index++) {
          _list.add(PostItemPage(listTemp[index], _list.length, bloc as HomeBloc, _shopId,
              callback: this, allowGotoShop: page.allowGotoShop,
              isOwner: page.isMyPost && !page.isView,
              reloadPosts: () => setState((){
                search(_key);
              }), clearPage: page.clearPage,
              controlListener: this, isShop: page.isShop, autoPlay: _autoPlay));
        }
        Timer(const Duration(seconds: 2), () {
          if (_list.length > maxTop && (_list[maxTop] is PostItemPage)) (_list[maxTop] as PostItemPage).stopScroll();
        });
      }
      listTemp.length == constants.limitPage ? _page++ : _page = 0;
    }
    if (_list.length == maxTop && !(widget as HomePage).isShop) _list.add(SizedBox(height: 0.4.sh, child: EmptySearch(_key)));
    _isLoading = false;
  }

  _handleResponseDeletePost(DeletePostHomeState state) {
    if (isResponseNotError(state.response, passString: true)) {
      setState((){
        search(_key);
      });
      if ((widget as HomePage).hasHighlight) bloc!.add(ReloadHighlightPostsHomeEvent());
    }
  }

  _handleResponseWarningPost(WarningPostHomeState state) {
    if (isResponseNotError(state.response)) {
      final LanguageKey languageKey = LanguageKey();
      UtilUI.showCustomDialog(
          context, MultiLanguage.get(languageKey.msgWarningPostSuccess),
          title: MultiLanguage.get(languageKey.ttlAlert));
    }
  }

  _handleResponseSharePost(SharePostHomeState state) {
    if (isResponseNotError(state.response, passString: true)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(MultiLanguage.get('msg_'+(_checkPostAuto?'':'in')+'active_process_post_auto'))));
      UtilUI.goBack(context, true);
      setState(() {
        search(_key);
      });
    }
  }

  void _changeIndexCatalogues(int index) {
    if (_indexCatalogues != index) {
      _indexCatalogues = index;
      bloc!.add(ChangeIndexHomeEvent(index));
    }
  }

  void _listenScroll() {
    if (_scroller.position.maxScrollExtent - 0.25.sh < _scroller.position.pixels && _page > 0 && !_isLoading) _loadPosts();
  }
}
