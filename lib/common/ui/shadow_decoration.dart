import 'package:flutter/material.dart';

class ShadowDecoration extends BoxDecoration {
  final Color bgColor, borderColor, shadowColor;
  final double opacity, size, width;
  ShadowDecoration({this.size = 0,this.shadowColor = Colors.grey,this.bgColor = Colors.white, this.opacity = 0.4,
    List<BoxShadow>? boxShadow, this.borderColor = Colors.transparent, this.width = 0.0}):super(
      border: width > 0 ? Border.all(color: borderColor, width: width) : null,
      color: bgColor,
      borderRadius: BorderRadius.circular(size),
      boxShadow: boxShadow??[BoxShadow(
          color: shadowColor.withOpacity(opacity),
          spreadRadius: 1,
          blurRadius: 7,
          offset: const Offset(0, 1) // changes position of shadow
      )]
  );
}