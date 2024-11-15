import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LabelCustom extends StatelessWidget {
  final String title;
  final TextAlign align;
  final Color color;
  final TextDecoration decoration;
  final double? size;
  final int? line;
  final FontWeight weight;
  final TextOverflow overflow;
  final FontStyle style;
  const LabelCustom(this.title, {this.align = TextAlign.left, this.color = Colors.white,
    this.size, this.weight = FontWeight.bold, this.decoration = TextDecoration.none,
    this.overflow = TextOverflow.clip, this.line, this.style = FontStyle.normal, Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) => Text(title, overflow: overflow, textAlign: align, maxLines: line,
      style: TextStyle(color: color, fontSize: size??40.sp, fontWeight: weight, decoration: decoration, fontStyle: style));
}