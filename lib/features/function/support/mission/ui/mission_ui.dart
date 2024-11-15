import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';

class MissionLine extends StatelessWidget {
  final String title, value;
  final EdgeInsets? padding;
  final bool hasPadding;
  final int flex;
  final Widget? more;
  const MissionLine(this.title, this.value, {this.more, this.flex = 3, this.hasPadding = true, this.padding, Key? key}):super(key: key);

  @override
  Widget build(BuildContext context) {
    final left = LabelCustom(value, color: Colors.black, size: 42.sp, weight: FontWeight.normal, align: TextAlign.right);
    final temp = Row(children: [
      Expanded(flex: flex, child: LabelCustom(title, color: const Color(0xFF636363), size: 42.sp, weight: FontWeight.normal)),
      Expanded(flex: 10 - flex, child: more != null ? Row(children: [left, SizedBox(width: 10.sp), more!], mainAxisAlignment: MainAxisAlignment.end) : left)
    ], crossAxisAlignment: CrossAxisAlignment.start);

    EdgeInsets? paddingTemp;
    if (hasPadding) paddingTemp = padding??EdgeInsets.all(40.sp);
    return paddingTemp != null ? Padding(padding: paddingTemp, child: temp) : temp;
  }
}