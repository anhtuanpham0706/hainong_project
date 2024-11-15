import 'package:flutter/material.dart';

class ButtonImageWidget extends StatelessWidget {
  final double radius, elevation;
  final Function onTap;
  final Widget child;
  final Color color;
  const ButtonImageWidget(this.radius, this.onTap, this.child,
      {this.color = Colors.transparent, this.elevation = 0.0, Key? key}):super(key:key);

  @override
  Widget build(BuildContext context) => Material(
      elevation: elevation, color: color,
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      child: InkWell(borderRadius: BorderRadius.all(Radius.circular(radius)),
          onTap: () {onTap();}, child: child));
}