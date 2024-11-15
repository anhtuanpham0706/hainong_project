import 'package:flutter/material.dart';

class CoreButtonCustom extends StatelessWidget {
  final Function function;
  final Function? funSub;
  final Widget child;
  final EdgeInsets padding, margin;
  final double sizeRadius;
  final double? width, height;
  final Color color;
  final BorderRadiusGeometry? borderRadius;
  final Border? border;
  final bool bgInside;
  final Alignment? align;

  const CoreButtonCustom(this.function, this.child,
      {this.padding = EdgeInsets.zero, this.sizeRadius = 0.0, this.margin = EdgeInsets.zero,
        this.color = Colors.transparent, this.borderRadius, this.border, Key? key, this.funSub,
        this.bgInside = false, this.width, this.height, this.align}) : super(key:key);

  @override
  Widget build(BuildContext context) => Material(
      color: bgInside ? Colors.transparent : color,
      borderRadius: borderRadius??BorderRadius.circular(sizeRadius),
      child: InkWell(
          borderRadius: BorderRadius.circular(sizeRadius),
          onTap: () => function(),
          onDoubleTap: () { if (funSub != null) funSub!(); },
          child: Container(width: width, height: height, decoration: BoxDecoration(
            color: bgInside ? color : Colors.transparent, border: border,
            borderRadius: border != null ? BorderRadius.circular(sizeRadius) : null
          ),padding: padding, child: child, margin: margin, alignment: align)));
}
