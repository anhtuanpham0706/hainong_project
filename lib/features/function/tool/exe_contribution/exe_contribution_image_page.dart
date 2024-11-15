import 'dart:io';
import 'dart:typed_data';
import 'package:image_cropper/image_cropper.dart';
import 'package:hainong/common/models/file_byte.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/permission_image_page_state.dart';
import 'exe_contribution_detail_bloc.dart';

class ExeContributionImagePage extends BasePage {
  final Function reload;
  ExeContributionImagePage(int idParent, dynamic detail, this.reload, {Key? key}):super(key: key, pageState: _ImageState(detail));
}

class _ImageState extends PermissionImagePageState {
  final dynamic detail;
  final List<ItemModel> _imageTypes = [
    ItemModel(id: LanguageKey().lblCamera, name: MultiLanguage.get(LanguageKey().lblCamera)),
    ItemModel(id: LanguageKey().lblGallery, name: MultiLanguage.get(LanguageKey().lblGallery))
  ];
  bool _isOpenCam = false;

  _ImageState(this.detail);

  @override
  void loadFiles(List<File> files) async {
    showLoadingPermission();
    bool hasAdd = false;
    dynamic temp, name, size, error = '';
    for (int i = 0; i < files.length && images!.length < 5; i++) {
      temp = await files[i].readAsBytes();
      name = files[i].path.split('/');
      if (name != null && name.isNotEmpty) name = name[name.length - 1];
      if (Util.isImage(files[i].path)) {
        //size = await _checkSize(temp, name: name, showError: false);
        //if (size.isEmpty) {
          images!.add(FileByte(temp, files[i].path));
          hasAdd = true;
        //} else error += '$name $size\n';
      }
    }
    if (hasAdd) {
      bloc!.add(ShowClearSearchEvent(true));
      if (_isOpenCam) _editImage(images!.length - 1);
    }
    showLoadingPermission(value: false);
    //if (error.isNotEmpty) UtilUI.showCustomDialog(context, 'Ảnh không hợp lệ\n${error}Kích thước ảnh nhỏ hơn tiêu chuẩn (448x448)', alignMessageText: TextAlign.left);
  }

  @override
  void showLoadingPermission({bool value = true}) => bloc!.add(LoadingEvent(value));

  @override
  void openCameraGallery() {
    _isOpenCam = checkPermission == languageKey.lblCamera;
    super.openCameraGallery();
  }

  @override
  void initState() {
    bloc = ExeContributionDetailBloc(-1, isDetail: false);
    super.initState();
    bloc!.stream.listen((state) {
      if (state is ReviewMissionState && isResponseNotError(state.resp, passString: true)) {
        images!.clear();
        bloc!.add(ShowClearSearchEvent(true));
        UtilUI.showCustomDialog(context, 'Đã thực hiện xong').whenComplete(() {
          (widget as ExeContributionImagePage).reload();
          UtilUI.goBack(context, true);
        });
      }
    });
    multiSelect = true;
    images = [];
    setOnlyImage();
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    return Stack(children: [
      Scaffold(backgroundColor: Colors.white,
        body: Column(children: [
          Expanded(child: ListView(padding: EdgeInsets.all(40.sp), children: [
            Row(children: [
              LabelCustom('Yêu cầu: ', color: StyleCustom.primaryColor, size: 48.sp, weight: FontWeight.w500),
              Expanded(child: LabelCustom(detail['title']??'', color: Colors.black87, size: 48.sp, weight: FontWeight.w400)),
            ], crossAxisAlignment: CrossAxisAlignment.start),
            SizedBox(height: 20.sp),
            Row(children: [
              LabelCustom('Mô tả: ', color: StyleCustom.primaryColor, size: 48.sp, weight: FontWeight.w500),
              Expanded(child: LabelCustom(detail['description']??'', color: Colors.black87, size: 48.sp, weight: FontWeight.w400)),
            ], crossAxisAlignment: CrossAxisAlignment.start),
            BlocBuilder(bloc: bloc, buildWhen: (state1, state2) => state2 is ShowClearSearchState,
                builder: (context, state) => Column(children: [
                  if (images!.isNotEmpty) SizedBox(height: 0.28.sh, child: imageUI(_editImage, _deleteImage, padding: 20.sp)),
                  _addMorePhoto(isAddMore: images!.isEmpty)
                ]))
          ])),
          Padding(padding: EdgeInsets.all(40.sp), child: ButtonImageWidget(10, _send,
              Container(padding: EdgeInsets.all(40.sp), alignment: Alignment.center, width: 1.sw,
                  child: LabelCustom('Gửi kết quả thực hiện', size: 50.sp)), color: StyleCustom.primaryColor))
        ]),
        appBar: AppBar(title: UtilUI.createLabel('Thực hiện đóng góp'), centerTitle: true, elevation: 5)),
      Loading(bloc)
    ]);
  }

  @override
  Widget imageUI(Function funAdd, Function funDelete, {double? padding}) => images!.length > 1 ?
  ListView.separated(padding: EdgeInsets.only(top: 40.sp),
      itemCount: images!.length, scrollDirection: Axis.horizontal,
      separatorBuilder: (context, index) => SizedBox(width: 20.sp),
      itemBuilder: (context, index) => _imageItemUI(index, funAdd, funDelete)) :
  Container(padding: EdgeInsets.only(top: 40.sp), alignment: Alignment.center, child: _imageItemUI(0, funAdd, funDelete));

  Widget _imageItemUI(int index, Function funAdd, Function funDelete) => Stack(children: [
    ClipRRect(child: Image.memory(
        Uint8List.fromList(images![index].bytes), height: 0.28.sh, fit: BoxFit.cover),
        borderRadius: BorderRadius.circular(16.sp)),
    ButtonImageWidget(100, () => funDelete(index), Container(
        margin: EdgeInsets.all(20.sp),
        padding: EdgeInsets.all(10.sp),
        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(200)),
        child: Icon(Icons.clear, color: Colors.white, size: 64.sp))),
    Container(margin: EdgeInsets.only(top: 100.sp),
        child: ButtonImageWidget(100, () => funAdd(index), Container(
            margin: EdgeInsets.all(20.sp), padding: EdgeInsets.all(10.sp),
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(200)),
            child: Icon(Icons.edit, color: Colors.white, size: 64.sp))))
  ], alignment: Alignment.topRight);

  Widget _addMorePhoto({bool isAddMore = true}) => ButtonImageWidget(8.sp, () => selectImage(_imageTypes),
      Container(alignment: Alignment.center, height: isAddMore ? 0.4.sh : 0.2.sh, width: 1.sw,
        margin: EdgeInsets.symmetric(vertical: 40.sp),
        decoration: BoxDecoration(
          image: DecorationImage(fit: BoxFit.fill,
              image: Image.asset('assets/images/v2/ic_background_${isAddMore ? 'camera' : 'addmore'}.png').image),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/v2/ic_add_photo.png',
                  width: isAddMore ? 200.sp : 120.sp, height: isAddMore ? 200.sp : 120.sp),
              SizedBox(height: isAddMore ? 70.sp : 40.sp),
              LabelCustom('Chọn hình để gửi kết quả',
                  color: StyleCustom.primaryColor, size: 46.sp, weight: FontWeight.normal, align: TextAlign.center)
            ]),
      ));

  void _deleteImage(int index) {
    images!.removeAt(index);
    bloc!.add(ShowClearSearchEvent(true));
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
        bloc!.add(ShowClearSearchEvent(true));
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

  void _send() {
    if (images!.isEmpty) {
      UtilUI.showCustomDialog(context, 'Vui lòng chọn ít nhất một hình để gửi đi');
      return;
    }
    bloc!.add(ReviewMissionEvent(detail['id'], -1 ,-1, '', list: images));
  }
}