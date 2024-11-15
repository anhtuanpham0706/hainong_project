import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hainong/common/models/file_byte.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hainong/common/ui/button_image_circle_widget.dart';

class ImageItem extends StatelessWidget {
  final FileByte item;
  final double width, height;
  final int index;
  final Function delete;
  const ImageItem(this. index, this.item, this.delete, this.width, this.height);
  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.topRight, children: [
      Container(width: width, height: height, decoration: BoxDecoration(
          image: DecorationImage(image: Image.memory(Uint8List.fromList(item.bytes)).image, fit: BoxFit.cover))),
      Container(width: 50.sp, height: 50.sp, margin: EdgeInsets.all(34.sp),
          decoration: BoxDecoration(
              color: Colors.black54, borderRadius: BorderRadius.circular(40.sp)),
          child: ButtonImageCircleWidget(50.sp, () => delete(index),
              child: Icon(Icons.close, color: Colors.white, size: 40.sp)))
    ]);
  }
}