import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget tabIconWidget(String name, {String? image, double? widthImage, double? heightImage, double? fontSize, Color? color, Color backGroundColor = Colors.transparent}) {
  return Container(
    child: Row(
      children: [
        if (image != null) Image.asset("assets/images/v9/map/" + image, width: widthImage ?? 62.h, height: heightImage ?? 62.h),
        const SizedBox(width: 4),
        Text(name, style: TextStyle(color: color ?? Colors.black87, fontSize: fontSize ?? 16))
      ],
    ),
    decoration: BoxDecoration(color: backGroundColor, borderRadius: BorderRadius.circular(20)),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  );
}
