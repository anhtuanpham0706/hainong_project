import 'package:flutter/material.dart';
import 'package:hainong/common/style_custom.dart';
import 'button_image_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CheckboxCustom extends StatelessWidget {
  final int index;
  final Function funChecked;
  final dynamic item;
  final bool active;
  const CheckboxCustom(this.index, this.item, this.funChecked, this.active, {Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    ButtonImageWidget(0, ()=>funChecked(index), active ? Container(width: 56.sp, height: 56.sp,
        color: StyleCustom.buttonColor, child: Icon(Icons.check, color: Colors.white, size: 50.sp)) :
    Container(width: 56.sp, height: 56.sp, decoration: BoxDecoration(border: Border.all(color: const Color(0xFF919191), width: 1.sp)))),
    SizedBox(width: 18.sp),
    Expanded(child: Text(item.name, style: TextStyle(color: const Color(0xFF2C2C2C), fontSize: 40.sp)))
  ]);
}