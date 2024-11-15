import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hainong/common/style_custom.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'gift_history_item_page.dart';
import '../bloc/gift_bloc.dart';
import '../gift_history_model.dart';

class GiftHistoryPage extends StatefulWidget {
  const GiftHistoryPage({Key? key}) : super(key: key);

  @override
  State<GiftHistoryPage> createState() => _GiftHistoryPageState();
}

class _GiftHistoryPageState extends State<GiftHistoryPage> {
  final GiftBloc bloc = GiftBloc();
  List<GiftHistoryModel> _list = [];
  final ScrollController _scroller = ScrollController();
  int _page = 1;

  @override
  void initState() {
    super.initState();
    bloc.stream.listen((state) {
      if(state is LoadHistoryGiftState){
        _handleLoadList(state.response.data);
      }
    });
    _loadMore();
    _scroller.addListener(_listenerScroll);
  }

  @override
  void dispose() {
    _list.clear();
    _scroller.removeListener(_listenerScroll);
    _scroller.dispose();
    super.dispose();
  }
  void _listenerScroll() {
    if (_page > 0 && _scroller.position.pixels == _scroller.position.maxScrollExtent) _loadMore();
  }
  void _loadMore() {
    if (_page > 0) bloc.add(LoadHistoryGiftEvent(_page));
  }

  void _handleLoadList(GiftHistoryModels data) {
    if (data.list.isNotEmpty) {
      _list.addAll(data.list);
      data.list.length == 15 ? _page++ : _page = 0;
    } else _page = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: StyleCustom.primaryColor,
        title: Text("Lịch sử đổi quà",style: TextStyle(fontSize: 50.sp,color: Colors.white),),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder(bloc: bloc,
                buildWhen: (oldState, newState) => newState is LoadHistoryGiftState,
                builder: (context, state) =>  AlignedGridView.count(
                    padding: EdgeInsets.only(left: 16.sp, right: 16.sp, top: 0.sp), controller: _scroller,
                    crossAxisCount: 1, mainAxisSpacing: 8.sp, crossAxisSpacing: 8.sp, itemCount: _list.length,
                    itemBuilder: (BuildContext context, int index) => _list.isEmpty ? const SizedBox() :
                    GiftHistoryItem(_list[index])
                )),
          )
        ],
      ),
    );
  }
}
