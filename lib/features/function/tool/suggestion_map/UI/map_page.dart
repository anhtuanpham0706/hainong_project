import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:hainong/common/ui/banner_2nong.dart';

import 'utils/trackasia_map_source.dart';
import 'package:trackasia_gl/mapbox_gl.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/button_item_map.dart';
import 'package:hainong/common/ui/loading.dart';
import '../../nutrition_map/nutrition_map_page.dart';
import '../mappage_block.dart';
import 'package:http/http.dart' as http;
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'dart:collection';
import 'dialog/popup_map_info_dialog.dart';
import 'map_filter.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  //==============VARIANT================//
  final Constants constants = Constants();
  BaseBloc? bloc;
  TrackasiaMapController? mapController;
  final initialLocation = const LatLng(16.25658, 106.31679);
  final double defaultZoomRate = 4.8;
  final sourceId = "trackasia_pet";
  final keyChartName = "pet";
  List<ItemModel> _currentKinds = [];
  ItemModel _currentProvince = ItemModel();
  String _fromDate = '', _toDate = '';
  Map<String, dynamic> dataMap = {};
  TrackasiaMapSource clusterSource = TrackasiaMapSource();
  //==============VARIANT================//

  //==============OVERRIDE================//
  @override
  void initState() {
    bloc = MapPageBloc(MapState());
    super.initState();
  }

  @override
  void dispose() {
    if (Constants().isLogin) Constants().indexPage = null;
    // mapController?.dispose();
    bloc!.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          titleSpacing: 0,
          actions: [IconButton(onPressed: () => _pushToFilterView(context), icon: const Icon(Icons.filter_list_alt, color: Colors.white))],
          title: UtilUI.createLabel('Bản đồ sâu bệnh'),
          centerTitle: true),
      body: Stack(children: [
        TrackasiaMap(
          styleString: constants.styleMap,
          compassEnabled: true,
          tiltGesturesEnabled: true,
          scrollGesturesEnabled: true,
          initialCameraPosition: const CameraPosition(target: LatLng(15.7146441, 106.401633), zoom: 4.8),
          onStyleLoadedCallback: _onStyleLoadedCallback,
          onMapCreated: _onMapCreated,
          onMapClick: _onMapClick,
          onMapIdle: () {},
          onCameraIdle: _onCameraIdleCallback,
          trackCameraPosition: true,
        ),
        Padding(
            padding: const EdgeInsets.all(10),
            child: Row(children: [
              ButtonMap('Sâu bệnh', () {}, active: true),
              const SizedBox(width: 5),
              ButtonMap('Dinh dưỡng', () => _gotoOther('nutrition')),
              /*
                const SizedBox(width: 5),
                ButtonMap('Độ mặn', () => _gotoOther('salinity')),
                const SizedBox(width: 5),
                ButtonMap('Độ pH', () => _gotoOther('pH'))*/
            ])),
        const Align(alignment: Alignment.bottomRight, child: Banner2Nong('diagnostic_map')),
        Loading(bloc)
      ]));

  void _onMapCreated(TrackasiaMapController controller) async {
    mapController = controller;
    controller.onFeatureTapped.add(_onFeatureTapped);
  }

  void _onStyleLoadedCallback() async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("Đang tải.."),
      backgroundColor: Theme.of(context).primaryColor,
      duration: const Duration(seconds: 1),
    ));
    await _fetchFeatures();
  }

  void _onFeatureTapped(dynamic featureId, Point<double> point, LatLng coords) async {
    var features = await mapController?.queryRenderedFeatures(point, ["pet_chart_circle_children"], null);
    if (features?.isNotEmpty ?? false) {
      var feature = HashMap.from(features!.first);
      PopupMapInfoDialog.show(context, feature);
    }
  }

  Future<void> _onCameraIdleCallback() async {}

  void _onMapClick(Point<double> point, LatLng coordinates) async {
    if (Platform.isIOS) {
      var features = await mapController?.queryRenderedFeatures(point, ["pet_chart_circle_children"], null);
      if (features?.isNotEmpty ?? false) {
        var feature = HashMap.from(features!.first);
        PopupMapInfoDialog.show(context, feature);
      }
    }
  }
  //==============OVERRIDE================//

  //===========FUNCTION============

  Future<void> _fetchFeatures() async {
    dataMap.clear();
    bloc!.add(LoadingEvent(true));
    String paramDate = '';
    if (_fromDate.isNotEmpty) paramDate = 'from_date=$_fromDate&';
    if (_toDate.isNotEmpty) paramDate += 'to_date=$_toDate&';
    if (_currentProvince.id.isNotEmpty) paramDate += 'province_name=${_currentProvince.name}&';
    if (_currentKinds.isNotEmpty) {
      String temp = '';
      for (var ele in _currentKinds) {
        temp += ',' + ele.id;
      }
      temp = temp.replaceFirst(',', '');
      paramDate += 'diagnostic_ids=[$temp]';
    } else if (paramDate.isNotEmpty) {
      paramDate = paramDate.substring(0, paramDate.length - 1);
    }
    final apiPetMap = Constants().apiVersion + 'diagnostics/pets_map?$paramDate';
    final response = await http.get(Uri.parse(Constants().baseUrl + apiPetMap));
    if (response.statusCode == 200) {
      bloc!.add(LoadingEvent(false));
      dataMap = jsonDecode(response.body);
      addResponseDataClusterMap();
    } else {
      bloc!.add(LoadingEvent(false));
      UtilUI.showCustomDialog(context, "Không thể lấy danh sách sâu bệnh");
    }
  }

  void _centerAround(LatLng location) => mapController!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: location, zoom: mapController!.cameraPosition!.zoom)));

  Future<void>? addResponseDataClusterMap() async {
    if (dataMap.isNotEmpty) {
      dataMap["type"] = "FeatureCollection";
      clusterSource.addTrackasiaClusterMap(mapController: mapController, dataMap: dataMap, sourceId: sourceId, keyChartName: keyChartName);
    }
  }

  void _pushToFilterView(BuildContext context) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => MapFilterPage(_currentKinds, _currentProvince, _fromDate, _toDate)));
    Util.trackActivities('', path: 'Pests Map -> Open Filter View');
    if (result != null) {
      _currentKinds = result['kinds'] ?? [];
      _currentProvince = result['province'] ?? ItemModel();
      _fromDate = result['from_date'] ?? '';
      _toDate = result['to_date'] ?? '';
      await _fetchFeatures();
    }
  }

  void _gotoOther(String type) => UtilUI.goToPage(context, NutritionMapPage(type: type), null);
  //===========FUNCTION============
}
