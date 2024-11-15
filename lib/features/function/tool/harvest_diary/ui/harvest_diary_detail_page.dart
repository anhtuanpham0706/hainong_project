import 'package:flutter/services.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/show_popup_html.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import 'package:hainong/common/ui/title_helper.dart';
import 'package:hainong/features/function/tool/farm_management/farm_management_bloc.dart';
import 'package:hainong/features/function/tool/farm_management/ui/farm_management_list_page.dart';
import 'package:hainong/features/function/tool/farm_management/ui/task_detail_page.dart';
import 'package:hainong/features/function/tool/plots_management/ui/plots_management_list_page.dart';
import 'package:hainong/features/home/ui/import_ui_home.dart';
import '../harvest_diary_bloc.dart';
import '../harvest_task_bloc.dart';
import 'harvest_task_detail_page.dart';

class HarvestDiaryDtlPage extends BasePage {
  final HarvestDiaryModel detail;
  final Function funReload;
  final bool lock;
  HarvestDiaryDtlPage(this.detail, this.funReload, {this.lock = false, Key? key}) : super(pageState: _HarvestDiaryDtlPageState(), key: key);
}

class _HarvestDiaryDtlPageState extends BasePageState {
  final TextEditingController _ctrName = TextEditingController(), _ctrPlot = TextEditingController(),
      _ctrTypeTree = TextEditingController(), _ctrQty = TextEditingController(), _ctrPlan = TextEditingController(),
      _ctrUnit = TextEditingController(), _ctrOtherUnit = TextEditingController(), _ctrTotal = TextEditingController();
  final FocusNode _fcTotal = FocusNode(), _fcName = FocusNode(), _fcPlot = FocusNode(), _fcTypeTree = FocusNode(),
      _fcQty = FocusNode(), _fcUnit = FocusNode(), _fcOtherUnit = FocusNode(), _fcPlan = FocusNode();
  final ItemModel _unit = ItemModel(id: 'other', name: 'Khác'), _plots = ItemModel();
  final FarmManageModel _plan = FarmManageModel();
  bool _isFinish = false, _lock = false;

  HarvestTaskBloc? _taskBloc;
  final ScrollController _scroller = ScrollController();
  final List _list = [true];
  final Map<String, String> _works = {
    'making_land': 'Làm đất',
    'pruning': 'Cắt tỉa',
    'sowing_seeds': 'Gieo hạt',
    'fertilize': 'Bón phân',
    'spray': 'Tưới cây',
    'harvest': 'Thu hoạch',
    'other': 'Khác'
  };
  int _pageHarvest = 1, _pagePlan = 1;

  @override
  void dispose() {
    _scroller.removeListener(_listenScroller);
    _scroller.dispose();
    _list.clear();
    _works.clear();
    _ctrName.dispose();
    _fcName.dispose();
    _ctrPlot.dispose();
    _fcPlot.dispose();
    _ctrTypeTree.dispose();
    _fcTypeTree.dispose();
    _ctrQty.dispose();
    _fcQty.dispose();
    _ctrUnit.dispose();
    _fcUnit.dispose();
    _ctrOtherUnit.dispose();
    _fcOtherUnit.dispose();
    _ctrTotal.dispose();
    _fcTotal.dispose();
    _ctrPlan.dispose();
    _fcPlan.dispose();
    super.dispose();
  }

  @override
  void initState() {
    final detail = (widget as HarvestDiaryDtlPage).detail;
    _isFinish = detail.working_status != 'working';
    bloc = HarvestDiaryBloc(typeInfo: 'harvest_diary');
    super.initState();
    bloc!.stream.listen((state) {
      if (state is CreatePlanState && isResponseNotError(state.resp)) {
        final page = widget as HarvestDiaryDtlPage;
        page.funReload();
        if (page.detail.id < 0) {
          page.detail.id = state.resp.data.id;
          page.detail.title = state.resp.data.title;
          page.detail.process_engineering_id = state.resp.data.process_engineering_id;
          _pagePlan = 1;
          _scroller.animateTo(_scroller.position.maxScrollExtent, duration: const Duration(milliseconds: 2000), curve: Curves.ease);
          _taskBloc!.id = page.detail.id;
          UtilUI.showCustomDialog(context, 'Lưu thành công. Hãy tiếp tục thực hiện công việc', title: 'Thông báo').whenComplete(() => _reset());
        } else UtilUI.showCustomDialog(context, 'Lưu thành công', title: 'Thông báo').whenComplete(() => UtilUI.goBack(context, state.resp.data));
      } else if (state is DeletePlanState && isResponseNotError(state.resp, passString: true)) {
        (widget as HarvestDiaryDtlPage).funReload();
        UtilUI.goBack(context, true);
      } else if (state is LoadFarmDtlState) {
        _plan.start_date = state.resp.data.start_date;
        _plan.end_date = state.resp.data.end_date;
      }
    });
    _initData();

    _taskBloc = HarvestTaskBloc(detail.id);
    if (detail.process_engineering_id < 0) _pagePlan = 0;
    _taskBloc!.stream.listen((state) {
      if (state is LoadTaskDtlState) {
        _pageHarvest = state.pageHarvest;
        _pagePlan = state.pagePlan;
        _list.addAll(state.resp.data);
        _lock = false;
      } else if (state is FinishHarvestState && isResponseNotError(state.resp, passString: true)) {
        (widget as HarvestDiaryDtlPage).detail.working_status = 'completed';
        setState(() {
          _isFinish = true;
        });
      } /*else if (state is DownloadFilesPostItemState && state.response.isNotEmpty) {
        bloc!.add(SaveFileEvent(state.response[0]));
      } else if (state is SaveFileState) {
        UtilUI.showCustomDialog(context, state.value ? 'Lưu ảnh thành công' : 'Lưu ảnh thất bại', title: state.value ? 'Thông báo' : 'Cảnh báo');
      }*/
    });
    if (_taskBloc!.id > 0) _loadMore();
    _scroller.addListener(_listenScroller);
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Scaffold(
      appBar: AppBar(elevation: 10, titleSpacing: 0, title: const TitleHelper('Chi tiết nhật ký canh tác', url: 'https://help.hainong.vn/muc/5/huong-dan/6'),
          centerTitle: true, actions: [
            IconButton(onPressed: clearFocus, icon: Icon(Icons.keyboard, color: Colors.white, size: 48.sp))
          ]),
      backgroundColor: Colors.white, body: Stack(children: [
          createUI(),
          Loading(bloc),
          Loading(_taskBloc)
        ]));

  @override
  Widget createUI() {
    final color = const Color(0XFFF5F6F8);
    final require = LabelCustom(' (*)', color: Colors.red, size: 36.sp, weight: FontWeight.normal);
    final bool hasDetail = (widget as HarvestDiaryDtlPage).detail.id > 0;
    return Column(children: [
      Expanded(child: RefreshIndicator(child: BlocBuilder(bloc: _taskBloc,
          buildWhen: (oldState, newState) => newState is LoadTaskDtlState,
          builder: (context, state) {
            return ListView.separated(
                padding: EdgeInsets.only(bottom: 40.sp), controller: _scroller,
                itemCount: _list.length, physics: const AlwaysScrollableScrollPhysics(),
                separatorBuilder: (context, index) => SizedBox(height: index > 0 ? 10.sp : 0),
                itemBuilder: (context, index) {
                  if (index > 0) {
                    try {
                      return Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp),
                          child: IntrinsicHeight(child: Row(children: [
                            _itemTitle(index, _list[index][1].working_date, _list[index][1].jobs, _list[index][1].images, false),
                            SizedBox(width: 5.sp),
                            _itemTitle(index, _list[index][0].working_date, _list[index][0].jobs, _list[index][0].images, true)
                          ], mainAxisAlignment: MainAxisAlignment.start)));
                    } catch (e) {
                      return const SizedBox();
                    }
                  }
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(padding: EdgeInsets.all(40.sp), child: Column(children: [
                      UtilUI.createLabel('Thông tin chung', fontSize: 52.sp, color: const Color(0xFF1AAD80)),
                      SizedBox(height: 40.sp),
                      Row(children: [_title('Tên mùa vụ'), require,ShowInfo(bloc, "title")]),
                      Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp), child: TextFieldCustom(_ctrName,
                          _fcName, _fcPlot, 'Nhập tên mùa vụ', size: 42.sp, color: color, readOnly: _isFinish,
                          borderColor: color, maxLine: 0, inputAction: TextInputAction.newline,
                          type: TextInputType.multiline, padding: EdgeInsets.all(30.sp))),

                      /*Row(children: [_title('Lô thửa'), require]),
        Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
          child: TextFieldCustom(_ctrPlot, _fcPlot, _fcTypeTree, 'Chọn lô thửa',
            size: 42.sp, color: color, borderColor: color, readOnly: true,
            onPressIcon: _selectPlots, maxLine: 0, inputAction: TextInputAction.newline,
            type: TextInputType.multiline, padding: EdgeInsets.all(30.sp),
            suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp))),*/

                      Row(children: [_title('Tên vùng canh tác'),ShowInfo(bloc, "harvest_area")],),
                      Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
                          child: TextFieldCustom(_ctrTypeTree, _fcTypeTree, _fcPlan, 'Nhập tên vùng canh tác',
                              size: 42.sp, color: color, borderColor: color, maxLine: 0, readOnly: _isFinish,
                              inputAction: TextInputAction.newline, type: TextInputType.multiline,
                              padding: EdgeInsets.all(30.sp))),

                      _title('Kế hoạch canh tác'),
                      Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
                          child: TextFieldCustom(_ctrPlan, _fcPlan, _fcQty, 'Chọn kế hoạch canh tác',
                              size: 42.sp, color: color, borderColor: color, readOnly: true,
                              onPressIcon: _selectPlan, maxLine: 0, inputAction: TextInputAction.newline,
                              type: TextInputType.multiline, padding: EdgeInsets.all(30.sp),
                              suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp))),

                      Padding(padding: EdgeInsets.symmetric(vertical: 40.sp), child: IntrinsicHeight(child: Row(children: [
                        Expanded(child: Column(children: [
                          _title('Sản lượng thực tế (Nhập sau khi thu hoạch)'),
                          SizedBox(height: 16.sp),
                          TextFieldCustom(_ctrQty, _fcQty, _fcUnit, 'Nhập', size: 42.sp, color: color, readOnly: _isFinish,
                              type: TextInputType.number, isOdd: false,
                              borderColor: color, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))])
                        ], crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end)),
                        const SizedBox(width: 10),
                        Expanded(child: Column(children: [
                          Row(children: [_title('Đơn vị tính'),ShowInfo(bloc, "unit")],
                          ),
                          SizedBox(height: 16.sp),
                          TextFieldCustom(_ctrUnit, _fcUnit, _fcTotal, '', size: 42.sp,
                              color: color, borderColor: color, readOnly: true,
                              onPressIcon: _selectUnit, suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp))
                        ], crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end))
                      ]))),

                      BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is ChangeUnitState,
                          builder: (context, state) => _unit.id == 'other' ? Column(children: [
                            Row(children: [_title('Đơn vị tính khác'),ShowInfo(bloc, "other_unit")],
                            ),
                            Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp), child: TextFieldCustom(_ctrOtherUnit, _fcOtherUnit, _fcTotal,
                                'Nhập đơn vị tính khác', size: 42.sp, color: color, borderColor: color, readOnly: _isFinish))
                          ], crossAxisAlignment: CrossAxisAlignment.start) : const SizedBox()),

                      Row(children: [_title('Doanh thu thực tế (VNĐ)'),ShowInfo(bloc, "revenue")],),
                      Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp), child: TextFieldCustom(_ctrTotal, _fcTotal, null,
                          'Nhập doanh thu thực tế', size: 42.sp, color: color, borderColor: color, readOnly: _isFinish,
                          type: TextInputType.number, isOdd: false,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))]))
                    ], crossAxisAlignment: CrossAxisAlignment.start)),
                    Divider(height: 32.sp, thickness: 32.sp, color: const Color(0xFFF4F4F4)),
                    Row(children: [
                      Padding(padding: EdgeInsets.all(40.sp), child: UtilUI.createLabel('Danh sách công việc thực hiện',
                          fontSize: 52.sp, color: const Color(0xFF1AAD80))),
                      if (!_isFinish && _taskBloc!.id > 0) ButtonImageWidget(100, () => _gotoDetail(-1, true), Icon(Icons.add_circle, color: const Color(0xFF1AAD80), size: 86.sp))
                    ]),
                    Container(child: Row(children: const [
                      Expanded(child: LabelCustom('Kế hoạch', align: TextAlign.center, weight: FontWeight.normal)),
                      Expanded(child: LabelCustom('Thực tế', align: TextAlign.center, weight: FontWeight.normal)),
                    ]), color: const Color(0xFF1AAD80), padding: EdgeInsets.all(20.sp),
                        margin: EdgeInsets.symmetric(horizontal: 40.sp)),
                  ]);
                });
          }), onRefresh: () async => _reset())),

      const Divider(height: 0.5, color: Colors.black12),
      if (!_isFinish) Padding(padding: EdgeInsets.all(40.sp), child: Row(children: [
        if (hasDetail) ButtonImageWidget(16.sp, _delete,
            Container(padding: EdgeInsets.all(40.sp), width: 0.3.sw, child: LabelCustom('Xoá',
                color: Colors.white, size: 48.sp, weight: FontWeight.normal, align: TextAlign.center)), color: Colors.black26),
        ButtonImageWidget(16.sp, _save,
            Container(padding: EdgeInsets.all(40.sp), width: hasDetail ? 0.3.sw : 1.sw - 80.sp, child: LabelCustom('Lưu',
                color: Colors.white, size: 48.sp, weight: FontWeight.normal, align: TextAlign.center)), color: StyleCustom.primaryColor),
        if (hasDetail) ButtonImageWidget(16.sp, _finish,
            Container(padding: EdgeInsets.all(40.sp), width: 0.3.sw, child: LabelCustom('Kết thúc',
                color: Colors.white, size: 48.sp, weight: FontWeight.normal, align: TextAlign.center)), color: StyleCustom.primaryColor)
      ], mainAxisAlignment: MainAxisAlignment.spaceBetween)),
    ]);
  }

  Widget _title(String title) => LabelCustom(title, color: const Color(0xFF787878), size: 36.sp, weight: FontWeight.normal);

  void _initData() {
    final detail = (widget as HarvestDiaryDtlPage).detail;
    if (detail.id > 0) {
      _ctrName.text = detail.title;
      _ctrTypeTree.text = detail.family_tree;
      _ctrOtherUnit.text = detail.other_unit;
      _ctrQty.text = Util.doubleToString(detail.amount);
      _ctrTotal.text = Util.doubleToString(detail.revenue);
      if (detail.culture_plot_id > 0) {
        _ctrPlot.text = detail.culture_plot_title;
        _plots.id = detail.culture_plot_id.toString();
        _plots.name = detail.culture_plot_title;
      }
      if (detail.process_engineering_id > 0) {
        _ctrPlan.text = detail.process_engineering_title;
        _plan.id = detail.process_engineering_id;
        _plan.title = detail.process_engineering_title;
        bloc!.add(LoadFarmDtlEvent(_plan.id));
      }
      if (detail.unit.isNotEmpty) {switch(detail.unit.toLowerCase()) {
        case 'other': _unit.setValue('other', 'Khác'); break;
        case 'kg': _unit.setValue('kg', 'Kg'); break;
        case 'bottle': _unit.setValue('bottle', 'Chai'); break;
        case 'bag': _unit.setValue('bag', 'Bao'); break;
        case 'tree': _unit.setValue('tree', 'Cây'); break;
        case 'ton': _unit.setValue('ton', 'Tấn'); break;
      }} else if (detail.other_unit.isNotEmpty) {
        _ctrOtherUnit.text = detail.other_unit;
      }
    }
    _setUnit(_unit, isFirst: true);
  }

  void _selectPlots() {
    if (_isFinish) return;
    clearFocus();
    UtilUI.goToNextPage(context, PlotsManageListPage(isSelect: true), funCallback: _setPlots);
  }

  void _setPlots(value) {
    if (value == null) return;
    if (_plots.id == value.id.toString()) return;
    _ctrPlot.text = value.title;
    _plots.id = value.id.toString();
    _plots.name = value.title;
    _ctrTypeTree.text = value.family_tree;
  }

  void _selectPlan() {
    if (_isFinish) return;
    clearFocus();
    UtilUI.goToNextPage(context, FarmManageListPage(isSelect: true), funCallback: _setPlan);
  }

  void _setPlan(value) {
    if (value == null) return;
    if (_plan.id == value.id) return;
    _ctrPlan.text = value.title;
    _plan.id = value.id;
    _plan.title = value.title;
    _plan.start_date = value.start_date;
    _plan.end_date = value.end_date;
    _plan.culture_plot_id = value.culture_plot_id;
    _plan.culture_plot_title = value.culture_plot_title;
    _plots.id = _plan.culture_plot_id.toString();
    _plots.name = _plan.culture_plot_title;
  }

  void _selectUnit() {
    if (_isFinish) return;
    clearFocus();
    final List<ItemModel> options = [
      ItemModel(id: 'other', name: 'Khác'),
      ItemModel(id: 'kg', name: 'Kg'),
      ItemModel(id: 'bottle', name: 'Chai'),
      ItemModel(id: 'bag', name: 'Bao'),
      ItemModel(id: 'tree', name: 'Cây'),
      ItemModel(id: 'ton', name: 'Tấn'),
    ];
    UtilUI.showOptionDialog(context, 'Chọn đơn vị tính', options, _ctrUnit.text).then((value) => _setUnit(value));
  }

  void _setUnit(ItemModel? value, {bool isFirst = false}) {
    if (value == null) return;
    if (!isFirst && _unit.id == value.id) return;
    _ctrUnit.text = value.name;
    _unit.id = value.id;
    _unit.name = value.name;
    bloc!.add(ChangeUnitEvent());
    if (value.id != 'other') _ctrOtherUnit.text = '';
  }

  void _save() {
    if (_isFinish) return;
    clearFocus();
    if (_ctrName.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, 'Nhập tên mùa vụ').whenComplete(() => _fcName.requestFocus());
      return;
    }
    /*if (_plots.id.isEmpty) {
      UtilUI.showCustomDialog(context, 'Chọn lô thửa').whenComplete(() => _fcPlot.requestFocus());
      return;
    }*/

    final detail = (widget as HarvestDiaryDtlPage).detail;
    bloc!.add(CreatePlanEvent(detail.id, _plots.id, TextFieldCustom.stringToDouble(_ctrQty.text), TextFieldCustom.stringToDouble(_ctrTotal.text),
        _ctrName.text, _ctrTypeTree.text, _plan.id.toString(), detail.working_status,
        _unit.id, _ctrOtherUnit.text));
  }

  void _delete() {
    if (_isFinish) return;
    clearFocus();
    final detail = (widget as HarvestDiaryDtlPage).detail;
    if (detail.id > 0) {
      UtilUI.showCustomDialog(context, 'Bạn có chắc muốn xoá mùa vụ này không?',
        isActionCancel: true).then((value) {
          if (value != null && value) bloc!.add(DeletePlanEvent(detail.id));
      });
    }
  }

  ///Jobs detail
  List<Widget> _itemDetails(String date, List<dynamic> jobs, List<String> images, bool isHarvest) {
    List<Widget> temp = [
      if (date.isNotEmpty) Padding(child: Row(children: [
        Icon(Icons.calendar_month, color: const Color(0xFF1AAD80), size: 42.sp),
        LabelCustom(' ' + Util.strDateToString(date, pattern: 'dd/MM/yyyy'), color: const Color(0xFF414141), weight: FontWeight.normal)
      ]), padding: EdgeInsets.only(bottom: 20.sp))
    ];

    String title = '';
    for(int i = 0; i < jobs.length; i++) {
      title = jobs[i].title;
      if (isHarvest && title.isEmpty && jobs[i].working_type.isNotEmpty) {
        title = _works[jobs[i].working_type]??'';
      }
      if (title.isNotEmpty) temp.add(Padding(child: LabelCustom(' - ' + title, color: Colors.black, weight: FontWeight.normal), padding: EdgeInsets.only(bottom: 20.sp)));
    }

    if (images.isNotEmpty) {
      temp.add(Padding(child: const LabelCustom('Hình ảnh', color: Color(0xFF5F5F5F), weight: FontWeight.normal, style: FontStyle.italic), padding: EdgeInsets.only(bottom: 20.sp)));

      Widget image1 = _image(images[0]);
      Widget? image2 = images.length > 1 ? _image(images[1]) : null;
      temp.add(images.length > 1 ? Row(children: [
        image1,
        SizedBox(width: 10.sp),
        images.length > 2 ? Stack(children: [
          image2!,
          Container(child: LabelCustom('+' + (images.length - 2).toString(), weight: FontWeight.normal, size: 36.sp),
            alignment: Alignment.center, padding: EdgeInsets.all(20.sp),
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(100)),)
        ], alignment: Alignment.center) : image2!
      ], mainAxisAlignment: MainAxisAlignment.spaceBetween) : image1);
    }

    return temp;
  }

  Widget _image(String image) => ClipRRect(child: FadeInImage.assetNetwork(placeholder: 'assets/images/ic_default.png',
      imageErrorBuilder: (_,__,___) => Image.asset('assets/images/ic_default.png', width: 0.25.sw - 50.sp, height: 0.12.sw, fit: BoxFit.fill),
      image: Util.getRealPath(image),
      width: 0.25.sw - 50.sp, height: 0.12.sw, fit: BoxFit.fill, imageScale: 0.5), borderRadius: BorderRadius.circular(8.sp));

  Widget _itemTitle(int index, String date, List<dynamic> jobs, List<String> images, bool isHarvest) =>
      Expanded(child: ButtonImageWidget(0, () => _gotoDetail(index, isHarvest),
          Container(color: const Color(0xFFF1FCF9), padding: EdgeInsets.all(20.sp),
              child: Column(children: _itemDetails(date, jobs, images, isHarvest), crossAxisAlignment: CrossAxisAlignment.start)
          )));

  void _loadMore() {
    if (_taskBloc!.id < 0) return;
    _taskBloc!.add(LoadTaskDtlEvent(_pageHarvest, _pagePlan, (widget as HarvestDiaryDtlPage).detail.process_engineering_id));
  }

  void _listenScroller() {
    if ((_pageHarvest + _pagePlan > 0) && _scroller.position.maxScrollExtent == _scroller.position.pixels) _loadMore();
  }

  void _reset() {
    if (_taskBloc!.id < 0 || _lock) return;
    _lock = true;
    setState(() {
      _list.removeRange(1, _list.length);
    });
    _pageHarvest = 1;
    _pagePlan = 1;
    if ((widget as HarvestDiaryDtlPage).detail.process_engineering_id < 0) _pagePlan = 0;
    _loadMore();
  }

  void _gotoDetail(int index, bool isHarvest) {
    final page = widget as HarvestDiaryDtlPage;
    if (isHarvest) {
      if (index < 0) {
        UtilUI.goToNextPage(context, HarvestTaskDtlPage(page.detail.id, HarvestTaskModel(), _reset, _works, _isFinish));
        return;
      }

      final temp = _list[index][0];
      if (temp.id > 0) UtilUI.goToNextPage(context, HarvestTaskDtlPage(page.detail.id, temp, _reset, _works, _isFinish));
      return;
    }

    final temp = _list[index][1];
    if (temp.id > 0) UtilUI.goToNextPage(context, TaskDtlPage(page.detail.process_engineering_id, _plan.start_date, _plan.end_date, temp, _reset, lock: page.lock));
  }

  void _finish() => UtilUI.showCustomDialog(context, 'Bạn có chắc chắn muốn kết thúc mùa vụ không?', isActionCancel: true).then((value) {
    if (value != null && value) _taskBloc!.add(FinishHarvestEvent());
  });
  ///End: Jobs detail
}