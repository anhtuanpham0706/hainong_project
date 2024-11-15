import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:hainong/common/ui/image_network_asset.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:hainong/common/ui/ads.dart';
import 'package:hainong/common/ui/banner_2nong.dart';
import 'package:hainong/common/ui/box_dec_custom.dart';
import 'package:just_audio/just_audio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hainong/common/models/item_option.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import 'package:hainong/common/ui/title_helper.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'weather_setting_notification.dart';
import 'dialog_list_address.dart';
import '../weather_bloc.dart';
import '../weather_list_province_model.dart';
import '../weather_model.dart';

class WeatherListPage extends BasePage {
  WeatherListPage({Key? key}):super(key: key, pageState: _WeatherListPageState());
}
extension StringCasingExtension on String {
  String toCapitalized() => length > 0 ?'${this[0].toUpperCase()}${substring(1).toLowerCase()}':'';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');
}

class _WeatherListPageState extends BasePageState {
  final GlobalKey _globalKey = GlobalKey();
  WeatherModel _weather_data = WeatherModel();
  String _audio_weather = '', _province_select_id = '0', negative_notices = 'disagree';
  AudioPlayer _player = AudioPlayer();
  late String  latitude, longitude, curLat, curLng;
  bool _isPlay = false, _hasAds = false;
  List<WeatherListModel> _list_weather = [];
  int _count = 0, negative_notice_id = -1;
  Uint8List? _screenFile;

  @override
  void dispose() async {
    if (constants.isLogin) constants.indexPage = null;
    try {
      _list_weather.clear();
      _weather_data.nextDay.clear();
      _weather_data.currentDate.currentWeatherGroup.clear();
    } catch (_) {}
    try {
      if (_player.playing) await _player.stop();
      await _player.dispose();
    } catch (_) {}
    super.dispose();
  }

  @override
  void initState() {
    _getLocalFile();
    bloc = WeatherBloc();
    bloc!.stream.listen((state) async {
      if (state is LoadDetailWeatherState) {
        if (_screenFile != null) _screenFile = null;
        _count ++;
        if (_count < 2) bloc!.add(LoadingEvent(true));
        _audio_weather = '';
        _weather_data = state.response.data;
        if (_weather_data.currentDate.audio_link.isEmpty) {
          bloc!.add(LoadAudioWeatherEvent(latitude, longitude));
        } else {
          _autoPlayAudio(_weather_data.currentDate.audio_link);
        }
      } else if(state is LoadListWeatherState) {
        _count ++;
        _list_weather = state.response.data.list;
        if (_count < 2) bloc!.add(LoadingEvent(true));
        else _playPauseAudio();
      } else if (state is LoadAudioWeatherState && state.data.isNotEmpty) {
        _autoPlayAudio(state.data);
      } else if(state is GetLatLonAddressState && isResponseNotError(state.response)) {
        _isPlay = false;
        _audio_weather = '';
        await _player.stop();
        latitude = state.lat;
        longitude = state.lon;
        bloc!.add(LoadDetailWeatherEvent(latitude, longitude));
      } else if(state is LoadNegativeWeatherStatusState) {
        negative_notices = state.response['status'];
        negative_notice_id = state.response['id'];
      } else if(state is ChangeNegativeWeatherStatusState) {
        negative_notices = state.status;
      }
    });
    super.initState();
    Geolocator.getCurrentPosition().then((value) {
      _audio_weather = '';
      latitude = curLat = value.latitude.toString();
      longitude = curLng = value.longitude.toString();
      bloc!.add(LoadDetailWeatherEvent(latitude, longitude, openModule: true, isSendLocation: constants.isLogin));
    }).onError((error, stackTrace) {
      _audio_weather = '';
      latitude = curLat = longitude = curLng = '';
      bloc!.add(LoadDetailWeatherEvent('', '', openModule: true));
    });
    bloc!.add(LoadListWeatherEvent());
    bloc!.add(LoadNegativeWeatherStatusEvent());
  }

  void _selectOption() async {
    if (bloc!.state.isShowLoading) return;
    final List<ItemOption> options = [];
    options.add(ItemOption('assets/images/ic_location.png', ' Quản lý địa chỉ', () {
      UtilUI.goBack(context, false);
      showOptionAddress(
        context,
        MultiLanguage.get('lbl_list_address'),
      ).then((value) async {
        if (value != null) {
          await _player.stop();
          _isPlay = false;
          bloc!.add(PlayAudioEvent(false));
          bloc!.add(GetLatLonAddressEvent(value.toString()));
        }
      });
    }, false));
    if(constants.isLogin) options.add(ItemOption('assets/images/ic_notification.png', ' Quản lý thông báo thời tiết', _goToNoticeList, false));
    UtilUI.showOptionDialog2(context, MultiLanguage.get('ttl_option'), options, colorLine: Colors.greenAccent,
        weight: FontWeight.bold, bgItem: const Color(0x08000000));
    Util.trackActivities('weathers', path: 'Post -> Option Menu Button -> Open Option Dialog');
  }

  void _goToNoticeList() {
    UtilUI.goBack(context, false);
    UtilUI.goToNextPage(context, WeatherSettingPage());
    Util.trackActivities('weathers', path: 'List Weather Screen -> Open Notice List Weather}');
    if (_player.playing) _playPauseAudio();
  }

  void _initPlayController() async {
    if (_audio_weather.isEmpty) return;
    _player = AudioPlayer();
    _player.setUrl(_audio_weather).whenComplete(() {
      _player.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          _isPlay = false;
          bloc!.add(PlayAudioEvent(false));
          _player.seek(const Duration(seconds: 0)).whenComplete(() => _player.pause());
        }
      });
      _playPauseAudio();
    });
  }

  void _changeStatusNegative(bool value) {
    if(negative_notice_id == -1) return;
    bloc!.add(ChangeNegativeWeatherStatusEvent(negative_notice_id, value ? "agree": "disagree"));
  }

  void _changedProvince(WeatherListModel item) async {
    await _player.stop();
    await _player.dispose();
    _province_select_id = item.id.toString();
    _audio_weather = '';
    latitude = item.lat;
    longitude = item.lng;
    _isPlay = false;
    bloc!.add(PlayAudioEvent(false));
    bloc!.add(LoadDetailWeatherEvent(item.lat, item.lng));
  }

  void _playPauseAudio({bool changeAudio = true}) {
    if (_audio_weather.isEmpty) {
      bloc!.add(LoadingAudioEvent(true));
      bloc!.add(LoadAudioWeatherEvent(latitude, longitude,isRequest: true));
    } else if (!bloc!.state.isShowLoading) {
      _isPlay = !_isPlay;
      bloc!.add(PlayAudioEvent(_isPlay));
      if (changeAudio) _isPlay ? _player.play() : _player.pause();
      bloc!.add(LoadingAudioEvent(false));
    }
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Stack(children: [
    RepaintBoundary(child: Scaffold(backgroundColor: const Color(0XFFEAF4FF),
      appBar: AppBar(title: const TitleHelper('ttl_weather', url: 'https://help.hainong.vn/muc/3'),
        backgroundColor: const Color(0xFF0E986F), elevation: 0, centerTitle: true, shadowColor: Colors.transparent,
        actions: [IconButton(onPressed: _selectOption, icon: Image.asset('assets/images/ic_menu.png',
                width: 60.sp,height: 60.sp,color: Colors.white,))]),
      body: BlocBuilder(bloc: bloc, buildWhen: (oldState, newState) => newState is LoadDetailWeatherState,
        builder: (context, state) => Column(children: [
          Container(width: 1.sw, color: const Color(0xFF0E986F), padding: EdgeInsets.fromLTRB(40.sp, 0, 40.sp, 40.sp),
            child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(children: [
                  Flexible(child: ButtonImageWidget(5, () {
                    if (bloc!.state.isShowLoading) return;
                    showOptionProvince(context, MultiLanguage.get(languageKey.lblProvince), _list_weather, _province_select_id).then((value) {
                      if (value != null) _changedProvince(value);
                    });
                  }, LabelCustom(_weather_data.currentDate.location_fullname + '  ', color: Colors.white, size: 50.sp, align: TextAlign.center, weight: FontWeight.w500))),
                  if (_weather_data.currentDate.location_fullname.isNotEmpty) ButtonImageWidget(0, () {
                                if (latitude != curLat && longitude != curLng) _changedProvince(WeatherListModel(id: 0, lat: curLat, lng: curLng));
                              }, Image.asset('assets/images/ic_location.png', width: 48.sp, color: Colors.white))
                ], mainAxisSize: MainAxisSize.min),
                SizedBox(height: 40.sp),
                Row(children: [
                  Container(width: 380.sp, height: 380.sp, margin: EdgeInsets.only(right: 20.sp),
                    child: _weather_data.currentDate.weatherStatusIcon.isNotEmpty ?
                      ImageNetworkAsset(path: constants.baseUrlImage + '/images/weather_icons/${_weather_data.currentDate.weatherStatusIcon}.png',
                        width: 380.sp, height: 380.sp, fit: BoxFit.fitHeight, uiError: const SizedBox()) : const CircularProgressIndicator()),
                  if (_weather_data.currentDate.temp > 0)
                    Flexible(child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LabelCustom(MultiLanguage.get('lbl_now'), color: Colors.white, size: 35.sp),
                        SizedBox(height: 10.sp),
                        LabelCustom(_weather_data.currentDate.weatherStatus.toCapitalized(), color: Color(_weather_data.currentDate.status_color), size: 54.sp),
                        LabelCustom('${_weather_data.currentDate.temp.round()}°', color: Colors.white, size: 120.sp, weight: FontWeight.w500),
                        LabelCustom('Khả năng mưa: ${_weather_data.currentDate.percent_rain.round()}%',
                          size: 45.sp, align: TextAlign.center, weight: FontWeight.w500),
                      ]))
                ], mainAxisAlignment: MainAxisAlignment.center),
                BlocBuilder(bloc: bloc,
                                buildWhen: (oldStt, newStt) => newStt is LoadNegativeWeatherStatusState || newStt is ChangeNegativeWeatherStatusState,
                                builder: (context, state) => Container(child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      LabelCustom('Cảnh báo thời tiết tiêu cực', size: 42.sp, align: TextAlign.center, weight: FontWeight.w500),
                                      SizedBox(width: 40.sp),
                                      Switch(activeColor: Colors.green, activeTrackColor: Colors.white,
                                          value: negative_notices == "agree", onChanged: (value) => _changeStatusNegative(value)),
                                    ]),
                                    decoration: BoxDecoration(color: Colors.black12,
                                        borderRadius: BorderRadius.all(Radius.circular(20.sp))),
                                    margin: EdgeInsets.fromLTRB(50.sp, 40.sp, 50.sp, 0)))
              ])),
          Expanded(child: ListView(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                      if(_hasAds) Container(padding: EdgeInsets.symmetric(vertical: 20.sp, horizontal: 30.sp),
                          margin: EdgeInsets.only(top: 20.sp),
                          decoration: const BoxDecoration(color: Colors.orange,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
                          child: Row(children: [
                            Image.asset('assets/images/v7/ic_thunderstorm.png', width: 56.sp, height: 56.sp),
                            LabelCustom('  Khuyến cáo nông vụ', weight: FontWeight.w500, size: 48.sp)
                          ])),
                      if(_weather_data.currentDate.updatedAt.isNotEmpty && !_hasAds) Padding(
                          padding: EdgeInsets.fromLTRB(32.sp, 20.sp, 0, 20.sp),
                          child: LabelCustom(MultiLanguage.get('lbl_today')+Util.dateToString(Util.stringToDateTime(_weather_data.currentDate.updatedAt),
                              locale: constants.localeVI, pattern: 'Md'), color: Colors.black, size: 48.sp,)),
                      Expanded(child: LabelCustom('Nghe tin', color: Colors.black, size: 42.sp, align: TextAlign.right, weight: FontWeight.normal)),
                      Padding(padding: EdgeInsets.all(10.sp),
                          child: ButtonImageWidget(50, _playPauseAudio, BlocBuilder(bloc: bloc,
                              buildWhen: (oldState, newState) => newState is PlayAudioState,
                              builder: (context, state) {
                                bool play = false;
                                if (state is PlayAudioState) play = state.value;
                                return Container(decoration: BoxDecCustom(radius: 100, bgColor: Colors.transparent,
                                    borderColor: play ? Colors.green : Colors.red, width: 3, hasBorder: true, hasShadow: false),
                                    child: Icon(play ? Icons.pause_circle_filled : Icons.play_circle_fill, color: play ? Colors.green : Colors.red, size: 80.sp));
                                return Icon(play ? Icons.pause_circle_filled : Icons.play_circle_fill, color: Colors.red, size: 120.sp);
                              }))),
                      BlocBuilder(bloc: bloc, buildWhen: (oldState, newState) => newState is LoadingAudioState,
                          builder: (context, state) {
                            return state is LoadingAudioState && state.value ?
                            Padding(padding: EdgeInsets.only(right: 32.sp),
                                child: LabelCustom('Đang tải ...', color: Colors.black, size: 42.sp, weight: FontWeight.normal)) : SizedBox(width: 24.sp);
                          })
                    ]),
            Ads('weather', fnReload: () => setState(() => _hasAds = true)),
            if(_weather_data.currentDate.updatedAt.isNotEmpty && _hasAds) Padding(padding: EdgeInsets.fromLTRB(32.sp, 20.sp, 0, 20.sp),
              child: LabelCustom(MultiLanguage.get('lbl_today') +
                  Util.dateToString(Util.stringToDateTime(_weather_data.currentDate.updatedAt), pattern: 'Md'), color: Colors.black, size: 48.sp)),
            SizedBox(height: 350.sp, child: ListView.builder(shrinkWrap: true,
              scrollDirection: Axis.horizontal, padding: EdgeInsets.symmetric(vertical: 30.sp),
              itemCount: _weather_data.currentDate.currentWeatherGroup.length,
              itemBuilder: (context, index) => _WeatherHourItem(_weather_data.currentDate.currentWeatherGroup[index].label,
                _weather_data.currentDate.currentWeatherGroup[index].weatherStatusIcon,
                _weather_data.currentDate.currentWeatherGroup[index].temp))),
            Row(children: [
              _WeatherStateItem("Nhiệt độ giao động",'temp_max','${_weather_data.currentDate.tempMin.round()}°-${_weather_data.currentDate.tempMax.round()}°'),
              _WeatherStateItem("Chỉ số bức xạ",'uv','${_weather_data.currentDate.uv}', isLeft: false)
            ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
            Padding(child: Row(children: [
              _WeatherStateItem(MultiLanguage.get('lbl_wind_power'),'wind','${_weather_data.currentDate.windSpeed}km/h'),
              _WeatherStateItem(MultiLanguage.get('lbl_hum'),'hum','${_weather_data.currentDate.humidity}%', isLeft: false),
            ], mainAxisAlignment: MainAxisAlignment.spaceBetween), padding: EdgeInsets.symmetric(vertical: 30.sp)),
            Row(children: [
              _WeatherStateItem(MultiLanguage.get('lbl_sunrise'),'sun_star',_weather_data.currentDate.sunrise.toUpperCase()),
              _WeatherStateItem(MultiLanguage.get('lbl_sunset'),'sun_stop',_weather_data.currentDate.sunset.toUpperCase(), isLeft: false)
            ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
            Padding(padding: EdgeInsets.only(left: 30.sp, top: 60.sp), child:
              LabelCustom('${_weather_data.totalNextDate} ngày tới', color: Colors.black, size: 38.sp)),
            ListView.separated(padding: EdgeInsets.all(30.sp), physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => SizedBox(height: 24.sp),
              itemCount: _weather_data.nextDay.length, shrinkWrap: true,
              itemBuilder: (context, index) => _WeatherNextDayItem(_weather_data.nextDay[index]))
          ]))
        ], mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start))), key: _globalKey),
    BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is LoadDetailWeatherState,
        builder: (context, state) {
          if (_weather_data.currentDate.id > 0 || _screenFile == null) {
            if (_weather_data.currentDate.id > 0) _takeScreenShot();
            return const SizedBox();
          }
          return Image.memory(_screenFile!, width: 1.sw, height: 1.sh, fit: BoxFit.scaleDown);
        }),
    const Banner2Nong('weather'),
    Loading(bloc)
  ], alignment: Alignment.bottomRight);

  Future showOptionAddress(BuildContext context, String title,
       {bool hasTitle = true,bool hasAdd = true}) {
    return showDialog(context: context, barrierDismissible: true,
        builder: (context) => DialogListAddressCustom(hintText: title,));
  }

  List<Widget> addressItems(BuildContext context, String title,
      List<String> values, String id, {bool hasTitle = true,bool hasAdd = true}) {
    final TextEditingController _ctrAddress = TextEditingController();
    final FocusNode focusAddress = FocusNode();
    final line = Container(color: Colors.grey.shade300, height: 2.sp);
    List<Widget> list = [];
    if (hasTitle) {list.add(SizedBox(height: 120.sp, child: Center(
        child: LabelCustom(title, color: Colors.black87))));}
    list.add(line);
    if(hasAdd) {
      list.add(SizedBox(height: 120.sp, child: TextFieldCustom(_ctrAddress,focusAddress,null,"nhập địa chỉ")));
    }

    for (var i = 0; i < values.length; i++) {
      list.add(line);
      list.add(OutlinedButton(
          style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.transparent),
              padding: EdgeInsets.zero),
          onPressed: () => Navigator.of(context).pop(values[i]),
          child: Container(color: Colors.white,
              width: 1.sw, height: 148.sp, alignment: Alignment.center,
              child: LabelCustom(values[i],
                  color: StyleCustom.primaryColor))));
    }
    return list;
  }

  Future showOptionProvince(BuildContext context, String title,
      List<WeatherListModel> values, String id, {bool hasTitle = true}) {
    return showDialog(context: context, barrierDismissible: true,
        builder: (context) => Align(alignment: Alignment.center,
            child: Container(width: 0.8.sw,
                height: 150.sp * values.length + (hasTitle?120.sp:0),
                margin: EdgeInsets.only(top: 300.sp, bottom: 80.sp),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(30.sp)),
                child: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min,
                        children: createItems(context, title, values, id, hasTitle: hasTitle))))));
  }

  List<Widget> createItems(BuildContext context, String title,
      List<WeatherListModel> values, String id, {bool hasTitle = true}) {
    final line = Container(color: Colors.grey.shade300, height: 2.sp);
    List<Widget> list = [];
    if (hasTitle) {list.add(SizedBox(height: 120.sp, child: Center(
        child: LabelCustom(title, color: Colors.black87))));}
    for (var i = 0; i < values.length; i++) {
      list.add(line);
      list.add(OutlinedButton(
          style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: Colors.transparent,
              ),
              padding: EdgeInsets.zero),
          onPressed: () => Navigator.of(context).pop(values[i]),
          child: Container(color: id != values[i].id.toString() ? Colors.transparent : StyleCustom.buttonColor,
              width: 1.sw, height: 148.sp, alignment: Alignment.center,
              child: LabelCustom(values[i].name,
                  color: id != values[i].id.toString() ? StyleCustom.primaryColor : Colors.white))));
    }
    return list;
  }

  void _autoPlayAudio(String link) {
    _audio_weather = link;
    setState(() => _initPlayController());
    bloc!.add(LoadingAudioEvent(false));
  }

  bool? _lock;
  void _takeScreenShot() {
    if (_lock != null) return;
    Timer(const Duration(milliseconds: 1500), () async {
      _lock = true;
      try {
        final boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2.0);
        final root = (await getApplicationDocumentsDirectory()).path;
        final byteData = await image.toByteData(format: ImageByteFormat.png);
        final pngBytes = byteData?.buffer.asUint8List();
        final folder = Directory(root + '/weather/');
        folder.createSync();
        File imgFile = File(folder.path + '/screen.png');
        imgFile.openWrite();
        imgFile.writeAsBytes(pngBytes!, mode: FileMode.writeOnly);
      } catch (_) {}
      _lock = null;
    });
  }

  Future<void> _getLocalFile() async {
    final folder = (await getApplicationDocumentsDirectory()).path;
    final temp = File(folder + '/weather/screen.png');
    if (temp.existsSync()) {
      temp.openSync();
      _screenFile = temp.readAsBytesSync();
      setState(() {});
    }
  }
}

class _WeatherStateItem extends StatelessWidget{
  final String name, icon, value;
  final bool isLeft;
  const _WeatherStateItem(this.name, this.icon, this.value, {this.isLeft = true, Key? key}) : super(key:key);
  @override
  Widget build(BuildContext context) => Container(height: 226.sp, width: 0.5.sw - 45.sp, alignment: Alignment.center,
    margin: EdgeInsets.only(left: isLeft ? 30.sp : 0, right: isLeft ? 0 : 30.sp), padding: EdgeInsets.all(30.sp),
    child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      LabelCustom(name, color: Colors.black, weight: FontWeight.normal, size: 36.sp),
      Row(children: [
        Image.asset('assets/images/v2/ic_$icon.png', height: 100.sp, width: 100.sp),
        SizedBox(width: 46.sp),
        LabelCustom(value, color: Colors.black, size: 55.sp, weight: FontWeight.normal)
      ], mainAxisAlignment: MainAxisAlignment.center)
    ]),
    decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors:[Colors.white, Color(0XFFEAF4FF)]),
          borderRadius: BorderRadius.all(Radius.circular(25.sp)),
          boxShadow: [
            BoxShadow(color: const Color(0XFFB9B9B9).withOpacity(0.25),
              spreadRadius: 0, blurRadius: 4, offset: const Offset(0, 4))
          ])
  );
}

class _WeatherNextDayItem extends StatelessWidget {
  final CurrentDate next_day;
  const _WeatherNextDayItem(this.next_day, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.start, children: [
    SizedBox(width: 0.22.sw, child: LabelCustom(MultiLanguage.get('lbl_' + next_day.weekName),
      color: const Color(0XFF757575), size: 42.sp, weight: FontWeight.normal)),
    LabelCustom('${next_day.tempMax.round()}°   ',color: Colors.black,size: 42.sp,weight: FontWeight.normal),
    LabelCustom('${next_day.tempMin.round()}°   ',color: const Color(0XFF868686),size: 42.sp,weight: FontWeight.normal),
    ImageNetworkAsset(path: Constants().baseUrlImage + '/images/weather_icons/'+next_day.weatherStatusIcon+'.png',
        width: 120.sp, height: 120.sp, fit: BoxFit.fitHeight, uiError: const SizedBox()),
    LabelCustom('   ' + next_day.weatherStatus.toCapitalized(), color: Colors.black, size: 42.sp, weight: FontWeight.normal),
  ]);
}

class _WeatherHourItem extends StatelessWidget {
  final String hour, icon;
  final double temp;
  const _WeatherHourItem(this.hour, this.icon, this.temp, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    LabelCustom(hour, color: Colors.black, size: 35.sp, weight: FontWeight.normal),
    ImageNetworkAsset(path: Constants().baseUrlImage + '/images/weather_icons/' + icon + '.png', width: 0.2.sw,
        height: 150.sp, fit: BoxFit.fitHeight, uiError: const SizedBox()),
    LabelCustom('${temp.round()}°', color: Colors.black, size: 35.sp, weight: FontWeight.normal),
  ]);
}
