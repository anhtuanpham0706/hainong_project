import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/banner_2nong.dart';
import 'package:hainong/common/ui/button_item_map.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import 'package:hainong/features/profile/profile_bloc.dart';
import 'package:trackasia_gl/mapbox_gl.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import '../../support/handbook/handbook_bloc.dart';
import '../suggestion_map/UI/map_page.dart';
import '../suggestion_map/UI/utils/trackasia_map_source.dart';
import 'nutrition_map_bloc.dart';
import 'nutrition_contribute_page.dart';
import 'nutrition_popup_map_info_widget.dart';

class NutritionMapPage extends BasePage {
  final String type;
  NutritionMapPage({this.type = 'nutrition', Key? key}) : super(pageState: _NutritionMapPageState(), key: key);
}

class _NutritionMapPageState extends BasePageState {
  final TextEditingController _ctrTo = TextEditingController(),
      _ctrFrom = TextEditingController(),
      _ctrProvince = TextEditingController(),
      _ctrDistrict = TextEditingController(),
      _ctrType = TextEditingController();
  TrackasiaMapController? mapController;
  final List<ItemModel> _options = [
    ItemModel(id: '', name: 'Tất cả'),
    ItemModel(id: 'nutrition', name: 'Độ dinh dưỡng'),
    ItemModel(id: 'salinity', name: 'Độ mặn'),
    ItemModel(id: 'pH', name: 'Độ pH')
  ];
  final List<ItemModel> _provinces = [ItemModel(id: '', name: '...')];
  final List<ItemModel> _districts = [ItemModel(id: '', name: '...')];
  final ItemModel _type = ItemModel(id: 'nutrition', name: 'Độ dinh dưỡng');
  final ItemModel _province = ItemModel();
  final ItemModel _district = ItemModel();
  TrackasiaMapSource clusterSource = TrackasiaMapSource();
  final sourceId = "trackasia_nutrition";
  final keyChartName = "nutrition";
  Map<String, dynamic> dataMap = {};

  @override
  void dispose() {
    _provinces.clear();
    _districts.clear();
    _options.clear();
    _ctrFrom.dispose();
    _ctrTo.dispose();
    _ctrType.dispose();
    _ctrProvince.dispose();
    _ctrDistrict.dispose();
    mapController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    switch ((widget as NutritionMapPage).type) {
      case 'salinity':
        _setType(_options[2]);
        break;
      case 'pH':
        _setType(_options[3]);
    }
    bloc = NutritionMapBloc();
    bloc!.stream.listen((state) {
      if (state is LoadListState && isResponseNotError(state.response) && state.response.data.isNotEmpty) {
        dataMap = state.response.data;
        addResponseDataClusterMap();
      } else if (state is LoadProvinceProfileState) {
        _provinces.addAll(state.response.data.list);
      } else if (state is LoadDistrictProfileState) {
        _districts.addAll(state.response.data.list);
      }
    });
    bloc!.add(LoadProvinceProfileEvent());
    super.initState();
    if (_ctrType.text.isEmpty) _ctrType.text = 'Độ dinh dưỡng';
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Scaffold(
      appBar: AppBar(
          titleSpacing: 0,
          actions: [
            IconButton(onPressed: _showFilter, icon: const Icon(Icons.filter_alt, color: Colors.white), padding: EdgeInsets.zero),
            if (Constants().isLogin) IconButton(onPressed: _addInfo, icon: const Icon(Icons.add_circle_outline, color: Colors.white), padding: EdgeInsets.zero)
          ],
          title: UtilUI.createLabel('Bản đồ dinh dưỡng'),
          centerTitle: true),
      body: Stack(children: [
        TrackasiaMap(
          minMaxZoomPreference: const MinMaxZoomPreference(1, 30),
          styleString: constants.styleMap,
          initialCameraPosition: const CameraPosition(target: LatLng(15.7146441, 106.401633), zoom: 4.8),
          trackCameraPosition: true,
          onMapCreated: _onMapCreated,
          onMapClick: _onMapClick,
        ),
        Padding(
            padding: const EdgeInsets.all(10),
            child: Row(children: [
              ButtonMap('Sâu bệnh', () => UtilUI.goToPage(context, const MapPage(), null)),
              const SizedBox(width: 5),
              ButtonMap('Dinh dưỡng', () => _changeMap(1), active: _type.id == 'nutrition'),
              /*const SizedBox(width: 5),
        ButtonMap('Độ mặn', () => _changeMap(2), active: _type.id == 'salinity'),
        const SizedBox(width: 5),
        ButtonMap('Độ pH', () => _changeMap(3), active: _type.id == 'pH')*/
            ])),
        const Align(alignment: Alignment.bottomRight, child: Banner2Nong('diagnostic_map')),
        Loading(bloc)
      ]));

  Widget _row(String label, String value, {double top = 0}) => Padding(
      padding: EdgeInsets.only(top: top, bottom: 20.sp),
      child: Row(children: [LabelCustom(label, size: 42.sp, color: Colors.black), Expanded(child: LabelCustom(value, size: 42.sp, color: Colors.black, weight: FontWeight.normal))]));

  Widget _title(String title) => LabelCustom(title, color: const Color(0xFF787878), size: 36.sp, weight: FontWeight.normal);

  /*void _showMenu() => UtilUI.showOptionDialog2(context, 'Tuỳ chọn', [
    ItemOption('', 'Lọc dữ liệu', _showFilter, false, icon: Icons.filter_alt),
    if (Constants().isLogin) ItemOption('', 'Đóng góp', _addInfo, false, icon: Icons.add_circle_outline)
  ]);*/

  void _showFilter() => showDialog(
      context: context,
      builder: (context) {
        const color = Color(0XFFF5F6F8);
        return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            titlePadding: EdgeInsets.zero,
            insetPadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.all(40.sp),
            content: Container(
                color: Colors.white,
                width: 0.8.sw,
                constraints: BoxConstraints(maxHeight: 0.75.sh),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /*_title('Loại'),
              Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
                  child: TextFieldCustom(_ctrType, null, null, 'Chọn loại',
                      size: 42.sp, color: color, borderColor: color, readOnly: true,
                      onPressIcon: _selectType, maxLine: 0, inputAction: TextInputAction.newline,
                      type: TextInputType.multiline, padding: EdgeInsets.all(30.sp),
                      suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp))),*/
                      _title('Tỉnh thành'),
                      Padding(
                          padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
                          child: TextFieldCustom(_ctrProvince, null, null, 'Chọn tỉnh thành',
                              size: 42.sp,
                              color: color,
                              borderColor: color,
                              readOnly: true,
                              maxLine: 0,
                              inputAction: TextInputAction.newline,
                              onPressIcon: _selectProvince,
                              type: TextInputType.multiline,
                              padding: EdgeInsets.all(30.sp),
                              suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp))),
                      _title('Quận huyện'),
                      Padding(
                          padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
                          child: TextFieldCustom(_ctrDistrict, null, null, 'Chọn quận huyện',
                              size: 42.sp,
                              color: color,
                              borderColor: color,
                              readOnly: true,
                              maxLine: 0,
                              inputAction: TextInputAction.newline,
                              onPressIcon: _selectDistrict,
                              type: TextInputType.multiline,
                              padding: EdgeInsets.all(30.sp),
                              suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp))),
                      Row(children: [
                        Expanded(
                            child: Column(children: [
                          _title('Từ ngày'),
                          SizedBox(height: 16.sp),
                          TextFieldCustom(_ctrFrom, null, null, 'dd/MM/yyyy',
                              size: 42.sp, color: color, borderColor: color, readOnly: true, onPressIcon: _selectFrom, suffix: Icon(Icons.calendar_today, color: Colors.grey, size: 48.sp))
                        ], crossAxisAlignment: CrossAxisAlignment.start)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Column(children: [
                          _title('Đến ngày'),
                          SizedBox(height: 16.sp),
                          TextFieldCustom(_ctrTo, null, null, 'dd/MM/yyyy',
                              size: 42.sp, color: color, borderColor: color, readOnly: true, onPressIcon: _selectTo, suffix: Icon(Icons.calendar_today, color: Colors.grey, size: 48.sp))
                        ], crossAxisAlignment: CrossAxisAlignment.start))
                      ]),
                      SizedBox(height: 40.sp),
                      Row(children: [
                        Expanded(
                            child: OutlinedButton(
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.transparent)),
                                onPressed: _setDefault,
                                child: Text('Thiết lập lại', style: TextStyle(fontSize: 48.sp)))),
                        Expanded(
                            child: OutlinedButton(
                                onPressed: () => _search(hasBack: true, reset: true),
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.transparent), backgroundColor: StyleCustom.primaryColor),
                                child: Text('Tìm', style: TextStyle(fontSize: 48.sp, color: Colors.white))))
                      ])
                    ],
                    mainAxisSize: MainAxisSize.min)));
      });

  void _addInfo() {
    //UtilUI.goBack(context, true);
    UtilUI.goToNextPage(context, NutritionContributePage(provinces: _provinces), funCallback: (value) => setState(() {}));
  }

  void _onMapCreated(TrackasiaMapController initialMap) {
    mapController = initialMap;
    initialMap.onFeatureTapped.add(_onFeatureTapped);
    _search();
  }

  void _onFeatureTapped(dynamic featureId, Point<double> point, LatLng coords) async {
    var features = await mapController?.queryRenderedFeatures(point, ["nutrition_chart_circle_children"], ['!=', 'cluster', true]);
    if (features?.isNotEmpty ?? false) {
      var feature = HashMap.from(features!.first);
      PopupMapInfoDialog.show(context, feature);
    }
  }

  void _onMapClick(Point<double> point, LatLng coordinates) async {
    if (Platform.isIOS) {
      var features = await mapController?.queryRenderedFeatures(point, ["nutrition_chart_circle_children"], ['!=', 'cluster', true]);
      if (features?.isNotEmpty ?? false) {
        var feature = HashMap.from(features!.first);
        PopupMapInfoDialog.show(context, feature);
      }
    }
  }

  void _onFeatureTouched() {}

  void _changeMap(int index) {
    if (_options[index].id != _type.id) {
      _setType(_options[index]);
      _search(reset: true);
    }
  }

  void _selectType() => UtilUI.showOptionDialog(context, 'Chọn loại', _options, _type.id).then((value) => _setType(value));

  void _setType(value) {
    if (value != null && value.id != _type.id) {
      _ctrType.text = value.name;
      _type.setValue(value.id, value.name);
    }
  }

  void _selectProvince() {
    if (_provinces.isNotEmpty) {
      UtilUI.showOptionDialog(context, 'Chọn tỉnh thành', _provinces, _province.id).then((value) => _setProvince(value));
    }
  }

  void _setProvince(value) {
    if (value != null && value.id != _province.id) {
      _districts.removeRange(1, _districts.length);
      if (value.id.isNotEmpty) bloc!.add(LoadDistrictProfileEvent(value.id));
      _ctrProvince.text = value.name;
      _province.setValue(value.id, value.name);
      _ctrDistrict.text = '';
      _district.setValue('', '');
    }
  }

  void _selectDistrict() {
    if (_districts.isNotEmpty) {
      UtilUI.showOptionDialog(context, 'Chọn quận huyện', _districts, _district.id).then((value) => _setDistrict(value));
    }
  }

  void _setDistrict(value) {
    if (value != null && value.id != _district.id) {
      _ctrDistrict.text = value.name;
      _district.setValue(value.id, value.name);
    }
  }

  void _selectFrom() {
    String temp = _ctrFrom.text;
    if (temp.isEmpty) {
      final now = DateTime.now();
      temp = '${now.day}/${now.month}/${now.year}';
    }
    DatePicker.showDatePicker(context,
        minTime: DateTime.now().add(const Duration(days: -365)),
        maxTime: _ctrTo.text.isNotEmpty ? Util.stringToDateTime(_ctrTo.text, pattern: 'dd/MM/yyyy') : DateTime.now(),
        showTitleActions: true,
        onConfirm: (DateTime date) => _ctrFrom.text = Util.dateToString(date, pattern: 'dd/MM/yyyy'),
        currentTime: Util.stringToDateTime(temp, pattern: 'dd/MM/yyyy'),
        locale: LocaleType.vi);
  }

  void _selectTo() {
    String temp = _ctrTo.text;
    if (temp.isEmpty) {
      final now = DateTime.now();
      temp = '${now.day}/${now.month}/${now.year}';
    }
    DatePicker.showDatePicker(context,
        minTime: _ctrFrom.text.isNotEmpty ? Util.stringToDateTime(_ctrFrom.text, pattern: 'dd/MM/yyyy') : DateTime.now().add(const Duration(days: -365)),
        maxTime: DateTime.now(),
        showTitleActions: true,
        onConfirm: (DateTime date) => _ctrTo.text = Util.dateToString(date, pattern: 'dd/MM/yyyy'),
        currentTime: Util.stringToDateTime(temp, pattern: 'dd/MM/yyyy'),
        locale: LocaleType.vi);
  }

  void _setDefault() {
    switch ((widget as NutritionMapPage).type) {
      case 'salinity':
        _setType(_options[2]);
        break;
      case 'pH':
        _setType(_options[3]);
        break;
      default:
        _setType(_options[1]);
    }
    _ctrFrom.text = '';
    _ctrTo.text = '';
    _ctrProvince.text = '';
    _province.setValue('', '');
    _ctrDistrict.text = '';
    _district.setValue('', '');
    _districts.clear();
  }

  void _search({bool hasBack = false, bool reset = false}) {
    if (hasBack) UtilUI.goBack(context, true);
    if (reset) {
      setState(() {
        dataMap.clear();
      });
    }
    bloc!.add(LoadingEvent(true));
    Timer(Duration(milliseconds: hasBack ? 1500 : 0), () => bloc!.add(LoadMarkersEvent(mapController!, _onFeatureTouched, _province.id, _district.id, _ctrFrom.text, _ctrTo.text, _type.id)));
  }

  Future<void>? addResponseDataClusterMap() async {
    if (dataMap.isNotEmpty) {
      dataMap["type"] = "FeatureCollection";
      clusterSource.addTrackasiaClusterMap(mapController: mapController, dataMap: dataMap, sourceId: sourceId, keyChartName: keyChartName);
    }
  }
}
