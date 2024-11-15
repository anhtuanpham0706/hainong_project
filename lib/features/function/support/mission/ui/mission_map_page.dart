import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import 'package:trackasia_gl/mapbox_gl.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import '../mission_bloc.dart';
import 'mission_mine_sub_detail_page.dart';
import 'mission_sub_detail_page.dart';

class MissionMapPage extends BasePage {
  MissionMapPage({Key? key}) : super(pageState: _MissionMapPageState(), key: key);
}

class _MissionMapPageState extends BasePageState {
  final TextEditingController _ctrSearch = TextEditingController(),
      _ctrProvince = TextEditingController(), _ctrDistrict = TextEditingController();
  TrackasiaMapController? _map;
  final List<Marker> _markers = [];
  final List<ItemModel> _provinces = [
    ItemModel(id: '', name: '...')
  ];
  final List<ItemModel> _districts = [
    ItemModel(id: '', name: '...')
  ];
  final ItemModel _province = ItemModel();
  final ItemModel _district = ItemModel();

  @override
  void dispose() {
    _markers.clear();
    _map?.removeListener(_refreshMarkers);
    _map?.dispose();
    _provinces.clear();
    _districts.clear();
    super.dispose();
  }

  @override
  void initState() {
    bloc = MissionBloc('map');
    bloc!.stream.listen((state) {
      if (state is LoadMarkersState) {
        setState(() {
          _markers.addAll(state.resp);
        });
      } else if (state is LoadMissionsState && isResponseNotError(state.resp)) {
        final total = (state.counts['total_joined']??.0).toDouble();
        final completed = (state.counts['work_status']??'') == 'completed';
        final notOwner = !Constants().isLogin || ((state.counts['user_id']??-1) != Constants().userId);
        UtilUI.goToNextPage(context, total > 0 || completed || notOwner ? MissionSubDetailPage(state.resp.data, state.counts, showParent: true) : MissionMineSubDetailPage(state.resp.data, state.counts));
      } else if (state is LoadProvinceState) {
        _provinces.addAll(state.list);
      } else if (state is LoadDistrictState) {
        _districts.addAll(state.list);
      }
    });
    bloc!.add(LoadProvinceEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Scaffold(appBar: AppBar(titleSpacing: 0,
      actions: [
        IconButton(onPressed: _showFilter, icon: const Icon(Icons.filter_alt, color: Colors.white), padding: EdgeInsets.zero),
      ],
      title: UtilUI.createLabel('Bản đồ nhiệm vụ'), centerTitle: true),
    body: Stack(children: [
      TrackasiaMap(minMaxZoomPreference: const MinMaxZoomPreference(1, 30),
          styleString: constants.styleMap,
          initialCameraPosition: const CameraPosition(target: LatLng(15.7146441, 106.401633), zoom: 4.8),
          trackCameraPosition: true, onMapCreated: _onMapCreated, onCameraIdle: _refreshMarkers
      ),
      Stack(children: _markers),
      Loading(bloc)
    ]));

  Widget _title(String title) => LabelCustom(title, color: const Color(0xFF787878), size: 36.sp, weight: FontWeight.normal);

  void _onMapCreated(TrackasiaMapController initialMap) {
    _map = initialMap;
    _map!.addListener(_refreshMarkers);
    _search();
  }

  void _onMarkerTouched(data) => bloc!.add(LoadMissionsEvent(0, (data['mission_id']??'').toString(), '', false, data: data));

  void _refreshMarkers() async {
    if (_map!.isCameraMoving && _markers.isNotEmpty) {
      final List<LatLng> latLngs = [];
      for (int i = 0; i < _markers.length; i++) {
        latLngs.add(_markers[i].getCoordinate());
      }
      final values = await _map!.toScreenLocationBatch(latLngs);
      for (int i = 0; i < values.length; i++) {
        _markers[i].updatePosition(values[i]);
      }
      values.clear;
      latLngs.clear();
    }
  }

  void _showFilter() => showDialog(context: context, builder: (context) {
    final color = const Color(0XFFF5F6F8);
    return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        titlePadding: EdgeInsets.zero, insetPadding: EdgeInsets.zero, contentPadding: EdgeInsets.all(40.sp),
        content: Container(color: Colors.white, width: 0.8.sw, constraints: BoxConstraints(maxHeight: 0.75.sh),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _title('Tên nhiệm vụ'),
              Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
                  child: TextFieldCustom(_ctrSearch, null, null, 'Nhập tên nhiệm vụ',
                      size: 42.sp, color: color, borderColor: color,
                      maxLine: 0, inputAction: TextInputAction.newline,
                      type: TextInputType.multiline, padding: EdgeInsets.all(30.sp))),

              _title('Tỉnh thành'),
              Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
                  child: TextFieldCustom(_ctrProvince, null, null, 'Chọn tỉnh thành',
                      size: 42.sp, color: color, borderColor: color, readOnly: true, maxLine: 0,
                      inputAction: TextInputAction.newline, onPressIcon: _selectProvince,
                      type: TextInputType.multiline, padding: EdgeInsets.all(30.sp),
                      suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp))),

              _title('Quận huyện'),
              Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
                  child: TextFieldCustom(_ctrDistrict, null, null, 'Chọn quận huyện',
                      size: 42.sp, color: color, borderColor: color, readOnly: true, maxLine: 0,
                      inputAction: TextInputAction.newline, onPressIcon: _selectDistrict,
                      type: TextInputType.multiline, padding: EdgeInsets.all(30.sp),
                      suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp))),

              SizedBox(height: 40.sp),
              Row(children: [
                Expanded(child: OutlinedButton(
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.transparent)),
                    onPressed: _setDefault,
                    child: Text('Thiết lập lại', style: TextStyle(fontSize: 48.sp)))),
                Expanded(child: OutlinedButton(onPressed: () => _search(hasBack: true, reset: true),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.transparent),
                        backgroundColor: StyleCustom.primaryColor),
                    child: Text('Tìm', style: TextStyle(fontSize: 48.sp, color: Colors.white))))
              ])
            ], mainAxisSize: MainAxisSize.min))
    );
  });

  void _selectProvince() {
    if (_provinces.isNotEmpty) UtilUI.showOptionDialog(context, 'Chọn tỉnh thành', _provinces, _province.id).then((value) => _setProvince(value));
  }

  void _setProvince(value) {
    if (value != null && value.id != _province.id) {
      _districts.removeRange(1, _districts.length);
      if (value.id.isNotEmpty) bloc!.add(LoadDistrictEvent(value.id));
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

  void _setDefault() {
    _ctrSearch.text = '';
    _ctrProvince.text = '';
    _province.setValue('', '');
    _ctrDistrict.text = '';
    _district.setValue('', '');
    _districts.removeRange(1, _districts.length);
  }

  void _search({bool hasBack = false, bool reset = false}) {
    if (hasBack) UtilUI.goBack(context, true);
    if (reset) {
      setState(() {
        _markers.clear();
      });
    }
    bloc!.add(LoadingEvent(true));
    Timer(Duration(milliseconds: hasBack ? 1500 : 0), () => bloc!.add(LoadMarkersEvent(_map!, _onMarkerTouched, _province.id, _district.id, _ctrSearch.text)));
  }
}

class Marker extends StatefulWidget {
  late LatLng coordinate;
  final Function onTouched;
  final dynamic data;
  final _MarkerState state = _MarkerState();

  Marker(this.data, Point initialPosition, this.onTouched, {Key? key}) : super(key: key) {
    coordinate = LatLng(data['latitude'], data['longitude']);
    state.position = initialPosition;
  }

  LatLng getCoordinate() => coordinate;

  void updatePosition(Point<num> point) => state.updatePosition(point);

  @override
  State<StatefulWidget> createState() => state;
}

class _MarkerState extends State<Marker> {
  late Point position;
  final height = 20.0;
  double ratio = 1.0;
  final MissionBloc bloc = MissionBloc('map');

  void updatePosition(Point<num> point) {
    position = point;
    bloc.add(GetLocationEvent(''));
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color color = Colors.green;
    // if ((widget.data['total_joined']??0).toInt() == (widget.data['number_joins']??0).toInt()) color = Colors.grey;
    if ((widget.data['work_status']??'') == 'completed') color = Colors.yellow;
    ratio = Platform.isIOS ? 1.0 : MediaQuery.of(context).devicePixelRatio;
    final child = GestureDetector(onTap: () => widget.onTouched(widget.data),
        child: Icon(Icons.location_on, color: color, size: 86.sp));
    return BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is GetLocationState,
        builder: (context, state) => Positioned(left: position.x / ratio - height,
            top: position.y / ratio - height, child: child));
  }
}
