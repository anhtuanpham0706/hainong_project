import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hainong/common/import_lib_system.dart';
import 'package:hainong/common/ui/avatar_circle_widget.dart';
import 'package:hainong/features/function/tool/map_task/map_model_update_page.dart';
import 'package:hainong/features/function/tool/map_task/models/map_data_model.dart';
import 'package:hainong/features/function/tool/map_task/models/map_enum.dart';
import 'package:hainong/features/function/tool/map_task/utils/map_utils.dart';

Widget tabBodyOverviewWidget(BuildContext context, MapModelEnum _selectTabMenuModel, MapDataModel data, ValueNotifier<bool> _expandedTime, ValueNotifier<bool> _expandedDescription, String imageUser,
    Function reloadComment, ValueNotifier<MapDataModel> _dataMap) {
  return SingleChildScrollView(
      child: Column(children: [
    const Divider(height: 0.2, color: Colors.grey),
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: Colors.blue, size: 32),
          SizedBox(width: 20.sp),
          Expanded(child: Text("${data.address},${data.district_name},${data.province_name}", style: const TextStyle(fontSize: 16), maxLines: 2))
        ],
      ),
    ),
    const Divider(height: 0.2, color: Colors.grey),
    Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
        child: _selectTabMenuModel == MapModelEnum.demonstration
            ? Row(children: [
                const Icon(Icons.access_time, color: Colors.blue, size: 32),
                SizedBox(width: 20.sp),
                Text(data.status == "finished" ? "Kết thúc " : (data.status == "happenning" ? "Đang diễn ra " : "Sắp diễn ra "),
                    style: TextStyle(fontSize: 16, color: data.status != "finished" ? StyleCustom.primaryColor : Colors.red)),
                SizedBox(width: 12.w),
                Text("Kết thúc " + Util.dateToString(Util.stringToDateTime(data.end_date), locale: Constants().localeVI, pattern: 'dd/MM/yyyy'), style: TextStyle(fontSize: 16, color: Colors.grey)),
              ])
            : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Align(
                  child: Icon(Icons.access_time, color: Colors.blue, size: 32),
                  alignment: Alignment.topCenter,
                ),
                SizedBox(width: 20.sp),
                ValueListenableBuilder<bool>(
                    valueListenable: _expandedTime,
                    builder: (context, expandedTime, child) {
                      return Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            !expandedTime
                                ? Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        Text(data.opening_status.isEmpty ? "Không có thông tin" : (data.opening_status != "closed" ? "Đang mở cửa " : "Đóng cửa"),
                                            style: TextStyle(fontSize: 16, color: data.opening_status.isEmpty ? Colors.grey : (data.opening_status == "closed" ? Colors.red : StyleCustom.primaryColor))),
                                        SizedBox(width: 12.w),
                                        Text(data.opening_status == "open_24_hours" ? "Cả ngày" : (data.opening_status == "custom_hours" ? ("Đóng cửa lúc ${data.closing_time}") : ""),
                                            style: TextStyle(fontSize: 16, color: Colors.grey))
                                      ],
                                    ),
                                  )
                                : Expanded(
                                    child: ListView.builder(
                                      itemBuilder: (context, index) => Container(
                                        margin: const EdgeInsets.only(bottom: 5, top: 10),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(MultiLanguage.get("lbl_" + data.agency_working_hours[index]['weekday']), style: TextStyle(fontSize: 16, color: Colors.black87)),
                                              flex: 4,
                                            ),
                                            Expanded(
                                              child: data.agency_working_hours[index]['opening_status'] == "custom_hours"
                                                  ? Text((data.agency_working_hours[index]['opening_time'] ?? "") + "-" + (data.agency_working_hours[index]['closing_time'] ?? ""),
                                                      style: TextStyle(fontSize: 16, color: Colors.black87))
                                                  : Text(data.agency_working_hours[index]['opening_status'] == "open_24_hours" ? "Cả ngày" : "Đóng cửa",
                                                      style: TextStyle(fontSize: 16, color: Colors.black87)),
                                              flex: 6,
                                            )
                                          ],
                                        ),
                                      ),
                                      itemCount: data.agency_working_hours.length,
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                            InkWell(
                              onTap: () {
                                if (data.agency_working_hours.isNotEmpty) {
                                  _expandedTime.value = !expandedTime;
                                }
                              },
                              child: Align(
                                child: SizedBox(
                                  child: Icon(
                                    !expandedTime == false ? Icons.expand_less : Icons.expand_more,
                                    size: 80.sp,
                                  ),
                                ),
                                alignment: Alignment.topCenter,
                              ),
                            )
                          ],
                        ),
                      );
                    }),
              ])),
    const Divider(height: 0.2, color: Colors.grey),
    ValueListenableBuilder<bool>(
        valueListenable: _expandedDescription,
        builder: (context, expandedDescription, child) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.info_outline_rounded, color: Colors.blue, size: 32),
                  SizedBox(width: 20.sp),
                  const Text("Mô tả", style: TextStyle(fontSize: 16)),
                  InkWell(onTap: () => _expandedDescription.value = !expandedDescription, child: SizedBox(child: Icon(!expandedDescription == false ? Icons.expand_less : Icons.expand_more)))
                ]),
                expandedDescription
                    ? Container(
                        child: _selectTabMenuModel != MapModelEnum.demonstration
                            ? Visibility(
                                child: Text(data.description, style: const TextStyle(fontSize: 16, color: Colors.black87), maxLines: 5, textAlign: TextAlign.start),
                                visible: data.description.isNotEmpty)
                            : Column(
                                children: [
                                  Visibility(
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 10.sp),
                                        child: Row(children: [
                                          const Text("▪Cây trồng:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                          SizedBox(width: 10.sp),
                                          Expanded(child: Text(data.categories.join(','), style: const TextStyle(fontSize: 16), maxLines: 2))
                                        ])),
                                    visible: data.categories.isNotEmpty,
                                  ),
                                  Visibility(
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 10.sp),
                                        child: Row(children: [
                                          const Text("▪Diện tích:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                          SizedBox(width: 10.sp),
                                          Expanded(child: Text("${data.acreage.round()} ha", style: const TextStyle(fontSize: 16), maxLines: 2))
                                        ])),
                                    visible: data.acreage != 0.0,
                                  ),
                                  Visibility(
                                      child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 10.sp),
                                          child: RichText(
                                            text: TextSpan(children: <TextSpan>[
                                              TextSpan(text: "▪Năng suất: ", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                                              TextSpan(text: data.productivity, style: const TextStyle(fontSize: 16, color: Colors.black)),
                                            ]),
                                            maxLines: 4,
                                          )),
                                      visible: data.productivity.isNotEmpty),
                                  Visibility(
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 10.sp),
                                        child: RichText(
                                            text: TextSpan(children: <TextSpan>[
                                              TextSpan(text: "▪Hiệu quả kinh tế: ", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black)),
                                              TextSpan(text: data.performance, style: const TextStyle(fontSize: 16, color: Colors.black)),
                                            ]),
                                            maxLines: 4)),
                                    visible: data.performance.isNotEmpty,
                                  ),
                                ],
                                crossAxisAlignment: CrossAxisAlignment.start,
                              ),
                        padding: EdgeInsets.only(top: 10.sp),
                      )
                    : const SizedBox()
              ],
            ),
          );
        }),
    const Divider(height: 0.2, color: Colors.grey),
    ValueListenableBuilder<MapDataModel>(
        valueListenable: _dataMap,
        builder: (context, dataMap, child) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
            child: GestureDetector(
              onTap: () {},
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Đánh giá", style: TextStyle(fontSize: 16, color: Colors.black87)),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 10.sp),
                      child: Row(children: [
                        AvatarCircleWidget(
                            border: Border.all(color: Colors.white30, width: 8.sp), size: 100.sp, link: imageUser, stack: true, assetsImageReplace: 'assets/images/v2/ic_avatar_drawer_v2.png'),
                        UtilUI.createStars(mainAxisAlignment: MainAxisAlignment.start, onClick: (index) {}, hasFunction: true, rate: dataMap.old_rate, size: 65.sp),
                      ])),
                  dataMap.has_commented
                      ? Text(dataMap.old_comment, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500), maxLines: 3)
                      : InkWell(
                          onTap: () {
                            UtilUI.goToNextPage(context, MapModelUpdatePage(data.classable_id, data.classable_type, title: "Đánh giá thông tin", isRating: true),
                                funCallback: reloadComment);
                          },
                          child: Image.asset("assets/images/v9/map/ic_map_model_add_camera.png", width: 360.w, height: 140.h))
                ],
              ),
            ),
          );
        }),
  ]));
}
