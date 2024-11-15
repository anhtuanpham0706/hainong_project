import 'package:hainong/common/ui/import_lib_base_ui.dart';
import '../style_custom.dart';
import 'button_image_widget.dart';
import 'label_custom.dart';

class FarmManageTitle extends StatelessWidget {
  final List<dynamic> item;
  final double? padding, width,size;
  final bool hasBg;
  final Color? titleColor;
  final int maxLine;
  const FarmManageTitle(this.item, {this.hasBg = true, this.maxLine = 1, this.padding, this.width,this.size,this.titleColor,Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) {
    final List<Widget> list = [];
    for(int i = 0; i < item.length; i++) {
      list.add(_title(item[i][0], item[i].length == 3 ? item[i][2] : TextAlign.left, flex: item[i][1]));
    }
    return Container(color: hasBg ? const Color(0xFFE9FDF7) : Colors.transparent, width: width??1.sw, child: Row(children: list));
    final child = Container(color: const Color(0xFFE9FDF7), width: width??1.sw, child: Row(children: list));
    return width != null ? SingleChildScrollView(child: child, scrollDirection: Axis.horizontal) : child;
  }

  Widget _title(String title, TextAlign align, {int flex = 3}) => Expanded(flex: flex, child: Padding(padding: EdgeInsets.all(padding??40.sp),
      child: LabelCustom(title,  line: maxLine, color: titleColor??const Color(0xFF1AAD80), size: size ?? 42.sp, align: align)));
}

class FarmManageItem extends StatelessWidget {
  final List<dynamic> item;
  final int index;
  final Function? action, funSelect;
  final bool active, visible;
  final double? padding, width ,size;
  final bool defaultColor;
  final Color? colorRow;
  final int? maxLine;
  const FarmManageItem(this.item, this.index, {this.colorRow, this.maxLine, this.width, this.defaultColor = false, this.padding, this.action, this.funSelect, this.active = false,  this.visible = true, this.size, Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox();

    final List<Widget> list = [];
    double padding = this.padding??40.sp;
    for(int i = 0; i < item.length - 1; i++) {
      list.add(_column(item[i][0], padding, item[i].length > 2 ? item[i][2] : TextAlign.left, flex: item[i][1], funSelect: funSelect, size: size, color: item[i].length > 3 ? item[i][3] : const Color(0xFF3E3E3E)));
    }

    list.add(_column(item[item.length - 1][0], padding, item[item.length - 1].length > 2 ? item[item.length - 1][2] : TextAlign.left, flex: item[item.length - 1][1], funSelect: funSelect, size: size, color: item[item.length - 1].length > 3 ? item[item.length - 1][3] : const Color(0xFF3E3E3E)));

    final color = defaultColor ? const Color(0xFFE9FDF7) : (colorRow??(index % 2 == 0 ? Colors.transparent : const Color(0xFFF8F8F8)));
    final row = Container(color: active ? null : color, width: width??1.sw,
        decoration: active ? BoxDecoration(
            color: color,
            border: Border.all(color: Colors.red)
        ) : null,
        child: Row(children: list) /*funSelect == null ? Row(children: list) : Stack(children: [
          Row(children: list),
          Padding(padding: EdgeInsets.only(top: 20.sp, right: 20.sp), child:
          ButtonImageWidget(50, funSelect!, Icon(Icons.radio_button_unchecked,
              color: StyleCustom.primaryColor, size: 72.sp)))
        ], alignment: Alignment.topRight)*/
    );
    return action == null ? row : ButtonImageWidget(0, () => action!(index), row);
  }

  Widget _column(dynamic name, double padding, TextAlign align, {int flex = 3, Function? funSelect, double? size, Color? color}) {
    final child = name is String ? LabelCustom(name, line: maxLine, color: color ?? const Color(0xFF3E3E3E), size: size??42.sp, weight: FontWeight.normal, align: align) : name;
    return Expanded(flex: flex, child: Padding(padding: EdgeInsets.all(padding),
        child: funSelect == null ? child : Row(children: [
          Expanded(child: child),
          Padding(padding: EdgeInsets.only(left: 10.sp), child:ButtonImageWidget(50, funSelect, Icon(Icons.radio_button_unchecked,
              color: StyleCustom.primaryColor, size: 80.sp)))
        ])));
  }
}