import 'package:flutter/material.dart';
import '../constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IconWidget extends StatelessWidget {
  final String? assetPath;
  final double? size;
  const IconWidget({this.assetPath, this.size, Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) => ImageIcon(AssetImage(assetPath??Constants().assetsEyeClose), size: size??60.sp);
}