import 'dart:async';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/core_button_custom.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/features/admin/review_contribute/review_bloc.dart';
import 'package:hainong/features/function/info_news/market_price/market_price_bloc.dart';
import 'package:hainong/features/function/info_news/weather/weather_bloc.dart';
import 'package:hainong/features/function/tool/nutrition_map/nutrition_location_page.dart';
import 'package:hainong/features/home/ui/import_ui_home.dart';
import 'package:hainong/features/main/bloc/main_bloc.dart';
import 'package:trackasia_gl/mapbox_gl.dart';
import 'package:hainong/common/models/file_byte.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/permission_image_page_state.dart';
import 'package:hainong/common/ui/task_bar_widget.dart';
import '../diagnose_pests_bloc.dart';
import '../model/plant_model.dart';
import 'diagnostis_pests_image_item.dart';

class DiagnosePetsContributePage extends BasePage {
  final String tree, diagnosis;
  final List<FileByte> images;
  final TrainConModel? detail;
  final bool isReview, readOnly;
  final Function? funReload;
  DiagnosePetsContributePage(List<PlantModel> catalogues, {Key? key, this.tree = '', this.diagnosis = '',
    this.images = const [], this.detail, this.isReview = false, this.readOnly = false, this.funReload}) :
        super(key: key, pageState: _DiagnosePetsContributeState(catalogues));
}

class _DiagnosePetsContributeState extends PermissionImagePageState {
  final List<PlantModel> catalogues;
  final List<ItemModel> _diagnosis = [];
  final List<ItemModel> _provinces = [];
  final List<ItemModel> _district = [];
  final ItemModel _locationProvinces = ItemModel();
  final ItemModel _locationDistrict = ItemModel();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _ctrTreeName = TextEditingController();
  final TextEditingController _ctrName = TextEditingController();
  final TextEditingController _ctrDescription = TextEditingController();
  final FocusNode _focusAddress = FocusNode();
  final FocusNode _focusTreeName = FocusNode();
  final FocusNode _focusName = FocusNode();
  final FocusNode _focusDescription = FocusNode();
  final List<FileByte> _images = [];
  final List<ItemModel> _imageTypes = [];
  String _description = '';
  //bool _isFinished = false;
  //WebViewXController? _controller;
  double _lat = .0, _lng = .0;

  _DiagnosePetsContributeState(this.catalogues) {
    for(var tree in catalogues) {
      for(var ele in tree.diagnostics) {
        _diagnosis.add(ItemModel(id: ele.name, name: ele.name + ' (${tree.name})'));
      }
    }
  }

  @override
  void loadFiles(List<File> files) {
    if (files.isEmpty) return;
    bool hasFile = false;
    for (int i = 0; i < files.length; i++) {
      if (Util.isImage(files[i].path)) {
        hasFile = true;
        _images.add(FileByte(files[i].readAsBytesSync(), files[i].path));
      }
    }
    if (hasFile) bloc!.add(ShowImageDiagnosePestsEvent());
  }

  @override
  openCameraGallery() {
    if (pass) {
      resetCheckPermission();
    } else
      super.openCameraGallery();
  }

  @override
  void dispose() {
    _diagnosis.clear();
    _provinces.clear();
    _district.clear();
    _addressCtrl.dispose();
    _ctrTreeName.dispose();
    _ctrName.dispose();
    _ctrDescription.dispose();
    _focusAddress.dispose();
    _focusTreeName.dispose();
    _focusName.dispose();
    _focusDescription.dispose();
    _images.clear();
    _imageTypes.clear();
    super.dispose();
  }

  void _updateDescription(dynamic value) async {
    SharedPreferences.getInstance()
        .then((prefs) => prefs.remove('hainong_url'));
    if (_description == value.toString()) return;
    _description = value.toString();
  }
  void _showLocations({bool loadProvince = true, bool loadDistrict = true, String idProvince = '', required bool isProvince}) {
    if ((widget as DiagnosePetsContributePage).isReview) return;
    if (isProvince) {
      if (_provinces.isEmpty) {
        if (loadProvince) bloc!.add(LoadListProvinceEvent());
        return;
      }
      UtilUI.showOptionDialog(context, MultiLanguage.get(languageKey.lblProvince), _provinces, _locationProvinces.id)
          .then((value) {
        if (value != null) _setLocation(value, isProvince);
      });
    } else {
      if (_locationProvinces.name.isEmpty) return;
      if (_district.isEmpty && idProvince.isNotEmpty) {
        if (loadDistrict) bloc!.add(LoadListDistrictEvent(idProvince));
        return;
      }
      UtilUI.showOptionDialog(context, MultiLanguage.get(languageKey.lblDistrict), _district, _locationDistrict.id).then((value) {
        if (value != null) _setLocation(value, isProvince);
      });
    }
  }
  void _setLocation(ItemModel value, bool isProvince) {
    if (isProvince) {
      if (_locationProvinces.id == value.id) return;
      _locationProvinces.id = value.id;
      _locationProvinces.name = value.name;
      _locationDistrict.name = '';
      _locationDistrict.id = '';
      _district.clear();
    } else {
      if (_locationDistrict.id == value.id) return;
      _locationDistrict.id = value.id;
      _locationDistrict.name = value.name;
    }
    bloc!.add(SetLocationEvent());
  }

  @override
  void initState() {
    final page = widget as DiagnosePetsContributePage;
    super.initState();
    bloc = DiagnosePestsBloc(const DiagnosePestsState());
    _initImageTypes();
    bloc!.stream.listen((state) {
      if (state is CreateDiagnostisPestSuccessState && isResponseNotError(state.resp, passString: true)) {
        _showDialogCreatePestContributeSuccess();
      } else if (state is LoadListProvincesState) {
        _provinces.addAll(state.response.data.list);
        _showLocations(loadProvince: false, isProvince: true);
      } else if (state is LoadListDistrictState) {
        _district.addAll(state.response.data.list);
        _showLocations(loadDistrict: true, isProvince: false);
      } else if (state is GetLocationState) {
        final json = state.response.data;
        if (Util.checkKeyFromJson(json, 'province_id')) {
          _setLocation(ItemModel(id: json['province_id'].toString(), name: json['province_name']), true);
        }
        if (Util.checkKeyFromJson(json, 'district_id')) {
          _setLocation(ItemModel(id: json['district_id'].toString(), name: json['district_name']), false);
        }
        if (Util.checkKeyFromJson(json, 'address_full')) {
          _addressCtrl.text = json['address_full'];
        }
      } else if (state is GetLatLonAddressState && state.lat.isNotEmpty && state.lon.isNotEmpty) {
        _lat = double.parse(state.lat);
        _lng = double.parse(state.lon);
      } else if (state is UpdateStatusState && isResponseNotError(state.resp, passString: true)) {
        (widget as DiagnosePetsContributePage).funReload!();
        String temp = 'Đã chấp nhận đóng góp thành công';
        if (state.status == 'rejected') temp = 'Đã từ chối đóng góp thành công';
        UtilUI.showCustomDialog(context, temp, title: MultiLanguage.get('ttl_alert'))
            .whenComplete(() => UtilUI.goBack(context, false));
      }
    });

    if (page.isReview) {
      _locationProvinces.setValue('', page.detail!.province_name);
      _locationDistrict.setValue('', page.detail!.district_name);
      _addressCtrl.text = page.detail!.address;
      _ctrTreeName.text = page.detail!.tree_name;
      _ctrName.text = page.detail!.pest_name;
      _ctrDescription.text = page.detail!.description;
      return;
    }

    if (page.images.isNotEmpty) {
      _images.addAll(page.images);
      bloc!.add(ShowImageDiagnosePestsEvent());
    }
    bloc!.add(LoadingEvent(true));
    Geolocator.getCurrentPosition()
        .then((position) => _setLatLng(position))
        .catchError((_, __) => bloc!.add(LoadingEvent(false)))
        .onError((_, __) => bloc!.add(LoadingEvent(false)));
    if (page.tree.isNotEmpty) _ctrTreeName.text = page.tree;
    if (page.diagnosis.isNotEmpty) _ctrName.text = page.diagnosis;
  }

  @override
  Widget createUI() {
    final page = widget as DiagnosePetsContributePage;
    final padding = SizedBox(height: 40.sp);
    final list = ListView(padding: EdgeInsets.zero, children: [
      Padding(
        padding: EdgeInsets.all(12.sp),
        child: Text("Vị trí ${page.readOnly?'sâu bệnh':'đóng góp'} *",style: TextStyle(fontSize: 40.sp,color: Colors.black,fontWeight: FontWeight.normal),),
      ),
      Row(
        children: [
          Expanded(
            child: _lineInfo(
              MultiLanguage.get('lbl_province'),
              CoreButtonCustom(
                    () => _showLocations(isProvince: true),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30.sp, vertical: 40.sp),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.sp),
                    color: const Color(0xFFF5F6F8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: BlocBuilder(
                            bloc: bloc,
                            buildWhen: (oldS, newS) => newS is SetLocationState,
                            builder: (context, state) => Padding(
                              child: LabelCustom(
                                  _locationProvinces.name.isEmpty
                                      ? MultiLanguage.get('lbl_location')
                                      : _locationProvinces.name,
                                  size: 40.sp,
                                  color: const Color(0xFF494747),
                                  weight: FontWeight.normal,
                                  overflow: TextOverflow.ellipsis,
                                  line: 1),
                              padding: EdgeInsets.symmetric(vertical: 4.sp),
                            )),
                      ),
                      SizedBox(
                        width: 16.sp,
                      ),
                      Icon(Icons.arrow_drop_down, color: const Color(0xFF919191), size: 48.sp)
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 20.sp,),
          Expanded(
            child: _lineInfo(
              MultiLanguage.get('lbl_district'),
              CoreButtonCustom(
                    () => _showLocations(isProvince: false, idProvince: _locationProvinces.id),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30.sp, vertical: 40.sp),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.sp),
                    color: const Color(0xFFF5F6F8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: BlocBuilder(
                          bloc: bloc,
                          buildWhen: (oldsState, newState) =>
                          newState is SetLocationState,
                          builder: (context, state) {
                            return LabelCustom(
                                _locationDistrict.name.isEmpty
                                    ? MultiLanguage.get('lbl_location')
                                    : _locationDistrict.name,
                                size: 40.sp,
                                overflow: TextOverflow.ellipsis,
                                color: const Color(0xFF494747),
                                weight: FontWeight.normal,
                                line: 1);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 16.sp,
                      ),
                      Icon(Icons.arrow_drop_down, color: const Color(0xFF919191), size: 48.sp)
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      padding,
      const Text('Địa chỉ chi tiết'),
      padding,
      Row(children: [
        Expanded(child: UtilUI.createTextField(context, _addressCtrl, _focusAddress, _focusTreeName, 'Nhập địa chỉ *',
            inputType: TextInputType.multiline, inputAction: TextInputAction.newline, maxLines: null,
            padding: EdgeInsets.all(30.sp), readOnly: page.isReview)),
        SizedBox(width: 20.sp),
        ButtonImageWidget(5, _openMap, Image.asset('assets/images/v5/ic_map_main2.png',
            width: 128.sp, height: 128.sp, fit: BoxFit.scaleDown))
      ]),
      padding,
      const Text('Loại cây trồng'),
      padding,
      catalogues.isNotEmpty ? Row(children: [
        Expanded(child: UtilUI.createTextField(context, _ctrTreeName, _focusTreeName, _focusName, 'Nhập/chọn loại cây trồng *', readOnly: page.isReview)),
        SizedBox(width: 32.sp),
        ButtonImageWidget(16.sp, _selectTree, Container(padding: EdgeInsets.all(20.sp),
            child: Icon(Icons.arrow_drop_down, color: Colors.white, size: 84.sp)), color: StyleCustom.primaryColor)
      ]) : UtilUI.createTextField(context, _ctrTreeName, _focusTreeName, _focusName, 'Nhập/chọn loại cây trồng *', readOnly: page.isReview),
      padding,
      const Text('Tình trạng *'),
      padding,
      _diagnosis.isNotEmpty ? Row(children: [
        Expanded(child: UtilUI.createTextField(context, _ctrName, _focusName, _focusDescription, 'Nhập/chọn tình trạng *', readOnly: page.isReview)),
        SizedBox(width: 32.sp),
        ButtonImageWidget(16.sp, _selectStatus, Container(padding: EdgeInsets.all(20.sp),
            child: Icon(Icons.arrow_drop_down, color: Colors.white, size: 84.sp)), color: StyleCustom.primaryColor)
      ]) : UtilUI.createTextField(context, _ctrName, _focusName, _focusDescription, 'Nhập/chọn tình trạng *', readOnly: page.isReview),
      padding,
      Text(MultiLanguage.get('lbl_product_des')),
      padding,
      UtilUI.createTextField(
          context,
          _ctrDescription,
          _focusDescription,
          null,
          page.readOnly ? '' : MultiLanguage.get('msg_input_content') + ' *',
          inputType: TextInputType.multiline,
          inputAction: TextInputAction.newline,
          maxLines: 4, readOnly: page.isReview,
          padding: const EdgeInsets.all(12)),
      padding,
      page.isReview ? FadeInImage.assetNetwork(placeholder: 'assets/images/ic_default.png', width: 1.sw, height: 0.58.sw,
          image: Util.getRealPath(page.detail!.image),
          fit: BoxFit.scaleDown, imageScale: 0.5, imageErrorBuilder: (_, __, ___) =>
              Image.asset('assets/images/ic_default.png', width: 1.sw, height: 0.58.sw, fit: BoxFit.fill)) : _createListImageUI(),
      /*BlocBuilder(
          bloc: bloc,
          builder: (context, state) {
            double height = 10;
            if (height < 0) {
              _isFinished = false;
              _controller = null;
              return const SizedBox();
            }
            return WebViewX(
                initialMediaPlaybackPolicy:
                AutoMediaPlaybackPolicy.alwaysAllow,
                initialContent: _description,
                initialSourceType: SourceType.html,
                height: height,
                width: 1.sw,
                onWebViewCreated: (controller) {
                  _controller ??= controller;
                },
                webSpecificParams: const WebSpecificParams(
                    webAllowFullscreenContent: false),
                mobileSpecificParams: const MobileSpecificParams(
                    androidEnableHybridComposition: true),
                navigationDelegate: (navigation) {
                  if (!_isFinished) {
                    return NavigationDecision.navigate;
                  }
                  String http = navigation.content.source;
                  if (!http.contains('http')) {
                    http = 'https://$http';
                  }
                  launch(http, enableJavaScript: true);
                  return NavigationDecision.prevent;
                },
                onPageFinished: (value) async {
                  if (!_isFinished) {
                    _isFinished = true;
                    await _controller?.evalRawJavascript(constants.jvWebView);
                    await Future.delayed(const Duration(seconds: 1));
                    await _controller?.scrollBy(0, 10);
                  }
                });
          }),*/
    ]);
    return Scaffold(backgroundColor: Colors.white,
        appBar: TaskBarWidget(page.readOnly ? 'Cảnh báo sâu bệnh' : (page.isReview ? 'Duyệt đóng góp loại bệnh' : 'lbl_contribute_type_pest'),
            lblButton: page.isReview ? '' : MultiLanguage.get('btn_send'), onPressed: page.isReview ? null : _createDiagnoticPestContribute).createUI(),
        body: Padding(padding: EdgeInsets.all(40.sp), child: page.isReview && !page.readOnly ? Column(children: [
          Expanded(child: list),
          SizedBox(height: 40.sp),
          Row(children: [
            ButtonImageWidget(16.sp, () => _setStatus('rejected'),
                Container(padding: EdgeInsets.all(40.sp), width: 0.5.sw - 60.sp, child: LabelCustom('Từ chối',
                    size: 48.sp, weight: FontWeight.normal, align: TextAlign.center)), color: Colors.red),
            ButtonImageWidget(16.sp, () => _setStatus('accepted'),
                Container(padding: EdgeInsets.all(40.sp), width: 0.5.sw - 60.sp, child: LabelCustom('Chấp nhận',
                    size: 48.sp, weight: FontWeight.normal, align: TextAlign.center)), color: StyleCustom.primaryColor)
          ], mainAxisAlignment: MainAxisAlignment.spaceBetween)
        ]) : list));
  }

  Widget _lineInfo(String title, Widget widget) => Padding(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
          child: Text(
            title,
            style: TextStyle(color: const Color(0xFF787878), fontSize: 40.sp,),
          ),
        ),
        SizedBox(height: 8.sp,),
        widget,
      ],
    ),
    padding: EdgeInsets.only(bottom: 16.sp),
  );

  Widget _createListImageUI() => Row(children: [
        Expanded(child: _createImageUI()),
        DottedBorder(
            padding: EdgeInsets.all(50.sp),
            strokeWidth: 1,
            color: Colors.grey,
            dashPattern: const [4],
            child: IconButton(
                onPressed: () {
                  selectImage(_imageTypes);
                },
                icon: Icon(Icons.add, size: 100.sp, color: Colors.grey)))
      ]);

  Widget _createImageUI() => SizedBox(
      height: 240.sp,
      child: BlocBuilder(
          bloc: bloc,
          buildWhen: (oldState, newState) =>
              newState is ShowImageDiagnosePestsState,
          builder: (context, state) => ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              itemBuilder: (context, index) => DiagnosePestsImageItemPage(
                  _images[index], () => _deleteImage(index)))));

  _initImageTypes() {
    multiSelect = true;
    setOnlyImage();
    _imageTypes.add(ItemModel(
        id: languageKey.lblCamera,
        name: MultiLanguage.get(languageKey.lblCamera)));
    _imageTypes.add(ItemModel(
        id: languageKey.lblGallery,
        name: MultiLanguage.get(languageKey.lblGallery)));
  }

  _deleteImage(int index) {
    _images.removeAt(index);
    bloc!.add(ShowImageDiagnosePestsEvent());
  }

  void _setLatLng(position) {
    _lat = position.latitude;
    _lng = position.longitude;
    bloc!.add(GetLocationEvent(_lat.toString(), _lng.toString()));
  }

  void _openMap() {
    if ((widget as DiagnosePetsContributePage).isReview) return;
    LatLng? current;
    try {
      if (_lat + _lng != 0) current = LatLng(_lat, _lng);
    } catch (_) {}
    UtilUI.goToNextPage(context, NutritionLocPage(current: current), funCallback: (value) {
      if (value != null) _setLatLng(value);
    });
  }

  void _selectTree() => UtilUI.showOptionDialog(context, 'Chọn loại cây', catalogues, '').then((value) {
    if (value != null) {
      _ctrTreeName.text = value.name;
      _ctrName.text = '';
    }
  });

  void _selectStatus() {
    final list = _diagnosis.where((ele) => ele.name.toLowerCase().contains(_ctrTreeName.text.toLowerCase())).toList();
    UtilUI.showOptionDialog(context, 'Chọn tình trạng bệnh', list.isEmpty ? _diagnosis : list, '').then((value) {
      if (value != null) _ctrName.text = value.id;
    });
  }

  void _showDialogCreatePestContributeSuccess() {
    clearFocus();
    UtilUI.showCustomDialog(
      context,
      MultiLanguage.get('msg_thank_feedback_pets'),
      title: MultiLanguage.get('lbl_success'),
    ).then((value) {
      Navigator.of(context).pop();
    });
  }

  void _createDiagnoticPestContribute() {
    if(_locationProvinces.name.isEmpty || _locationDistrict.name.isEmpty) {
      UtilUI.showCustomDialog(context, "Chọn vị trí đóng góp");
      return;
    }
    if(_addressCtrl.text.isEmpty) {
      UtilUI.showCustomDialog(context, "Vui lòng nhập địa chỉ").then((value) => _focusAddress.requestFocus());
      return;
    }
    if (_ctrTreeName.text.isEmpty) {
      UtilUI.showCustomDialog(context, 'Nhập/chọn loại cây').then((value) => _focusTreeName.requestFocus());
      return;
    }
    if (_ctrName.text.isEmpty) {
      UtilUI.showCustomDialog(context, 'Nhập/chọn tình trạng').then((value) => _focusName.requestFocus());
      return;
    }
    if (_ctrDescription.text.isEmpty) {
      UtilUI.showCustomDialog(context, MultiLanguage.get('msg_input_content')).then((value) => _focusDescription.requestFocus());
      return;
    }
    if (_images.isEmpty == true) {
      UtilUI.showCustomDialog(context, MultiLanguage.get('msg_please_choose_image'));
      return;
    }
    bloc!.add(CreateDiagnostisPestEvent(
        _locationProvinces.id,_locationDistrict.id,_addressCtrl.text,_ctrTreeName.text,_ctrName.text,_ctrDescription.text,_images));
  }

  void _setStatus(String status) => bloc!.add(UpdateStatusEvent((widget as DiagnosePetsContributePage).detail!.id.toString(), status));
}
