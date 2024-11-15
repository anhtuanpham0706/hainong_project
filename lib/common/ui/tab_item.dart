import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/style_custom.dart';
import 'package:hainong/common/util/util_ui.dart';
import '../multi_language.dart';
import 'button_image_widget.dart';
import 'label_custom.dart';

class TabItem extends StatelessWidget {
  final bool active, parseTitle, expanded;
  final String title;
  final dynamic index;
  final Function change;
  final int? line;
  final double? size;
  final Color color;
  const TabItem(this.title, this.index, this.active, this.change, {this.color = Colors.black, this.parseTitle = true, this.expanded = true, this.line, this.size ,Key? key}):super(key:key);

  @override
  Widget build(BuildContext context) {
    Widget temp = Container(
        decoration: BoxDecoration(border: active
            ? Border(bottom: BorderSide(color: StyleCustom.buttonColor, width: 10.sp))
            : BoxBorder.lerp(null, null, 0.0)),
        child: ButtonImageWidget(5.sp, () => change(index), Padding(padding: EdgeInsets.all(40.sp),
            child: LabelCustom(parseTitle?MultiLanguage.get(title):title, color: color,
                align: TextAlign.center, weight: active ? FontWeight.bold : FontWeight.normal, line: line, size: size??50.sp))));
    return expanded ? Expanded(child: temp) : temp;
  }
}

