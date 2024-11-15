import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/ui_farm.dart';
import '../mission_bloc.dart';
import 'mission_sub_detail_page.dart';
import 'mission_ui.dart';

class MissionDetailPage extends BasePage {
  dynamic item;
  final Function? reload;
  MissionDetailPage(this.item, {this.reload, Key? key}) : super(pageState: _MissionDetailPageState(), key: key);
}

class _MissionDetailPageState extends BasePageState {
  final ScrollController _scroller = ScrollController();
  final List _list = [true];
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
    bloc = MissionBloc('detail');
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadMissionsState && isResponseNotError(state.resp)) {
        final list = state.resp.data;
        if (list.isEmpty) _page = 0;
        else {
          _list.addAll(list);
          list.length == 20 ? _page++ : _page = 0;
        }
      }
    });
    _loadDetails();
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    dynamic item = (widget as MissionDetailPage).item;
    return Stack(children: [
      Scaffold(backgroundColor: color, appBar: AppBar(elevation: 0, titleSpacing: 0, centerTitle: true,
          toolbarHeight: 200.sp, title: UtilUI.createLabel('Thông tin nhiệm vụ ' + (item['title']??''), line: 2)),
        body: RefreshIndicator(child: BlocBuilder(bloc: bloc,
            buildWhen: (oldS, newS) => newS is LoadMissionsState, builder: (context, state) =>
                ListView.builder(padding: EdgeInsets.zero, itemCount: _list.length + 1, controller: _scroller,
                    itemBuilder: (context, index) {
                      if (index > 0) {
                        if (index == _list.length) {
                          double joined = (item['total_joined']??.0).toDouble(),
                              total = (item['number_joins']??.0).toDouble(),
                              points = (item['total_points']??.0).toDouble();
                          return FarmManageTitle([const ['Tổng', 6],
                            [Util.doubleToString(joined) + '/' + Util.doubleToString(total), 2, TextAlign.center],
                            [Util.doubleToString(points), 2, TextAlign.center]], hasBg: false);
                        }
                        return _item(index);
                      }
                      return _header(item);
                    }, physics: const AlwaysScrollableScrollPhysics())), onRefresh: () async => _reset(0))),
      Loading(bloc)
    ]);
  }

  Widget _item(int index) {
    double joined = (_list[index]['total_joined']??.0).toDouble(),
        total = (_list[index]['number_joins']??.0).toDouble();
    String startDate = _list[index]['start_date']??'',
        endDate = _list[index]['end_date']??'', date = '';
    if (startDate.isNotEmpty) {
      startDate = Util.strDateToString(startDate, pattern: 'dd/MM/yyyy');
      date = startDate;
    }
    if (endDate.isNotEmpty) {
      endDate = Util.strDateToString(endDate, pattern: 'dd/MM/yyyy');
      date += (date.isEmpty ? '' : '\n') + endDate;
    }
    return FarmManageItem([
      [_list[index]['title']??'', 3],
      [date, 3, TextAlign.center],
      [Util.doubleToString(joined) + '/' + Util.doubleToString(total), 2, TextAlign.center],
      [Util.doubleToString((_list[index]['point']??.0).toDouble()), 2, TextAlign.center]
    ], index, action: _gotoDetail, colorRow: (index % 2 != 0) ? Colors.transparent : const Color(0xFFF8F8F8));
  }

  Widget _header(item) => Column(children: [
    MissionLine('Tên NV', item['title']??'', padding: EdgeInsets.fromLTRB(40.sp, 40.sp, 40.sp, 0)),
    MissionLine('Danh mục NV', item['mission_catalogue_name']??''),
    MissionLine('Bắt đầu', Util.strDateToString(item['start_date']??'', pattern: 'dd/MM/yyyy'), padding: EdgeInsets.symmetric(horizontal: 40.sp)),
    MissionLine('Kết thúc', Util.strDateToString(item['end_date']??'', pattern: 'dd/MM/yyyy')),
    MissionLine('Mô tả NV', '', padding: EdgeInsets.symmetric(horizontal: 40.sp), flex: 10),
    (item['content']??'').isEmpty ? SizedBox(height: 40.sp) : Padding(padding: EdgeInsets.fromLTRB(40.sp, 20.sp, 40.sp, 40.sp), child:
      LabelCustom(item['content']??'', color: const Color(0xFF1AAD80), size: 42.sp, weight: FontWeight.normal)),
    MissionLine('Tỉnh/TP', item['province_name']??'', padding: EdgeInsets.symmetric(horizontal: 40.sp)),
    MissionLine('Quận/Huyện', item['district_name']??''),
    MissionLine('ĐC canh tác', item['address']??'', padding: EdgeInsets.symmetric(horizontal: 40.sp)),
    Divider(height: 100.sp, thickness: 20.sp, color: const Color(0xFFF4F4F4)),
    Padding(padding: EdgeInsets.fromLTRB(40.sp, 0, 40.sp, 40.sp),
        child: LabelCustom('Danh sách nhiệm vụ con', size: 46.sp, color: Colors.black, weight: FontWeight.normal)),
    const FarmManageTitle([['Tên nhiệm vụ', 3], ['Thời gian\nthực hiện', 3, TextAlign.center], ['Số người', 2, TextAlign.center], ['Số điểm', 2, TextAlign.center]]),
  ], crossAxisAlignment: CrossAxisAlignment.start);

  void _listenScroller() {
    if (_page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) _loadDetails();
  }

  void _loadDetails() => bloc!.add(LoadMissionsEvent(_page, '', ((widget as MissionDetailPage).item['id']??-1).toString(), false));

  void _gotoDetail(int index) => UtilUI.goToNextPage(context, MissionSubDetailPage((widget as MissionDetailPage).item, _list[index], reload: _reset));

  void _reset(int count) {
    final page = widget as MissionDetailPage;

    _page = 1;
    _list.removeRange(1, _list.length);
    if (count != 0) setState(() => page.item['total_joined'] += count);

    _loadDetails();
    if (count != 0 && page.reload != null) page.reload!();
  }
}