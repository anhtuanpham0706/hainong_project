import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hainong/common/ui/avatar_circle_widget.dart';
import 'package:hainong/common/util/util_ui.dart';
import 'package:hainong/features/function/tool/map_task/components/map_pet/popup_pet_contribute_widget.dart';
import 'package:hainong/features/function/tool/map_task/components/tab_body_image_widget.dart';
import 'package:hainong/features/function/tool/map_task/map_model_update_page.dart';
import 'package:hainong/features/function/tool/map_task/models/map_data_model.dart';
import 'package:hainong/features/function/tool/map_task/utils/dialog_utils.dart';
import 'package:hainong/features/function/tool/map_task/utils/map_utils.dart';
import 'package:trackasia_gl/mapbox_gl.dart';

Widget topBodyPetWidget(MapDataModel data) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      if (data.category_image.isNotEmpty)
        Container(
          width: 140.w,
          height: 140.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), spreadRadius: 2, blurRadius: 2, offset: const Offset(0, 2))],
            image: DecorationImage(image: NetworkImage(data.category_image), fit: BoxFit.fill),
          ),
        ),
      SizedBox(width: 20.sp),
      Text(data.category_name, style: const TextStyle(fontSize: 24, color: Colors.black87, fontWeight: FontWeight.bold))
    ]),
    SizedBox(height: 20.sp),
    Row(children: [
      Text("(${data.rate})", style: const TextStyle(fontSize: 16, color: Colors.grey)),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.sp),
          child: Row(children: [
            UtilUI.createStars(mainAxisAlignment: MainAxisAlignment.start, onClick: (index) => {}, hasFunction: true, rate: data.rate, size: 60.sp),
            Text("(${data.total_rated})", style: const TextStyle(fontSize: 16, color: Colors.grey))
          ]))
    ]),
    SizedBox(height: 20.sp),
    Row(children: [
      Text(data.suggest, style: const TextStyle(fontSize: 16, color: Colors.green)),
      Padding(padding: EdgeInsets.symmetric(horizontal: 10.sp), child: Row(children: [Text(" ${data.percent}%", style: const TextStyle(fontSize: 16, color: Colors.red))]))
    ])
  ]);
}

Widget tabMenuPetBodyWidget(BuildContext root,MapDataModel data) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 20.sp),
    height: 120.h,
    child: ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      itemBuilder: (context, index) {
        return GestureDetector(
            onTap: () {
              switch (index) {
                case 0:
                  MapUtils.openMapApp(const LatLng(10.9514, 107.0855), LatLng(data.lat, data.lng));
                  break;
                case 1:
                  logDebug(data.deep_link);
                  UtilUI.shareDeeplinkTo(root, data.deep_link, 'Option Share Dialog -> Choose "Share"', 'map task');
                  break;
                case 2:
                  DialogUtils.showDialogPopup(root, PopupPetContributeWidget(data,data.category_name, data.suggest, LatLng(data.lat, data.lng)));
                  break;
                default:
              }
            },
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Image.asset(MapUtils.menuListPet()[index].image)));
      },
    ),
  );
}

Widget tabPetOverviewWidget(BuildContext context, MapDataModel data, String imageUser, ValueNotifier<bool> _expandedDescription) {
  return SingleChildScrollView(
      child: Column(children: [
    const Divider(height: 0.2, color: Colors.grey),
    Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 30.sp),
        child: Row(children: [
          const Icon(Icons.location_on_outlined, color: Colors.blue, size: 32),
          SizedBox(width: 20.sp),
          Expanded(child: Text(data.full_address, style: const TextStyle(fontSize: 16), maxLines: 2))
        ])),
    const Divider(height: 0.2, color: Colors.grey),
    Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 30.sp),
        child: Row(children: [
          const Icon(Icons.access_time, color: Colors.blue, size: 32),
          SizedBox(width: 20.sp),
          Row(children: [
            const Text("Cập nhật lần cuối: ", style: TextStyle(fontSize: 16)),
            Text(MapUtils.datetimeToFormat(data.updated_at), style: const TextStyle(fontSize: 16, color: Colors.green))
          ])
        ])),
    const Divider(height: 0.2, color: Colors.grey),
    Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 30.sp),
        child: Row(children: [
          Padding(padding: EdgeInsets.only(left: 16.sp), child: Image.asset("assets/images/v9/map/ic_map_rate_ai.png", width: 64.w, height: 64.w)),
          SizedBox(width: 20.sp),
          Row(children: [const Text("Tỉ lệ chuẩn đoán ", style: TextStyle(fontSize: 16)), Text("${data.percent.toString()}%", style: const TextStyle(fontSize: 16, color: Colors.green))])
        ])),
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
                    ? Visibility(
                        child: Text(data.description, style: const TextStyle(fontSize: 16, color: Colors.black87), maxLines: 5, textAlign: TextAlign.start), visible: data.description.isNotEmpty)
                    : const SizedBox()
              ],
            ),
          );
        }),
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
      child: InkWell(
        onTap: () {
          UtilUI.goToNextPage(context, MapModelUpdatePage(data.classable_id, data.classable_type, title: "Đánh giá thông tin", isRating: true),
              funCallback: (value){
                UtilUI.goBack(context, true);
              });
        },
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
                  UtilUI.createStars(mainAxisAlignment: MainAxisAlignment.start, onClick: (index) {}, hasFunction: true, rate: data.old_rate, size: 65.sp),
                ])),
            data.has_commented
                ? Text(data.old_comment, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500), maxLines: 3)
                : Image.asset("assets/images/v9/map/ic_map_model_add_camera.png", width: 360.w, height: 140.h)
          ],
        ),
      ),
    ),

  ]));
}

Widget tabBarPetWidget(BuildContext context, TabController _tabBodyController, MapDataModel data, String imageUser, ValueNotifier<bool> _expandedDescription) {
  return Container(
      color: Colors.transparent,
      child: Column(children: [
        TabBar(
            padding: EdgeInsets.zero,
            isScrollable: true,
            controller: _tabBodyController,
            labelColor: Colors.blue,
            indicatorColor: Colors.blue,
            unselectedLabelColor: Colors.black,
            indicatorWeight: 1,
            labelPadding: EdgeInsets.symmetric(horizontal: 200.sp),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: EdgeInsets.zero,
            unselectedLabelStyle: const TextStyle(color: Colors.black87),
            indicator: UnderlineTabIndicator(borderSide: const BorderSide(width: 4.0, color: Colors.blue), insets: EdgeInsets.symmetric(horizontal: 40.sp)),
            tabs: const [Tab(text: "Tổng quan"), Tab(text: "Hình ảnh")]),
        Expanded(child: TabBarView(controller: _tabBodyController, children: [tabPetOverviewWidget(context, data, imageUser, _expandedDescription), tabBodyImageWidget(data)]))
      ]));
}
