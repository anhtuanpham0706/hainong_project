import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import 'package:hainong/features/function/info_news/weather/weather_bloc.dart';
import 'package:hainong/features/function/support/handbook/handbook_bloc.dart';
import 'nutrition_location_page.dart';
import 'package:hainong/features/profile/profile_bloc.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/features/main/bloc/main_bloc.dart';
import 'package:trackasia_gl/mapbox_gl.dart';
import 'nutrition_map_bloc.dart';

class NutritionContributePage extends BasePage {
  final List<ItemModel> provinces;
  NutritionContributePage({required this.provinces, Key? key}) : super(pageState: _NuConPageState(), key: key);
}

class _NuConPageState extends BasePageState {
  final TextEditingController _ctrHarvest = TextEditingController(), _ctrDesHar = TextEditingController(),
      _ctrTree = TextEditingController(), _ctrDesTree = TextEditingController(),
      _ctrAddress = TextEditingController(), _ctrNutrition = TextEditingController(),
      _ctrSalinity = TextEditingController(), _ctrPH = TextEditingController(),
      _ctrN = TextEditingController(), _ctrP = TextEditingController(),
      _ctrK = TextEditingController(), _ctrS = TextEditingController(),
      _ctrCa = TextEditingController(), _ctrOrganic = TextEditingController(),
      _ctrProvince = TextEditingController(), _ctrDistrict = TextEditingController(),
      _ctrLat = TextEditingController(), _ctrLng = TextEditingController();
  final List<ItemModel> _provinces = [], _districts = [], _harvests = [], _trees = [], _nutrition = [];
  final ItemModel _province = ItemModel(), _district = ItemModel();
  final color = const Color(0XFFF5F6F8);
  bool _isClose = false, _isShowSnack = false, _changeAddress = false;

  @override
  void dispose() {
    if (_isClose) super.dispose();
    else {
      _isClose = true;
      _provinces.clear();
      _districts.clear();
      _harvests.clear();
      _trees.clear();
      _nutrition.clear();
      _ctrProvince.dispose();
      _ctrDistrict.dispose();
      _ctrLat.dispose();
      _ctrLng.dispose();
      _ctrAddress.dispose();
      _ctrTree.dispose();
      _ctrDesTree.dispose();
      _ctrHarvest.dispose();
      _ctrDesHar.dispose();
      _ctrNutrition.dispose();
      _ctrSalinity.dispose();
      _ctrPH.dispose();
      _ctrN.dispose();
      _ctrP.dispose();
      _ctrK.dispose();
      _ctrS.dispose();
      _ctrCa.dispose();
      _ctrOrganic.dispose();
      UtilUI.goBack(context, true);
    }
  }

  @override
  void initState() {
    final pro = (widget as NutritionContributePage).provinces;
    if (pro.length > 1) _provinces.addAll(pro.sublist(1, pro.length));
    bloc = NutritionMapBloc();
    bloc!.stream.listen((state) {
      if (state is LoadProvinceProfileState) {
        _provinces.addAll(state.response.data.list);
      } else if (state is LoadDistrictProfileState) {
        _districts.addAll(state.response.data.list);
      } else if (state is LoadListNameState) {
        _harvests.addAll(state.list[0]);
        _trees.addAll(state.list[1]);
        _nutrition.addAll(state.list[2]);
      } else if (state is CreateQuestionState && isResponseNotError(state.response, passString: true)) {
        UtilUI.showCustomDialog(context, 'Cảm ơn bạn đã đóng góp dữ liệu.', title: 'Thông báo')
            .whenComplete(() => UtilUI.goBack(context, true));
      } else if (state is GetLocationState) {
        final json = state.response.data;
        _setProvince(Util.checkKeyFromJson(json, 'province_id') ? ItemModel(id: json['province_id'].toString(), name: json['province_name']) : ItemModel());
        _setDistrict(Util.checkKeyFromJson(json, 'district_id') ? ItemModel(id: json['district_id'].toString(), name: json['district_name']) : ItemModel());
        _ctrAddress.text = Util.checkKeyFromJson(json, 'address_full') ? json['address_full'] : '';
        _changeAddress = false;
      } else if (state is GetLatLonAddressState) {
        if (state.lat.isNotEmpty && state.lon.isNotEmpty) {
          _ctrLat.text = state.lat;
          _ctrLng.text = state.lon;
          _setProvince(ItemModel());
          _setDistrict(ItemModel());
          _changeAddress = false;
          UtilUI.showCustomDialog(context, 'Lấy vị trí thành công');
        } else {
          UtilUI.showCustomDialog(context, 'Lấy vị trí thất bại');
        }
      }
    });
    if (_provinces.isEmpty) bloc!.add(LoadProvinceProfileEvent());
    bloc!.add(LoadListNameEvent());
    super.initState();
    Geolocator.getCurrentPosition().then((position) => _setLatLng(position));
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) =>
    Scaffold(appBar: AppBar(titleSpacing: 0, centerTitle: true,
        title: UtilUI.createLabel('Đóng góp thông tin dinh dưỡng'),
        actions: [IconButton(onPressed: clearFocus, icon: Icon(Icons.keyboard, color: Colors.white, size: 48.sp))]),
      body: Stack(children: [createUI(), Loading(bloc)]));

  @override
  Widget createUI() {
    final require = LabelCustom(' (*)', color: Colors.red, size: 36.sp, weight: FontWeight.normal);
    return Column(children: [
      Expanded(child: ListView(padding: EdgeInsets.all(40.sp), children: [
        _title('Loại cây (*)'),
        Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
            child: Row(children: [
              Expanded(child: TextFieldCustom(_ctrTree, null, null, 'Nhập loại cây',
                  size: 42.sp, color: color, borderColor: color, maxLine: 0,
                  inputAction: TextInputAction.newline, type: TextInputType.multiline,
                  padding: EdgeInsets.all(30.sp))),
              SizedBox(width: 32.sp),
              ButtonImageWidget(16.sp, _selectTree, Container(padding: EdgeInsets.all(20.sp),
                  child: Icon(Icons.arrow_drop_down, color: Colors.white, size: 84.sp)), color: StyleCustom.primaryColor)
            ])),
        _title('Mô tả loại cây'),
        Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
            child: TextFieldCustom(_ctrDesTree, null, null, 'Nhập mô tả loại cây',
                size: 42.sp, color: color, borderColor: color, maxLine: 0,
                inputAction: TextInputAction.newline, type: TextInputType.multiline,
                padding: EdgeInsets.all(30.sp))),
        _title('Mùa vụ (*)'),
        Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
            child: Row(children: [
              Expanded(child: TextFieldCustom(_ctrHarvest, null, null, 'Nhập mùa vụ',
                  size: 42.sp, color: color, borderColor: color, maxLine: 0,
                  inputAction: TextInputAction.newline, type: TextInputType.multiline,
                  padding: EdgeInsets.all(30.sp))),
              SizedBox(width: 32.sp),
              ButtonImageWidget(16.sp, _selectHarvest, Container(padding: EdgeInsets.all(20.sp),
                  child: Icon(Icons.arrow_drop_down, color: Colors.white, size: 84.sp)), color: StyleCustom.primaryColor)
            ])),
        _title('Mô tả mùa vụ'),
        Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
            child: TextFieldCustom(_ctrDesHar, null, null, 'Nhập mô tả mùa vụ',
                size: 42.sp, color: color, borderColor: color, maxLine: 0,
                inputAction: TextInputAction.newline, type: TextInputType.multiline,
                padding: EdgeInsets.all(30.sp))),
        _title('Dinh dưỡng trong đất (*)'),
        Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
            child: Row(children: [
              Expanded(child: TextFieldCustom(_ctrNutrition, null, null, 'Nhập dinh dưỡng trong đất',
                  size: 42.sp, color: color, borderColor: color, maxLine: 0,
                  inputAction: TextInputAction.newline, type: TextInputType.multiline,
                  padding: EdgeInsets.all(30.sp))),
              SizedBox(width: 32.sp),
              ButtonImageWidget(16.sp, _selectNutrition, Container(padding: EdgeInsets.all(20.sp),
                  child: Icon(Icons.arrow_drop_down, color: Colors.white, size: 84.sp)), color: StyleCustom.primaryColor)
            ])),

        Row(children: [
          Expanded(child: Column(children: [
            _title('N (Nitơ)'),
            Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
                child: TextFieldCustom(_ctrN, null, null, 'Nhập dinh dưỡng N (Nitơ)', size: 42.sp,
                    color: color, borderColor: color, inputFormatters:
                    [FilteringTextInputFormatter.allow(RegExp(r'^([0-9])*([.])?([0-9]?)*$'))]))
          ], crossAxisAlignment: CrossAxisAlignment.start)),
          SizedBox(width: 20.sp),
          Expanded(child: Column(children: [
            _title('P (P2O5)'),
            Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
                child: TextFieldCustom(_ctrP, null, null, 'Nhập P (P2O5)', size: 42.sp,
                    color: color, borderColor: color, inputFormatters:
                    [FilteringTextInputFormatter.allow(RegExp(r'^([0-9])*([.])?([0-9]?)*$'))])),
          ], crossAxisAlignment: CrossAxisAlignment.start))
        ]),

        Row(children: [
          Expanded(child: Column(children: [
            _title('K (K20)'),
            Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
                child: TextFieldCustom(_ctrK, null, null, 'Nhập K (K20)', size: 42.sp,
                    color: color, borderColor: color, inputFormatters:
                    [FilteringTextInputFormatter.allow(RegExp(r'^([0-9])*([.])?([0-9]?)*$'))]))
          ], crossAxisAlignment: CrossAxisAlignment.start)),
          SizedBox(width: 20.sp),
          Expanded(child: Column(children: [
            _title('Lưu huỳnh (S)'),
            Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
                child: TextFieldCustom(_ctrS, null, null, 'Nhập lưu huỳnh (S)', size: 42.sp,
                    color: color, borderColor: color, inputFormatters:
                    [FilteringTextInputFormatter.allow(RegExp(r'^([0-9])*([.])?([0-9]?)*$'))])),
          ], crossAxisAlignment: CrossAxisAlignment.start))
        ]),

        Row(children: [
          Expanded(child: Column(children: [
            _title('Canxi (CaO)'),
            Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
                child: TextFieldCustom(_ctrCa, null, null, 'Nhập Canxi (CaO)', size: 42.sp,
                    color: color, borderColor: color, inputFormatters:
                    [FilteringTextInputFormatter.allow(RegExp(r'^([0-9])*([.])?([0-9]?)*$'))]))
          ], crossAxisAlignment: CrossAxisAlignment.start)),
          SizedBox(width: 20.sp),
          Expanded(child: Column(children: [
            _title('Hữu cơ'),
            Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
                child: TextFieldCustom(_ctrOrganic, null, null, 'Nhập hữu cơ', size: 42.sp,
                    color: color, borderColor: color, inputFormatters:
                    [FilteringTextInputFormatter.allow(RegExp(r'^([0-9])*([.])?([0-9]?)*$'))])),
          ], crossAxisAlignment: CrossAxisAlignment.start))
        ]),

        Row(children: [
          Expanded(child: Column(children: [
            _title('Độ mặn'),
            Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
                child: TextFieldCustom(_ctrSalinity, null, null, 'Nhập độ mặn', size: 42.sp,
                    color: color, borderColor: color, inputFormatters:
                    [FilteringTextInputFormatter.allow(RegExp(r'^([0-9])*([.])?([0-9]?)*$'))]))
          ], crossAxisAlignment: CrossAxisAlignment.start)),
          SizedBox(width: 20.sp),
          Expanded(child: Column(children: [
            _title('Độ pH'),
            Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
                child: TextFieldCustom(_ctrPH, null, null, 'Nhập độ pH', size: 42.sp,
                    color: color, borderColor: color, inputFormatters:
                    [FilteringTextInputFormatter.allow(RegExp(r'^([0-9])*([.])?([0-9]?)*$'))])),
          ], crossAxisAlignment: CrossAxisAlignment.start))
        ]),

        /*Row(children: [
          Expanded(child: Column(children: [
            Row(children: [_title('Tỉnh thành'), require]),
            Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
                child: TextFieldCustom(_ctrProvince, null, null, 'Chọn tỉnh thành',
                    size: 42.sp, color: color, borderColor: color, readOnly: true, maxLine: 0,
                    inputAction: TextInputAction.newline, onPressIcon: _selectProvince,
                    type: TextInputType.multiline, padding: EdgeInsets.all(30.sp),
                    suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp))),
          ])),
          SizedBox(width: 20.sp),
          Expanded(child: Column(children: [
            Row(children: [_title('Quận huyện'), require]),
            Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
                child: TextFieldCustom(_ctrDistrict, null, null, 'Chọn quận huyện',
                    size: 42.sp, color: color, borderColor: color, readOnly: true, maxLine: 0,
                    inputAction: TextInputAction.newline, onPressIcon: _selectDistrict,
                    type: TextInputType.multiline, padding: EdgeInsets.all(30.sp),
                    suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp))),
          ]))
        ]),*/

        _title('Địa chỉ'),
        Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp), child: Row(children: [
          Expanded(child: TextFieldCustom(_ctrAddress, null, null, 'Nhập địa chỉ', size: 42.sp, color: color,
              borderColor: color, maxLine: 0, padding: EdgeInsets.all(30.sp),
              inputAction: TextInputAction.newline, type: TextInputType.multiline, onChanged: _onChangeAddress)),
          SizedBox(width: 32.sp),
          ButtonImageWidget(16.sp, () {
              clearFocus();
              if (_ctrAddress.text.trim().isNotEmpty) bloc!.add(GetLatLonAddressEvent(_ctrAddress.text));
            }, Container(padding: EdgeInsets.all(30.sp),
              child: Icon(Icons.sync, color: Colors.white, size: 64.sp)), color: StyleCustom.primaryColor),
          SizedBox(width: 32.sp),
          ButtonImageWidget(5, _openMap, Image.asset('assets/images/v5/ic_map_main2.png',
              width: 128.sp, height: 128.sp, fit: BoxFit.scaleDown))
        ])),
        /*_title('Vị trí đóng góp trên bản đồ'),
        SizedBox(height: 16.sp),
        Row(children: [
          Expanded(child: Column(children: [
            _title('Vĩ độ'),
            SizedBox(height: 16.sp),
            TextFieldCustom(_ctrLat, null, null, 'Nhập vĩ độ', size: 42.sp, readOnly: true,
                color: color, borderColor: color, inputFormatters:
                [FilteringTextInputFormatter.allow(RegExp(r'^([-])?([0-9])*([.])?([0-9]?)*$'))])
          ], crossAxisAlignment: CrossAxisAlignment.start)),
          SizedBox(width: 16.sp),
          Expanded(child: Column(children: [
            _title('Kinh độ'),
            SizedBox(height: 16.sp),
            TextFieldCustom(_ctrLng, null, null, 'Nhập kinh độ', size: 42.sp, readOnly: true,
                color: color, borderColor: color, inputFormatters:
                [FilteringTextInputFormatter.allow(RegExp(r'^([-])?([0-9])*([.])?([0-9]?)*$'))])
          ], crossAxisAlignment: CrossAxisAlignment.start)),
          Padding(padding: EdgeInsets.only(left: 32.sp), child:
          ButtonImageWidget(5, _openMap, Image.asset('assets/images/v5/ic_map_main2.png',
              width: 128.sp, height: 128.sp, fit: BoxFit.scaleDown)))
        ], crossAxisAlignment: CrossAxisAlignment.end)*/
      ])),
      Padding(padding: EdgeInsets.symmetric(vertical: 40.sp), child: ButtonImageWidget(16.sp, _send,
          Container(padding: EdgeInsets.all(40.sp), width: 1.sw - 80.sp, child: LabelCustom('Gửi',
              color: Colors.white, size: 48.sp, weight: FontWeight.normal, align: TextAlign.center)), color: StyleCustom.primaryColor))
    ]);
  }

  Widget _title(String title) => LabelCustom(title, color: const Color(0xFF787878), size: 36.sp, weight: FontWeight.normal);

  void _selectTree() {
    if (_trees.isNotEmpty) {UtilUI.showOptionDialog(context, 'Chọn loại cây', _trees, _ctrTree.text).then((value) {
      if (value != null && value.name != _ctrTree.text) _ctrTree.text = value.name;
    });}
  }

  void _selectHarvest() {
    if (_harvests.isNotEmpty) {UtilUI.showOptionDialog(context, 'Chọn mùa vụ', _harvests, _ctrHarvest.text).then((value) {
      if (value != null && value.name != _ctrHarvest.text) _ctrHarvest.text = value.name;
    });}
  }

  void _selectNutrition() {
    if (_nutrition.isNotEmpty) {UtilUI.showOptionDialog(context, 'Chọn dinh dưỡng', _nutrition, _ctrNutrition.text).then((value) {
      if (value != null && value.name != _ctrNutrition.text) _ctrNutrition.text = value.name;
    });}
  }

  void _selectProvince() {
    if (_provinces.isNotEmpty) UtilUI.showOptionDialog(context, 'Chọn tỉnh thành', _provinces, _province.id).then((value) => _setProvince(value));
  }

  void _setProvince(value) {
    if (value != null && value.id != _province.id) {
      _districts.clear();
      if (value.id.isNotEmpty) bloc!.add(LoadDistrictProfileEvent(value.id));
      _ctrProvince.text = value.name;
      _province.setValue(value.id, value.name);
      _ctrDistrict.text = '';
      _district.setValue('', '');
    }
  }

  void _selectDistrict() {
    if (_districts.isNotEmpty) UtilUI.showOptionDialog(context, 'Chọn quận huyện', _districts, _district.id).then((value) => _setDistrict(value));
  }

  void _setDistrict(value) {
    if (value != null && value.id != _district.id) {
      _ctrDistrict.text = value.name;
      _district.setValue(value.id, value.name);
    }
  }

  void _setLatLng(position) {
    _ctrLat.text = position.latitude.toString();
    _ctrLng.text = position.longitude.toString();
    bloc!.add(GetLocationEvent(_ctrLat.text, _ctrLng.text));
  }

  void _openMap() {
    clearFocus();
    LatLng? current;
    try {
      if (_ctrLat.text.isNotEmpty &&
          _ctrLng.text.isNotEmpty) current = LatLng(double.parse(_ctrLat.text), double.parse(_ctrLng.text));
    } catch (_) {}
    UtilUI.goToNextPage(context, NutritionLocPage(current: current), funCallback: (value) {
      if (value != null) _setLatLng(value);
    });
  }

  void _onChangeAddress(control, value) {
    if (_isShowSnack) return;
    _isShowSnack = true;
    _changeAddress = true;
    final snackBar = SnackBar(shape: const RoundedRectangleBorder(),
        backgroundColor: Colors.black, elevation: 0, margin: EdgeInsets.zero, behavior: SnackBarBehavior.floating,
        content: LabelCustom('Chọn nút đồng bộ để lấy vị trí mới nhất từ địa chỉ vừa thay đổi', size: 48.sp, weight: FontWeight.normal));
    ScaffoldMessenger.of(context).showSnackBar(snackBar).closed.whenComplete(() => _isShowSnack = false);
  }

  void _send() {
    clearFocus();
    bool alert = false;
    alert = _ctrHarvest.text.trim().isEmpty && _ctrTree.text.trim().isEmpty &&
        _ctrNutrition.text.trim().isEmpty && _ctrSalinity.text.trim().isEmpty && _ctrPH.text.trim().isEmpty;
    if (alert) {
      UtilUI.showCustomDialog(context, 'Vui lòng cung cấp một trong các thông tin: mùa vụ, loại cây, dinh dưỡng, độ mặn, độ pH');
      return;
    }
    /*if (_ctrProvince.text.isEmpty) {
      UtilUI.showCustomDialog(context, 'Vui lòng chọn tỉnh thành');
      return;
    }
    if (_ctrDistrict.text.isEmpty) {
      UtilUI.showCustomDialog(context, 'Vui lòng chọn quận huyện');
      return;
    }*/
    if (_changeAddress) {
      UtilUI.showCustomDialog(context, 'Chọn nút đồng bộ để lấy vị trí mới nhất từ địa chỉ vừa thay đổi');
      return;
    }
    if (_ctrLat.text.isEmpty || _ctrLng.text.isEmpty) {
      UtilUI.showCustomDialog(context, 'Vui lòng cung cấp thông tin vị trí đầy đủ');
      return;
    }
    bloc!.add(SendContributeEvent(_ctrHarvest.text, _ctrDesHar.text,_ctrTree.text, _ctrDesTree.text, _ctrNutrition.text,
        _ctrSalinity.text, _ctrPH.text, _province.id, _district.id, _ctrAddress.text, _ctrLat.text, _ctrLng.text,
        _ctrN.text, _ctrP.text, _ctrK.text, _ctrS.text, _ctrCa.text, _ctrOrganic.text));
  }
}