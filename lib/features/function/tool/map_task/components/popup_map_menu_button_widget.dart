import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hainong/features/function/tool/map_task/models/map_enum.dart';
import 'package:hainong/features/function/tool/map_task/models/map_item_menu_model.dart';
import 'package:hainong/features/function/tool/map_task/utils/map_utils.dart';

class PopupMapMenuButton extends StatelessWidget {
  final List<MenuItemMap>? menuList;
  final MapMenuEnum selectMenuId;
  final Function(int) onCallBack;
  const PopupMapMenuButton({this.selectMenuId = MapMenuEnum.pet, this.menuList, Key? key, required this.onCallBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        alignment: Alignment.topRight,
        customButton: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 1))],
          ),
          padding: const EdgeInsets.all(12),
          child: const Icon(Icons.menu),
        ),
        dropdownStyleData: DropdownStyleData(
          offset: Offset(0,-10),
          direction: DropdownDirection.left,
          width: 0.58.sw,
          decoration:
              BoxDecoration(borderRadius: BorderRadius.circular(20.sp), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 1))]),
        ),
        items: menuList?.map((item) {
          final menu = MapUtils.indexEnumMenuMap(item.id);
          return DropdownMenuItem<String>(
            value: item.name,
            child: SizedBox(
              child: Column(
                children: [
                  SizedBox(height: 30.sp),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (selectMenuId == menu) const Icon(Icons.check, color: Colors.black87),
                        SizedBox(width: 20.sp),
                        Expanded(child: Text(item.name)),
                        SizedBox(width: 72.w, height: 72.w, child: Image.asset(item.image))
                      ],
                    ),
                  ),
                  SizedBox(height: 30.sp),
                  if (item.id != 4) const Divider(color: Colors.grey, height: 2, thickness: 0),
                ],
              ),
            ),
            // onTap: () => onCallBack(item.id),
          );
        }).toList(),
        onChanged: (value) {
          if (menuList != null) {
            final selectedItem = menuList!.firstWhere((item) => item.name == value);
            onCallBack(selectedItem.id);
          }
        },
        iconStyleData: IconStyleData(icon: const Icon(Icons.menu), iconEnabledColor: Colors.green, iconDisabledColor: Colors.black87, iconSize: 24.sp),
      ),
    );
  }
}
