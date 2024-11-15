import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/style_custom.dart';
import 'button_image_circle_widget.dart';

abstract class MultiChoiceCallback {
  void deleteItem(int index, String type);
}

class MultiChoice {
  static const String userType = 'user_type';
  static const String hashTag = 'hash_tag';
  final String type;
  final List<ItemModel> list = [];
  final MultiChoiceCallback? callback;

  MultiChoice(this.callback, this.type);

  clear() => list.clear();

  bool addItem(ItemModel? item) {
    if (item == null) return false;
    int index = list.indexWhere((element) => element.id == item.id);
    if (index == -1) {
      list.add(item);
      return true;
    }
    return false;
  }

  void deleteItem(int index) {
    if (callback != null) {
      list.removeAt(index);
      callback?.deleteItem(index, type);
    }
  }

  List<Widget> createUIItems() {
    List<Widget> tmp = [];
    if(list.isNotEmpty) for (int i = 0; i < list.length; i++) tmp.add(_CreateItem(list[i].name, i, deleteItem));
    return tmp;
  }
}

class _CreateItem extends StatelessWidget {
  final String name;
  final int index;
  final Function function;
  const _CreateItem(this.name, this.index, this.function);

  @override
  Widget build(context) => InputChip(
    shape:
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.sp)),
    backgroundColor: const Color(0xFFEFEFEF),
    label: Text(name,
        style: TextStyle(color: Colors.black, fontSize: 35.sp)),
    labelPadding: EdgeInsets.only(left: 20.sp),
    deleteIcon: ButtonImageCircleWidget(30.sp, () => function(index),
        child: Icon(Icons.clear, size: 60.sp, color: StyleCustom.buttonColor)),
    onDeleted: () {},
  );
}

class RenderMultiChoice extends StatelessWidget {
  final MultiChoice choice;
  const RenderMultiChoice(this.choice, {Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) => Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10.sp),
      ),
      padding: EdgeInsets.only(
          left: 30.sp, right: 30.sp, top: 20.sp, bottom: 20.sp),
      child: Wrap(spacing: 20.sp, children: choice.createUIItems()));
}
