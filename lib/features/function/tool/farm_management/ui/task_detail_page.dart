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
import 'package:hainong/features/function/tool/material_management/material_bloc.dart';
import 'package:hainong/features/function/tool/material_management/ui/material_detail_page.dart';
import 'package:hainong/features/function/tool/material_management/ui/material_list_page.dart';
import 'package:hainong/features/home/bloc/home_bloc.dart';
import 'package:hainong/features/home/bloc/home_event.dart';
import 'package:hainong/features/post/bloc/post_item_bloc.dart';
import '../farm_management_bloc.dart';
import '../task_bloc.dart';
import 'package:hainong/common/ui/ui_farm.dart';

class TaskDtlPage extends BasePage {
  final int id;
  final String start, end;
  final TaskModel detail;
  final Function funReload;
  final bool lock;
  TaskDtlPage(this.id, this.start, this.end, this.detail, this.funReload, {this.lock = false, Key? key}) : super(pageState: _TaskDtlPageState(), key: key);
}

class _TaskDtlPageState extends PermissionImagePageState {
  final TextEditingController _ctrName = TextEditingController(), _ctrWorkDate = TextEditingController(),
      _ctrMContent = TextEditingController(), _ctrMType = TextEditingController(),
      _ctrMQty = TextEditingController(), _ctrMUnit = TextEditingController(),
      _ctrMCost = TextEditingController(), _ctrOtherCost = TextEditingController(),
      _ctrCost = TextEditingController();
  final FocusNode _fcName = FocusNode(), _fcWorkDate = FocusNode(),
      _fcMContent = FocusNode(), _fcMType = FocusNode(),
      _fcMQty = FocusNode(), _fcMUnit = FocusNode(),
      _fcMCost = FocusNode(), _fcOtherCost = FocusNode(), _fcCost = FocusNode();
  final ItemModel _unit = ItemModel(id: '-1');
  final List<ItemModel> _units = [];
  int _indexDtl = -1;
  final MaterialModel _type = MaterialModel();

  @override
  void dispose() {
    (widget as TaskDtlPage).detail.clearJobs();
    _ctrName.dispose();
    _fcName.dispose();
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
    images?.clear();
    _units.clear();
    super.dispose();
  }

  @override
  void initState() {
    bloc = TaskBloc((widget as TaskDtlPage).id);
    super.initState();
    bloc!.stream.listen((state) {
      if (state is CreatePlanState && isResponseNotError(state.resp)) {
        final page = widget as TaskDtlPage;
        page.funReload();
        if (page.detail.id < 0) {
          page.detail.id = state.resp.data.id;
          page.detail.title = state.resp.data.title;
        }
        page.detail.jobs.clear();
        page.detail.jobs.addAll(state.resp.data.jobs);
        UtilUI.showCustomDialog(context, 'Lưu thành công', title: 'Thông báo').whenComplete(() => UtilUI.goBack(context, true));
      } else if (state is DeletePlanState && isResponseNotError(state.resp, passString: true)) {
        (widget as TaskDtlPage).funReload();
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
    final unlock = !(widget as TaskDtlPage).lock;
    final color = const Color(0XFFF5F6F8);
    final require = LabelCustom(' (*)', color: Colors.red, size: 36.sp, weight: FontWeight.normal);
    return Column(children: [
      Expanded(child: ListView(padding: EdgeInsets.symmetric(vertical: 40.sp), children: [
        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child:
          Row(children: [_title('Tên công việc'), require])),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 40.sp),
          child: TextFieldCustom(_ctrName, _fcName, _fcWorkDate, 'Nhập tên công việc',
              size: 42.sp, color: color, borderColor: color, maxLine: 0,
              inputAction: TextInputAction.newline, readOnly: !unlock,
              type: TextInputType.multiline, padding: EdgeInsets.all(30.sp))),

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
              final detail = (widget as TaskDtlPage).detail;
              return ListView.builder(itemCount: detail.jobs.length,
                  padding: EdgeInsets.symmetric(horizontal: 40.sp), shrinkWrap: true,
                  itemBuilder: (context, index) => FarmManageItem([
                    [detail.jobs[index].title, 3],
                    [detail.jobs[index].material_name, 3],
                    [Util.doubleToString(detail.jobs[index].material_quantity), 2],
                    [detail.jobs[index].material_unit_name, 2]
                  ], index, action: _selectJob, active: index == _indexDtl,
                      visible: detail.jobs[index].destroy == 0), physics: const NeverScrollableScrollPhysics());
            }
        ),

        Padding(padding: EdgeInsets.fromLTRB(40.sp, 40.sp, 40.sp, 0),
            child: Row(children: [
              Expanded(child: LabelCustom('Tổng chi phí vật tư (vnd): ', size: 42.sp,
                  color: const Color(0xFFFF0E0E), weight: FontWeight.normal)),
              Expanded(child: BlocBuilder(bloc: bloc,
                  buildWhen: (oldS, newS) => newS is AddDtlState || newS is SelectDtlState,
                  builder: (context, state) {
                    final detail = (widget as TaskDtlPage).detail;
                    return LabelCustom(Util.doubleToString(detail.getTotal()),
                        color: const Color(0xFFFF0E0E), size: 42.sp,
                        weight: FontWeight.normal, align: TextAlign.right);
                  }))
            ], mainAxisAlignment: MainAxisAlignment.spaceBetween)),

        Padding(padding: EdgeInsets.fromLTRB(40.sp, 40.sp, 40.sp, 0), child: _title('Nội dung thực hiện')),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 40.sp),
            child: TextFieldCustom(_ctrMContent, _fcMContent, _fcMType, 'Nhập nội dung thực hiện',
                size: 42.sp, color: color, borderColor: color, maxLine: 0,
                inputAction: TextInputAction.newline, readOnly: !unlock,
                type: TextInputType.multiline, padding: EdgeInsets.all(30.sp))),

        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: _title('Loại vật tư')),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 0),
          child: //Row(children: [
            //Expanded(child:
            TextFieldCustom(_ctrMType, _fcMType, _fcMQty, 'Chọn loại vật tư',
                size: 42.sp, color: color, borderColor: color, readOnly: true,
                onPressIcon: _selectMaterial, maxLine: 0, inputAction: TextInputAction.newline,
                type: TextInputType.multiline, padding: EdgeInsets.all(30.sp),
                suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp))),
            /*SizedBox(width: 32.sp),
            ButtonImageWidget(16.sp, _selectMaterialCreate, Container(padding: EdgeInsets.all(32.sp),
                child: Icon(Icons.add, color: Colors.white, size: 64.sp)), color: StyleCustom.primaryColor)
          ])),*/

        Padding(padding: EdgeInsets.all(40.sp), child: Row(children: [
          Expanded(child: Column(children: [
            _title('Sản lượng vật tư sử dụng'),
            SizedBox(height: 16.sp),
            TextFieldCustom(_ctrMQty, _fcMQty, _fcMUnit, 'Nhập sản lượng', size: 42.sp, readOnly: !unlock,
                type: TextInputType.number, isOdd: false,
                color: color, borderColor: color, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))])
          ], crossAxisAlignment: CrossAxisAlignment.start)),
          const SizedBox(width: 10),
          Expanded(child: Column(children: [
            _title('Đơn vị tính'),
            SizedBox(height: 16.sp),
            TextFieldCustom(_ctrMUnit, _fcMUnit, _fcMCost,
                'Chọn đơn vị', size: 42.sp, color: color, borderColor: color, readOnly: true,
                suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp))
          ], crossAxisAlignment: CrossAxisAlignment.start))
        ])),

        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: _title('Chi phí vật tư (VND)')),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 40.sp),
          child: TextFieldCustom(_ctrMCost, _fcMCost, _fcOtherCost, 'Nhập chi phí', size: 42.sp, readOnly: true,
              type: TextInputType.number, isOdd: false,
              color: color, borderColor: color, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))])),

        if (unlock) Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: BlocBuilder(bloc: bloc,
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

        Divider(height: 128.sp, color: const Color(0xFFF4F4F4), thickness: 32.sp),

        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: _title('Chi phí khác (VND)')),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 0),
            child: TextFieldCustom(_ctrOtherCost, _fcOtherCost, _fcCost, 'Nhập các chi phí khác', readOnly: !unlock,
                type: TextInputType.number, isOdd: false,
                size: 42.sp, color: color, borderColor: color, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))])),

        /*Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: _title('Chi phí thực hiện (VND)')),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 0),
            child: TextFieldCustom(_ctrCost, _fcCost, null, 'Nhập chi phí thực hiện',
                size: 42.sp, color: color, borderColor: color, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))])),*/

        imageUI(_selectImage, _deleteImage)
      ])),

      const Divider(height: 0.5, color: Colors.black12),
      if (unlock) Padding(padding: EdgeInsets.all(40.sp), child: Row(children: [
        ButtonImageWidget(16.sp, _delete,
            Container(padding: EdgeInsets.all(40.sp), width: 0.5.sw - 60.sp, child: LabelCustom('Xoá',
                color: Colors.white, size: 48.sp, weight: FontWeight.normal, align: TextAlign.center)), color: Colors.black26),
        ButtonImageWidget(16.sp, _save,
            Container(padding: EdgeInsets.all(40.sp), width: 0.5.sw - 60.sp, child: LabelCustom('Lưu',
                color: Colors.white, size: 48.sp, weight: FontWeight.normal, align: TextAlign.center)), color: StyleCustom.primaryColor)
      ], mainAxisAlignment: MainAxisAlignment.spaceBetween))
    ]);
  }

  Widget _title(String title) => LabelCustom(title, color: const Color(0xFF787878), size: 36.sp, weight: FontWeight.normal);

  void _initData() {
    bloc!.add(LoadUnitEvent());
    setOnlyImage();
    multiSelect = true;
    images = [];
    final detail = (widget as TaskDtlPage).detail;
    if (detail.id > 0) {
      _ctrName.text = detail.title;
      if (detail.working_date.isNotEmpty) _ctrWorkDate.text = Util.strDateToString(detail.working_date, pattern: 'dd/MM/yyyy');
      if (detail.other_cost > 0) _ctrOtherCost.text = Util.doubleToString(detail.other_cost);
      if (detail.cost > 0) _ctrCost.text = detail.cost.toInt().toString();
      if (detail.images.isNotEmpty) {
        showLoadingPermission();
        final List<ItemModel> list = [];
        for (var ele in detail.images) {
          list.add(ItemModel(name: ele));
        }
        bloc!.add(DownloadFilesPostItemEvent(list));
      }
    }
  }

  void _selectImage() {
    if ((widget as TaskDtlPage).lock) return;
    clearFocus();
    selectImage([
      ItemModel(id: languageKey.lblCamera, name: MultiLanguage.get(languageKey.lblCamera)),
      ItemModel(id: languageKey.lblGallery, name: MultiLanguage.get(languageKey.lblGallery))
    ]);
  }

  void _deleteImage(int index) {
    if ((widget as TaskDtlPage).lock) return;
    clearFocus();
    images!.removeAt(index);
    bloc!.add(AddImageHomeEvent());
  }

  void _selectDate() {
    clearFocus();
    final page = widget as TaskDtlPage;
    if (page.lock) return;
    String temp = _ctrWorkDate.text, start = page.start, end = page.end;
    if (temp.isEmpty) {
      final now = DateTime.now();
      temp = '${now.day}/${now.month}/${now.year}';
    }
    DatePicker.showDatePicker(context,
        minTime: start.isEmpty ? DateTime.now().add(const Duration(days: -3650)) : Util.stringToDateTime(start),
        maxTime: end.isEmpty ? DateTime.now().add(const Duration(days: 3650)) : Util.stringToDateTime(end),
        showTitleActions: true,
        onConfirm: (DateTime date) => _ctrWorkDate.text = Util.dateToString(date, pattern: 'dd/MM/yyyy'),
        currentTime: Util.stringToDateTime(temp, pattern: 'dd/MM/yyyy'),
        locale: LocaleType.vi);
  }

  void _selectMaterial() {
    if ((widget as TaskDtlPage).lock) return;
    clearFocus();
    UtilUI.goToNextPage(context, MaterialListPage(isSelect: true), funCallback: (value) => _setMaterial(value));
  }

  void _selectMaterialCreate() {
    clearFocus();
    UtilUI.goToNextPage(context, MaterialDtlPage(MaterialModel(), (){}, isSelect: true), funCallback: (value) => _setMaterial(value));
  }

  void _setMaterial(value) {
    if (value != null && _type.id != value.id) {
      _type.copy(value);
      _ctrMType.text = value.name;
      _ctrMUnit.text = _type.material_unit_name;
      _unit.setValue(_type.material_unit_id.toString(), _type.material_unit_name);
      _ctrMQty.text = Util.doubleToString(_type.volume);
      _ctrMCost.text = Util.doubleToString(_type.price);
    }
  }

  void _selectUnit() {
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
    final page = widget as TaskDtlPage;
    final detail = page.detail;
    _type.setValue(detail.jobs[index].id, detail.jobs[index].title, detail.jobs[index].material_id, detail.jobs[index].material_name, detail.jobs[index].material_unit_id, detail.jobs[index].material_unit_name, detail.jobs[index].material_quantity, detail.jobs[index].material_cost);
    _ctrMType.text = _type.material_type_name;
    //_setMaterial(ItemModel(id: detail.jobs[index].material_id.toString(), name: detail.jobs[index].material_name));
    _setUnit(ItemModel(id: detail.jobs[index].material_unit_id.toString(), name: detail.jobs[index].material_unit_name));
    _ctrMQty.text = detail.jobs[index].material_quantity > 0 ? Util.doubleToString(detail.jobs[index].material_quantity) : '';
    _ctrMCost.text = detail.jobs[index].material_cost > 0 ? Util.doubleToString(detail.jobs[index].material_cost) : '';
    _ctrMContent.text = detail.jobs[index].title;
    bloc!.add(SelectDtlEvent());
  }

  void _resetDetail() {
    clearFocus();
    _setMaterial(MaterialModel());
    _setUnit(ItemModel(id: '-1'));
    _ctrMContent.text = '';
    _ctrMType.text = '';
    _ctrMUnit.text = '';
    _ctrMQty.text = '';
    _ctrMCost.text = '';
  }

  void _cancelJob() {
    _resetDetail();
    _indexDtl = -1;
    bloc!.add(SelectDtlEvent());
  }

  void _updateJob() {
    final detail = (widget as TaskDtlPage).detail;
    detail.jobs[_indexDtl].destroy = 0;
    detail.jobs[_indexDtl].title = _ctrMContent.text;
    if (_type.id != -1) {
      detail.jobs[_indexDtl].material_id = _type.id;
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
      final detail = (widget as TaskDtlPage).detail;
      detail.jobs[_indexDtl].destroy = 1;
      _cancelJob();
    }
  });

  void _addJob() {
    clearFocus();
    if (_ctrMContent.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, 'Nhập nội dung thực hiện').whenComplete(() => _fcMContent.requestFocus());
      return;
    }
    final detail = (widget as TaskDtlPage).detail;
    detail.jobs.add(TaskDtlModel(
      title: _ctrMContent.text,
      material_id: _type.id,
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
    if (_ctrName.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, 'Nhập tên công việc').whenComplete(() => _fcName.requestFocus());
      return;
    }
    if (_ctrWorkDate.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, 'Chọn ngày thực hiện').whenComplete(() => _fcWorkDate.requestFocus());
      return;
    }

    bloc!.add(CreateTaskEvent((widget as TaskDtlPage).detail, _ctrName.text, _ctrWorkDate.text, _ctrCost.text, TextFieldCustom.stringToDouble(_ctrOtherCost.text), images!));
  }

  void _delete() {
    clearFocus();
    final detail = (widget as TaskDtlPage).detail;
    if (detail.id > 0) {
      UtilUI.showCustomDialog(context, 'Bạn có chắc muốn xoá công việc này không?',
        isActionCancel: true).then((value) {
          if (value != null && value) bloc!.add(DeletePlanEvent(detail.id));
      });
    }
  }
}