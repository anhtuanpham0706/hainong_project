import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/features/function/support/handbook/handbook_bloc.dart';
import '../task_bloc.dart';
import 'package:hainong/common/ui/ui_farm.dart';
import 'task_detail_page.dart';

class TaskListPage extends BasePage {
  final int id;
  final String name, start, end;
  TaskListPage(this.id, this.name, this.start, this.end, {Key? key}) : super(pageState: _TaskListPageState(), key: key);
}

class _TaskListPageState extends BasePageState {
  final ScrollController _scroller = ScrollController();
  final List<TaskModel> _list = [];
  int _page = 1;

  @override
  void dispose() {
    _scroller.removeListener(_listenScroller);
    _scroller.dispose();
    _list.clear();
    super.dispose();
  }

  @override
  void initState() {
    bloc = TaskBloc((widget as TaskListPage).id);
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadListState && isResponseNotError(state.response)) {
        final list = state.response.data.list;
        if (list.isNotEmpty) {
          _list.addAll(list);
          list.length == 20 ? _page++ : _page = 0;
        } else _page = 0;
      }
    });
    _loadMore();
    _scroller.addListener(_listenScroller);
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
          onTapDown: (value) {clearFocus();},
          child: Stack(children: [
            createUI(),
            Loading(bloc)
          ])));

  @override
  Widget createUI() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: EdgeInsets.fromLTRB(40.sp, 40.sp, 40.sp, 0), child:
      UtilUI.createLabel('Tên kế hoạch: ' + (widget as TaskListPage).name,
        textAlign: TextAlign.left, fontSize: 42.sp, color: const Color(0xFF1AAD80), fontWeight: FontWeight.normal)),
    Padding(padding: EdgeInsets.all(40.sp), child: UtilUI.createLabel('Danh sách công việc thực hiện', textAlign: TextAlign.left,
        fontSize: 36.sp, fontWeight: FontWeight.w400, color: Colors.black)),
    const FarmManageTitle([
      ['Ngày thực hiện', 4],
      ['Tên công việc', 6]
    ]),
    Expanded(child: RefreshIndicator(child: BlocBuilder(bloc: bloc,
        buildWhen: (oldState, newState) => newState is LoadListState && _list.isNotEmpty,
        builder: (context, state) {
          return ListView.builder(padding: EdgeInsets.zero, controller: _scroller, itemCount: _list.length,
              itemBuilder: (context, index) => FarmManageItem([
                [Util.strDateToString(_list[index].working_date, pattern: 'dd/MM/yyyy'), 4],
                [_list[index].title, 6]
              ], index, action: _gotoDetail), physics: const AlwaysScrollableScrollPhysics());
        }), onRefresh: () async => _reset())),
    Container(padding: EdgeInsets.all(40.sp), child: ButtonImageWidget(16.sp, () => _gotoDetail(-1),
        Container(padding: EdgeInsets.all(40.sp), child: Row(children: [
          Icon(Icons.add_circle_outline_outlined, color: Colors.white, size: 60.sp),
          const SizedBox(width: 5),
          LabelCustom('Thêm công việc', color: Colors.white, size: 48.sp, weight: FontWeight.normal)
        ], mainAxisAlignment: MainAxisAlignment.center)), color: StyleCustom.primaryColor))
  ]);

  void _loadMore() => bloc!.add(LoadListEvent(_page, ''));

  void _listenScroller() {
    if (_page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) _loadMore();
  }

  void _reset() {
   setState(() => _list.clear());
    _page = 1;
    _loadMore();
  }

  void _gotoDetail(int index) {
    final page = widget as TaskListPage;
    UtilUI.goToNextPage(context, TaskDtlPage((bloc as TaskBloc).id, page.start, page.end, index < 0 ? TaskModel() : _list[index], _reset));
  }
}