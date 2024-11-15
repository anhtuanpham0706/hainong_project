import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../style_custom.dart';
import 'label_custom.dart';

class ButtonCustom extends StatelessWidget {
  final Function onPress;
  final String title;
  final Color color, textColor, borderColor;
  final double? size, radius;
  final double borderWidth, elevation;
  final FontWeight weight;
  final EdgeInsets? padding;

  const ButtonCustom(this.onPress, this.title, {this.color = StyleCustom.buttonColor,
    this.textColor = Colors.white, this.elevation = 4.0, this.padding,
    this.borderColor = Colors.transparent, this.size, this.radius,
    this.weight = FontWeight.bold, this.borderWidth = 1.0, Key? key}):super(key:key);

  @override
  Widget build(BuildContext context) => ElevatedButton(
      onPressed: () => onPress(),
      style: ElevatedButton.styleFrom(
          side: const BorderSide(
            color: Colors.transparent,
          ),
          padding: padding,
          primary: color,
          elevation: elevation,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius ?? 80.sp),
              side: BorderSide(color: borderColor, width: borderWidth))),
      child: LabelCustom(title,
          color: textColor, weight: weight, size: size ?? 42.sp));
}