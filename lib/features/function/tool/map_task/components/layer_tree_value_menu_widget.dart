import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hainong/features/function/tool/map_task/models/map_item_menu_model.dart';

class LayerTreeLayerMenuWidget extends StatelessWidget {
  final List<MenuItemMap>? menuList;
  final MenuItemMap? selectTreeLayer;
  final Function(MenuItemMap) onCallBack;
  const LayerTreeLayerMenuWidget({this.selectTreeLayer, this.menuList, Key? key, required this.onCallBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(left: 40.sp, bottom: 20.sp),
        child: DropdownButtonHideUnderline(
            child: DropdownButton2(
                isExpanded: true,
                alignment: Alignment.topLeft,
                value: selectTreeLayer?.value,
                customButton: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 1))],
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.sp,horizontal: 12.sp),
                  child: Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.sp)),
                      width: 0.48.sw,
                      height: 65.h,
                      child: Column(children: [
                        // const Divider(color: Colors.grey, height: 2, thickness: 0),
                        Expanded(
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              SizedBox(width: 100.sp),
                              Expanded(child: Text(selectTreeLayer?.value == "npk" ? "Hiển thị tất cả" : "Hàm lượng ${selectTreeLayer?.value.toUpperCase()}", maxLines: 1, overflow: TextOverflow.ellipsis)),
                              Icon(Icons.unfold_more, size: 56.sp)
                            ])),
                      ])),
                ),
                dropdownStyleData: DropdownStyleData(
                  decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20.sp), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 1))]),
                ),
                // dropdownStyleData: DropdownStyleData(
                //     width: 0.48.sw,
                //     maxHeight: 0.26.sh,
                //     padding: EdgeInsets.only(bottom: 20.sp),
                //     decoration: BoxDecoration(
                //         borderRadius: BorderRadius.circular(20.sp), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 1))])),
                items: menuList?.map((item) {
                  return DropdownMenuItem<String>(
                    value: item.value,
                    child: Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.sp)),
                        width: 0.52.sw,
                        height: 72.h,
                        child: Column(children: [
                          // const Divider(color: Colors.grey, height: 2, thickness: 0),
                          Expanded(
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            SizedBox(width: 20.sp),
                            if (selectTreeLayer?.id == item.id) Icon(Icons.check, color: Colors.black87,size: 56.sp,),
                            SizedBox(width: 20.sp),
                            Expanded(child: Padding(
                              padding: EdgeInsets.only(left: selectTreeLayer?.id != item.id ? 56.sp : 0.sp),
                              child: Text(item.value == "npk" ? "Hiển thị tất cả" : "Hàm lượng ${item.value.toUpperCase()}", maxLines: 1, overflow: TextOverflow.ellipsis),
                            ))
                          ])),
                          SizedBox(height: 20.sp),
                          if (item.id != 4) const Divider(color: Colors.grey, height: 2, thickness: 0),
                        ])),
                    onTap: () => onCallBack(item),
                  );
                }).toList(),
                onChanged: (value) {
                  if (menuList != null) {
                    final selectedItem = menuList!.firstWhere((item) => item.value == value);
                    onCallBack(selectedItem);
                  }
                },
                style: const TextStyle(color: Colors.black),
                buttonStyleData: ButtonStyleData(
                    padding: EdgeInsets.only(left: 20.sp),
                    height: 86.h,
                    width: 0.48.sw,
                    decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.sp),
                            border: Border.all(
                              color: Colors.black26,
                            ),
                            color: Colors.white)
                        .copyWith(boxShadow: kElevationToShadow[2])),
                iconStyleData: IconStyleData(
                    icon: Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0), child: Icon(Icons.unfold_more, size: 56.sp)),
                    iconEnabledColor: Colors.black,
                    iconDisabledColor: Colors.black,
                    iconSize: 24.sp))),
      ),
    );
  }
}
