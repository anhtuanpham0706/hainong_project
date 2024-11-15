import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/features/post/ui/highlight_post_item_page.dart';
import '../bloc/home_bloc.dart';
import 'package:hainong/features/post/model/post.dart';

abstract class ListHighlightPostCallback {
  reloadPage();
  reloadHighlightPost(Post post);
}

class ListHighlightPostPage extends StatefulWidget {
  final ListHighlightPostCallback callback;
  const ListHighlightPostPage(this.callback, {Key? key}):super(key:key);
  @override
  _ListHighlightPostPageState createState() => _ListHighlightPostPageState();
}

class _ListHighlightPostPageState extends State<ListHighlightPostPage> {
  int _page = 1;
  String _shopId = '';
  final ScrollController _scroller = ScrollController();
  final List<Post> _list = [];
  final HomeBloc _bloc = HomeBloc(HomeState());

  @override
  void dispose() {
    _list.clear();
    _bloc.close();
    _scroller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _bloc.stream.listen((state) {
      if (state is LoadHighlightPostsHomeState) {
        if (state.response.checkOK()) {
          final List<Post> listTemp = state.response.data.list;
          if (listTemp.isNotEmpty) _list.addAll(listTemp);
          listTemp.length == 5 ? _page++ : _page = 0;
        }
      } else if (state is SharePostHomeState || state is DeletePostHomeState) widget.callback.reloadPage();
    });

    SharedPreferences.getInstance().then((value) {
      final Constants constants = Constants();
      _shopId = value.getInt(constants.shopId).toString();
      _bloc.add(LoadHighlightPostsHomeEvent(_page));
    });

    _scroller.addListener(() {
      if (_page > 0 && _page < 3 && _scroller.position.maxScrollExtent == _scroller.position.pixels) _bloc.add(LoadHighlightPostsHomeEvent(_page));
    });
  }

  @override
  Widget build(BuildContext context) => Container(height: 0.25.sh, padding: EdgeInsets.only(top: 20.sp, bottom: 20.sp),
      child: BlocBuilder(bloc: _bloc, buildWhen: (state1, state2) => state2 is LoadHighlightPostsHomeState,
          builder: (context, state) => ListView.builder(scrollDirection: Axis.horizontal, controller: _scroller, itemCount: _list.length,
              itemBuilder: (context, index) => HighlightPostItemPage(_list[index], index, _bloc, _shopId, widget.callback))));
}
