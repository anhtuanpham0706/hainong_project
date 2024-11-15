import 'package:flutter/material.dart';
import 'package:hainong/common/style_custom.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../multi_language.dart';
import 'label_custom.dart';

class TaskBarWidget {
  final String title;
  final String lblButton;
  final Function? onPressed;
  final Color? shadowColor;
  final double elevation;
  const TaskBarWidget(this.title, {this.lblButton = '', this.onPressed, this.shadowColor, this.elevation = 4});
  PreferredSizeWidget createUI() => AppBar(
        shadowColor: shadowColor ?? ThemeData().shadowColor,
        elevation: elevation,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: LabelCustom(MultiLanguage.get(title), align: TextAlign.center, size: 50.sp)),
            lblButton.isNotEmpty ?
            OutlinedButton(
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Colors.transparent,
                    ),
                  backgroundColor: StyleCustom.primaryColor,
                  textStyle: const TextStyle(color: Colors.transparent)
                ),
                onPressed: () => onPressed!(),
                child: LabelCustom(MultiLanguage.get(lblButton),
                    size: 50.sp, weight: FontWeight.normal)):
            SizedBox(width: 96.sp)
          ]
        )
      );
}
