import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hainong/common/util/util_ui.dart';
import 'package:hainong/features/function/tool/map_task/map_nutrition_info_update_page.dart';
import 'package:hainong/features/function/tool/map_task/models/map_address_model.dart';
import 'package:hainong/features/function/tool/map_task/models/map_item_menu_model.dart';
import 'package:hainong/features/function/tool/map_task/models/map_response_model.dart';
import 'package:trackasia_gl/mapbox_gl.dart';

Widget addressNutritionWidget(ValueNotifier<MapAddressModel> _addressMap, MenuItemMap? _treeType) {
  return ValueListenableBuilder<MapAddressModel>(
      valueListenable: _addressMap,
      builder: (context, address, child) {
        return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 20.sp), child: Text(address.address_full ?? "", style: const TextStyle(fontSize: 14)))),
          if (_treeType != null) Container(
            padding: EdgeInsets.all(10.sp),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.all(Radius.circular(25.sp))
            ),
              child: Image.asset(_treeType.image, width: 100.w, height: 100.w))
        ]);
      });
}

Widget tabBarNutritionWidget(
    BuildContext context, ValueNotifier<MapAddressModel> _addressMap, TabController _tabBodyController, MenuItemMap? _treeType, MenuItemMap? _treeNutritionType, MapGeoJsonModel data, LatLng point,
    {bool isRecommend = true}) {
  return Container(
    color: Colors.transparent,
    child: Column(
      children: [
        TabBar(
            padding: EdgeInsets.zero,
            isScrollable: true,
            controller: _tabBodyController,
            labelColor: Colors.blue,
            indicatorColor: Colors.blue,
            unselectedLabelColor: Colors.black,
            indicatorWeight: 1,
            indicatorSize: TabBarIndicatorSize.tab,
            labelPadding: EdgeInsets.symmetric(horizontal: 100.sp),
            indicatorPadding: EdgeInsets.zero,
            unselectedLabelStyle: const TextStyle(color: Colors.black87),
            indicator: UnderlineTabIndicator(borderSide: const BorderSide(width: 4.0, color: Colors.blue), insets: EdgeInsets.symmetric(horizontal: 40.sp)),
            tabs: isRecommend ? [const Tab(text: "Tổng quan"), const Tab(text: "Khuyến cáo")] : [const Tab(text: "Tổng quan")]),
        Expanded(
            child: TabBarView(
                controller: _tabBodyController,
                children: isRecommend
                    ? [tabBodyOverviewNutritionWidget(context, _addressMap, _treeType, _treeNutritionType, data, point), tabBodyAdviseNutritionWidget(data, _treeType, _treeNutritionType)]
                    : [tabBodyOverviewNutritionWidget(context, _addressMap, _treeType, _treeNutritionType, data, point)])),
      ],
    ),
  );
}

Widget tabBodyOverviewNutritionWidget(BuildContext context, ValueNotifier<MapAddressModel> _addressMap, MenuItemMap? _treeType, MenuItemMap? _treeNutritionType, MapGeoJsonModel data, LatLng point) {
  return ValueListenableBuilder<MapAddressModel>(
      valueListenable: _addressMap,
      builder: (context, address, child) {
        return SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Divider(height: 0.2, color: Colors.grey),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
            child: Row(
              children: [
                Image.asset("assets/images/v9/map/ic_map_ecological.png", width: 32, height: 32),
                SizedBox(width: 20.sp),
                Expanded(
                  child: Text("Vùng sinh thái: ${data.data['overall']["region_name"]}", style: const TextStyle(fontSize: 16)),
                )
              ],
            ),
          ),
          Divider(height: 0.2, color: Colors.grey.withOpacity(0.4)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 30.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                    _treeNutritionType?.value == "ph"
                        ? "assets/images/v9/map/ic_map_ph.png"
                        : _treeNutritionType?.value == "ec"
                            ? "assets/images/v9/map/ic_map_ec.png"
                            : "assets/images/v9/map/ic_map_mass.png",
                    width: 42,
                    height: 42),
                SizedBox(width: 20.sp),
                Expanded(
                  child: Row(
                    children: [
                      Text(_treeNutritionType?.value == "ph" || _treeNutritionType?.value == "ec" ? "Độ" : "Hàm lượng ", style: const TextStyle(fontSize: 16), maxLines: 1),
                      Expanded(
                        child: Column(children: [
                          if (_treeNutritionType?.value == "ph")
                            Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                              const Text('<PH>: ', style: TextStyle(fontSize: 14, color: Colors.red)),
                              Text("${data.data["overall"]["ph"] ?? "N/A"}", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                              const Expanded(child: Text(" %", style: TextStyle(fontSize: 14)))
                            ]),
                          if (_treeNutritionType?.value == "ec")
                            Row(children: [
                              const Text('<EC>: ', style: TextStyle(fontSize: 14, color: Colors.red)),
                              Text("${data.data["overall"]["ec"] ?? "N/A"}", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                              const Expanded(child: Text(" %", style: TextStyle(fontSize: 14)))
                            ]),
                          if (_treeNutritionType?.value == "npk")
                            Column(children: [
                              Row(children: [
                                const Text('<Nito tổng số>: ', style: TextStyle(fontSize: 14, color: Colors.red)),
                                Text("${data.data["overall"]["n"] ?? "N/A"}", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                const Expanded(child: Text(" %", style: TextStyle(fontSize: 14)))
                              ]),
                              Row(children: [
                                const Text('<Phospho dễ tiêu>: ', style: TextStyle(fontSize: 14, color: Colors.red)),
                                Text("${data.data["overall"]["p"] ?? "N/A"}", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                const Expanded(child: Text(" mg/kg", style: TextStyle(fontSize: 14)))
                              ]),
                              Row(children: [
                                const Text('<Kali trao đổi>: ', style: TextStyle(fontSize: 14, color: Colors.red)),
                                Text("${data.data["overall"]["k"] ?? "N/A"}", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                const Expanded(child: Text(" meq/100g", style: TextStyle(fontSize: 14)))
                              ])
                            ]),
                          if (_treeNutritionType?.value == 'n')
                            Row(children: [
                              const Text('<Nito tổng số>: ', style: TextStyle(fontSize: 14, color: Colors.red)),
                              Text("${data.data["overall"]["n"] ?? "N/A"}", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                              const Expanded(child: Text(" %", style: TextStyle(fontSize: 14)))
                            ]),
                          if (_treeNutritionType?.value == 'p')
                            Row(children: [
                              const Text('<Phospho dễ tiêu>: ', style: TextStyle(fontSize: 14, color: Colors.red)),
                              Text("${data.data["overall"]["p"] ?? "N/A"}", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                              const Expanded(child: Text(" mg/kg", style: TextStyle(fontSize: 14)))
                            ]),
                          if (_treeNutritionType?.value == 'k')
                            Row(children: [
                              const Text('<Kali trao đổi>: ', style: TextStyle(fontSize: 14, color: Colors.red)),
                              Text("${data.data["overall"]["k"] ?? "N/A"}", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                              const Expanded(child: Text(" meq/100g", style: TextStyle(fontSize: 14)))
                            ])
                        ]),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Divider(height: 0.2, color: Colors.grey.withOpacity(0.4)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 30.sp),
            child: Row(
              children: [
                Image.asset("assets/images/v9/map/ic_map_rate.png", width: 32, height: 32),
                SizedBox(width: 20.sp),
                Text("Tọa độ: Lat: ${point.latitude.toStringAsFixed(4)} Lng: ${point.longitude.toStringAsFixed(4)}", style: const TextStyle(fontSize: 16))
              ],
            ),
          ),
          Divider(height: 0.2, color: Colors.grey.withOpacity(0.4)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 30.sp),
            child: GestureDetector(
              onTap: () {
                UtilUI.goToNextPage(context, MapNutritionInfoUpdatePage(addressMap: address, point: point));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("assets/images/v9/map/ic_map_location_plus.png", width: 32, height: 32),
                  SizedBox(width: 20.sp),
                  const Text("Thêm thông tin vị trí", style: TextStyle(fontSize: 16, color: Colors.blue))
                ],
              ),
            ),
          ),
        ]));
      });
}

Widget tabBodyAdviseNutritionWidget(MapGeoJsonModel data, MenuItemMap? _treeType, MenuItemMap? _treeNutritionType) {
  return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Divider(height: 0.2, color: Colors.grey),
    Padding(
      padding: EdgeInsets.only(left: 10.sp, right: 10.sp, top: 30.sp),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset("assets/images/v9/map/ic_map_mass.png", width: 32, height: 32),
              SizedBox(width: 20.sp),
              Padding(padding: EdgeInsets.symmetric(vertical: 20.sp), child: const Text("Công thức khuyến cáo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1)),
            ],
          ),
        ],
      ),
    ),
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.symmetric(vertical: 30.sp), child: Divider(height: 0.2, color: Colors.grey.withOpacity(0.4))),
          Row(children: [
            SizedBox(width: 85.sp,),
            const Text("Nitơ (N): ", style: TextStyle(fontSize: 16), maxLines: 1),
            Text("${_treeNutritionType?.value == 'npk' || _treeNutritionType?.value == 'n' ? data.data["recommendation"]["n"] : "N/A"}",
                style: TextStyle(fontSize: 16, color: _treeNutritionType?.value == 'npk' || _treeNutritionType?.value == 'n' ? Colors.red : Colors.black87), maxLines: 1),
            _treeNutritionType?.value == 'npk'
                ? const Text(" Kg/cây/năm", style: TextStyle(fontSize: 16, color: Colors.grey), maxLines: 1)
                : const Text(" Kg/hecta", style: TextStyle(fontSize: 16, color: Colors.grey), maxLines: 1),
          ]),
          Padding(padding: EdgeInsets.symmetric(vertical: 30.sp), child: Divider(height: 0.2, color: Colors.grey.withOpacity(0.4))),
          Row(children: [
            SizedBox(width: 85.sp,),
            const Text("Phospho (P205): ", style: TextStyle(fontSize: 16), maxLines: 1),
            Text("${_treeNutritionType?.value == 'npk' || _treeNutritionType?.value == 'p' ? data.data["recommendation"]["p"] : "N/A"}",
                style: TextStyle(fontSize: 16, color: _treeNutritionType?.value == 'npk' || _treeNutritionType?.value == 'p' ? Colors.red : Colors.black87), maxLines: 1),
            _treeNutritionType?.value == 'npk' || _treeNutritionType?.value == 'p' ? const Text(" Kg/cây/năm", style: TextStyle(fontSize: 16, color: Colors.grey), maxLines: 1) : const SizedBox(),
          ]),
          Padding(padding: EdgeInsets.symmetric(vertical: 30.sp), child: Divider(height: 0.2, color: Colors.grey.withOpacity(0.4))),
          Row(children: [
            SizedBox(width: 85.sp,),
            const Text("Kali (K20): ", style: TextStyle(fontSize: 16), maxLines: 1),
            Text("${_treeNutritionType?.value == 'npk' || _treeNutritionType?.value == 'k' ? data.data["recommendation"]["k"] : "N/A"}",
                style: TextStyle(fontSize: 16, color: _treeNutritionType?.value == 'npk' || _treeNutritionType?.value == 'k' ? Colors.red : Colors.black87), maxLines: 1),
            _treeNutritionType?.value == 'npk' || _treeNutritionType?.value == 'k' ? const Text(" Kg/cây/năm", style: TextStyle(fontSize: 16, color: Colors.grey), maxLines: 1) : const SizedBox(),
          ]),
          Padding(padding: EdgeInsets.symmetric(vertical: 30.sp), child: Divider(height: 0.2, color: Colors.grey.withOpacity(0.4))),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 30.sp),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.red[400]?.withOpacity(0.4)),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.red),
                  const Text("Lưu ý: ", style: TextStyle(color: Colors.red)),
                  Expanded(
                      child: Text(
                          _treeType?.value != "lua"
                              ? '-Công thức khuyến cáo hiện đang áp dụng trên cây ăn trái giai đoạn kinh doanh. \n -Dữ liệu hiện tại đang được mô phỏng từ các điểm lấy mẫu lân cận, chỉ mang tính chất tham khảo.'
                              : "Dữ liệu hiện tại đang được mô phỏng từ các điểm lấy mẫu lân cận, chỉ mang tính chất tham khảo.",
                          style: const TextStyle(fontSize: 12),
                          maxLines: 4))
                ],
              ))
        ],
      ),
    )
  ]));
}
