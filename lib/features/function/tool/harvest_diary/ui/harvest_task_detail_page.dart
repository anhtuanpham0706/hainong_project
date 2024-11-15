import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:hainong/common/models/file_byte.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/permission_image_page_state.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import 'package:hainong/features/function/tool/farm_management/farm_management_bloc.dart';
import 'package:hainong/features/function/tool/farm_management/task_bloc.dart';
import 'package:hainong/common/ui/ui_farm.dart';
import 'package:hainong/features/function/tool/material_management/material_bloc.dart';
import 'package:hainong/features/function/tool/material_management/ui/material_detail_page.dart';
import 'package:hainong/features/function/tool/material_management/ui/material_list_page.dart';
import 'package:hainong/features/home/bloc/home_bloc.dart';
import 'package:hainong/features/home/bloc/home_event.dart';
import 'package:hainong/features/post/bloc/post_item_bloc.dart';
import '../harvest_task_bloc.dart';

class HarvestTaskDtlPage extends BasePage {
  final int id;
  final HarvestTaskModel detail;
  final Function funReload;
  final Map<String, String> works;
  final bool finished;
  HarvestTaskDtlPage(this.id, this.detail, this.funReload, this.works, this.finished, {Key? key}) : super(pageState: _HarvestTaskDtlPageState(), key: key);
}

class _HarvestTaskDtlPageState extends PermissionImagePageState {
  final TextEditingController _ctrPercent = TextEditingController(), _ctrWorkDate = TextEditingController(),
      _ctrMContent = TextEditingController(), _ctrMType = TextEditingController(),
      _ctrMQty = TextEditingController(), _ctrMUnit = TextEditingController(),
      _ctrMCost = TextEditingController(), _ctrOtherCost = TextEditingController(),
      _ctrCost = TextEditingController(), _ctrMWork = TextEditingController();
  final FocusNode _fcPercent = FocusNode(), _fcWorkDate = FocusNode(),
      _fcMContent = FocusNode(), _fcMType = FocusNode(),
      _fcMQty = FocusNode(), _fcMUnit = FocusNode(), _fcMWork = FocusNode(),
      _fcMCost = FocusNode(), _fcOtherCost = FocusNode(), _fcCost = FocusNode();
  final ItemModel _type = ItemModel(id: '-1'), _unit = ItemModel(id: '-1'), _work = ItemModel();
  final List<ItemModel> _units = [];
  int _indexDtl = -1;
  bool _isFinish = false;

  @override
  void dispose() {
    (widget as HarvestTaskDtlPage).detail.clearJobs();
    _ctrPercent.dispose();
    _fcPercent.dispose();
    _ctrWorkDate.dispose();
    _fcWorkDate.dispose();
    _ctrMContent.dispose();
    _fcMContent.dispose();
    _ctrMType.dispose();
    _fcMType.dispose();
    _ctrMQty.dispose();
    _fcMQty.dispose();
    _ctrMUnit.dispose();
    _fcMUnit.dispose();
    _ctrMCost.dispose();
    _fcMCost.dispose();
    _ctrOtherCost.dispose();
    _fcOtherCost.dispose();
    _ctrCost.dispose();
    _fcCost.dispose();
    _ctrMWork.dispose();
    _fcMWork.dispose();
    images?.clear();
    _units.clear();
    super.dispose();
  }

  @override
  void initState() {
    _isFinish = (widget as HarvestTaskDtlPage).finished;
    bloc = HarvestTaskBloc((widget as HarvestTaskDtlPage).id);
    super.initState();
    bloc!.stream.listen((state) {
      if (state is CreatePlanState && isResponseNotError(state.resp)) {
        final page = widget as HarvestTaskDtlPage;
        page.funReload();
        if (page.detail.id < 0) {
          page.detail.id = state.resp.data.id;
        }
        page.detail.jobs.clear();
        page.detail.jobs.addAll(state.resp.data.jobs);
        UtilUI.showCustomDialog(context, 'Lưu thành công', title: 'Thông báo').whenComplete(() => UtilUI.goBack(context, true));
      } else if (state is DeletePlanState && isResponseNotError(state.resp, passString: true)) {
        (widget as HarvestTaskDtlPage).funReload();
        UtilUI.goBack(context, true);
      } else if (state is AddDtlState) {
        _resetDetail();
      } else if (state is DownloadFilesPostItemState) {
        loadFiles(state.response);
      } else if (state is LoadUnitState) {
        _units.addAll(state.list);
      }
    });
    _initData();
  }

  @override
  void showLoadingPermission({bool value = true}) => bloc!.add(ShowLoadingHomeEvent(value));

  @override
  void loadFiles(List<File> files) {
    showLoadingPermission();
    bool overSize = false;
    int size = getSize();
    for(int i = 0; i < files.length; i++) {
      if (size + files[i].lengthSync() > 102400000) {
        overSize = true;
        break;
      }
      size += files[i].lengthSync();
      images!.add(FileByte(files[i].readAsBytesSync(), files[i].path));
    }
    bloc!.add(AddImageHomeEvent());
    if (overSize) UtilUI.showCustomDialog(context, MultiLanguage.get('msg_file_100mb'));
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Scaffold(
      appBar: AppBar(elevation: 10, titleSpacing: 0, centerTitle: true,
          actions: [
            IconButton(onPressed: clearFocus, icon: Icon(Icons.keyboard, color: Colors.white, size: 48.sp))
          ],
          title: UtilUI.createLabel('Thông tin công việc thực hiện')),
      backgroundColor: Colors.white, body: Stack(children: [createUI(), Loading(bloc)]));

  @override
  Widget createUI() {
    final color = const Color(0XFFF5F6F8);
    final require = LabelCustom(' (*)', color: Colors.red, size: 36.sp, weight: FontWeight.normal);
    return Column(children: [
      Expanded(child: ListView(padding: EdgeInsets.symmetric(vertical: 40.sp), children: [
        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child:
          Row(children: [_title('Ngày thực hiện'), require])),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 0),
          child: TextFieldCustom(_ctrWorkDate, _fcWorkDate, _fcMContent, 'dd/MM/yyyy',
            size: 42.sp, color: color, borderColor: color, readOnly: true,
            onPressIcon: _selectDate, suffix: Icon(Icons.calendar_today, color: Colors.grey, size: 48.sp))),

        Divider(height: 128.sp, color: const Color(0xFFF4F4F4), thickness: 32.sp),

        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child:
          LabelCustom('Chi tiết công việc', size: 52.sp, color: const Color(0xFF1AAD80))),

        Padding(padding: EdgeInsets.fromLTRB(40.sp, 40.sp, 40.sp, 16.sp), child: _title('Danh sách nội dung thực hiện trong ngày')),
        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: const FarmManageTitle([
          ['Nội dung', 3], ['Loại vật tư', 3], ['SL', 2], ['Đơn vị', 2]
        ])),
        BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is AddDtlState || newS is SelectDtlState,
            builder: (context, state) {
              final page = widget as HarvestTaskDtlPage;
              return ListView.builder(itemCount: page.detail.jobs.length,
                  padding: EdgeInsets.symmetric(horizontal: 40.sp), shrinkWrap: true,
                  itemBuilder: (context, index) {
                    String title = page.detail.jobs[index].title;
                    String temp = page.detail.jobs[index].working_type;
                    if (temp != 'other' && page.works.containsKey(temp)) title = page.works[temp] ?? '';
                    return FarmManageItem([
                      [title, 3],
                      [page.detail.jobs[index].material_name, 3],
                      [Util.doubleToString(page.detail.jobs[index].material_quantity), 2],
                      [page.detail.jobs[index].material_unit_name, 2]
                    ], index, action: _selectJob, active: index == _indexDtl,
                        visible: page.detail.jobs[index].destroy == 0);
                  }, physics: const NeverScrollableScrollPhysics());
            }
        ),

        Padding(padding: EdgeInsets.fromLTRB(40.sp, 40.sp, 40.sp, 0),
            child: Row(children: [
              Expanded(child: LabelCustom('Tổng chi phí vật tư (vnd): ', size: 42.sp,
                  color: const Color(0xFFFF0E0E), weight: FontWeight.normal)),
              Expanded(child: BlocBuilder(bloc: bloc,
                  buildWhen: (oldS, newS) => newS is AddDtlState || newS is SelectDtlState,
                  builder: (context, state) {
                    final detail = (widget as HarvestTaskDtlPage).detail;
                    return LabelCustom(Util.doubleToString(detail.getTotal()),
                        color: const Color(0xFFFF0E0E), size: 42.sp,
                        weight: FontWeight.normal, align: TextAlign.right);
                  }))
            ], mainAxisAlignment: MainAxisAlignment.spaceBetween)),

        Padding(padding: EdgeInsets.fromLTRB(40.sp, 40.sp, 40.sp, 0), child: _title('Nội dung thực hiện')),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 0),
            child: TextFieldCustom(_ctrMWork, _fcMWork, _fcMType, 'Chọn nội dung thực hiện',
                size: 42.sp, color: color, borderColor: color, readOnly: true,
                onPressIcon: _selectWork, suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp))),

        BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is ChangeUnitState,
          builder: (context, state) {
            if (_work.id != 'other') return SizedBox(height: 40.sp);
            return Padding(padding: EdgeInsets.fromLTRB(40.sp, 20.sp, 40.sp, 40.sp),
                child: TextFieldCustom(_ctrMContent, _fcMContent, _fcMType, 'Nhập nội dung thực hiện',
                    size: 42.sp, color: color, borderColor: color, maxLine: 0,
                    inputAction: TextInputAction.newline, readOnly: _isFinish,
                    type: TextInputType.multiline, padding: EdgeInsets.all(30.sp)));
        }),

        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: _title('Loại vật tư')),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 0),
          child: //Row(children: [
            //Expanded(child:
            TextFieldCustom(_ctrMType, _fcMType, _fcMQty, 'Chọn loại vật tư',
                size: 42.sp, color: color, borderColor: color, readOnly: true,
                onPressIcon: _selectMaterial, maxLine: 0, inputAction: TextInputAction.newline,
                type: TextInputType.multiline, padding: EdgeInsets.all(30.sp),
                suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp))
            ),
            /*SizedBox(width: 32.sp),
            ButtonImageWidget(16.sp, _selectMaterialCreate, Container(padding: EdgeInsets.all(32.sp),
                child: Icon(Icons.add, color: Colors.white, size: 64.sp)), color: StyleCustom.primaryColor)
          ])),*/

        Padding(padding: EdgeInsets.all(40.sp), child: Row(children: [
          Expanded(child: Column(children: [
            _title('Sản lượng vật tư sử dụng'),
            SizedBox(height: 16.sp),
            TextFieldCustom(_ctrMQty, _fcMQty, _fcMUnit, 'Nhập sản lượng', size: 42.sp, readOnly: _isFinish,
                type: TextInputType.number, isOdd: false,
                color: color, borderColor: color, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))])
          ], crossAxisAlignment: CrossAxisAlignment.start)),
          const SizedBox(width: 10),
          Expanded(child: Column(children: [
            _title('Đơn vị tính'),
            SizedBox(height: 16.sp),
            TextFieldCustom(_ctrMUnit, _fcMUnit, _fcMCost,
                'Chọn đơn vị', size: 42.sp, color: color, borderColor: color, readOnly: true,
                onPressIcon: _selectUnit, suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp))
          ], crossAxisAlignment: CrossAxisAlignment.start))
        ])),

        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: _title('Chi phí vật tư (VND)')),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 0),
          child: TextFieldCustom(_ctrMCost, _fcMCost, _fcOtherCost, 'Nhập chi phí', size: 42.sp, readOnly: _isFinish,
              type: TextInputType.number, isOdd: false,
              color: color, borderColor: color, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))])),

        if (!_isFinish) Padding(padding: EdgeInsets.fromLTRB(40.sp, 40.sp, 40.sp, 0), child: BlocBuilder(bloc: bloc,
          buildWhen: (oldS, newS) => newS is SelectDtlState,
          builder: (context, state) {
            if (_indexDtl < 0) {
              return ButtonImageWidget(16.sp, _addJob,
                  Container(padding: EdgeInsets.all(40.sp), width: 1.sw - 80.sp, child: Row(children: [
                    Icon(Icons.add_circle_outline, color: const Color(0xFF1AAD80), size: 64.sp),
                    SizedBox(width: 16.sp),
                    LabelCustom('Thêm nội dung', color: const Color(0xFF1AAD80),
                        size: 48.sp, weight: FontWeight.normal, align: TextAlign.center)
                  ], mainAxisAlignment: MainAxisAlignment.center)), color: const Color(0xFFEAFBF6));
            }
            return Row(children: [
              Expanded(child: ButtonImageWidget(16.sp, _cancelJob,
                  Container(padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 40.sp),
                      child: Row(children: [
                    Icon(Icons.cancel_outlined, color: const Color(0xFF1AAD80), size: 60.sp),
                    SizedBox(width: 16.sp),
                    LabelCustom('Bỏ chọn', color: const Color(0xFF1AAD80),
                        size: 46.sp, weight: FontWeight.normal, align: TextAlign.center)
                  ], mainAxisAlignment: MainAxisAlignment.center)), color: const Color(0xFFEAFBF6))),
              const SizedBox(width: 10),
              Expanded(child: ButtonImageWidget(16.sp, _updateJob,
                Container(padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 40.sp),
                  child: Row(children: [
                    Icon(Icons.edit, color: const Color(0xFF1AAD80), size: 60.sp),
                    SizedBox(width: 16.sp),
                    LabelCustom('Cập nhật', color: const Color(0xFF1AAD80),
                        size: 46.sp, weight: FontWeight.normal, align: TextAlign.center)
                  ], mainAxisAlignment: MainAxisAlignment.center)), color: const Color(0xFFEAFBF6))),
              const SizedBox(width: 10),
              Expanded(child: ButtonImageWidget(16.sp, _deleteJob,
                  Container(padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 40.sp),
                      child: Row(children: [
                    Icon(Icons.delete_forever, color: const Color(0xFF1AAD80), size: 60.sp),
                    SizedBox(width: 16.sp),
                    LabelCustom('Xoá', color: const Color(0xFF1AAD80),
                        size: 46.sp, weight: FontWeight.normal, align: TextAlign.center)
                  ], mainAxisAlignment: MainAxisAlignment.center)), color: const Color(0xFFEAFBF6)))
            ]);
        })),

        //if (_isFinish) SizedBox(height: 40.sp),

        Divider(height: 128.sp, color: const Color(0xFFF4F4F4), thickness: 32.sp),

        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: _title('Chi phí khác (VND)')),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 40.sp),
            child: TextFieldCustom(_ctrOtherCost, _fcOtherCost, _fcCost, 'Nhập các chi phí khác', readOnly: _isFinish,
                type: TextInputType.number, isOdd: false,
                size: 42.sp, color: color, borderColor: color, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))])),

        /*Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: _title('Chi phí thực hiện (VND)')),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 40.sp),
            child: TextFieldCustom(_ctrCost, _fcCost, _fcPercent, 'Nhập chi phí thực hiện', readOnly: _isFinish,
                size: 42.sp, color: color, borderColor: color, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))])),*/

        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: _title('Hoàn thành công việc được (% công việc tòan thửa)')),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 0),
            child: TextFieldCustom(_ctrPercent, _fcPercent, null, 'Nhập số % công việc đã hoàn thành', readOnly: _isFinish,
                size: 42.sp, color: color, borderColor: color, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^([0-9])*([.])?([0-9]?)*$'))])),

        imageUI(_selectImage, _deleteImage)
      ])),

      const Divider(height: 0.5, color: Colors.black12),
      if (!_isFinish) Padding(padding: EdgeInsets.all(40.sp), child: Row(children: [
        ButtonImageWidget(16.sp, _delete,
            Container(padding: EdgeInsets.all(40.sp), width: 0.5.sw - 60.sp, child: LabelCustom('Xoá',
                color: Colors.white, size: 48.sp, weight: FontWeight.normal, align: TextAlign.center)), color: Colors.black26),
        ButtonImageWidget(16.sp, _save,
            Container(padding: EdgeInsets.all(40.sp), width: 0.5.sw - 60.sp, child: LabelCustom('Lưu',
                color: Colors.white, size: 48.sp, weight: FontWeight.normal, align: TextAlign.center)), color: StyleCustom.primaryColor)
      ], mainAxisAlignment: MainAxisAlignment.spaceBetween)),
    ]);
  }

  Widget _title(String title) => LabelCustom(title, color: const Color(0xFF787878), size: 36.sp, weight: FontWeight.normal);

  void _initData() {
    bloc!.add(LoadUnitEvent());
    setOnlyImage();
    multiSelect = true;
    images = [];
    final detail = (widget as HarvestTaskDtlPage).detail;
    if (detail.id > 0) {
      if (detail.images.isNotEmpty) {
        showLoadingPermission();
        final List<ItemModel> list = [];
        for (var ele in detail.images) {
          list.add(ItemModel(name: ele));
        }
        bloc!.add(DownloadFilesPostItemEvent(list));
      }
      if (detail.percent_finish > 0) _ctrPercent.text = detail.percent_finish.toString();
      if (detail.working_date.isNotEmpty) _ctrWorkDate.text = Util.strDateToString(detail.working_date, pattern: 'dd/MM/yyyy');
      if (detail.other_cost > 0) _ctrOtherCost.text = Util.doubleToString(detail.other_cost);
      if (detail.cost > 0) _ctrCost.text = detail.cost.toInt().toString();
    }
  }

  void _selectImage() {
    if (_isFinish) return;
    clearFocus();
    selectImage([
      ItemModel(id: languageKey.lblCamera, name: MultiLanguage.get(languageKey.lblCamera)),
      ItemModel(id: languageKey.lblGallery, name: MultiLanguage.get(languageKey.lblGallery))
    ]);
  }

  void _deleteImage(int index) {
    if (_isFinish) return;
    clearFocus();
    images!.removeAt(index);
    bloc!.add(AddImageHomeEvent());
  }

  void _selectDate() {
    if (_isFinish) return;
    clearFocus();
    String temp = _ctrWorkDate.text;
    if (temp.isEmpty) {
      final now = DateTime.now();
      temp = '${now.day}/${now.month}/${now.year}';
    }
    DatePicker.showDatePicker(context,
        minTime: DateTime.now().add(const Duration(days: -3650)),
        maxTime: DateTime.now(),
        showTitleActions: true,
        onConfirm: (DateTime date) => _ctrWorkDate.text = Util.dateToString(date, pattern: 'dd/MM/yyyy'),
        currentTime: Util.stringToDateTime(temp, pattern: 'dd/MM/yyyy'),
        locale: LocaleType.vi);
  }

  void _selectMaterial() {
    if (_isFinish) return;
    clearFocus();
    UtilUI.goToNextPage(context, MaterialListPage(isSelect: true), funCallback: (value) => _setMaterial(value));
  }

  void _selectMaterialCreate() {
    if (_isFinish) return;
    clearFocus();
    UtilUI.goToNextPage(context, MaterialDtlPage(MaterialModel(), (){}, isSelect: true), funCallback: (value) => _setMaterial(value));
  }

  void _setMaterial(value) {
    if (value != null) {
      _type.setValue(value.id.toString(), value.name);
      _ctrMType.text = value.name;
      _ctrMQty.text = Util.doubleToString(value.volume);
      _ctrMCost.text = Util.doubleToString(value.price);
      _setUnit(ItemModel(id: value.material_unit_id.toString(), name: value.material_unit_name));
    }
  }

  void _selectWork() {
    if (_isFinish) return;
    clearFocus();
    final page = widget as HarvestTaskDtlPage;
    final List<ItemModel> list = [];
    page.works.forEach((key, value) => list.add(ItemModel(id: key, name: value)));
    UtilUI.showOptionDialog(context, 'Chọn nội dung thực hiện', list, _work.id).then((value) => _setWork(value));
  }

  void _setWork(ItemModel? value) {
    if (value != null && _work.id != value.id) {
      _ctrMWork.text = value.name;
      _ctrMContent.text = '';
      _work.setValue(value.id, value.name);
      bloc!.add(ChangeUnitEvent());
    }
  }

  void _selectUnit() {
    if (_isFinish) return;
    clearFocus();
    UtilUI.showOptionDialog(context, 'Chọn đơn vị tính', _units, '').then((value) => _setUnit(value));
  }

  void _setUnit(ItemModel? value) {
    if (value != null && _unit.id != value.id) {
      _ctrMUnit.text = value.name;
      _unit.setValue(value.id, value.name);
    }
  }

  void _selectJob(int index) {
    if (_indexDtl == index) return;
    _indexDtl = index;
    final page = widget as HarvestTaskDtlPage;
    final detail = page.detail;
    _setMaterial(MaterialModel(id: detail.jobs[index].material_id, name: detail.jobs[index].material_name,
      volume: detail.jobs[index].material_quantity, price: detail.jobs[index].material_cost,
      material_unit_id: detail.jobs[index].material_unit_id, material_unit_name: detail.jobs[index].material_unit_name));
    String work = detail.jobs[index].working_type;
    if (work.isNotEmpty && page.works.containsKey(work)) _setWork(ItemModel(id: work, name: page.works[work]??''));
    _ctrMContent.text = detail.jobs[index].title;
    if (_ctrMContent.text.isEmpty && detail.jobs[index].working_type.isNotEmpty) {
      _ctrMContent.text = page.works[detail.jobs[index].working_type]??'';
    }
    bloc!.add(SelectDtlEvent());
  }

  void _resetDetail() {
    clearFocus();
    _setMaterial(MaterialModel());
    _setUnit(ItemModel(id: '-1'));
    _setWork(ItemModel());
    _ctrMType.text = '';
    _ctrMUnit.text = '';
    _ctrMWork.text = '';
    _ctrMQty.text = '';
    _ctrMCost.text = '';
  }

  void _cancelJob() {
    _resetDetail();
    _indexDtl = -1;
    bloc!.add(SelectDtlEvent());
  }

  void _updateJob() {
    final detail = (widget as HarvestTaskDtlPage).detail;
    detail.jobs[_indexDtl].destroy = 0;
    detail.jobs[_indexDtl].title = _ctrMContent.text;
    if (_work.id.isNotEmpty) detail.jobs[_indexDtl].working_type = _work.id;
    if (_type.id != '-1') {
      detail.jobs[_indexDtl].material_id = int.parse(_type.id);
      detail.jobs[_indexDtl].material_name = _type.name;
    }
    if (_unit.id != '-1') {
      detail.jobs[_indexDtl].material_unit_id = int.parse(_unit.id);
      detail.jobs[_indexDtl].material_unit_name = _unit.name;
    }
    detail.jobs[_indexDtl].material_quantity = _ctrMQty.text.isEmpty ? .0 : double.parse(TextFieldCustom.stringToDouble(_ctrMQty.text));
    detail.jobs[_indexDtl].material_cost = _ctrMCost.text.isEmpty ? .0 : double.parse(TextFieldCustom.stringToDouble(_ctrMCost.text));
    _cancelJob();
  }

  void _deleteJob() => UtilUI.showCustomDialog(context, 'Bạn có chắc muốn xoá chi tiết công việc này không?',
    isActionCancel: true).then((value) {
          if (value != null && value) {
            final detail = (widget as HarvestTaskDtlPage).detail;
            detail.jobs[_indexDtl].destroy = 1;
            _cancelJob();
          }
  });

  void _addJob() {
    clearFocus();
    if (_work.id == '') {
      UtilUI.showCustomDialog(context, 'Chọn nội dung thực hiện').whenComplete(() => _fcMWork.requestFocus());
      return;
    } else if (_work.id == 'other' && _ctrMContent.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, 'Nhập nội dung thực hiện').whenComplete(() => _fcMContent.requestFocus());
      return;
    }

    final detail = (widget as HarvestTaskDtlPage).detail;
    detail.jobs.add(HarvestTaskDtlModel(
      title: _ctrMContent.text,
      working_type: _work.id,
      material_id: _type.id.isEmpty ? -1 : int.parse(_type.id),
      material_name: _type.name,
      material_unit_id: _unit.id.isEmpty ? -1 : int.parse(_unit.id),
      material_unit_name: _unit.name,
      material_quantity: _ctrMQty.text.isEmpty ? .0 : double.parse(TextFieldCustom.stringToDouble(_ctrMQty.text)),
      material_cost: _ctrMCost.text.isEmpty ? .0 : double.parse(TextFieldCustom.stringToDouble(_ctrMCost.text)),
    ));
    bloc!.add(AddDtlEvent());
  }

  void _save() {
    clearFocus();
    if (_ctrWorkDate.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, 'Chọn ngày thực hiện').whenComplete(() => _fcWorkDate.requestFocus());
      return;
    }

    bloc!.add(CreateHarvestTaskEvent((widget as HarvestTaskDtlPage).detail, _ctrPercent.text, _ctrWorkDate.text, _ctrCost.text, TextFieldCustom.stringToDouble(_ctrOtherCost.text), images!));
  }

  void _delete() {
    clearFocus();
    final detail = (widget as HarvestTaskDtlPage).detail;
    if (detail.id > 0) {
      UtilUI.showCustomDialog(context, 'Bạn có chắc muốn xoá công việc này không?',
        isActionCancel: true).then((value) {
          if (value != null && value) bloc!.add(DeletePlanEvent(detail.id));
      });
    }
  }
}