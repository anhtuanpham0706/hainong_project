import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:hainong/common/models/file_byte.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/permission_image_page_state.dart';
import 'package:hainong/common/ui/show_popup_html.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import 'package:hainong/features/function/tool/nutrition_map/nutrition_location_page.dart';
import 'package:hainong/features/home/bloc/home_event.dart';
import 'package:hainong/features/post/bloc/post_item_bloc.dart';
import 'package:trackasia_gl/mapbox_gl.dart';
import '../mission_bloc.dart';

class MissionMineSubDetailPage extends BasePage {
  final dynamic parent, item;
  final Function? reload;
  final String addressExtend;
  final LatLng? addressLocation;
  final ItemModel? province, district;
  MissionMineSubDetailPage(this.parent, this.item, {this.reload, this.addressExtend = '',
    this.addressLocation, this.province, this.district, Key? key}) : super(pageState: _MissionMineSubDetailPageState(), key: key);
}

class _MissionMineSubDetailPageState extends PermissionImagePageState {
  final TextEditingController _ctrName = TextEditingController(), _ctrDes = TextEditingController(),
      _ctrStart = TextEditingController(), _ctrEnd = TextEditingController(), _ctrJoinNumber = TextEditingController(),
      _ctrProvince = TextEditingController(), _ctrDistrict = TextEditingController(), _ctrAddress = TextEditingController(),
      _ctrAcreage = TextEditingController(), _ctrPoint = TextEditingController(), _ctrCat = TextEditingController();
  final FocusNode _fcName = FocusNode(), _fcStart = FocusNode(), _fcEnd = FocusNode(), _fcDes = FocusNode(),
      _fcJoinNumber = FocusNode(), _fcProvince = FocusNode(), _fcDistrict = FocusNode(), _fcAddress = FocusNode(),
      _fcAcreage = FocusNode(), _fcPoint = FocusNode(), _fcCat = FocusNode();
  final List<ItemModel> _cats = [], _provinces = [], _districts = [];
  final ItemModel _cat = ItemModel(), _province = ItemModel(), _district = ItemModel();
  LatLng? _address;
  bool _isView = false;
  double _lat = .0,_lng = .0;

  @override
  void dispose() {
    _ctrName.dispose();
    _fcName.dispose();
    _ctrCat.dispose();
    _fcCat.dispose();
    _ctrStart.dispose();
    _fcStart.dispose();
    _ctrEnd.dispose();
    _fcEnd.dispose();
    _ctrDes.dispose();
    _fcDes.dispose();
    _ctrJoinNumber.dispose();
    _fcJoinNumber.dispose();
    _ctrProvince.dispose();
    _fcProvince.dispose();
    _ctrDistrict.dispose();
    _fcDistrict.dispose();
    _ctrAddress.dispose();
    _fcAddress.dispose();
    _ctrAcreage.dispose();
    _fcAcreage.dispose();
    _ctrPoint.dispose();
    _fcPoint.dispose();
    _provinces.clear();
    _districts.clear();
    _cats.clear();
    super.dispose();
  }

  @override
  void showLoadingPermission({bool value = true}) => bloc!.add(LoadingEvent(value));

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
  void initState() {
    bloc = MissionBloc('mine_sub_detail',typeInfo: 'mission_detail');
    bloc!.stream.listen((state) {
      if (state is LoadCatalogueState) {
        _cats.addAll(state.resp);
      } else if (state is LoadProvinceState) {
        _provinces.addAll(state.list);
      } else if (state is LoadDistrictState) {
        _districts.addAll(state.list);
      } else if (state is GetAddressState) {
        final json = state.address;
        final hasPro = Util.checkKeyFromJson(json, 'province_id');
        _setProvince(hasPro ? ItemModel(id: json['province_id'].toString(), name: json['province_name']) : ItemModel(), loadDistrict: hasPro);
        _setDistrict(Util.checkKeyFromJson(json, 'district_id') ? ItemModel(id: json['district_id'].toString(), name: json['district_name']) : ItemModel());
        _ctrAddress.text = Util.checkKeyFromJson(json, 'address_full') ? json['address_full'] : '';
      } else if (state is GetLocationState) {
        try {
            double lat = double.parse((state.latLng['lat']?? _lat).toString());
            double lng = double.parse((state.latLng['lng']?? _lng).toString());
            _address = LatLng(lat, lng);
        } catch (_) {}
      } else if (state is DownloadFilesPostItemState) {
        loadFiles(state.response);
      } else if (state is SaveMissionState && isResponseNotError(state.resp, passString: true)) {
        final page = widget as MissionMineSubDetailPage;
        if (page.reload != null) page.reload!();
        String msg = 'Lưu thành công';
        if (state.status == 'completed') msg = 'Kết thúc nhiệm vụ thành công';
        UtilUI.showCustomDialog(context, msg).whenComplete(() => UtilUI.goBack(context, true));
      }
    });
    _initData();
    super.initState();

    //bloc!.add(LoadCatalogueEvent());
    bloc!.add(LoadProvinceEvent());
    if (_ctrAddress.text.trim().isNotEmpty) bloc!.add(GetLocationEvent(_ctrAddress.text.trim()));
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    final colorTitle = const Color(0XFFF5F6F8);
    final require = LabelCustom(' (*)', color: Colors.red, size: 36.sp, weight: FontWeight.normal);
    final item = (widget as MissionMineSubDetailPage).item;
    return Stack(children: [
      Scaffold(appBar: AppBar(elevation: 0, titleSpacing: 0, centerTitle: true, title: UtilUI.createLabel('Chi tiết nhiệm vụ con'),
          actions: [IconButton(onPressed: clearFocus, icon: Icon(Icons.keyboard, color: Colors.white, size: 48.sp))]),
          backgroundColor: color, body:
            Column(children: [
            Expanded(child: ListView(padding: EdgeInsets.all(40.sp), children: [
              Row(children: [_title('Tên nhiệm vụ con'), require,ShowInfo(bloc, "title")]),
              Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp), child: TextFieldCustom(_ctrName,
                  _fcName, null, 'Nhập tên nhiệm vụ', size: 42.sp, color: colorTitle, readOnly: _isView,
                  borderColor: colorTitle, maxLine: 0, inputAction: TextInputAction.newline,
                  type: TextInputType.multiline, padding: EdgeInsets.all(30.sp))),

              /*Row(children: [_title('Danh mục nhiệm vụ'), require]),
              Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
                  child: TextFieldCustom(_ctrCat, _fcCat, null, 'Chọn danh mục nhiệm vụ',
                      size: 42.sp, color: colorTitle, borderColor: colorTitle, readOnly: true,
                      onPressIcon: _selectCat, maxLine: 0, inputAction: TextInputAction.newline,
                      type: TextInputType.multiline, padding: EdgeInsets.all(30.sp),
                      suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp))),*/

              _title('Mô tả tổng quát'),
              Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp), child: TextFieldCustom(_ctrDes,
                  _fcDes, null, 'Nhập mô tả ...', size: 42.sp, color: colorTitle, readOnly: _isView,
                  borderColor: colorTitle, maxLine: 0, inputAction: TextInputAction.newline,
                  type: TextInputType.multiline, padding: EdgeInsets.all(30.sp))),

              Row(children: [_title('Thời gian thực hiện nhiệm vụ con'), require]),
              SizedBox(height: 16.sp),
              Row(children: [
                Expanded(child: Column(children: [
                  Row(children: [_title('Bắt đầu', style: FontStyle.italic), ShowInfo(bloc, "start_date")
                    ],),
                  Padding(child: TextFieldCustom(_ctrStart, _fcStart, null, 'dd/MM/yyyy', size: 42.sp,
                      color: colorTitle, borderColor: colorTitle, readOnly: true, onPressIcon: _selectDate,
                      suffix: Icon(Icons.calendar_today, color: Colors.grey, size: 48.sp)), padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp))
                ], crossAxisAlignment: CrossAxisAlignment.start)),
                const SizedBox(width: 10),
                Expanded(child: Column(children: [
                  Row(children: [_title('Kết thúc', style: FontStyle.italic),ShowInfo(bloc, "end_date")],),
                  Padding(child: TextFieldCustom(_ctrEnd, _fcEnd, null, 'dd/MM/yyyy', size: 42.sp,
                      color: colorTitle, borderColor: colorTitle, readOnly: true, onPressIcon: () => _selectDate(isStart: false),
                      suffix: Icon(Icons.calendar_today, color: Colors.grey, size: 48.sp)), padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp))
                ], crossAxisAlignment: CrossAxisAlignment.start))
              ]),

              Row(children: [_title('Số người tham gia nhiệm vụ con'), require,ShowInfo(bloc, "number_joins")]),
              Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 35.sp), child: TextFieldCustom(_ctrJoinNumber, _fcJoinNumber, _fcProvince,
                  'Nhập số người tham gia', size: 42.sp, color: colorTitle, readOnly: _isView, borderColor: colorTitle,
                  type: TextInputType.number, isOdd: false,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))])),

              Row(
                children: [
                  _title('Địa chỉ'),
                  SizedBox(width: 30.sp,),
                if(!_isView)  ButtonImageWidget(16.sp, (){ _setExtendAddress();},
                      Container(padding: EdgeInsets.all(22.sp), child: LabelCustom('Lấy nhanh',
                          color: Colors.white, size: 42.sp, weight: FontWeight.normal, align: TextAlign.center)), color: StyleCustom.primaryColor),
                  ShowInfo(bloc, "address"),
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 32.sp, bottom: 40.sp), child: Row(children: [
                Expanded(child:
                    TextFieldCustom(_ctrAddress, _fcAddress, null, 'Nhập địa chỉ', size: 42.sp,
                    color: colorTitle, borderColor: colorTitle, readOnly: _isView, maxLine: 0, inputAction: TextInputAction.newline,
                    type: TextInputType.multiline, padding: EdgeInsets.all(30.sp)),),
                SizedBox(width: 20.sp),
                ButtonImageWidget(5, _openMap, Image.asset('assets/images/v5/ic_map_main2.png',
                    width: 128.sp, height: 128.sp, fit: BoxFit.scaleDown))
              ])),

              Row(children: [
                Expanded(child: Column(children: [
                  Row(children: [_title('Tình/ Thành phố'), require]),
                  Padding(child: TextFieldCustom(_ctrProvince, _fcProvince, null, 'Chọn tình/ Thành phố', size: 42.sp,
                      color: colorTitle, borderColor: colorTitle, readOnly: true, onPressIcon: _selectProvince,
                      type: TextInputType.multiline, inputAction: TextInputAction.newline, maxLine: 0,
                      suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp),
                      padding: EdgeInsets.all(30.sp)), padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp))
                ], crossAxisAlignment: CrossAxisAlignment.start)),
                const SizedBox(width: 10),
                Expanded(child: Column(children: [
                  Row(children: [_title('Quận/ Huyện'), require]),
                  Padding(child: TextFieldCustom(_ctrDistrict, _fcDistrict, null, 'Chọn quận/ Huyện', size: 42.sp,
                      color: colorTitle, borderColor: colorTitle, readOnly: true, onPressIcon: _selectDistrict,
                      type: TextInputType.multiline, inputAction: TextInputAction.newline, maxLine: 0,
                      suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp),
                      padding: EdgeInsets.all(30.sp)), padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp))
                ], crossAxisAlignment: CrossAxisAlignment.start))
              ], crossAxisAlignment: CrossAxisAlignment.start),

              Row(children: [
                Expanded(child: Column(children: [
                  Row(children: [_title('DT canh tác (m2)'), require,ShowInfo(bloc, "acreage"),]),
                  Padding(child: TextFieldCustom(_ctrAcreage, _fcAcreage, _fcPoint, 'Nhập diện tích', size: 42.sp, color: colorTitle,
                      type: TextInputType.number, isOdd: false,
                      borderColor: colorTitle, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))]),
                      padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp))
                ], crossAxisAlignment: CrossAxisAlignment.start)),
                const SizedBox(width: 10),
                Expanded(child: Column(children: [
                  Row(children: [_title('Điểm thưởng NV'), require,ShowInfo(bloc, "point")]),
                  Padding(child: TextFieldCustom(_ctrPoint, _fcPoint, null, 'Nhập điểm thưởng', size: 42.sp, color: colorTitle,
                      type: TextInputType.number, isOdd: false,
                      borderColor: colorTitle, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))]),
                      padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp))
                ], crossAxisAlignment: CrossAxisAlignment.start))
              ]),

              imageUI(_selectImage, _deleteImage, padding: 0)
            ])),

            const Divider(height: 0.5, color: Colors.black12),
            if (!_isView) Padding(padding: EdgeInsets.all(40.sp), child: Row(children: [
              if (item != null) ButtonImageWidget(16.sp, _complete,
                  Container(padding: EdgeInsets.all(40.sp), width: 0.5.sw - 60.sp, child: LabelCustom('Kết thúc NV',
                      color: Colors.white, size: 48.sp, weight: FontWeight.normal, align: TextAlign.center)), color: Colors.black26),
              ButtonImageWidget(16.sp, _save,
                  Container(padding: EdgeInsets.all(40.sp), width: item == null ? 1.sw - 80.sp : 0.5.sw - 60.sp, child: LabelCustom('Lưu',
                      color: Colors.white, size: 48.sp, weight: FontWeight.normal, align: TextAlign.center)), color: StyleCustom.primaryColor)
            ], mainAxisAlignment: MainAxisAlignment.spaceBetween))
          ]),),
      Loading(bloc)
    ]);
  }

  Widget _title(String title, {FontStyle style = FontStyle.normal}) => LabelCustom(title, color: const Color(0xFF787878), size: 36.sp, weight: FontWeight.normal, style: style);

  void _initData() {
    setOnlyImage();
    multiSelect = true;
    images = [];
    final item = (widget as MissionMineSubDetailPage).item;
    if (item != null) {
      _isView = (item['work_status']??'pending') == 'completed';

      final images = item['images']??[];
      if (images.isNotEmpty) {
        showLoadingPermission();
        final List<ItemModel> list = [];
        for (var ele in images) {
          list.add(ItemModel(name: ele['name']??''));
        }
        bloc!.add(DownloadFilesPostItemEvent(list));
      }

      String temp = item['start_date']??'';
      if (temp.isNotEmpty) {
        try {
          _ctrStart.text = Util.strDateToString(temp, pattern: 'dd/MM/yyyy');
        } catch (_) {}
      }
      temp = item['end_date']??'';
      if (temp.isNotEmpty) {
        try {
          _ctrEnd.text = Util.strDateToString(temp, pattern: 'dd/MM/yyyy');
        } catch (_) {}
      }
      _setCat(ItemModel(id: (item['mission_catalogue_id']??'').toString(), name: item['mission_catalogue_name']??''));
      _setProvince(ItemModel(id: (item['province_id']??'').toString(), name: item['province_name']??''), loadDistrict: false);
      _setDistrict(ItemModel(id: (item['district_id']??'').toString(), name: item['district_name']??''));

      _ctrName.text = item['title']??'';
      _ctrDes.text = item['content']??'';
      _ctrAddress.text = item['address']??'';
      _ctrPoint.text = Util.doubleToString((item['point']??0).toDouble());
      _ctrAcreage.text = Util.doubleToString((item['acreage']??.0).toDouble());
      _ctrJoinNumber.text = Util.doubleToString((item['number_joins']??0).toDouble());
    } else {
      final parent = (widget as MissionMineSubDetailPage).parent;
      _setCat(ItemModel(id: (parent['mission_catalogue_id']??'').toString(), name: parent['mission_catalogue_name']??''));
    }
  }

  void _setExtendAddress() {
    final page = widget as MissionMineSubDetailPage;
    _ctrAddress.text = page.addressExtend;
    _address = page.addressLocation;
    _setProvince(page.province != null ? page.province! : ItemModel(), loadDistrict: false);
    _setDistrict(page.district != null ? page.district! : ItemModel());
  }

  void _selectCat() {
    if (_isView) return;
    UtilUI.showOptionDialog(context, 'Chọn danh mục nhiệm vụ', _cats, _cat.id).then((value) {
      if (value != null) _setCat(value);
    });
  }

  void _setCat(ItemModel value) {
    if (_cat.id != value.id) {
      _ctrCat.text = value.name;
      _cat.setValue(value.id, value.name);
    }
  }

  void _selectDate({bool isStart = true}) {
    if (_isView) return;
    clearFocus();
    final parent = (widget as MissionMineSubDetailPage).parent;
    DateTime min = Util.stringToDateTime(parent['start_date']),
        max = Util.stringToDateTime(parent['end_date']);
    String temp = isStart ? _ctrStart.text : _ctrEnd.text;
    if (temp.isEmpty) {
      final now = DateTime.now();
      temp = '${now.day}/${now.month}/${now.year}';
    }
    DatePicker.showDatePicker(context,
        minTime: min,
        maxTime: max,
        showTitleActions: true,
        onConfirm: (DateTime date) => _setDate(date, isStart),
        currentTime: Util.stringToDateTime(temp, pattern: 'dd/MM/yyyy'),
        locale: LocaleType.vi);
  }

  void _setDate(DateTime date, bool isStart) {
    if (isStart) {
      if (_ctrEnd.text.isNotEmpty) {
        DateTime end = Util.stringToDateTime(_ctrEnd.text, pattern: 'dd/MM/yyyy');
        if (date.compareTo(end) > 0) return;
      }
    } else {
      if (_ctrStart.text.isNotEmpty) {
        DateTime start = Util.stringToDateTime(_ctrStart.text, pattern: 'dd/MM/yyyy');
        if (date.compareTo(start) < 0) return;
      }
    }
    String temp = Util.dateToString(date, pattern: 'dd/MM/yyyy');
    isStart ? _ctrStart.text = temp : _ctrEnd.text = temp;
  }

  void _selectProvince() {
    if (_isView) return;
    UtilUI.showOptionDialog(context, 'Chọn tỉnh/ Thành phố', _provinces, _province.id).then((value) {
      if (value != null) _setProvince(value);
    });
  }

  void _setProvince(ItemModel value, {bool loadDistrict = true}) {
    if (_province.id != value.id) {
      _ctrProvince.text = value.name;
      _province.setValue(value.id, value.name);

      if (loadDistrict) {
        _districts.clear();
        _ctrDistrict.text = '';
        _district.setValue('', '');
        bloc!.add(LoadDistrictEvent(_province.id));
      }
    }
  }

  void _selectDistrict() {
    if (_isView) return;
    UtilUI.showOptionDialog(context, 'Chọn quận/ Huyện', _districts, _district.id).then((value) {
      if (value != null) _setDistrict(value);
    });
  }

  void _setDistrict(ItemModel value) {
    if (_district.id != value.id) {
      _ctrDistrict.text = value.name;
      _district.setValue(value.id, value.name);
    }
  }

  void _openMap() {
    if (_isView) return;
    UtilUI.goToNextPage(context, NutritionLocPage(current: _address,), funCallback: (value) {
     _setAddress(value);
    });
  }

  void _setAddress(LatLng value) {
    _address = value;
    bloc!.add(GetAddressEvent(value));
  }

  void _selectImage() {
    if (_isView) return;
    clearFocus();
    selectImage([
      ItemModel(id: languageKey.lblCamera, name: MultiLanguage.get(languageKey.lblCamera)),
      ItemModel(id: languageKey.lblGallery, name: MultiLanguage.get(languageKey.lblGallery))
    ]);
  }

  void _deleteImage(int index) {
    if (_isView) return;
    clearFocus();
    images!.removeAt(index);
    bloc!.add(AddImageHomeEvent());
  }

  void _save() {
    clearFocus();
    if (_ctrName.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, 'Nhập tên nhiệm vụ con').whenComplete(() => _fcName.requestFocus());
      return;
    }
    if (_ctrStart.text.isEmpty) {
      UtilUI.showCustomDialog(context, 'Chọn ngày bắt đầu thực hiện nhiệm vụ').whenComplete(() => _fcStart.requestFocus());
      return;
    }
    if (_ctrEnd.text.isEmpty) {
      UtilUI.showCustomDialog(context, 'Chọn ngày kết thúc thực hiện nhiệm vụ').whenComplete(() => _fcEnd.requestFocus());
      return;
    }
    if (_ctrProvince.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, 'Chọn tỉnh/ Thành phố').whenComplete(() => _fcProvince.requestFocus());
      return;
    }
    if (_ctrDistrict.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, 'Chọn quận/ Huyện').whenComplete(() => _fcDistrict.requestFocus());
      return;
    }
    if (_ctrJoinNumber.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, 'Nhập số người tham gia').whenComplete(() => _fcJoinNumber.requestFocus());
      return;
    }
    if (_ctrAcreage.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, 'Nhập diện tích').whenComplete(() => _fcAcreage.requestFocus());
      return;
    }
    if (_ctrPoint.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, 'Nhập điểm thưởng').whenComplete(() => _fcPoint.requestFocus());
      return;
    }
    final page = widget as MissionMineSubDetailPage;
    bloc!.add(SaveMissionEvent(page.item != null ? (page.item['id']??-1) : -1, _ctrName.text, _cat.id,
      _ctrStart.text, _ctrEnd.text, _ctrDes.text, _province.id, _district.id, _ctrAddress.text,
      acreage: TextFieldCustom.stringToDouble(_ctrAcreage.text, isOdd: true), images: images, idParent: page.parent['id'],
      point: TextFieldCustom.stringToDouble(_ctrPoint.text), joinNumber: TextFieldCustom.stringToDouble(_ctrJoinNumber.text)));
  }

  void _complete() => UtilUI.showCustomDialog(context, 'Bạn có chắc muốn kết thúc nhiệm vụ con này không?', isActionCancel: true).then((value) {
    if (value != null && value) {
      final page = widget as MissionMineSubDetailPage;
      bloc!.add(SaveMissionEvent(page.item['id']??-1, '', '', '', '', '', '', '', '', status: 'completed', idParent: page.parent['id']));
    }
  });
}