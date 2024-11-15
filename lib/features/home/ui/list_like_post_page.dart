import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import '../bloc/home_bloc.dart';
import 'package:hainong/features/post/model/post.dart';
import 'package:hainong/features/post/ui/like_post_item_page.dart';

class ListLikePostPage extends BasePage {
  final bool isMain2;
  ListLikePostPage({this.isMain2 = false, Key? key}):super(key: key, pageState: _ListLikePostPageState());
}

class _ListLikePostPageState extends BasePageState implements LikePostItemPageCallback {
  int _page = 1;
  String _shopId = '';
  final ScrollController _scroller = ScrollController();
  final List<Post> _list = [];

  @override
  removeLikePost(int index) => _handleUnlike(index);

  @override
  void dispose() {
    _scroller.dispose();
    _list.clear();
    super.dispose();
  }

  @override
  initState() {
    bloc = HomeBloc(HomeState());
    SharedPreferences.getInstance()
        .then((value) => _shopId = value.getInt(constants.shopId).toString());
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadLikePostsHomeState)
        _handleResponse(state.response, state.response, _handleLoadList);
      else if (state is UnlikePostHomeState)
        _handleResponse(state.response, state.index, _handleUnlike, passString: true);
      else if (state is DeletePostHomeState)
        _handleResponse(state.response, state.index, _handleUnlike, passString: true);
    });
    bloc!.add(LoadLikePostsHomeEvent(_page));
    _scroller.addListener(() {
      if (_page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) bloc!.add(LoadLikePostsHomeEvent(_page));
    });
  }

  void _handleResponse(BaseResponse base, value, Function funHandleDetail, {bool passString = false}) {
    if (base.checkTimeout()) UtilUI.showDialogTimeout(context);
    else if (base.checkOK(passString: passString)) funHandleDetail(value);
  }

  void _handleLoadList(BaseResponse base) {
    final List<Post> listTemp = base.data.list;
    if (listTemp.isNotEmpty) _list.addAll(listTemp);
    listTemp.length == constants.limitPage ? _page++ : _page = 0;
  }

  void _handleUnlike(int index) {
    Util.trackActivities('list_post_like', path: 'List Posts Liked Screen -> Unlike Post of ${_list[index].shop_name}');
    _reloadList();
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    final child = RefreshIndicator(child: BlocBuilder(bloc: bloc,
        buildWhen: (state1, state2) =>
        state2 is LoadLikePostsHomeState || state2 is ReloadLikePostsHomeState,
        builder: (context, state) =>
            ListView.builder(padding: EdgeInsets.zero,
                shrinkWrap: true, physics: const AlwaysScrollableScrollPhysics(),
                controller: _scroller, itemCount: _list.length,
                itemBuilder: (context, index) => LikePostItemPage(
                    _list[index], index, bloc as HomeBloc, _shopId, this)
            )), onRefresh: () async => _reloadList());
    return (widget as ListLikePostPage).isMain2 ? Scaffold(
      appBar: AppBar(title: UtilUI.createLabel(MultiLanguage.get('ttl_liked_posts'), textAlign: TextAlign.center), centerTitle: true),
      body: child
    ) : child;
  }

  void _reloadList() {
    setState((){
      _list.clear();
    });
    _page = 1;
    bloc!.add(LoadLikePostsHomeEvent(_page));
    Util.trackActivities('list_post_like', path: 'List Posts Liked Screen -> Reload List Posts Liked');
  }
}
