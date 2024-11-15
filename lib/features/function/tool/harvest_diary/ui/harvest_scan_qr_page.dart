import 'dart:io';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/permission_image_page_state.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';


class HarvestScanQRPage extends BasePage {
  HarvestScanQRPage({Key? key}) : super(pageState: _HarvestScanQRPageState(), key: key);
}

class _HarvestScanQRPageState extends PermissionImagePageState {
  bool _isInit = true, _stop = true;
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) controller?.pauseCamera();
    controller?.resumeCamera();
  }

  @override
  void initState() {
    showCamGal = false;
    super.initState();
    checkPermissions(ItemModel(id: languageKey.lblCamera));
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) =>
    Scaffold(appBar: AppBar(elevation: 10, titleSpacing: 0,
      title: UtilUI.createLabel('Quét mã QR'), centerTitle: true),
      body: QRView(key: GlobalKey(debugLabel: 'QR'), onQRViewCreated: _onQRViewCreated, onPermissionSet: _onPermissionSet,
          overlay: QrScannerOverlayShape(borderColor: Colors.white, borderLength: 20, borderWidth: 5, cutOutSize: 0.75.sw))
    );

  @override
  void loadFiles(List<File> files) {}

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    this.controller!.scannedDataStream.listen((scanData) {
      if (scanData.code != null && scanData.code!.isNotEmpty) _onCapture(scanData.code!);
    });
  }

  void _onPermissionSet(QRViewController ctrl, bool p) {
    if (Platform.isAndroid) controller?.pauseCamera();
    controller?.resumeCamera();
  }

  dynamic _onCapture(String value) {
    controller?.pauseCamera();
    if (value.isNotEmpty) {
      UtilUI.goBack(context, value);
    } else {
      UtilUI.showCustomDialog(context, "Quét mã không thành công").whenComplete(() => controller?.resumeCamera());
    }
  }
}