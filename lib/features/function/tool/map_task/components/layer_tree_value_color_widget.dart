import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hainong/features/function/tool/map_task/models/map_item_menu_model.dart';
import 'package:hainong/features/function/tool/map_task/utils/map_utils.dart';

class LayerTreeValueColorWidget extends StatefulWidget {
  const LayerTreeValueColorWidget(this._treeValueList, {Key? key}) : super(key: key);

  final List<ColorItemMap> _treeValueList;

  @override
  State<LayerTreeValueColorWidget> createState() => _LayerTreeValueColorWidgetState();
}

class _LayerTreeValueColorWidgetState extends State<LayerTreeValueColorWidget> {
  double heightWidget = 0;

  @override
  Widget build(BuildContext context) {
    heightWidget = (widget._treeValueList.length * 60) + 50;
    return widget._treeValueList.isNotEmpty
        ? Container(
            constraints: BoxConstraints(maxHeight: heightWidget, maxWidth: 0.26.sw),
            margin: EdgeInsets.only(left: 20.sp, top: 20.sp),
            padding: EdgeInsets.only(left: 20.sp, top: 20.sp),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.sp),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 1))]),
            child: SingleChildScrollView(
                child: Column(children: [
              Column(children: [
                Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [Text("Hàm lượng", style: TextStyle(color: Colors.black87, fontSize: 10)), Expanded(child: Text("<N/P/K>", style: TextStyle(color: Colors.red, fontSize: 10)))]),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  Text("Tổng số", style: TextStyle(color: Colors.black87, fontSize: 10)),
                  Expanded(child: Text("(<%,mg/kg, meq/100g>)", style: TextStyle(color: Colors.red, fontSize: 10)))
                ])
              ]),
              Column(children: treeValueColorsWidget())
            ])))
        : const SizedBox();
  }

  List<Widget> treeValueColorsWidget() {
    List<Widget> treeValueColorList = [];
    for (var item in widget._treeValueList) {
      treeValueColorList.add(Column(children: [
        Row(children: [
          Container(color: MapUtils.hexToColor(item.color), width: 20.w, height: 100.w),
          SizedBox(width: 20.sp),
          Expanded(child: Text(item.value, style: const TextStyle(color: Colors.blue, fontSize: 11))),
        ])
      ]));
    }
    return treeValueColorList;
  }
}
