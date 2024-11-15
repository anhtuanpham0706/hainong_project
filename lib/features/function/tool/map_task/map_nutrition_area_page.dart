import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:hainong/common/ui/button_item_map.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/shadow_decoration.dart';
import 'package:hainong/features/function/tool/map_task/map_task_bloc.dart';
import 'package:trackasia_gl/mapbox_gl.dart';

class MapNutritionAreaPage extends BasePage {
  final TextEditingController ctrLocation;
  final bool lock;
  final List<LatLng> _areaLocation;
  MapNutritionAreaPage(this.ctrLocation, this._areaLocation, {this.lock = false, Key? key}) : super(pageState: _PlotsMapPageState(), key: key);
}

class _PlotsMapPageState extends BasePageState {
  TrackasiaMapController? _mapController;
  LatLng? _myLocation, _plotsLocation;
  bool _startDraw = false;
  List<LatLng> _points = [];
  LatLng? _first, _last;
  Circle? _circle;
  late MapNutritionAreaPage page;

  @override
  void dispose() {
    _first = null;
    _last = null;
    _circle = null;
    _myLocation = null;
    _plotsLocation = null;
    super.dispose();
  }

  @override
  void initState() {
    page = widget as MapNutritionAreaPage;
    _points = page._areaLocation;
    _initData();
    bloc = MapTaskBloc();
    super.initState();
    bloc!.stream.listen((state) {});
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Scaffold(
      appBar: AppBar(elevation: 10, titleSpacing: 0, title: UtilUI.createLabel('Bản đồ toạ độ'), centerTitle: true),
      body: GestureDetector(
          onTapDown: (value) {
            clearFocus();
          },
          child: Stack(children: [createUI(), createBodyUI(), Loading(bloc)], alignment: Alignment.bottomCenter)));

  @override
  Widget createUI() => TrackasiaMap(
      minMaxZoomPreference: const MinMaxZoomPreference(1.0, 30.0),
      styleString: constants.styleMap,
      initialCameraPosition: const CameraPosition(target: LatLng(15.7146441, 106.401633), zoom: 4.8),
      onMapCreated: _onMapCreated,
      onMapClick: _onMapClick,
      onMapLongClick: _onMapLongClick,
      myLocationEnabled: Platform.isIOS ? true : false);

  @override
  Widget createBodyUI() {
    final bool unlock = !(widget as MapNutritionAreaPage).lock;
    return Container(
        margin: EdgeInsets.all(40.sp),
        padding: EdgeInsets.all(20.sp),
        decoration: ShadowDecoration(opacity: 0.15, size: 16.sp),
        child: Row(children: [
          BlocBuilder(
              bloc: bloc,
              buildWhen: (oldS, newS) => newS is DrawMapState,
              builder: (context, state) => ButtonItemMap(_startDraw ? Icons.stop_circle_outlined : Icons.draw, _startDraw ? 'Dừng vẽ' : 'Vẽ bản đồ\n', () => _draw(renderDraw: true))),
          ButtonItemMap(Icons.my_location, 'Vị trí của tôi\n', _gotoMyLocation),
          ButtonItemMap(Icons.map, 'Vị trí dinh dưỡng\n', _gotoPlots),
          if (unlock) ButtonItemMap(Icons.location_off, 'Xoá các toạ độ\n', _removePlots),
          if (unlock) ButtonItemMap(Icons.save, 'Lưu\n', _save)
        ], crossAxisAlignment: CrossAxisAlignment.start));
  }

  void _onMapCreated(TrackasiaMapController controller) {
    _mapController ??= controller;
    _mapController!.onCircleTapped.add(_onCircleTapped);
    _mapController!.onFeatureDrag.add(_onDrag);
    Timer(const Duration(milliseconds: 1500), () => _drawPoints().whenComplete(() => _endDraw()));
    _determinePosition().then((value) {
      _myLocation ??= LatLng(value.latitude, value.longitude);
      if (_plotsLocation == null) _gotoMyLocation();
    }).whenComplete(() => Timer(const Duration(milliseconds: 500), () => _gotoPlots()));
    if (_points.isNotEmpty) {
      final LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(_points.first.latitude, _points.first.longitude),
        northeast: LatLng(_points.last.latitude, _points.last.longitude),
      );
      _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, left: 20.0, top: 20.0, right: 20.0, bottom: 20.0));
      _mapController?.addLine(LineOptions(geometry: _points, lineWidth: 3, lineColor: '#0000FF'));
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error(MultiLanguage.get('msg_gps_disable'));

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) return Future.error(MultiLanguage.get('msg_gps_deny_forever'));

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) return Future.error(MultiLanguage.get('msg_gps_denied'));
    }
    return await Geolocator.getCurrentPosition();
  }

  void _initData() {
    final page = widget as MapNutritionAreaPage;
    if (page.ctrLocation.text.isNotEmpty) {
      final array = page.ctrLocation.text.split(' - ');
      if (array.length == 2) {
        try {
          _plotsLocation = LatLng(double.parse(array[0].trim()), double.parse(array[1].trim()));
        } catch (_) {}
      }
    }
  }

  void _gotoMyLocation() {
    if (_myLocation != null) _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_myLocation!, 6));
  }

  void _gotoPlots() {
    if (_plotsLocation != null) _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_plotsLocation!, 6));
  }

  void _save() async {
    await _endDraw();
    Navigator.of(context).pop(_points);
  }

  void _onMapClick(Point<double> point, LatLng coordinates) async {
    if (_startDraw) {
      await _mapController!.addCircle(CircleOptions(circleColor: '#0000FF', geometry: coordinates, circleRadius: 10));

      _points.add(coordinates);
      _first ??= coordinates;
      _plotsLocation = LatLng(_points.first.latitude, _points.first.longitude);

      if (_first != null && _last == null)
        _last = coordinates;
      else if (_first != null && _last != null) {
        _first = _last;
        _last = coordinates;
        await _mapController!.addLine(LineOptions(geometry: [_first!, _last!], lineWidth: 3, lineColor: '#0000FF'));
      }
    } else if (_circle != null) {
      double lat = (double.parse(Util.doubleToString(_circle!.options.geometry!.latitude, locale: constants.localeENLang, digit: 5)) -
              double.parse(Util.doubleToString(coordinates.latitude, locale: constants.localeENLang, digit: 5)))
          .abs();
      double lng = (double.parse(Util.doubleToString(_circle!.options.geometry!.longitude, locale: constants.localeENLang, digit: 5)) -
              double.parse(Util.doubleToString(coordinates.longitude, locale: constants.localeENLang, digit: 5)))
          .abs();
      if (lat > 0.00011 || lng > 0.00011) {
        await _mapController!.updateCircle(_circle!, const CircleOptions(circleColor: '#0000FF', circleRadius: 10, draggable: false));
        _circle = null;
      }
    }
  }

  void _onCircleTapped(Circle circle) async {
    if (_startDraw) return;
    if (_circle == null || _circle!.id != circle.id) {
      await _mapController!.updateCircle(_circle == null ? circle : _circle!, const CircleOptions(circleColor: '#0000FF', circleRadius: 10, draggable: false));
      _circle = circle;
      await _mapController!.updateCircle(_circle!, const CircleOptions(circleColor: '#FF0000', circleRadius: 15, draggable: true));
      _count = 0;
    }
  }

  int _count = 0;
  void _onDrag(id, {required LatLng current, required LatLng delta, required DragEventType eventType, required LatLng origin, required Point<double> point}) async {
    if (delta.latitude == 0 && delta.longitude == 0) {
      if (_count == 0) {
        _count++;
        return;
      }

      await _mapController!.updateCircle(_circle!, CircleOptions(geometry: current));
      await _draw();
      await _endDraw();
      _count = 0;
    }
  }

  Future<void> _draw({bool renderDraw = false}) async {
    if (_startDraw) {
      await _endDraw(renderDraw: renderDraw);
    } else {
      _startDraw = true;
      if (renderDraw) bloc!.add(DrawMapEvent());
      _first = null;
      _last = null;
      final list = _mapController!.circles;
      if (list.isNotEmpty) {
        for (var circle in list) {
          _points.add(circle.options.geometry!);
        }

        _plotsLocation = LatLng(_points.first.latitude, _points.first.longitude);
        await _mapController!.clearLines();
        await _mapController!.clearCircles();
        await _drawPoints();
      }
    }
  }

  Future<void> _drawPoints() async {
    for (var point in _points) {
      try {
        await _mapController!.addCircle(CircleOptions(circleColor: '#0000FF', geometry: point, circleRadius: 10));
      } catch (_) {}

      _first ??= point;

      if (_first != null && _last == null)
        _last = point;
      else if (_first != null && _last != null) {
        _first = _last;
        _last = point;
        await _mapController!.addLine(LineOptions(geometry: [_first!, _last!], lineWidth: 3, lineColor: '#0000FF'));
      }
    }
  }

  Future<void> _endDraw({bool renderDraw = false}) async {
    _startDraw = false;
    if (renderDraw) bloc!.add(DrawMapEvent());
    if (_points.length > 1) await _mapController!.addLine(LineOptions(geometry: [_points.last, _points.first], lineWidth: 3, lineColor: '#0000FF'));
    _first = null;
    _last = null;
    _circle = null;
    // _points.clear();
  }

  void _onMapLongClick(Point<double> point, LatLng coordinates) async {
    /*if (_startDraw || _circle == null) return;
    double lat = (double.parse(Util.doubleToString(_circle!.options.geometry!.latitude, locale: constants.localeENLang, digit: 5)) - double.parse(Util.doubleToString(coordinates.latitude, locale: constants.localeENLang, digit: 5))).abs();
    double lng = (double.parse(Util.doubleToString(_circle!.options.geometry!.longitude, locale: constants.localeENLang, digit: 5)) - double.parse(Util.doubleToString(coordinates.longitude, locale: constants.localeENLang, digit: 5))).abs();
    if (lat < 0.00011 && lng < 0.00011) {
      await _mapController!.removeCircle(_circle!);
      await _draw();
      await _endDraw();
    }*/
  }

  void _removePlots() => UtilUI.showCustomDialog(
              context,
              'Bạn có chắc chắn '
              'muốn xoá tất cả các toạ độ hiện tại trên bản đồ không?',
              isActionCancel: true)
          .then((value) async {
        if (value != null && value) {
          _points.clear();
          await _mapController!.clearCircles();
          await _mapController!.clearLines();
        }
      });
}
