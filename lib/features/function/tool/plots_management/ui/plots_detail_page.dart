import 'dart:io';
import 'package:flutter/services.dart';
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
import 'package:hainong/features/function/tool/plots_management/ui/plots_map_page.dart';
import 'package:hainong/features/home/bloc/home_bloc.dart';
import 'package:hainong/features/home/bloc/home_event.dart';
import 'package:hainong/features/post/bloc/post_item_bloc.dart';
import 'package:hainong/features/profile/profile_bloc.dart';
import 'package:hainong_chat_call_module/presentation/pages/expert_page.dart';
import '../plots_management_bloc.dart';

class PlotsDtlPage extends BasePage {
  final PlotsManageModel detail;
  final Function funReload;
  final bool isSelect;
  PlotsDtlPage(this.detail, this.funReload, {this.isSelect = false, Key? key}) : super(pageState: _PlotsDtlPageState(), key: key);
}

class _PlotsDtlPageState extends PermissionImagePageState {
  final TextEditingController _ctrName = TextEditingController(), _ctrAcreage = TextEditingController(),
      _ctrExpert = TextEditingController(), _ctrTree = TextEditingController(),
      _ctrProvince = TextEditingController(), _ctrDistrict = TextEditingController(),
      _ctrAddress = TextEditingController(), _ctrLocation = TextEditingController(),
      _ctrContent = TextEditingController(), _ctrOwner = TextEditingController();
  final FocusNode _fcName = FocusNode(), _fcOwner = FocusNode(),
      _fcAcreage = FocusNode(), _fcExpert = FocusNode(),
      _fcProvince = FocusNode(), _fcDistrict = FocusNode(),
      _fcAddress = FocusNode(), _fcLocation = FocusNode(),
      _fcTree = FocusNode(), _fcContent = FocusNode();
  final ItemModel _province = ItemModel(id: '-1'), _district = ItemModel(id: '-1'), _expert = ItemModel(id: '-1');
  final List<ItemModel> _provinces = [], _districts = [];
  bool _lock = false;

  @override
  void dispose() {
    _ctrName.dispose();
    _fcName.dispose();
    _ctrOwner.dispose();
    _fcOwner.dispose();
    _ctrAcreage.dispose();
    _fcAcreage.dispose();
    _ctrExpert.dispose();
    _fcExpert.dispose();
    _ctrTree.dispose();
    _fcTree.dispose();
    _ctrContent.dispose();
    _fcContent.dispose();
    _ctrProvince.dispose();
    _fcProvince.dispose();
    _ctrDistrict.dispose();
    _fcDistrict.dispose();
    _ctrAddress.dispose();
    _fcAddress.dispose();
    _ctrLocation.dispose();
    _fcLocation.dispose();
    images?.clear();
    _provinces.clear();
    _districts.clear();
    super.dispose();
  }

  @override
  void initState() {
    bloc = PlotsManagementBloc(typeInfo: 'culture_plot');
    super.initState();
    bloc!.stream.listen((state) {
      if (state is CreatePlanState && isResponseNotError(state.resp)) {
        final page = widget as PlotsDtlPage;
        page.funReload();
        if (page.detail.id < 0) {
          page.detail.id = state.resp.data.id;
          page.detail.title = state.resp.data.title;
        }
        UtilUI.showCustomDialog(context, 'Lưu thành công', title: 'Thông báo').whenComplete(() =>
          UtilUI.goBack(context, page.isSelect ? ItemModel(id: page.detail.id.toString(), name: page.detail.title) : true));
      } else if (state is DeletePlanState && isResponseNotError(state.resp, passString: true)) {
        (widget as PlotsDtlPage).funReload();
        UtilUI.goBack(context, true);
      } else if (state is DownloadFilesPostItemState) {
        loadFiles(state.response);
      } else if (state is LoadProvinceProfileState) {
        _provinces.addAll(state.response);
      } else if (state is LoadDistrictProfileState) {
        _districts.addAll(state.response);
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
          actions: _lock ? null : [
            IconButton(onPressed: clearFocus, icon: Icon(Icons.keyboard, color: Colors.white, size: 48.sp))
          ],
          title: UtilUI.createLabel('Thông tin lô thửa')),
      backgroundColor: Colors.white, body: Stack(children: [createUI(), Loading(bloc)]));

  @override
  Widget createUI() {
    final color = const Color(0XFFF5F6F8);
    final require = LabelCustom(' (*)', color: Colors.red, size: 36.sp, weight: FontWeight.normal);
    return Column(children: [
      Expanded(child: ListView(padding: EdgeInsets.symmetric(vertical: 40.sp), children: [
        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child:
          Row(children: [_title('Tên lô thửa'), require,ShowInfo(bloc, "title")])),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 40.sp),
            child: TextFieldCustom(_ctrName, _fcName, _fcAcreage, 'Nhập tên lô thửa',
                size: 42.sp, color: color, borderColor: color, maxLine: 0,
                inputAction: TextInputAction.newline, readOnly: _lock,
                type: TextInputType.multiline, padding: EdgeInsets.all(30.sp))),

        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child:
          Row(children: [_title('Diện tích (m2)'), require,ShowInfo(bloc, "acreage")])),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 40.sp),
            child: TextFieldCustom(_ctrAcreage, _fcAcreage, _fcOwner, 'Nhập diện tích lô đất', size: 42.sp, readOnly: _lock,
                color: color, borderColor: color, type: TextInputType.number, isOdd: true,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^([0-9])*([.])?([0-9]?)*$'))])),

        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: _title('Số điện thoại người quản lý')),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 40.sp), child: TextFieldCustom(_ctrOwner, _fcOwner,
            _fcExpert, 'Nhập số điện thoại người quản lý', size: 42.sp, color: color, borderColor: color, readOnly: _lock,
            type: TextInputType.phone, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))]
        )),

        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: _title('Chuyên gia tư vấn (nếu có)')),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 40.sp),
            child: TextFieldCustom(_ctrExpert, _fcExpert, _fcTree, 'Chọn danh sách chuyên gia tư vấn',
                size: 42.sp, color: color, borderColor: color, readOnly: true, maxLine: 0,
                inputAction: TextInputAction.newline, onPressIcon: _selectExpert,
                type: TextInputType.multiline, padding: EdgeInsets.all(30.sp),
                suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp))),

        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: Row(children: [_title('Loại cây'),ShowInfo(bloc, "family_tree")],
        )),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 40.sp), child: TextFieldCustom(_ctrTree, _fcTree,
            _fcProvince, 'Nhập loại cây trồng', size: 42.sp, color: color, borderColor: color, maxLine: 0, readOnly: _lock,
            inputAction: TextInputAction.newline, type: TextInputType.multiline, padding: EdgeInsets.all(30.sp))),

        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: _title('Tỉnh thành')),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 40.sp),
            child: TextFieldCustom(_ctrProvince, _fcProvince, _fcDistrict, 'Chọn tỉnh thành',
                size: 42.sp, color: color, borderColor: color, readOnly: true, maxLine: 0,
                inputAction: TextInputAction.newline, onPressIcon: _selectProvince,
                type: TextInputType.multiline, padding: EdgeInsets.all(30.sp),
                suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp))),

        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: _title('Quận huyện')),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 40.sp),
            child: TextFieldCustom(_ctrDistrict, _fcDistrict, _fcAddress, 'Chọn quận huyện',
                size: 42.sp, color: color, borderColor: color, readOnly: true, maxLine: 0,
                inputAction: TextInputAction.newline, onPressIcon: _selectDistrict,
                type: TextInputType.multiline, padding: EdgeInsets.all(30.sp),
                suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp))),

        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: Row(children: [_title('Địa chỉ'),ShowInfo(bloc, "address")],
        )),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 40.sp),
            child: TextFieldCustom(_ctrAddress, _fcAddress, _fcContent, 'Nhập số nhà, tên đường', size: 42.sp,
                color: color, borderColor: color, maxLine: 0, inputAction: TextInputAction.newline, readOnly: _lock,
                type: TextInputType.multiline, padding: EdgeInsets.all(30.sp))),

        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: _title('Toạ độ vị trí')),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 40.sp),
            child: TextFieldCustom(_ctrLocation, _fcLocation, _fcContent, 'Toạ độ lô đất', size: 42.sp,
                color: color, borderColor: color, readOnly: true, onPressIcon: _selectLocation,
                suffix: Padding(padding: EdgeInsets.all(30.sp), child: Image.asset('assets/images/v5/ic_map_main2.png',
                    width: 24.sp, height: 24.sp, fit: BoxFit.scaleDown)))),

        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: _title('Thông tin thêm')),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 0),
            child: TextFieldCustom(_ctrContent, _fcContent, null, 'Nhập thông tin thêm về lô đất ...', size: 42.sp,
                color: color, borderColor: color, maxLine: 0, inputAction: TextInputAction.newline, readOnly: _lock,
                type: TextInputType.multiline, padding: EdgeInsets.all(30.sp))),

        imageUI(_selectImage, _deleteImage)
      ])),

      const Divider(height: 0.5, color: Colors.black12),
      if (!_lock) Padding(padding: EdgeInsets.all(40.sp), child: Row(children: [
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

  void _initData() async {
    bloc!.add(LoadProvinceProfileEvent());
    setOnlyImage();
    multiSelect = true;
    images = [];
    final detail = (widget as PlotsDtlPage).detail;
    if (detail.id > 0) {
      if (detail.images.isNotEmpty) {
        showLoadingPermission();
        final List<ItemModel> list = [];
        for (var ele in detail.images) {
          list.add(ItemModel(name: ele));
        }
        bloc!.add(DownloadFilesPostItemEvent(list));
      }
      _ctrName.text = detail.title;
      _ctrOwner.text = detail.office_name;
      _ctrContent.text = detail.content;
      _ctrTree.text = detail.family_tree;
      _ctrAddress.text = detail.address;
      //_ctrAcreage.text = detail.acreage.toString();
      _ctrAcreage.text = Util.doubleToString(detail.acreage, digit: 3);
      if (detail.expert_id > 0) _setExpert(ItemModel(id: detail.expert_id.toString(), name: detail.expert_name));
      if (detail.province_id > 0) _setProvince(ItemModel(id: detail.province_id.toString(), name: detail.province_name));
      if (detail.district_id > 0) _setDistrict(ItemModel(id: detail.district_id.toString(), name: detail.district_name));
      if (detail.latitude * detail.longitude != 0) _ctrLocation.text = '${detail.latitude} - ${detail.longitude}';

      final prefs = await SharedPreferences.getInstance();
      if ((prefs.getInt('id')??-1) != detail.user_id) {
        setState(() {
          _lock = true;
        });
      }
    }
  }

  void _selectImage() {
    if (_lock) return;
    clearFocus();
    selectImage([
      ItemModel(id: languageKey.lblCamera, name: MultiLanguage.get(languageKey.lblCamera)),
      ItemModel(id: languageKey.lblGallery, name: MultiLanguage.get(languageKey.lblGallery))
    ]);
  }

  void _deleteImage(int index) {
    if (_lock) return;
    clearFocus();
    images!.removeAt(index);
    bloc!.add(AddImageHomeEvent());
  }

  void _selectExpert() {
    if (_lock) return;
    constants.isLogin ? UtilUI.goToNextPage(context, ExpertPage(isSelectExpert: true),
        funCallback: _setExpert) : UtilUI.showDialogTimeout(context, message: MultiLanguage.get('msg_login_create_account'));
  }

  void _setExpert(value) {
    if (value != null && _expert.id != value.id.toString()) {
      _expert.setValue(value.id.toString(), value.name);
      _ctrExpert.text = value.name;
    }
  }

  void _selectProvince() {
    if (_lock) return;
    clearFocus();
    UtilUI.showOptionDialog(context, 'Chọn tỉnh thành', _provinces, '').then((value) => _setProvince(value));
  }

  void _setProvince(ItemModel? value) {
    if (value != null && _province.id != value.id) {
      _province.setValue(value.id, value.name);
      _ctrProvince.text = value.name;
      _districts.clear();
      _setDistrict(ItemModel(id: '-1'));
      bloc!.add(LoadDistrictProfileEvent(_province.id));
    }
  }

  void _selectDistrict() {
    if (_lock) return;
    clearFocus();
    if (_districts.isEmpty) bloc!.add(LoadDistrictProfileEvent(_province.id));
    else UtilUI.showOptionDialog(context, 'Chọn quận huyện', _districts, '').then((value) => _setDistrict(value));
  }

  void _setDistrict(ItemModel? value) {
    if (value != null && _district.id != value.id) {
      _ctrDistrict.text = value.name;
      _district.setValue(value.id, value.name);
    }
  }

  void _selectLocation() {
    final detail = (widget as PlotsDtlPage).detail;
    detail.id > 0 ? UtilUI.goToNextPage(context, PlotsMapPage(detail, _ctrLocation, lock: _lock), funCallback: _setLocation) :
      UtilUI.showCustomDialog(context, 'Bạn phải lưu thông tin lô thửa trước, sau đó mới có thể lấy thông tin toạ độ từ bản đồ');
  }

  void _setLocation(value) {
    if (value != null) {
      double lat = .0, long = .0;
      if (_ctrLocation.text.isNotEmpty) {
        try {
          final array = _ctrLocation.text.split('-');
          lat = double.parse(array[0].trim());
          long = double.parse(array[1].trim());
        } catch (_) {}
      }
      try {
        if (lat != double.parse(value.id) || long != double.parse(value.name)) _ctrLocation.text = value.id + ' - ' + value.name;
      } catch (_) {}
    }
  }

  void _save() {
    clearFocus();
    if (_ctrName.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, 'Nhập tên lô thửa').whenComplete(() => _fcName.requestFocus());
      return;
    }
    if (_ctrAcreage.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, 'Nhập diện tích lô đất').whenComplete(() => _fcAcreage.requestFocus());
      return;
    }

    bloc!.add(CreatePlotsEvent((widget as PlotsDtlPage).detail.id, _ctrName.text, _ctrTree.text, _ctrOwner.text, _ctrAddress.text,
      _ctrContent.text, _ctrLocation.text, TextFieldCustom.stringToDouble(_ctrAcreage.text, isOdd: true), _expert.id, _province.id, _district.id, images!));
  }

  void _delete() {
    clearFocus();
    final detail = (widget as PlotsDtlPage).detail;
    if (detail.id > 0) {
      UtilUI.showCustomDialog(context, 'Bạn có chắc muốn xoá lô thửa này không?',
        isActionCancel: true).then((value) {
          if (value != null && value) bloc!.add(DeletePlanEvent(detail.id));
      });
    }
  }
}