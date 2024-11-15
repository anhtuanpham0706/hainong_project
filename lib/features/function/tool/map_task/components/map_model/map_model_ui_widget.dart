import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hainong/common/import_lib_system.dart';
import 'package:hainong/features/function/tool/map_task/models/map_data_model.dart';
import 'package:hainong/features/function/tool/map_task/models/map_enum.dart';

Widget topBodyModelWidget(MapDataModel data, MapModelEnum menuTabBar) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
      children: [
    Text(data.name, style: const TextStyle(fontSize: 22, color: Colors.black87)),
    Row(children: [
      Text("${data.rate}", style: const TextStyle(fontSize: 16, color: Colors.grey)),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.sp),
          child: UtilUI.createStars(mainAxisAlignment: MainAxisAlignment.start, onClick: (index) => {}, hasFunction: true, rate: data.rate.round(), size: 35.sp)),
      Text("(${data.total_rated})", style: const TextStyle(fontSize: 16, color: Colors.grey))
    ]),
    SizedBox(height: 20.sp),
    menuTabBar == MapModelEnum.demonstration
        ? Row(children: [
            Text(data.status == "finished" ?  "Kết thúc " : (data.status == "happenning" ? "Đang diễn ra " : "Sắp diễn ra "), style: TextStyle(fontSize: 16, color: data.status != "finished" ? StyleCustom.primaryColor : Colors.red)),
            SizedBox(width: 12.w),
            Text("Kết thúc " + Util.dateToString(Util.stringToDateTime(data.end_date), locale: Constants().localeVI, pattern: 'dd/MM/yyyy'), style: TextStyle(fontSize: 16, color: Colors.grey))
          ])
        : Row(children: [
            Text(data.opening_status.isEmpty ? "Không có thông tin" : (data.opening_status != "closed" ? "Đang mở cửa " : "Đóng cửa"), style: TextStyle(fontSize: 16, color: data.opening_status.isEmpty ? Colors.grey : (data.opening_status == "closed" ? Colors.red : StyleCustom.primaryColor))),
            SizedBox(width: 12.w),
            Text(data.opening_status != "open_24_hours" ? (data.opening_status == "custom_hours" ? ("Đóng cửa lúc ${data.closing_time}") : "") : "Cả ngày",
                style: const TextStyle(fontSize: 16, color: Colors.grey))
          ])
  ]);
}


Widget body(MapDataModel data, int menuTabBar, Widget topBodyWidget, Widget menuBodyWidget, Widget tabbarBodyWidget, {double? height}) {
  return Container(
      color: Colors.white,
      height: height ?? 0.60.sh,
      padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 40.sp),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [topBodyWidget, menuBodyWidget, Expanded(child: tabbarBodyWidget)],
      ));
}
