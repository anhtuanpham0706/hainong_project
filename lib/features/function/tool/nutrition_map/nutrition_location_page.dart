import 'dart:io';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:hainong/common/ui/button_item_map.dart';
import 'package:hainong/common/ui/shadow_decoration.dart';
import 'package:trackasia_gl/mapbox_gl.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import '../suggestion_map/mappage_block.dart';
import 'nutrition_map_bloc.dart';

class NutritionLocPage extends BasePage {
  LatLng? current;
  NutritionLocPage({this.current, Key? key}) : super(pageState: _NutritionLocPageState(), key: key);
}

class _NutritionLocPageState extends BasePageState {
  TrackasiaMapController? _map;
  LatLng? _myLocation, _current;
  _Marker? _marker;

  @override
  void dispose() {
    _map!.removeListener(_listener);
    _map?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    final page = widget as NutritionLocPage;
    if (page.current != null) {
      _current = page.current;
      _marker = _Marker(Point(_current!.latitude, _current!.longitude), _current);
    }
    bloc = NutritionMapBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Scaffold(appBar: AppBar(titleSpacing: 0,
      title: UtilUI.createLabel('Chọn vị trí'), centerTitle: true),
    body: Stack(children: [
      TrackasiaMap(
        minMaxZoomPreference: const MinMaxZoomPreference(1.0, 30.0),
        styleString: constants.styleMap,
        initialCameraPosition: const CameraPosition(target: LatLng(10.77144, 106.69709), zoom: 8),
        trackCameraPosition: true, onMapCreated: _onMapCreated, onMapClick: _onClickMap,
        onCameraIdle: _listener,  myLocationEnabled: Platform.isIOS ? true : false,
      ),
      if (_marker != null) _marker!,
      Container(margin: EdgeInsets.all(40.sp), padding: EdgeInsets.all(20.sp),
          decoration: ShadowDecoration(opacity: 0.15, size: 16.sp),
          child: Row(children: [
            ButtonItemMap(Icons.my_location, 'Vị trí\ncủa tôi', _gotoMyLocation),
            ButtonItemMap(Icons.location_on, 'Vị trí\nđã chọn', _gotoCurrent),
            ButtonItemMap(Icons.location_off, 'Huỷ chọn\n', _removeCurrent),
            ButtonItemMap(Icons.check_circle, 'Chọn\n', _confirm)
          ], crossAxisAlignment: CrossAxisAlignment.start))
    ], alignment: Alignment.bottomCenter));

  void _onMapCreated(TrackasiaMapController initialMap) async {
    _map = initialMap;
    _map!.addListener(_listener);
    if (_current != null) _map!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _current!, zoom: _map!.cameraPosition!.zoom)));
    Geolocator.getCurrentPosition().then((position) {
      _myLocation ??= LatLng(position.latitude, position.longitude);
      if (_current == null) _map!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _myLocation!, zoom: _map!.cameraPosition!.zoom)));
    });
  }

  void _onClickMap(Point<double> point, LatLng coordinates) async {
    if (_marker == null) {
      _marker = _Marker(point, coordinates);
      setState(() {});
    } else {
      _marker!.updatePosition(point, coordinates);
    }
  }

  void _listener() {
    if (_map!.isCameraMoving && _marker != null) {
      _map!.toScreenLocation(_marker!.getCoordinate()).then((point) {
        _marker!.state.updatePosition(point);
      });
    }
  }

  void _gotoMyLocation() {
    if (_myLocation != null) _map?.animateCamera(CameraUpdate.newLatLng(_myLocation!));
  }

  void _gotoCurrent() {
    if (_marker != null) _map?.animateCamera(CameraUpdate.newLatLng(_marker!.getCoordinate()));
  }

  void _removeCurrent() => setState(() {_marker = null;});

  void _confirm() => UtilUI.goBack(context, _marker != null ? _marker!.getCoordinate() : null);
}

class _Marker extends StatefulWidget {
  LatLng? coordinate;
  final Point<num> point;
  final _MarkerState state = _MarkerState();

  _Marker(this.point, this.coordinate, {Key? key}) : super(key: key);

  LatLng getCoordinate() => coordinate!;

  void updatePosition(Point<num> point, LatLng coordinate) {
    this.coordinate = coordinate;
    state.updatePosition(point);
  }

  @override
  State<StatefulWidget> createState() => state;
}

class _MarkerState extends State<_Marker> {
  late Point position;
  final MapPageBloc bloc = MapPageBloc(MapState());

  void updatePosition(Point<num> point) {
    position = point;
    bloc.add(LoadMarkerEvent());
  }

  @override
  void initState() {
    position = widget.point;
    super.initState();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ratio = Platform.isIOS ? 1.0 : MediaQuery.of(context).devicePixelRatio;
    final child = Image.asset('assets/images/ic_location.png', width: 96.sp, height: 96.sp, color: Colors.red);
    return BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is LoadMarkerState,
        builder: (context, state) => Positioned(left: position.x/ratio - 48.sp,
            top: position.y/ratio - 96.sp, child: child));
  }
}