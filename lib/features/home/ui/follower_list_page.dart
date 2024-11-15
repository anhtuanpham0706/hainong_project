import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/tab_item.dart';
import 'package:hainong/features/home/ui/import_ui_home.dart';
import 'package:hainong/features/post/bloc/post_list_bloc.dart';
import 'package:hainong/features/post/ui/follower_item_page.dart';
import 'package:hainong/features/post/ui/like_post_item_page.dart';
import 'package:hainong/features/shop/shop_model.dart';

class FollowerListPage extends BasePage {
  final bool isMain2;
  final int follower, following, followPost;
  FollowerListPage(this.follower, this.following,this.followPost, {this.isMain2 = false, Key? key}):super(key: key, pageState: _FollowerListPageState());
}

class _FollowerListPageState extends BasePageState implements LikePostItemPageCallback{
  int _page = 1, _index = 0, _follower = 0, _following = 0, _followPost = 0;
  final List<dynamic> _list = [];
  final subBloc = HomeBloc(HomeState());
  final ScrollController _scroller = ScrollController();

  @override
  void dispose() {
    _list.clear();
    _scroller.dispose();
    super.dispose();
  }

  @override
  initState() {
    final page = widget as FollowerListPage;
    _follower = page.follower;
    _following = page.following;
    _followPost = page.followPost;
    bloc = PostListBloc(PostListState());

    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadFollowersPostListState) _handleResponseLoadFollowers(state);
      else if(state is UnfollowPostState && isResponseNotError(state.baseResponse,passString: true)) {
        _list.clear();
        _page = 1;
        bloc!.add(LoadFollowersPostListEvent(_page, _index));
      }
    });
    _loadMore();
    _scroller.addListener(() {
      if (_page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) _loadMore();
    });
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    final child = Stack(children: [
      Column(children: [
        Container(color: Colors.white, child: BlocBuilder(bloc: bloc,
                buildWhen: (state1, state2) => state2 is ChangeTabState || state2 is ReloadTotalState || state2 is UnfollowPostState,
                builder: (context, state) {
                  if (state is ReloadTotalState ) {
                    _follower = state.total.total_followers;
                    _following = state.total.total_followings;
                    _followPost = state.total.total_follow_posts;
                  }
                  return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    TabItem(MultiLanguage.get('lbl_follower') + (_follower > 0 ? ' ($_follower)':' (0)'), 0, _index == 0, _changeTab, parseTitle: false, line: 2,),
                    TabItem(MultiLanguage.get('lbl_following') + (_following > 0 ? ' ($_following)':' (0)'), 1, _index == 1, _changeTab, parseTitle: false, line: 2,),
                    TabItem('Bài viết theo dõi' + (_followPost > 0 ? ' ($_followPost)':' (0)'), 2, _index == 2, _changeTab, parseTitle: false, line: 2)
                  ]);
                })),
        Expanded(child: RefreshIndicator(onRefresh: _reload, child: BlocBuilder(bloc: bloc,
                    buildWhen: (state1, state2) => state2 is ChangeTabState || state2 is LoadFollowersPostListState,
                    builder: (context, state) => _list.isNotEmpty ?
                    ListView.builder(padding: EdgeInsets.zero, controller: _scroller,
                        itemCount: _list.length < Constants().limitPage?Constants().limitPage:_list.length,
                        itemBuilder: (context, index) {
                          if (index < _list.length) {
                            if(_index == 2 ) {
                              return  LikePostItemPage(_list[index] as Post, index, subBloc, '', this, funCallBackRemoveItem: _removeItem, key: UniqueKey(),);
                            } else {
                              return FollowerItemPage(index, _list[index], _index, index < _list.length - 1);
                            }
                          }
                          return SizedBox(height: 250.sp, width: 1.sw);
                        }) : SizedBox(height: 1.sh, child: ListView(children: const [])
                    )
                )))
      ]),
      Loading(bloc)
    ]);
    return (widget as FollowerListPage).isMain2 ? Scaffold(
        appBar: AppBar(title: UtilUI.createLabel('Theo dõi', textAlign: TextAlign.center), centerTitle: true),
        body: child) : child;
  }

  void _loadMore() => bloc!.add(LoadFollowersPostListEvent(_page, _index));

  _handleResponseLoadFollowers(LoadFollowersPostListState state) {
    if (isResponseNotError(state.response)) {
      final List<dynamic> listTemp = state.response.data.list;
      if (listTemp.isNotEmpty) {
        _index == 2 ? _list.addAll(listTemp as List<Post>) : _list.addAll(listTemp as List<ShopModel>);
        listTemp.length == constants.limitPage ? _page++ : _page = 0;
      } else _page = 0;
    }
  }

  void _changeTab(int index) {
    if (_index != index) {
      _index = index;
      bloc!.add(ChangeTabEvent(index));
      _reload();
    }
    Util.trackActivities('list_post_follow', path: 'Follower List Screen -> Show ${index == 0 ? 'List Follower':'List Following'}');
  }

  Future<void> _reload() async {
    _list.clear();
    _page = 1;
    _loadMore();
  }

  _removeItem(int index) {
    if(_index ==2 ) {
      final item = _list[index] as Post;
      bloc!.add(UnfollowPostEvent(item.classable_type, item.classable_id));
    }
  }

  @override
  removeLikePost(int index) {}
}
