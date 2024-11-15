import 'package:flutter/material.dart';
class DividerWidget extends StatelessWidget {
  final Color color;
  final double height;
  final EdgeInsets margin;
  const DividerWidget({this.color = Colors.black12, this.height = 0.5, this.margin = EdgeInsets.zero, Key? key}):super(key:key);
  Widget build(BuildContext context) => Container(color: color, height: height, margin: margin);
}
