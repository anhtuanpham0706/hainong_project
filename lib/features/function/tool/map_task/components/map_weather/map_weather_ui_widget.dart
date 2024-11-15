import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/features/function/tool/map_task/models/map_address_model.dart';
import 'package:hainong/features/function/tool/map_task/models/map_response_model.dart';
import 'package:hainong/features/function/tool/map_task/utils/map_utils.dart';
import 'package:trackasia_gl/mapbox_gl.dart';

Widget addressWeatherWidget(ValueNotifier<MapAddressModel> _addressMap, {bool isAddressFull = true}) {
  return ValueListenableBuilder<MapAddressModel>(
      valueListenable: _addressMap,
      builder: (context, address, child) {
        final _address = isAddressFull ? address.address_full ?? "" : '${address.district_name}, ${address.province_name}';
        return Padding(padding: EdgeInsets.symmetric(horizontal: 20.sp), child: Text(_address, style: const TextStyle(fontSize: 14)));
      });
}

Widget tabBodyOverviewWeatherWidget(BuildContext context, MapGeoJsonModel data, LatLng point, ValueNotifier<bool> isPlay, Function(bool _isPlay, String url) callBackAudio) {
  final imageUrl = data.data['icon'];
  return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SizedBox(height: 20.sp),
    Divider(height: 0.2, color: Colors.grey.withOpacity(0.4)),
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.sp),
      child: GestureDetector(
        onTap: () => callBackAudio(!isPlay.value, data.data['audio_link']),
        child: ValueListenableBuilder(
          builder: (BuildContext context, value, Widget? child) {
            return Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
              IconButton(
                  icon: value == true
                      ? Stack(
                          children: const [
                            SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 4.0)),
                            Icon(
                              Icons.play_arrow,
                              color: Colors.red,
                            ),
                          ],
                        )
                      : const Icon(Icons.mic_none, size: 32, color: Colors.blue),
                  onPressed: () {}),
              Text(value == true ? "Dừng nghe" : "Nhấn để nghe", style: const TextStyle(fontSize: 16, color: Colors.blue)),
            ]);
          },
          valueListenable: isPlay,
        ),
      ),
    ),
    Divider(height: 0.2, color: Colors.grey.withOpacity(0.4)),
    Padding(
      padding: EdgeInsets.only(left: 20.sp, right: 20.sp, top: 20.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset("assets/images/v9/map/ic_map_rate.png", width: 28, height: 28),
          SizedBox(width: 20.sp),
          Text("Tọa độ: Lat: ${point.latitude.toStringAsFixed(4)} Lng: ${point.longitude.toStringAsFixed(4)}", style: const TextStyle(fontSize: 14))
        ],
      ),
    ),
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 80.sp, vertical: 20.sp),
      child: Column(
        children: [
          if (imageUrl != null) SizedBox(width: 0.36.sw, height: 0.36.sw, child: Image.asset("assets/images/v9/map/weather/$imageUrl.png", fit: BoxFit.fill)),
          SizedBox(height: 20.sp),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const LabelCustom('Hiện tại: ', color: Colors.green),
              LabelCustom('${(data.data['description']) ?? "N/A"}', color: Colors.green),
            ],
          ),
          SizedBox(height: 20.sp),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const LabelCustom('Khả năng mưa: ', color: Colors.black87),
              LabelCustom('${(data.data['pop']) ?? "N/A"}%', color: Colors.black87),
            ],
          ),
          SizedBox(height: 20.sp),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const LabelCustom('Nhiệt độ: ', color: Colors.black87),
              LabelCustom('${(data.data['temp_day']) ?? "N/A"}°', color: Colors.black87),
            ],
          ),
          SizedBox(height: 20.sp),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const LabelCustom('Nhiệt độ giao động: ', color: Colors.black87),
              LabelCustom('${MapUtils.convertMapKeyToDouble(data.data, "temp_min").round()}°-${(MapUtils.convertMapKeyToDouble(data.data, "temp_max").round())}°', color: Colors.black87),
            ],
          ),
          SizedBox(height: 20.sp),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const LabelCustom('Chỉ số bức xạ: ', color: Colors.black87),
              LabelCustom('${(data.data['uvi']) ?? "N/A"}', color: Colors.black87),
            ],
          ),
          SizedBox(height: 20.sp),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const LabelCustom('Sức gió: ', color: Colors.black87),
              LabelCustom('${(data.data['wind_speed']) ?? "N/A"} km/h', color: Colors.black87),
            ],
          ),
          SizedBox(height: 20.sp),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const LabelCustom('Độ ẩm: ', color: Colors.black87),
              LabelCustom('${(data.data['humidity']) ?? "N/A"} %', color: Colors.black87),
            ],
          ),
          SizedBox(height: 20.sp),
        ],
      ),
    ),
  ]));
}
