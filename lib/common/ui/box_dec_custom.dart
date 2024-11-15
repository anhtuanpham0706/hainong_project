import 'package:hainong/common/ui/import_lib_base_ui.dart';
class BoxDecCustom extends BoxDecoration {
  BoxDecCustom({
    bool hasShadow = true, bool hasBorder = false, double? radius, Color? bgColor, Color? borderColor, double? width
  }) : super(
      color: bgColor??Colors.white,
      borderRadius: BorderRadius.circular(radius??8.sp),
      border: hasBorder?Border.all(color: borderColor??Colors.black12, width: width??0.5.sp):null,
      boxShadow: hasShadow?[BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 3,
          blurRadius: 5, offset: const Offset(0, 3))]:null
  );
}