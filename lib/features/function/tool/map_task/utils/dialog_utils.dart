import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DialogUtils {
  static void showMapFarmingBottomSheet(BuildContext context, Widget treeTypeWidget, Widget treeLayerWidget) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.white,
        builder: (context) {
          return Container(
              color: Colors.white,
              height: 0.60.sh,
              padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 40.sp),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(children: [
                  treeTypeWidget,
                  Padding(
                    padding: EdgeInsets.only(top: 20.sp, bottom: 40.sp),
                    child: const Divider(color: Colors.grey, height: 2, thickness: 0),
                  ),
                  treeLayerWidget
                ]),
              ));
        });
  }

  static Future<void> showMapInfoBottomSheet(BuildContext context, Widget addressBodyWidget, Widget tabbarBodyWidget, {double? height}) async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.white,
        builder: (context) => StatefulBuilder(
              builder: (BuildContext context, void Function(void Function()) setState) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Container(
                      color: Colors.white,
                      height: height ?? 0.46.sh,
                      padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 40.sp),
                      child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [addressBodyWidget, Expanded(child: tabbarBodyWidget)])),
                );
              },
            ));
  }

  static Future<void> showMapBottomSheet(BuildContext context, Widget topBodyWidget, Widget menuBodyWidget, Widget tabbarBodyWidget, {double? height}) async {
    await showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: true,
        context: context,
        backgroundColor: Colors.white,
        builder: (context) => SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Container(
                  color: Colors.white,
                  height: height ?? 0.68.sh,
                  padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 40.sp),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [topBodyWidget, SizedBox(height: 20.sp), menuBodyWidget, Expanded(child: tabbarBodyWidget)])),
            ));
  }

  static Future showDialogPopup(BuildContext context, Widget bodyWidget, {bool isDismiss = false}) {
    return showDialog(
        barrierDismissible: isDismiss, context: context, builder: (context) => Dialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.sp))), child: bodyWidget));
  }

  static Future showBottomSheetPopup(BuildContext context, Widget bodyWidget, {double? height}) async {
    await showModalBottomSheet(
        isScrollControlled: true, isDismissible: true, context: context, backgroundColor: Colors.white, builder: (context) => SizedBox(height: height ?? 0.48.sh, child: bodyWidget));
  }
}
