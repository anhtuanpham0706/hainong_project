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
import 'package:hainong/common/ui/show_popup_html.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import 'package:hainong/features/function/tool/farm_management/farm_management_bloc.dart';
import 'package:hainong/features/function/tool/farm_management/task_bloc.dart';
import 'package:hainong/features/function/tool/harvest_diary/harvest_diary_bloc.dart';
import 'package:hainong/features/function/tool/material_management/material_bloc.dart';
import 'package:hainong/features/home/bloc/home_bloc.dart';
import 'package:hainong/features/home/bloc/home_event.dart';
import 'package:hainong/features/post/bloc/post_item_bloc.dart';
import '../material_bloc.dart';

class MaterialDtlPage extends BasePage {
  final MaterialModel detail;
  final Function funReload;
  final bool isSelect, isLoadDtl;
  MaterialDtlPage(this.detail, this.funReload, {this.isSelect = false, this.isLoadDtl = false, Key? key}) : super(pageState: _MaterialDtlPageState(), key: key);
}

class _MaterialDtlPageState extends PermissionImagePageState {
  final TextEditingController _ctrName = TextEditingController(), _ctrType = TextEditingController(),
      _ctrUnit = TextEditingController(), _ctrVolume = TextEditingController(),
      _ctrPrice = TextEditingController(), _ctrCode = TextEditingController(), _ctrDate = TextEditingController();
  final FocusNode _fcName = FocusNode(), _fcCode = FocusNode(),
      _fcType = FocusNode(), _fcVolume = FocusNode(),
      _fcUnit = FocusNode(), _fcPrice = FocusNode(), _fcDate = FocusNode();
  final ItemModel _type = ItemModel(id: '-1'), _unit = ItemModel(id: '-1');
  final List<ItemModel> _types = [], _units = [];

  @override
  void dispose() {
    //_fcPrice.removeListener(_listener);
    _ctrDate.dispose();
    _fcDate.dispose();
    _ctrName.dispose();
    _fcName.dispose();
    _ctrCode.dispose();
    _fcCode.dispose();
    _ctrType.dispose();
    _fcType.dispose();
    _ctrUnit.dispose();
    _fcUnit.dispose();
    _ctrVolume.dispose();
    _fcVolume.dispose();
    _ctrPrice.dispose();
    _fcPrice.dispose();
    images?.clear();
    _units.clear();
    _types.clear();
    super.dispose();
  }

  @override
  void initState() {
    bloc = MaterialBloc(typeInfo: 'material');
    super.initState();
    bloc!.stream.listen((state) {
      if (state is CreatePlanState && isResponseNotError(state.resp)) {
        final page = widget as MaterialDtlPage;
        page.funReload();
        if (page.detail.id < 0) {
          page.detail.id = state.resp.data.id;
          page.detail.name = state.resp.data.name;
        }
        UtilUI.showCustomDialog(context, 'Lưu thành công', title: 'Thông báo').whenComplete(() =>
          UtilUI.goBack(context, page.isSelect ? ItemModel(id: page.detail.id.toString(), name: page.detail.name) : null));
      } else if (state is DeletePlanState && isResponseNotError(state.resp, passString: true)) {
        (widget as MaterialDtlPage).funReload();
        UtilUI.goBack(context, true);
      } else if (state is DownloadFilesPostItemState) {
        loadFiles(state.response);
      } else if (state is LoadUnitState) {
        _units.addAll(state.list);
      } else if (state is LoadTypeState) {
        _types.addAll(state.list);
      } else if (state is LoadFarmDtlState && isResponseNotError(state.resp)) {
        final detail = (widget as MaterialDtlPage).detail;
        detail.copy(state.resp.data);
        _setData(detail);
      }
    });
    //_fcPrice.addListener(_listener);
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
          title: UtilUI.createLabel('Thông tin vật tư')),
      backgroundColor: Colors.white, body: Stack(children: [createUI(), Loading(bloc)]));

  @override
  Widget createUI() {
    final color = const Color(0XFFF5F6F8);
    final require = LabelCustom(' (*)', color: Colors.red, size: 36.sp, weight: FontWeight.normal);
    return Column(children: [
      Expanded(child: ListView(padding: EdgeInsets.symmetric(vertical: 40.sp), children: [
        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child:
          Row(children: [_title('Tên vật tư'), require,ShowInfo(bloc, "name")])),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 40.sp),
            child: TextFieldCustom(_ctrName, _fcName, _fcType, 'Nhập tên vật tư',
                size: 42.sp, color: color, borderColor: color, maxLine: 0,
                inputAction: TextInputAction.newline,
                type: TextInputType.multiline, padding: EdgeInsets.all(30.sp))),

        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child:
          Row(children: [_title('Loại vật tư'), require,ShowInfo(bloc, "material_type_name")])),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 40.sp),
            child: TextFieldCustom(_ctrType, _fcType, _fcCode, 'Chọn loại vật tư',
                size: 42.sp, color: color, borderColor: color, readOnly: true, maxLine: 0,
                inputAction: TextInputAction.newline, onPressIcon: _selectType,
                type: TextInputType.multiline, padding: EdgeInsets.all(30.sp),
                suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp))),

        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: Row(children: [
          Expanded(child: Column(children: [
            Row(children: [_title('Mã số'),ShowInfo(bloc, "code")]),
            SizedBox(height: 16.sp),
            TextFieldCustom(_ctrCode, _fcCode,
                _fcVolume, 'Nhập mã số', size: 42.sp, color: color, borderColor: color)
          ], crossAxisAlignment: CrossAxisAlignment.start)),
          const SizedBox(width: 10),
          Expanded(child: Column(children: [
            Row(children: [_title('Ngày nhập kho'), require]),
            SizedBox(height: 16.sp),
            TextFieldCustom(_ctrDate, _fcDate, _fcVolume, 'Chọn ngày',
                readOnly: true, size: 42.sp, color: color, borderColor: color,
                onPressIcon: _selectDate, suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp))
          ], crossAxisAlignment: CrossAxisAlignment.start))
        ])),

        Padding(padding: EdgeInsets.all(40.sp), child: Row(children: [
          Expanded(child: Column(children: [
            Row(children: [_title('SL/Khối lượng'), require,ShowInfo(bloc, "volume")]),
            SizedBox(height: 16.sp),
            TextFieldCustom(_ctrVolume, _fcVolume, _fcUnit, 'Nhập SL/khối lượng', size: 42.sp, type: TextInputType.number, isOdd: false,
                color: color, borderColor: color, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))])
          ], crossAxisAlignment: CrossAxisAlignment.start)),
          const SizedBox(width: 10),
          Expanded(child: Column(children: [
            Row(children: [_title('Đơn vị tính'), require,ShowInfo(bloc, "material_unit_name")]),
            SizedBox(height: 16.sp),
            TextFieldCustom(_ctrUnit, _fcUnit, _fcPrice,
                'Chọn đơn vị', size: 42.sp, color: color, borderColor: color, readOnly: true,
                onPressIcon: _selectUnit, suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp))
          ], crossAxisAlignment: CrossAxisAlignment.start))
        ])),

        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: Row(children: [_title('Đơn giá (VND)'), require,ShowInfo(bloc, "price")])),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 0),
            child: TextFieldCustom(_ctrPrice, _fcPrice, null, 'Nhập đơn giá', size: 42.sp, type: TextInputType.number, isOdd: false,
                color: color, borderColor: color, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))])),

        imageUI(_selectImage, _deleteImage)
      ])),

      const Divider(height: 0.5, color: Colors.black12),
      Padding(padding: EdgeInsets.all(40.sp), child: Row(children: [
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
    bloc!.add(LoadTypeEvent());
    setOnlyImage();
    multiSelect = true;
    images = [];
    final page = widget as MaterialDtlPage;
    page.isLoadDtl ? bloc!.add(LoadFarmDtlEvent(page.detail.id)) : _setData(page.detail);
  }

  void _setData(detail) {
    if (detail.id > 0) {
      _ctrName.text = detail.name;
      _ctrCode.text = detail.code;
      //if (detail.price > 0) _ctrPrice.text = detail.price.toInt().toString();
      if (detail.price > 0) _ctrPrice.text = Util.doubleToString(detail.price);
      //if (detail.volume > 0) _ctrVolume.text = detail.volume.toInt().toString();
      if (detail.volume > 0) _ctrVolume.text = Util.doubleToString(detail.volume);
      if (detail.warehouse_date.isNotEmpty) _ctrDate.text = Util.strDateToString(detail.warehouse_date, pattern: 'dd/MM/yyyy');
      if (detail.material_type_id > 0) _setType(ItemModel(id: detail.material_type_id.toString(), name: detail.material_type_name));
      if (detail.material_unit_id > 0) _setUnit(ItemModel(id: detail.material_unit_id.toString(), name: detail.material_unit_name));
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

  /*bool _hasFocus = false;
  void _listener() {
    if (_fcPrice.hasFocus) {
      if (_ctrPrice.text.isNotEmpty && !_hasFocus) {
        _hasFocus = true;
        _ctrPrice.text = _ctrPrice.text.replaceAll('.', '');
      }
    } else {
      _hasFocus = false;
      if (_ctrPrice.text.isNotEmpty) {
        double temp = .0;
        try {
          temp = double.parse(_ctrPrice.text);
        } catch (_) {}
        _ctrPrice.text = Util.doubleToString(temp);
      }
    }
  }*/

  void _selectImage() {
    clearFocus();
    selectImage([
      ItemModel(id: languageKey.lblCamera, name: MultiLanguage.get(languageKey.lblCamera)),
      ItemModel(id: languageKey.lblGallery, name: MultiLanguage.get(languageKey.lblGallery))
    ]);
  }

  void _deleteImage(int index) {
    clearFocus();
    images!.removeAt(index);
    bloc!.add(AddImageHomeEvent());
  }

  void _selectType() {
    clearFocus();
    UtilUI.showOptionDialog(context, 'Chọn loại vật tư', _types, '').then((value) => _setType(value));
  }

  void _setType(ItemModel? value) {
    if (value != null && _type.id != value.id) {
      _type.setValue(value.id, value.name);
      _ctrType.text = value.name;
    }
  }

  void _selectUnit() {
    clearFocus();
    UtilUI.showOptionDialog(context, 'Chọn đơn vị', _units, '').then((value) => _setUnit(value));
  }

  void _setUnit(ItemModel? value) {
    if (value != null && _unit.id != value.id) {
      _ctrUnit.text = value.name;
      _unit.setValue(value.id, value.name);
    }
  }

  void _selectDate() {
    clearFocus();
    clearFocus();
    String temp = _ctrDate.text;
    if (temp.isEmpty) {
      final now = DateTime.now();
      temp = '${now.day}/${now.month}/${now.year}';
    }
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        onConfirm: (DateTime date) => _ctrDate.text = Util.dateToString(date, pattern: 'dd/MM/yyyy'),
        currentTime: Util.stringToDateTime(temp, pattern: 'dd/MM/yyyy'), locale: LocaleType.vi);
  }

  void _save() {
    clearFocus();
    if (_ctrName.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, 'Nhập tên vật tư').whenComplete(() => _fcName.requestFocus());
      return;
    }
    if (_ctrType.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, 'Chọn loại vật tư').whenComplete(() => _fcType.requestFocus());
      return;
    }
    if (_ctrDate.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, 'Chọn ngày nhập kho').whenComplete(() => _fcDate.requestFocus());
      return;
    }
    if (_ctrVolume.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, 'Nhập khối lượng').whenComplete(() => _fcVolume.requestFocus());
      return;
    }
    if (_ctrUnit.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, 'Chọn đơn vị tính').whenComplete(() => _fcUnit.requestFocus());
      return;
    }
    if (_ctrPrice.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, 'Nhập đơn giá').whenComplete(() => _fcPrice.requestFocus());
      return;
    }

    bloc!.add(CreateMaterialEvent((widget as MaterialDtlPage).detail.id, _ctrName.text, _ctrCode.text, _type.id, _unit.id, TextFieldCustom.stringToDouble(_ctrPrice.text), TextFieldCustom.stringToDouble(_ctrVolume.text), _ctrDate.text, images!));
    //bloc!.add(CreateMaterialEvent((widget as MaterialDtlPage).detail.id, _ctrName.text, _ctrCode.text, _type.id, _unit.id, _ctrPrice.text.replaceAll('.', ''), _ctrVolume.text, images!));
  }

  void _delete() {
    clearFocus();
    final detail = (widget as MaterialDtlPage).detail;
    if (detail.id > 0) {
      UtilUI.showCustomDialog(context, 'Bạn có chắc muốn xoá vật tư này không?',
        isActionCancel: true).then((value) {
          if (value != null && value) bloc!.add(DeletePlanEvent(detail.id));
      });
    }
  }
}