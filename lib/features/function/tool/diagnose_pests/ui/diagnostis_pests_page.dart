import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_html/flutter_html.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/ads.dart';
import 'package:hainong/common/ui/banner_2nong.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/image_network_asset.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/permission_image_page_state.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import 'package:hainong/common/ui/title_helper.dart';
import 'package:hainong/features/product/ui/image_item_page.dart';
import '../diagnose_pests_bloc.dart';
import '../model/diagnostic_model.dart';
import '../model/plant_model.dart';
import 'diagnostic_result_page.dart';
import 'diagnostis_pests_contribute_page.dart';
import 'diagnostis_pests_detail_page.dart';
import 'package:hainong/common/models/file_byte.dart';
import 'package:hainong/common/ui/button_custom.dart';
import 'package:hainong/common/ui/checkbox_custom.dart';
import 'package:hainong/common/ui/loading_percent.dart';
import 'package:hainong/features/function/support/pests_handbook/ui/pests_handbook_list_page.dart';
import 'diagnostis_history_page.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:image_cropper/image_cropper.dart';

class DiagnosePestsPage extends BasePage {
  DiagnosePestsPage({Key? key}) : super(key: key, pageState: _DiagnosePestsPageState());
}

class _DiagnosePestsPageState extends PermissionImagePageState {
  final List<ItemModel> _imageTypes = [];
  final List<PlantModel> _catalogues = [];
  List? _results;
  final TextEditingController _ctrDes = TextEditingController();
  int _indexCatalogue = -2, _indexPest = -1, _point = 0, _indexResult = -1;
  String _guidCamera = '';
  bool _popupCamera = true, _isOpenCam = false;

  @override
  void dispose() {
    if (Constants().isLogin) Constants().indexPage = null;
    _imageTypes.clear();
    _catalogues.clear();
    _results?.clear();
    _ctrDes.dispose();
    super.dispose();
  }

  @override
  loadFiles(List<File> files) async {
    showLoadingPermission();
    bool hasAdd = false;
    dynamic temp, name, size, error = '';
    for (int i = 0; i < files.length && images!.length < 5; i++) {
      //if (images!.length < 5) {
        temp = await files[i].readAsBytes();
        name = files[i].path.split('/');
        if (name != null && name.isNotEmpty) name = name[name.length - 1];
        if (Util.isImage(files[i].path)) {
          size = await _checkSize(temp, name: name, showError: false);
          if (size.isEmpty) {
            images!.add(FileByte(temp, files[i].path));
            hasAdd = true;
          } else error += '$name $size\n';
        }
      //}
    }
    if (hasAdd) {
      bloc!.add(ShowImageDiagnosePestsEvent());
      if (_isOpenCam) _editImage(images!.length - 1);
    }
    showLoadingPermission(value: false);
    if (error.isNotEmpty) UtilUI.showCustomDialog(context, 'Ảnh không hợp lệ\n${error}Kích thước ảnh nhỏ hơn tiêu chuẩn (448x448)', alignMessageText: TextAlign.left);
  }

  @override
  void showLoadingPermission({bool value = true}) => bloc!.add(LoadingEvent(value));

  @override
  void initState() {
    multiSelect = true;
    setOnlyImage();
    images = [];
    bloc = DiagnosePestsBloc(const DiagnosePestsState());
    super.initState();
    _initImageTypes();
    bloc!.stream.listen((state) {
      if (state is UploadFileDiagnosePestsState && isResponseNotError(state.response)) {
        /*for(Diagnostic ele in state.response.data.diagnostics) {
          if (ele.item_id.isNotEmpty) _results.add(ele.item_id);
        }
        if (_results.isEmpty) {
          for(var ele in state.response.data.ids) _results.add(ele.toString());
        }*/
        _results = state.response.data.ids;
        String content = MultiLanguage.get('lbl_result');
        if (state.response.data.summaries.isEmpty && state.response.data.tree.isEmpty) {
          content += '<b>' + MultiLanguage.get('lbl_unknown') + '</b>\nBạn có thể thử lại với tính năng nhận dạng nâng cao.';
          _showDialogDiagnostic(state.response.data.diagnostics, content, false);
        } else {
          bool hasCreate = false;
          state.response.data.summaries.forEach((ele) {
            final bool hasPercent = !ele.suggest.toLowerCase()
                .contains(MultiLanguage.get('lbl_unknown').toLowerCase());
            if (hasPercent) hasCreate = true;
            content += '</br>  - ${hasPercent ? '<a href="${ele.suggest}">' : ''}${ele.suggest}${hasPercent ? '</a>' : ''}'
                '${hasPercent ? ' (${ele.percent}%)' : ''}';
          });
          Map<String, dynamic> tree = state.response.data.tree;
          _indexResult = -1;
          if (Util.checkKeyFromJson(tree, 'id')) {
            for(int i = _catalogues.length - 1; i > -1; i--) {
              if (_catalogues[i].id == (tree['id']??-1).toString()) {
                _indexResult = i;
                break;
              }
            }
          }
          UtilUI.goToNextPage(context, DiaResultPage(state.response.data, hasCreate ? content : '', images!, _catalogues), funCallback: (value) => _showDialogRating());
        }
      } else if (state is CreatePostDiagnosePestsState) {
        _handleResponse(state.response, _handleCreatePost);
      } else if (state is LoadCatalogueState) {
        _catalogues.addAll(state.list);
      } else if (state is PostRatingState && isResponseNotError(state.response, passString: true)) {
        UtilUI.showCustomDialog(context, MultiLanguage.get('msg_rating_success'), title: MultiLanguage.get('ttl_alert'));
      } else if (state is LoadOptionState) {
        _guidCamera = state.value;
        _popupCamera = state.popup;
      }
    });
    bloc!.add(LoadCatalogueEvent());
    bloc!.add(LoadOptionEvent());
  }

  _handleResponse(base, Function funHandleDetail) {
    if (base.checkTimeout()) UtilUI.showDialogTimeout(context);
    else if (base.checkOK()) funHandleDetail(base);
  }

  _handleCreatePost(base) {
    UtilUI.showCustomDialog(
            context, MultiLanguage.get('msg_create_post_success'),
            title: MultiLanguage.get('ttl_alert'))
        .then((value) => _showDialogRating());
  }

  @override
  Widget createUI() => Stack(children: [
    Scaffold(backgroundColor: Colors.white, appBar: AppBar(elevation: 0, centerTitle: true,
      title: const Padding(padding: EdgeInsets.only(right: 48), child:
        TitleHelper('lbl_diagnose_pests', url: 'https://help.hainong.vn/muc/7'))),
      body: Column(children: [
        Expanded(child: ListView(padding: EdgeInsets.zero, children: [
          const Ads('pest'),

          BlocBuilder(bloc: bloc, buildWhen: (state1, state2) => state2 is ShowImageDiagnosePestsState,
            builder: (context, state) => images!.isNotEmpty ? Container(padding: EdgeInsets.symmetric(horizontal: 40.sp),
                height: 0.26.sh, child: imageUI(_editImage, _deleteImage, padding: 0)) : const SizedBox()),

          Stack(children: [
            BlocBuilder(bloc: bloc, buildWhen: (state1, state2) => state2 is ShowImageDiagnosePestsState || state2 is ChangeCatalogueState,
                builder: (context, state) => _addMorePhoto(isAddMore: images!.isEmpty)),
            ButtonImageWidget(100, () => checkPermissions(_imageTypes[0]),
              Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp, vertical: 16.sp), child: Row(children: [
                LabelCustom('Chụp ảnh', size: 48.sp, weight: FontWeight.w400),
                const SizedBox(width: 5),
                Image.asset('assets/images/ic_camera.png', width: 48.sp, height: 48.sp, color: Colors.white)
              ], mainAxisSize: MainAxisSize.min)), color: StyleCustom.primaryColor)
          ], alignment: Alignment.bottomCenter),

          SizedBox(height: 40.sp),
          ButtonImageWidget(0, () {
            _changeCatalogue(_indexCatalogue == -2 ? 0 : -2);
          }, BlocBuilder(bloc: bloc, buildWhen: (state1, state2) => state2 is ChangeCatalogueState,
              builder: (context, state) {
                String temp = 'Nhận dạng nâng cao ';
                if (_indexCatalogue > -1) temp = 'Nhận dạng tự động ';
                return Row(children: [
                  LabelCustom(temp, color: const Color(0xFF1AAD80), align: TextAlign.center,
                      size: 48.sp, weight: FontWeight.normal),
                  Icon(_indexCatalogue == -2 ? Icons.keyboard_arrow_down :
                  Icons.keyboard_arrow_up, color: const Color(0xFF1AAD80), size: 64.sp)
                ], mainAxisAlignment: MainAxisAlignment.center);
              })),

          BlocBuilder(bloc: bloc,
              buildWhen: (state1, state2) => state2 is ChangeCatalogueState || state2 is LoadCatalogueState,
              builder: (context, state) {
                if (_indexCatalogue == -2) return const SizedBox();
                final List<Widget> list = [];
                for(int i = 0; i < _catalogues.length; i++) {
                  list.add(Expanded(child: ButtonImageWidget(10, () => _changeCatalogue(i), Column(children: [
                    ClipRRect(borderRadius: BorderRadius.circular(200),
                        child: ImageNetworkAsset(path: _catalogues[i].icon, width: 0.24.sw - 80.sp, height: 0.24.sw - 80.sp,
                        fit: BoxFit.cover, opacity: i == _indexCatalogue ? 1.0 : 0.5)),
                    SizedBox(height: 20.sp),
                    LabelCustom(_catalogues[i].name, size: 42.sp, color: Color(i == _indexCatalogue ? 0xFF1AAD80 : 0xFFACACAC), weight: FontWeight.normal),
                    if (i == _indexCatalogue) Container(decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF1AAD80), width: 4.sp)),
                        width: 1.sw/12 , alignment: Alignment.center, margin: const EdgeInsets.only(top: 2))
                  ]))));
                }
                return Padding(padding: EdgeInsets.only(top: 40.sp), child: Row(children: list));
              }),

          Container(padding: EdgeInsets.all(24.sp), margin: EdgeInsets.all(40.sp),
              decoration: BoxDecoration(color: const Color(0xFFF7F7F7), borderRadius: BorderRadius.circular(8.sp)),
              child: Text(MultiLanguage.get('msg_note_rice'), style: TextStyle(color: const Color(0xFF929292), fontSize: 30.sp), textAlign: TextAlign.center))
        ])),

        /*Container(width: 1.sw, padding: EdgeInsets.all(40.sp),
            child: ButtonCustom(_history, 'Danh sách chẩn đoán',
                padding: EdgeInsets.all(40.sp), size: 42.sp, textColor: const Color(0xFF4D4D4D),
                color: const Color(0xFFF3FCF9), radius: 16.sp, elevation: 0)),*/

        Divider(height: 16.sp, color: const Color(0xFFF5F5F5), thickness: 16.sp),

        Padding(padding: EdgeInsets.all(40.sp), child: IntrinsicHeight(child: Row(children: [
          Expanded(child: ButtonImageWidget(16.sp, _history,
            Container(padding: EdgeInsets.all(32.sp), child: Column(children: [
              Icon(Icons.history_sharp, size: 44.sp, color: const Color(0xFF2ECF4D)),
              SizedBox(height: 24.sp),
              LabelCustom('Lịch sử chẩn đoán', size: 42.sp, color: const Color(0xFF4D4D4D), align: TextAlign.center)
            ]),
          ), color: const Color(0xFFF3FCF9))),
          SizedBox(width: 40.sp),
          Expanded(child: ButtonImageWidget(16.sp, _contributePets, Container(padding: EdgeInsets.all(32.sp),
            child: Column(children: [
              Image.asset('assets/images/v5/ic_contribute.png', width: 44.sp, height: 44.sp, fit: BoxFit.scaleDown),
              SizedBox(height: 24.sp),
              LabelCustom('Đóng góp dữ liệu', size: 42.sp, color: const Color(0xFF4D4D4D), align: TextAlign.center)
            ]),
          ), color: const Color(0xFFF3FCF9)))
        ]))),

        BlocBuilder(bloc: bloc, buildWhen: (state1, state2) => state2 is ShowImageDiagnosePestsState,
          builder: (context, state) => images!.isNotEmpty ? Column(children: [
            Container(width: 1.sw, padding: EdgeInsets.symmetric(horizontal: 40.sp),
              child: ButtonCustom(_diagnostic, MultiLanguage.get('btn_diagnose_pests'),
                  padding: EdgeInsets.all(40.sp), size: 48.sp,
                  color: const Color(0xFF0E986F), radius: 16.sp, elevation: 0)),
            Container(margin: EdgeInsets.fromLTRB(40.sp, 20.sp, 40.sp, 40.sp),
                padding: EdgeInsets.all(20.sp),
                decoration: BoxDecoration(color: const Color(0xFFF3FCF9), borderRadius: BorderRadius.circular(8.sp)),
                child: Text(MultiLanguage.get('msg_ai'),
              style: TextStyle(color: const Color(0xFFA08805), fontSize: 36.sp), textAlign: TextAlign.center))
          ]) : SizedBox(height: 20.sp))
      ])),
    const Banner2Nong('pest'),
    BlocBuilder(bloc: bloc, buildWhen: (oldState, newState) => newState is ShowPercentState,
      builder: (context, state) {
        bool show = false;
        if (state is ShowPercentState) show = state.value;
        return show ? LoadingPercent(images!.length * 5) : const SizedBox();
      })
  ], alignment: Alignment.bottomRight);

  @override
  Widget imageUI(Function funAdd, Function funDelete, {double? padding}) => images!.length > 1 ?
    ListView.separated(padding: EdgeInsets.only(top: 40.sp), itemCount: images!.length, scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(), addRepaintBoundaries: false,
      separatorBuilder: (context, index) => SizedBox(width: 20.sp),
      itemBuilder: (context, index) => ImageItemPests(images![index], index, funAdd, funDelete, padding: padding)) :
  Container(padding: EdgeInsets.only(top: 40.sp), alignment: Alignment.center, child: ImageItemPests(images![0], 0, funAdd, funDelete, padding: padding));

  @override
  void openCameraGallery() {
    _isOpenCam = checkPermission == languageKey.lblCamera;
    _isOpenCam && _guidCamera.isNotEmpty && _popupCamera ? showDialog(barrierDismissible: false, context: context,
        builder: (context) => Dialog(shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.sp))),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 1.sw, decoration: BoxDecoration(color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.sp), topRight: Radius.circular(30.sp))),
                  child: Padding(padding: EdgeInsets.all(40.sp), child: Stack(children: [
                    Align(alignment: Alignment.topRight, child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(false),
                        child: const Icon(Icons.close, color: Color(0xFF626262)))),
                    Center(child: LabelCustom('Lưu ý', color: const Color(0xFF191919), size: 60.sp))
                  ]))),
              Flexible(child: SingleChildScrollView(child: Padding(
                  padding: EdgeInsets.fromLTRB(20.sp, 40.sp, 20.sp, 40.sp),
                  child: Html(data: _guidCamera, style: {
                    'html, body, p': Style(margin: EdgeInsets.zero, padding: EdgeInsets.zero, fontSize: FontSize(42.sp),
                        color: Colors.black),
                    'img': Style(margin: EdgeInsets.zero, padding: EdgeInsets.zero, width: 1.sw, height: 0.5.sw),
                  })))),
              Padding(padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 40.sp),
                  child: BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is CheckPopupCameraState,
                      builder: (context, state) => Row(children: [
                        ButtonImageWidget(0, _checkPopupCamera,
                            Icon(_popupCamera ? Icons.check_box_outline_blank : Icons.check_box, size: 48.sp, color: _popupCamera ? Colors.black54 : StyleCustom.primaryColor)),
                        LabelCustom(' Không hiện lưu ý vào lần sau', size: 42.sp, color: Colors.blue, weight: FontWeight.normal)
                      ]))),
              Row(crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center, children: [
                    ElevatedButton(style: ElevatedButton.styleFrom(primary: StyleCustom.buttonColor),
                        child: LabelCustom(MultiLanguage.get(languageKey.btnOK)), onPressed: _saveCheckPopupCamera)
                  ]),
              SizedBox(height: 40.sp)
            ]))).whenComplete(() => super.openCameraGallery()) : super.openCameraGallery();
  }

  Widget _addMorePhoto({bool isAddMore = true}) => ButtonImageWidget(8.sp, () => selectImage(_imageTypes),
      Container(alignment: Alignment.center, height: isAddMore ? 0.4.sh : 0.2.sh, width: 1.sw,
        margin: EdgeInsets.all(40.sp),
        decoration: BoxDecoration(
          image: DecorationImage(fit: BoxFit.fill,
              image: Image.asset('assets/images/v2/ic_background_${isAddMore ? 'camera' : 'addmore'}.png').image),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/v2/ic_add_photo.png',
                  width: isAddMore ? 200.sp : 80.sp, height: isAddMore ? 200.sp : 80.sp),
              SizedBox(height: isAddMore ? 70.sp : 10.sp),
              Padding(padding: EdgeInsets.symmetric(horizontal: 80.sp), child: Wrap(children: [
                LabelCustom('Chọn hình để nhận dạng và chẩn đoán ',
                    color: const Color(0xFF2C2C2C), size: 46.sp, weight: FontWeight.normal, align: TextAlign.center),
                LabelCustom(
                    (_indexCatalogue > -1 ? 'nâng cao cho cây ' : 'tự động'),
                    color: const Color(0xFF2C2C2C), size: 46.sp, weight: FontWeight.normal, align: TextAlign.center),
                LabelCustom(
                    (_indexCatalogue > -1 ? _catalogues[_indexCatalogue].name.toLowerCase() : ''),
                    color: Colors.orange, size: 46.sp, align: TextAlign.center),
              ], alignment: WrapAlignment.center)),
              SizedBox(height: isAddMore ? 40.sp : 20.sp),
              if (isAddMore) Padding(padding: EdgeInsets.symmetric(horizontal: 80.sp),
                  child: Text('Cần hình ảnh cận cảnh và sắc nét để tăng độ chính xác (Cách điểm cần nhận dạng 20-30cm)',
                  style: TextStyle(color: const Color(0xFF2C2C2C), fontSize: 40.sp), textAlign: TextAlign.center))
            ]),
      ));

  void _initImageTypes() {
    multiSelect = true;
    setOnlyImage();
    _imageTypes.add(ItemModel(
        id: languageKey.lblCamera,
        name: MultiLanguage.get(languageKey.lblCamera)));
    _imageTypes.add(ItemModel(
        id: languageKey.lblGallery,
        name: MultiLanguage.get(languageKey.lblGallery)));
  }

  void _deleteImage(int index) {
    images!.removeAt(index);
    if (images!.isEmpty && _indexCatalogue > -1 &&
        _indexPest > -1) _catalogues[_indexCatalogue].diagnostics[_indexPest].selected = false;
    bloc!.add(ShowImageDiagnosePestsEvent());
  }

  void _editImage(int index) async {
    var dir = Directory.systemTemp.createTempSync().path;
    var temp = File("$dir/temp_photo.png");
    temp.writeAsBytesSync(images![index].bytes);
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: temp.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cắt ảnh',
            toolbarColor: StyleCustom.primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(title: 'Cắt ảnh')
      ],
    );

    temp.delete();
    if (croppedFile != null) {
      croppedFile.readAsBytes().then((value) async {
        if (await _checkSize(value)) return;
        images![index].bytes = value.toList();
        bloc!.add(ShowImageDiagnosePestsEvent());
      });
    }
  }

  Future<dynamic> _checkSize(Uint8List bytes, {String? name, bool showError = true}) async {
    var decodedImage = await decodeImageFromList(bytes);
    if (decodedImage.width < 448 || decodedImage.height < 448) {
      name = (name != null && name.isNotEmpty) ? ' ($name)' : '';
      if (showError) UtilUI.showCustomDialog(context, 'Ảnh không hợp lệ$name.\nKích thước ảnh (${decodedImage.width}x${decodedImage.height}) nhỏ hơn tiêu chuẩn (448x448)', alignMessageText: TextAlign.left);
      return showError ? true : '(${decodedImage.width}x${decodedImage.height})';
    }
    return showError ? false : '';
  }

  void _changeCatalogue(int index) {
    if (_indexCatalogue == index) return;
    if (index > -1 && _catalogues[index].name.toLowerCase() == "sầu riêng") {
      UtilUI.showCustomDialog(context, "Tính năng AI trên cây Sầu riêng đang được phát triển, cần đóng góp thêm dữ liệu", lblOK: "Tiếp tục");
    }
    _indexCatalogue = index;
    if (!bloc!.isClosed) bloc!.add(ChangeCatalogueEvent());
    _changePest(-1);
  }

  void _changePest(int index) {
    int temp = _indexResult;
    if (_indexCatalogue > -1 && index > -1) temp = _indexCatalogue;
    if (temp > -1 && index > -1) {
      if (_indexPest == index && _indexPest > -1) {
        bool value = _catalogues[temp].diagnostics[_indexPest].selected;
        _catalogues[temp].diagnostics[_indexPest].selected = !value;
        if (value) index = -1;
      } else {
        if (_indexPest > -1) _catalogues[temp].diagnostics[_indexPest].selected = false;
        _catalogues[temp].diagnostics[index].selected = true;
      }
      Util.trackActivities('pest_diagnosis', path: 'Diagnose Pests Screen -> Check for ${_catalogues[temp].diagnostics[index].name}');
    }
    _indexPest = index;
    if (!bloc!.isClosed) bloc!.add(ChangePestEvent());
  }

  void _diagnostic() {
    if (constants.isLogin) {
      _results?.clear();
      showLoadingPermission();
      _indexPest = -1;
      _determinePosition().then((value) {
        bloc!.add(UploadFileDiagnosePestsEvent(
            images!,
            _indexCatalogue < 0 ? '' : _catalogues[_indexCatalogue].id,
            value.latitude.toString(),
            value.longitude.toString()));
      }).catchError((e) {
        bloc!.add(ShowPercentEvent(false));
        UtilUI.showCustomDialog(context, e);
      });
      Util.trackActivities('pest_diagnosis', path: 'Diagnose Pests Screen -> Touch Diagnose Button');
    } else UtilUI.showDialogTimeout(context, message: languageKey.msgLoginOrCreate);
  }

  void _history() => constants.isLogin ? UtilUI.goToNextPage(context, DiagnosisHistoryPage()) :
      UtilUI.showDialogTimeout(context, message: languageKey.msgLoginOrCreate);

  void _contributePets() async {
    if (await UtilUI().alertVerifyPhone(context)) return;
    constants.isLogin ? UtilUI.goToNextPage(context, DiagnosePetsContributePage(_catalogues))
        : UtilUI.showDialogTimeout(context, message: languageKey.msgLoginOrCreate);
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
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) return Future.error(MultiLanguage.get('msg_gps_denied'));
    }

    return await Geolocator.getCurrentPosition();
  }

  void _showDialogRating() => _createDialogRating().then((value) {
    if (value!) {
      int index = _indexResult;
      if (_indexCatalogue > -1) index = _indexCatalogue;
      bloc!.add(PostRatingEvent(_point, _ctrDes.text, _results, _indexPest > -1 ? _catalogues[index].diagnostics[_indexPest].id : ''));
    }
  }).whenComplete(() => _changeCatalogue(-2));

  Future<bool?> _createDialogRating() {
    images?.clear();
    _point = 0;
    _ctrDes.text = '';
    bloc!.add(ShowImageDiagnosePestsEvent());

    List<Widget> actions = [];
    actions.add(_addAction(MultiLanguage.get(languageKey.btnCancel), false,
        color: Colors.grey));
    actions.add(_addAction(MultiLanguage.get(languageKey.btnOK), true));

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
            title: Text(MultiLanguage.get('ttl_rating')),
            actions: actions,
            content: SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  LabelCustom(MultiLanguage.get('msg_rating'), size: 40.sp, color: Colors.black, weight: FontWeight.normal),
                  Padding(padding: EdgeInsets.only(top: 20.sp, bottom: 20.sp),
                      child: BlocBuilder(bloc: bloc, buildWhen: (state1, state2) => state2 is ChangePointState,
                          builder: (context, state) => UtilUI.createStars(
                              rate: _point,
                              size: 80.sp,
                              color: StyleCustom.buttonColor,
                              onClick: (index) => _clickStart(context, index),
                              hasFunction: true))),
                  TextFieldCustom(_ctrDes, null, null, MultiLanguage.get('lbl_des'), maxLine: 2,
                      padding: EdgeInsets.all(20.sp), type: TextInputType.multiline, inputAction: TextInputAction.newline),
                  BlocBuilder(bloc: bloc, buildWhen: (state1, state2) => state2 is ChangePestState,
                      builder: (context, state) {
                        int index = _indexResult;
                        if (_indexCatalogue > -1) index = _indexCatalogue;
                        if (index > -1) {
                          final List<Widget> list = [Padding(padding: EdgeInsets.only(top: 40.sp, bottom: 20.sp),
                              child: LabelCustom(MultiLanguage.get('lbl_guess_pest'),
                                  size: 40.sp, color: Colors.black, weight: FontWeight.normal))];
                          final pests = _catalogues[index].diagnostics;
                          for (int i = 0; i < pests.length - 1; i += 2) {
                            list.add(Padding(padding: EdgeInsets.only(bottom: 32.sp),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                          child: CheckboxCustom(
                                              i,
                                              pests[i],
                                              _changePest,
                                              pests[i].selected &&
                                                  i == _indexPest)),
                                      SizedBox(width: 10.sp),
                                      Expanded(
                                          child: CheckboxCustom(
                                              i + 1,
                                              pests[i + 1],
                                              _changePest,
                                              pests[i + 1].selected &&
                                                  i + 1 == _indexPest))
                                    ])));}
                          return Column(children: list, crossAxisAlignment: CrossAxisAlignment.start);
                        }
                        return const SizedBox();
                      })
                ]))));
  }

  Widget _addAction(buttonName, value, {color = StyleCustom.buttonColor, hasPoint = true}) =>
      ElevatedButton(child: Text(buttonName),
          style: ElevatedButton.styleFrom(
              side: const BorderSide(color: Colors.transparent),
              primary: color, elevation: 4,
              textStyle: const TextStyle(color: Colors.white)),
          onPressed: () {
            if (value) {
              if (_point == 0 && hasPoint) UtilUI.showCustomDialog(context, MultiLanguage.get('msg_point'));
              else Navigator.of(context).pop(value);
            } else Navigator.of(context).pop(value);
          });

  void _clickStart(BuildContext context, int index) {
    _point = index;
    bloc!.add(ChangePointEvent(index));
    Util.trackActivities('pest_diagnosis', path: 'Diagnose Pests Screen -> Vote $index start for result');
  }

  void _showDialogDiagnostic(List<Diagnostic> predicts, String content, bool createPost) =>
      _createDialogDiagnostic(predicts, content, createPost).then((value) {
        if (value != null && value && createPost) {
          bloc!.add(CreatePostDiagnosePestsEvent(images!, content));
          Util.trackActivities('pest_diagnosis', path: 'Diagnose Pests Screen -> Create post from diagnose result');
          return;
        }
        _showDialogRating();
      });

  Future<bool?> _createDialogDiagnostic(
      List<Diagnostic> predicts, String content, bool createPost) {
    List<Widget> actions = [];
    if (createPost) actions.add(_addAction(MultiLanguage.get(languageKey.btnCancel), false, color: Colors.grey));
    actions.add(_addAction(
        createPost ? MultiLanguage.get(languageKey.btnOK) : 'Đóng', true,
        hasPoint: false));
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
            title: Text(MultiLanguage.get('ttl_diagnose_result')),
            actions: actions,
            content: SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Html(
                      data: content,
                      style: {"body": Style(fontSize: FontSize(42.sp))},
                      onLinkTap: (url, render, map, ele) => _launchUrl(url!)),
                  OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                        color: Colors.transparent,
                      )),
                      onPressed: () {
                        UtilUI.goToNextPage(
                          context,
                          DiagnosisPestDetailPage(predicts),
                        );
                        Util.trackActivities('pest_diagnosis', path: 'Diagnose Pests Screen -> Show detail diagnose result');
                      },
                      child: Row(children: [
                        Expanded(
                            child: LabelCustom(
                                MultiLanguage.get('msg_detail_diagnostic'),
                                size: 36.sp,
                                color: Colors.blue,
                                weight: FontWeight.normal)),
                        Icon(Icons.remove_red_eye_outlined, size: 48.sp)
                      ])),
                  if (createPost)
                    UtilUI.createLabel(
                        MultiLanguage.get('msg_create_post_question'),
                        fontSize: 40.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        line: 2)
                ]))));
  }

  void _launchUrl(String url) {
    UtilUI.goToNextPage(context, PestsHandbookListPage(url));
    Util.trackActivities('pest_diagnosis', path: 'Diagnose Pests Screen -> Open Pests Hand book List Page');
  }

  void _checkPopupCamera() {
    _popupCamera = !_popupCamera;
    bloc!.add(CheckPopupCameraEvent());
  }

  void _saveCheckPopupCamera() {
    Navigator.of(context).pop(true);
    bloc!.add(CheckPopupCameraEvent(value: _popupCamera, isSave: true));
  }
}
