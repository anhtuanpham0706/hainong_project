import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
// import 'package:gmo_media_picker/media_picker.dart';
import 'package:hainong/features/home/bloc/home_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import '../models/file_byte.dart';
import 'button_image_widget.dart';
import 'label_custom.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

abstract class PermissionImagePageState extends BasePageState { //with WidgetsBindingObserver {
  String checkPermission = '';
  bool isCheckPermission = false, pass = false, multiSelect = false, showCamGal = true;
  List<String>? allowedExtensions;
  List<dynamic>? types;
  List<FileByte>? images;

  @override
  void dispose() {
    types?.clear();
    allowedExtensions?.clear();
    images?.clear();
    super.dispose();
  }

  /*@override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        checkPermission.isNotEmpty &&
        isCheckPermission) {
      if (checkPermission == languageKey.lblCamera)
        Permission.camera.status.isGranted
            .then((value) => _showDialogPermission(value));
      else
        Permission.storage.status.isGranted
            .then((value) => _showDialogPermission(value));
    }
  }

  void _showDialogPermission(bool value) {
    isCheckPermission = false;
    WidgetsBinding.instance?.removeObserver(this);
    value ? openCameraGallery() : UtilUI.showCustomDialog(
        context,
        MultiLanguage.get(checkPermission == languageKey.lblCamera
            ? languageKey.msgPermissionCamera
            : languageKey.msgPermissionGallery),
        isActionCancel: true).then((value2) {
            if (value2! || pass) _getImage();
        });
  }*/

  void selectImage(List<ItemModel> list, {String? title}) {
    UtilUI.showOptionDialog(context, MultiLanguage.get(title??'msg_select_image_from'), list, title??'')
        .then((value) {checkPermissions(value);});
    String function = '', path = '';
    switch(widget.runtimeType.toString()) {
      case '_DiagnosePestsPageState':
        path = 'Diagnose Pests Screen -> Add Photo for Diagnose';
        function = 'pest_diagnosis'; break;
      case '_ProductPageState':
        path = 'Product Create/Edit Screen -> Add Photo for Product';
        function = 'products';
    }
    Util.trackActivities(function, path: path);
  }

  void checkPermissions(ItemModel? item) {
    if(item == null) return;
    checkPermission = item.id;
    _getImage();
  }

  void resetCheckPermission() {
    //pass = false;
    checkPermission = '';
    if (isCheckPermission) {
      isCheckPermission = false;
      //WidgetsBinding.instance?.removeObserver(this);
    }
    showLoadingPermission(value: false);
  }

  Future<PermissionStatus> funCheckPermission(Permission permission) async {
    PermissionStatus status = await permission.status;
    /*if (status == PermissionStatus.denied || status == PermissionStatus.limited) {
      return permission.request();
    } else if (status == PermissionStatus.restricted || status == PermissionStatus.permanentlyDenied) {
      //openAppSettings();
      UtilUI.showCustomDialog(context, 'Bạn không thể chọn ảnh từ ${checkPermission == languageKey.lblCamera ? 'máy ảnh' : 'thư viện ảnh'}, quyền truy xuất ảnh đã bị từ chối.'
          '\nHãy vào phần cài đặt của hệ thống trên thiết bị để cấp quyền lại', alignMessageText: TextAlign.left);
    }*/

    if (status == PermissionStatus.denied || status == PermissionStatus.limited) status = await permission.request();

    if (status != PermissionStatus.granted) {
      UtilUI.showCustomDialog(context, 'Bạn không thể chọn ảnh từ ${checkPermission == languageKey.lblCamera ? 'máy ảnh' : 'thư viện ảnh'}, quyền truy xuất ảnh đã bị từ chối.'
          '\nHãy vào phần cài đặt của hệ thống trên thiết bị để cấp quyền lại', alignMessageText: TextAlign.left);//.whenComplete(() => openAppSettings());
    }
    return status;
  }

  Future<PermissionStatus> funCheckPermissions({List<Permission>? arrayPer}) async {
    Map<Permission, PermissionStatus> statuses = await (arrayPer ?? [
      Permission.audio,
      Permission.photos,
      Permission.videos
    ]).request();

    for(var status in statuses.keys) {
      if (await funCheckPermission(status) != PermissionStatus.granted) return statuses[status]!;
    }
    return PermissionStatus.granted;
  }

  void _permissionResult(PermissionStatus value) {
    if (value == PermissionStatus.granted) {
      if (showCamGal) openCameraGallery();
    } else if (!isCheckPermission) {
      isCheckPermission = true;
      //WidgetsBinding.instance?.addObserver(this);
    }
  }

  void _getImage() async {
    if (checkPermission == languageKey.lblCamera) {
      funCheckPermission(Permission.camera).then((value) {
        _permissionResult(value);
      });
      return;
    }

    if (Platform.isAndroid) {
      openCameraGallery();
    } else {
      dynamic per = [Permission.storage, Permission.photos];
      funCheckPermissions(arrayPer: per).then((value) {
        _permissionResult(value);
      });
    }
  }

  void setOnlyImage() {
    allowedExtensions = ['gif', 'jpg', 'jpeg', 'png'];
    types = ['image'];
  }

  void openCameraGallery() async {
    try {
      showLoadingPermission();

      final ImagePicker picker = ImagePicker();
      if (checkPermission == languageKey.lblCamera) {
        XFile? image = await picker.pickImage(source: ImageSource.camera);
        _responseImage(image);
        return;
      }

      if (Platform.isAndroid) {
        final deviceInfo = await DeviceInfoPlugin().androidInfo;
        if ((deviceInfo.version.sdkInt??1) > 32) {
          FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowMultiple: multiSelect,
            allowedExtensions: allowedExtensions ?? ['gif', 'jpg', 'png', 'jpeg', 'mp4', 'mov'],
          ).then((value) => _responseFile(value)).onError((e, stackTrace) => _error(e)).catchError((e) => _error(e));
          return;
        }
      }

      resetCheckPermission();
      // final XFile? image = await picker.pickVideo(source: ImageSource.gallery);
      // _responseImage(image);
      final List<AssetEntity>? result = await AssetPicker.pickAssets(context);
      if (result != null && result.isNotEmpty) _processAsset(result);
    } catch (_) {}
  }

  void _responseImage(XFile? file) async {
    if (file != null && file.path.isNotEmpty) await loadFiles([File(file.path)]);
    resetCheckPermission();
  }

  void _responseFile(FilePickerResult? imageFile) async {
    if (imageFile != null && imageFile.files.isNotEmpty) {
      final List<File> files = [];
      for (var file in imageFile.files) {
        final temp = file.path;
        if (temp != null && temp.isNotEmpty) files.add(File(temp));
      }
      if (files.isNotEmpty) await loadFiles(files);
    }
    resetCheckPermission();
  }

  void _processAsset(List<AssetEntity> assets) async {
    showLoadingPermission();
    try {
      final List<File> files = [];
      for (int i = 0; i < assets.length; i++) {
        final temp = await assets[i].file;
        if (temp != null) files.add(temp);
      }
      await loadFiles(files);
    } catch (_) {}
    resetCheckPermission();
  }

  dynamic _error(dynamic error) {
    resetCheckPermission();
    UtilUI.showCustomDialog(context, error.toString());
  }

  void showLoadingPermission({bool value = true}) {}

  loadFiles(List<File> files);

  int getSize() {
    int maxSize = 0;
    for (var file in images!) {
      maxSize += file.bytes.length;
    }
    return maxSize;
  }

  Widget imageUI(Function funAdd, Function funDelete, {double? padding}) => Container(width: 1.sw,
    margin: EdgeInsets.fromLTRB(padding??40.sp, padding??40.sp, padding??40.sp, 0), padding: EdgeInsets.all(20.sp),
    decoration: BoxDecoration(image: DecorationImage(fit: BoxFit.fill,
        image: Image.asset('assets/images/v5/bg_border.png').image),
      borderRadius: BorderRadius.circular(16.sp)), height: 320.sp,
    child: BlocBuilder(bloc: bloc, builder: (context, state) =>
      images!.isEmpty ? ButtonImageWidget(16.sp, funAdd, Column(children: [
        Image.asset('assets/images/v5/ic_add_image.png', width: 114.sp, height: 114.sp),
        Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 8.sp),
            child: LabelCustom('Upload ảnh', size: 36.sp, color: const Color(0xFF5B5B5B))),
        LabelCustom('Thêm ảnh hoặc chụp ảnh mới', size: 30.sp, color: const Color(0xFF5B5B5B), weight: FontWeight.normal)
      ], mainAxisAlignment: MainAxisAlignment.center))
      : Row(children: [
        Expanded(child: ListView.separated(padding: EdgeInsets.zero,
            itemCount: images!.length, scrollDirection: Axis.horizontal,
            separatorBuilder: (context, index) => SizedBox(width: 20.sp),
            itemBuilder: (context, index) => Stack(children: [
              ClipRRect(child: Image.memory(
                  Uint8List.fromList(images![index].bytes), height: 280.sp, fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(16.sp)),
              ButtonImageWidget(100, () => funDelete(index), Container(
                  margin: EdgeInsets.all(10.sp),
                  padding: EdgeInsets.all(10.sp),
                  decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(100)
                  ),
                  child: Icon(Icons.clear, color: Colors.white, size: 42.sp)
              ))
            ], alignment: Alignment.topRight)
        )),
        Padding(child: ButtonImageWidget(100, funAdd, Image.asset('assets/images/v5/ic_add_image.png',
          width: 114.sp, height: 114.sp)), padding: EdgeInsets.only(left: 20.sp))
      ]), buildWhen: (oldS, newS) => newS is AddImageHomeState));
}
