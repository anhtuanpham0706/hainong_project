import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/features/function/tool/map_task/models/map_data_model.dart';
import 'package:hainong/features/home/ui/import_ui_home.dart';

Widget tabBodyImageWidget(MapDataModel data) {
  return data.images_pet?.isNotEmpty == true
      ? GridView.custom(
           padding: EdgeInsets.symmetric(vertical: 20.sp),
          gridDelegate: SliverWovenGridDelegate.count(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, pattern: [
            const WovenGridTile(1,
              crossAxisRatio: 1,
            ),
          ]),
          childrenDelegate: SliverChildBuilderDelegate((context, index) {
            return Stack(
              alignment: Alignment.topLeft,
              children: [
                FadeInImage.assetNetwork(image: Util.getRealPath(data.images_pet![index].name),
                    imageErrorBuilder: (_, __, ___) => Image.asset('assets/images/ic_default.png', width: 0.48.sw, height: 0.48.sw, fit: BoxFit.fill),
                    placeholder: 'assets/images/ic_default.png', width: 0.48.sw, height: 0.48.sw, fit: BoxFit.fill),
                Visibility(
                  visible: data.images_pet![index].user_name.isNotEmpty,
                  child: Padding(
                    padding: EdgeInsets.all(15.sp),
                    child: Text("🧑‍🌾: ${data.images_pet![index].user_name}",style: TextStyle(fontSize: 40.sp,color: Colors.white,fontWeight: FontWeight.w500),),
                  ),
                )
              ],
            );
          }, childCount: data.images_pet?.length))
      : Container(alignment: Alignment.center, child: const Text("Hiện không có hình ảnh", style: TextStyle(fontSize: 18)));
}
